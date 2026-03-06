# Phase 4: Applied AI — NLP Sentiment Analysis

## Overview
AI-powered review translation and sentiment analysis on the Olist Brazilian e-commerce dataset. Reviews are originally in Portuguese — we first translate them to English using Claude (Anthropic's LLM), then run multi-model sentiment analysis comparing traditional NLP techniques against LLM-based classification.

This phase builds on the clean data models from Phase 1 (dbt) and the shared DuckDB database used across all phases.

## Dataset
- **98,410** unique reviews from the Olist e-commerce platform
- **40,668** reviews with comment messages, **11,519** with titles
- Review scores: 1–5 stars (heavily skewed — 58% are 5-star)
- All review text originally in Portuguese

## Infrastructure

Runs as the `llm-app` service in the root `docker-compose.yml`. Shares a DuckDB database (`data/analytics.duckdb`) with the dbt and data science services. Requires an Anthropic API key set in `.env`.

## Folder Structure
```
phase4-llm/
├── Dockerfile
├── requirements.txt
├── .env                          # ANTHROPIC_API_KEY (not committed)
├── app/
│   ├── 01_batch_translate_reviews.ipynb   # Translation pipeline
│   ├── 02_submit_batch.ipynb              # Batch API submission
│   ├── 03_retrieve_batch.ipynb            # Batch API retrieval
│   ├── 04_combine_translations.ipynb      # Merge all translations
│   ├── 05_sentiment_analysis.ipynb        # Multi-model sentiment analysis
│   ├── 06_batch_sentiment.ipynb           # LLM sentiment batch submission
│   ├── 07_retrieve_sentiment_batch.ipynb  # LLM sentiment batch retrieval
│   ├── short_review_lookup.csv            # Portuguese→English dictionary for short reviews
│   └── download_models.py                 # GloVe + NLTK data downloader
└── README.md
```

## Notebooks

### Part 1: Translation (Notebooks 01–04)

Portuguese → English translation of ~40K review messages and ~11K review titles using a two-tier approach.

#### 01 — Batch Translate Reviews (`01_batch_translate_reviews.ipynb`)

Develops and tests the translation pipeline using Claude Haiku.

**Approach:**
- **Short reviews (<10 chars):** Dictionary lookup using `short_review_lookup.csv` — a curated Portuguese→English mapping for common 1–2 word reviews like "bom" → "good", "otimo" → "great". Text is normalized (accent removal, lowercasing) before lookup. Mapped **2,507** of 2,954 short reviews
- **Longer reviews (≥10 chars):** Translated via Claude Haiku API in batches of 100, using multithreaded parallel execution (5 workers)
- **Stratified sample:** To avoid blocking development on a 3+ hour full translation job, a stratified sample of **5,000 reviews** (1,000 per score) is translated synchronously (~10 minutes) for immediate use
- Both review messages and titles are translated separately

#### 02 — Submit Batch (`02_submit_batch.ipynb`)

Submits the full **49,651 requests** (38,334 messages + 11,317 titles) to Anthropic's Batch API for asynchronous processing at 50% cost.

- Each review is submitted as an individual request with a `custom_id` prefix (`msg_` or `title_`) to distinguish message vs title translations
- Uses Claude Haiku (`claude-haiku-4-5-20251001`) with 512 max tokens for messages, 256 for titles
- Batch ID saved to file for retrieval

#### 03 — Retrieve Batch (`03_retrieve_batch.ipynb`)

Retrieves completed batch results and saves translations.

- **48,825** of 49,651 requests succeeded (18 errored)
- Results pivoted into separate `translated_message` and `translated_title` columns
- **39,946** reviews with translations saved to `llm_outputs.translated_reviews` in DuckDB

#### 04 — Combine Translations (`04_combine_translations.ipynb`)

Merges all translation sources into a single enriched dataset.

- Combines dictionary-based short review translations with Batch API translations
- Prioritizes lookup translations (already validated) over API translations using `combine_first`
- Final dataset: **98,410** reviews with **40,209** translated messages and **11,174** translated titles
- Saved to `llm_outputs.review_translations_final` in DuckDB

---

### Part 2: Sentiment Analysis (Notebooks 05–07)

Multi-model sentiment analysis comparing VADER, TF-IDF classifiers, Word2Vec, GloVe, LSTM, and Claude LLM.

#### 05 — Sentiment Analysis (`05_sentiment_analysis.ipynb`)

Core analysis notebook. Loads translated reviews from `llm_outputs.review_translations_final` and evaluates six modeling approaches.

**Text Pre-processing:**
- Filtered to reviews with at least one translated field (message or title)
- Combined translated title + message into a single text field
- Lowercased, removed stopwords (preserving negation words like "not", "never"), lemmatized
- Separate `vader_text` (with punctuation/caps) and `clean_text` (fully cleaned) fields

**Models evaluated:**

| Model | Accuracy | F1 Macro | Notes |
|-------|----------|----------|-------|
| TF-IDF + Logistic Regression | 69.24% | 0.3679 | High accuracy but ignores minority classes |
| TF-IDF + Logistic Regression (balanced) | 64.78% | 0.4152 | Better minority class recall |
| TF-IDF + LinearSVC | 69.51% | 0.3711 | Slightly better than LogReg |
| **TF-IDF + LinearSVC (balanced)** | **67.67%** | **0.4294** | Best overall — tuned with GridSearchCV |
| TF-IDF + Random Forest | 67.75% | 0.3253 | Struggles with sparse TF-IDF features |
| TF-IDF + Random Forest (balanced) | 52.48% | 0.3500 | Overcompensates for class weights |
| Word2Vec + LinearSVC (balanced) | 66.93% | 0.4218 | Averaging word vectors loses context |
| GloVe + LinearSVC (balanced) | 63.59% | 0.3935 | Domain mismatch hurts performance |
| LSTM (unbalanced) | 51.41% | — | Predicts majority class only |
| LSTM (balanced) | 15.22% | — | Collapses to single class |
| Claude (LLM) | ~75%+ | — | 3-class sentiment — evaluated on small sample only (in progress) |

**Key findings:**

- **VADER** captures general sentiment trends but struggles with factual complaints ("The product has not arrived yet" tagged as neutral). 36-37% neutral rate on 1-2 star reviews
- **TF-IDF + LinearSVC (balanced)** is the best traditional ML approach. Tuned with `f1_macro` scoring and `MaxAbsScaler` to preserve TF-IDF sparsity. The C=0.01 regularization improves generalization across all classes
- **Word2Vec** trained on our corpus slightly underperforms TF-IDF — averaging word vectors collapses word order and negation context
- **GloVe** (pretrained on Wikipedia/news) performs worse than domain-trained Word2Vec due to domain mismatch. "Delivery" in Wikipedia associates with supply chains; in our corpus it associates with "fast", "late", "arrived"
- **LSTM** fails completely — reviews are too short (~10-15 words), severe class imbalance, and linguistically indistinguishable middle classes
- **Claude LLM** (in progress) — evaluated on a small stratified sample (500 reviews, 100 per class) where it outperforms all traditional approaches on 3-class sentiment. Full-scale batch sentiment analysis is pending

#### 06 — Batch Sentiment (`06_batch_sentiment.ipynb`) — *In Progress*

Submits reviews to Anthropic's Batch API for sentiment classification.

- Each review classified as positive, negative, or neutral using Claude Haiku
- `max_tokens=10` since only a single word response is needed
- Batch ID saved for retrieval
- Currently tested on a small sample; full-scale batch submission pending

#### 07 — Retrieve Sentiment Batch (`07_retrieve_sentiment_batch.ipynb`) — *In Progress*

Retrieves batch sentiment results and saves to DuckDB.

- Results parsed and joined back to review IDs via batch index mapping
- Will save to `llm_outputs.review_sentiments` in DuckDB once full batch completes

---

## Pipeline Integration

LLM outputs are written directly to the shared DuckDB database (`llm_outputs` schema):
- **`llm_outputs.translated_reviews`** — Batch API translations (39,946 reviews)
- **`llm_outputs.review_translations_final`** — Combined translations from all sources (98,410 reviews)
- **`llm_outputs.review_sentiments`** — Claude sentiment classifications (in progress — small sample evaluated, full batch pending)

## Tech Stack
Python, Anthropic Claude API (Haiku), DuckDB, Pandas, NumPy, Scikit-learn, NLTK, VADER, TensorFlow/Keras (LSTM), Gensim (Word2Vec), GloVe, Plotly, Docker, Jupyter
