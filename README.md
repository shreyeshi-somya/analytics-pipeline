# End-to-End Analytics Pipeline

A comprehensive data analytics project showcasing modern data engineering and analytics practices across multiple phases.

## Project Overview

This project demonstrates end-to-end analytics capabilities from data ingestion through visualization, using real-world e-commerce data.

### Phases

- **Phase 1: dbt Analytics Platform (DuckDB)** ✅ *Complete*
   - **Phase 1.5: Cloud Migration (Snowflake)** ✅ *Complete*
- **Phase 2: Visualization & Analytics (Tableau)** ✅ *Complete*
- **Phase 3: Data Science & ML** ✅ *Complete*
- **Phase 4: Applied AI — NLP Sentiment Analysis** ✅ *Complete*

---

## Phase 1: dbt Analytics Platform ✅

Built a production-grade data transformation pipeline using dbt, DuckDB, and Docker.

### Tech Stack

**Local Development:**
- **Transformation:** dbt Core 1.7.3
- **Database:** DuckDB 0.10.0
- **Orchestration:** Docker & Docker Compose

**Cloud Production (Phase 1.5):**
- **Cloud Warehouse:** Snowflake (AWS US-East-1)
- **Adapter:** dbt-snowflake 1.7.3

**Common:**
- **Languages:** SQL, Python
- **Testing:** dbt tests (generic, singular, custom)
- **Data:** Brazilian E-commerce (Olist dataset)

### Project Structure
```
analytics-pipeline/
├── docker-compose.yml          # Centralized orchestration for all phases
├── data/
│   └── analytics.duckdb        # Shared DuckDB database across phases
├── phase1-dbt-platform/
│   ├── Dockerfile
│   ├── dbt_project/
│   │   ├── models/
│   │   │   ├── staging/        # Clean, typed data from sources (9 models)
│   │   │   ├── intermediate/   # Business logic & transformations (9 models)
│   │   │   └── marts/          # Final analytical models (6 models)
│   │   ├── macros/             # Custom reusable SQL functions (3 macros)
│   │   ├── tests/              # Data quality tests (30+ tests)
│   │   └── seeds/              # Reference data (3 seed files)
│   ├── data/
│   │   └── raw/               # Source CSV files (not committed)
│   └── scripts/
│       └── load_data.py       # Data ingestion script
└── phase3-data-science/
    ├── Dockerfile
    └── notebooks/              # Jupyter notebooks (EDA, ML)
```

### Key Features

✅ **Multi-layer Architecture**
- Staging → Intermediate → Marts
- 24 total models across 3 layers
- Dimensional modeling (3 dimensions + 2 facts + 1 wide mart)

✅ **Data Quality Framework**
- 30+ tests (generic, singular, custom)
- Tiered severity (WARN vs ERROR)
- Custom generic tests (positive_values, non_negative_values)

✅ **Custom Business Logic**
- Timezone conversion macro (São Paulo → Eastern Time, database-aware)
- Custom schema naming macro (clean schema names without prefix)
- Review deduplication (intelligent 1-day window logic)
- Payment aggregation by type
- Surrogate key generation

✅ **Dual-Target Deployment**
- DuckDB for fast local development
- Snowflake for cloud production
- Single codebase with cross-database SQL compatibility
- Database-aware macros with conditional logic

✅ **Production Best Practices**
- Dockerized environment
- Comprehensive YAML documentation
- Version-controlled transformations
- Reusable macros and tests
- Environment variable management

### Data Model

**Source Data:** Brazilian E-commerce (Olist dataset from Kaggle)
- 100k+ orders
- 112k order items
- 99k customers
- 32k products
- 3k sellers
- 1M geolocation records
- Time period: Sept 2016 - Dec 2018

**Dimensional Model:**
- `dim_customers` - Customer lifetime metrics, behavior, and geographic region
- `dim_products` - Product performance, attributes, and broad category grouping
- `dim_sellers` - Seller performance, ratings, and geographic region
- `fact_order` - Order-level transactions with delivery tracking, holiday flags, and customer region
- `fact_order_items` - Item-level details with product broad category, seller/customer regions, and shipping logistics
- `mart_order_items` - Wide denormalized table pre-joined with all dimensions and ML-derived seller cluster labels for BI tool performance

### Highlights

**Custom Transformations:**
- Timezone conversions for all timestamps
- Intelligent review deduplication logic
- Payment method aggregation and categorization
- Missing data imputation (order approval timestamps)
- Geolocation deduplication by zip code
- Seed-based enrichments (broad product categories, state names, geographic regions)

**Data Quality Insights:**
- Identified data quality issues (5 canceled orders with delivery dates)
- Implemented threshold-based monitoring
- Documented edge cases and business rules

**Reference Data (3 Seed Files):**
- Brazilian holidays (26 holidays, 2016-2018) — holiday shopping pattern analysis
- Product category rollup — maps 71 categories to broad groupings (e.g., Electronics & Tech, Home & Living)
- Brazil states with regions — maps 27 states to geographic regions (North, Northeast, Central-West, Southeast, South)

### Getting Started

**Prerequisites:**
- Docker Desktop
- Git
- (Optional) Snowflake account for cloud deployment

**Setup:**
```bash
# Clone the repository
git clone https://github.com/shreyeshi-somya/analytics-pipeline.git
cd analytics-pipeline

# Start all services (dbt + Jupyter) from root
docker compose build
docker compose up -d

# Enter the dbt container
docker compose exec dbt bash

# Load data & run pipeline
python /app/scripts/load_data.py
dbt seed && dbt run && dbt test
```

### Phase 1 Deliverables ✅

- ✅ Docker environment setup
- ✅ Data ingestion pipeline (8 raw tables, 1M+ rows)
- ✅ Staging layer (9 models with type casting, timezone conversion)
- ✅ Intermediate layer (9 models with business logic, joins, deduplication)
- ✅ Marts layer (6 models: 3 dims + 2 facts + 1 wide mart)
- ✅ Data quality framework (30+ tests)
- ✅ Custom macros (3: timezone conversion, schema naming, data validation)
- ✅ Custom generic tests (2: positive_values, non_negative_values)
- ✅ Seed data (3 files: Brazilian holidays, product category rollup, Brazil states/regions)
- ✅ Comprehensive documentation (YAML schemas, inline comments)
- ✅ Project README with architecture and screenshots

**[View Phase 1 detailed documentation →](phase1-dbt-platform/README.md)**

---

## Phase 1.5: Cloud Migration (Snowflake) ✅

**Status:** Complete

Migrated the entire dbt transformation pipeline from local DuckDB to Snowflake cloud data warehouse, with dual-target support from a single codebase.

### Objectives Achieved

✅ **Cloud Data Warehouse Deployment** - Migrated 1M+ rows across 9 source tables to Snowflake
✅ **Dual-Target Architecture** - Single codebase supporting both DuckDB and Snowflake
✅ **Cross-Database SQL Compatibility** - Database-agnostic macros and functions
✅ **Production Best Practices** - Proper schema organization and credential management

### Tech Stack
- **Cloud Platform:** Snowflake (AWS US-East-1)
- **Compute:** XSMALL warehouse with auto-suspend
- **Connection:** dbt-snowflake adapter 1.7.3
- **Authentication:** Environment variables

### Schema Structure
```
ECOMM_ANALYTICS (Database)
├── RAW (9 tables, 1M+ rows)
├── STAGING (9 models)
├── INTERMEDIATE (9 models)
├── MARTS (6 models)
└── SEEDS (3: brazilian_holidays, product_category_rollup, brazil_states_with_regions)
```

### SQL Compatibility Changes
- **Timezone functions:** Database-aware macro using `CONVERT_TIMEZONE()` for Snowflake, `AT TIME ZONE` for DuckDB
- **Date functions:** `datediff()` for cross-database compatibility
- **Boolean aggregation:** `max()` replacing DuckDB-specific `bool_or()`

### Build Performance

| Layer        | DuckDB | Snowflake |
|--------------|--------|-----------|
| Staging      | 3s     | 10s       |
| Intermediate | 3s     | 17s       |
| Marts        | 3s     | 14s       |
| **Total**    | 9s     | 41s       |

### Storage
- **Total:** ~220MB compressed (~2.7x compression from 130MB CSV)

**[View Snowflake Migration Details →](phase1-dbt-platform/SNOWFLAKE.md)**

---

## Phase 2: Tableau Data Visualization ✅ COMPLETE

**Status:** Complete  
**Dashboards:** 2 interactive dashboards with 4 navigable views  
**Published:** [Tableau Public](https://public.tableau.com/app/profile/shreyeshi.somya/viz/ecomm-analytics/Dashboard1)

### **Deliverables:**

**Dashboard 1: Executive Overview**
- 5 KPI cards (Revenue, Orders, AOV, Review Score, Customers)
- Parameter-driven analysis (6 metrics dynamically update 4 charts)
- Monthly trend with MoM% analysis
- Geographic performance (Brazil map with state/regional breakdown)
- Top 10 categories (dynamic ranking)
- Payment method distribution

**Dashboard 2: Delivery Performance** (3 views)
- **Overview:** Dual-axis delivery trend, histogram with dynamic bins, 5 operational KPIs
- **State Deep Dive:** Bullet chart comparing actual vs estimated vs target delivery times
- **Category Deep Dive:** LOD-based variance analysis with dual encoding (speed + volume)

### **Advanced Features:**
- LOD expressions (FIXED calculations)
- Dual-axis charts with independent scales
- Parameter-driven controls (metric selector, date granularity, bin size)
- Reference bands and trend lines
- Multi-dashboard navigation with buttons
- Bullet charts with triple benchmarking
- Dual encoding (size + color)
- Dashboard actions and cross-filtering

### **Key Insights Delivered:**
- Geographic paradox: High-pop states = lower AOV
- Delivery improvement: 14→8 days avg (2017→2018)
- Category bottleneck: Electronics (high volume + slow delivery)
- On-time challenge: 91.8% vs estimated, only 51.8% meet 10-day target

**Tools:** Tableau Public, dbt seed files for reference data  
**Skills:** Advanced calculations, interactive design, data storytelling, executive presentation

[View Dashboards →](phase2-tableau-data-vis/)

---

## Phase 3: Data Science & ML ✅

**Status:** Complete

Exploratory data analysis and machine learning on the Olist dataset, using the clean dbt marts from Phase 1.

### Tech Stack
- **ML:** Scikit-learn, XGBoost, LightGBM, SHAP
- **Data:** Pandas, NumPy, DuckDB
- **Visualization:** Matplotlib, Seaborn
- **Environment:** Docker, Jupyter Notebook

### Notebooks

**1. EDA (01_eda.ipynb)** — Comprehensive analysis across growth trends, geography, delivery performance, seller concentration, product categories, and payment behavior.

Key findings:
- Order growth plateaued at ~7K/month after Nov 2017. AOV stable ~R\$160
- São Paulo = 42% of orders. Southeast region = 69%. North region averages 1.5x longer delivery
- 92.1% on-time delivery rate, median 10 days
- 19% of sellers drive 80% of revenue. 97% of customers are one-time buyers

**2. Seller Segmentation (02_seller_segmentation.ipynb)** — K-Means clustering on 2,970 sellers using 8 features across volume, business type, and quality dimensions.

Four segments identified:

| Segment | Sellers | Revenue | Avg Review | On-Time |
|---------|---------|---------|------------|---------|
| Small & Reliable | 1,206 (41%) | 2.7% | 4.38 | 97% |
| Top Performers | 763 (26%) | 79.1% | 4.15 | 92% |
| Mid-Tier | 876 (29%) | 17.6% | 4.14 | 92% |
| Underperformers | 125 (4%) | 0.7% | 2.66 | 29% |

Key insight: Mid-Tier sellers already match Top Performers on quality — the gap is purely in scale and catalog size, making them strong candidates for growth programs.

**3. Delivery Prediction (03_delivery_prediction.ipynb)** — XGBoost regression predicting actual delivery time using 22 engineered features (geography, product attributes, seller profile, temporal signals).

| Model | MAE (days) | R² |
|-------|-----------|-----|
| Naive (predict median) | 4.91 | -0.155 |
| Random Forest | 3.54 | 0.164 |
| **XGBoost (tuned)** | **3.44** | **0.232** |

- 79.4% of predictions within 5 days of actual delivery
- Distance is the dominant driver (33% importance via SHAP), followed by temporal trend and region
- Outperforms Olist's existing estimates by 4x (MAE 3.44 vs 13.22 days)

### Deliverables
- 22 analysis and model visualizations
- `ml_outputs.seller_clusters` — cluster assignments for 2,970 sellers (stored in shared DuckDB)
- `ml_outputs.delivery_predictions` — model predictions for test set orders (stored in shared DuckDB)
- Seller cluster labels integrated into dbt `mart_order_items` via source join

**[View Phase 3 detailed documentation →](phase3-data-science/README.md)**

---

## Phase 4: Applied AI — NLP Sentiment Analysis ✅

**Status:** Complete

AI-powered review translation, sentiment analysis, and interactive analytics on the Olist dataset. Reviews are originally in Portuguese — translated to English using Claude, evaluated across multiple sentiment analysis approaches, and surfaced through a Streamlit app with seller intelligence and natural language querying.

### Tech Stack
- **LLM:** Anthropic Claude API (Haiku + Sonnet) — translation, sentiment classification, NL query
- **NLP:** NLTK, VADER, Gensim (Word2Vec), GloVe
- **ML:** Scikit-learn (TF-IDF + classifiers), TensorFlow/Keras (LSTM)
- **App:** Streamlit (multi-page), MotherDuck (cloud deployment)
- **Data:** Pandas, DuckDB, Plotly
- **Environment:** Docker, Jupyter Notebook, Streamlit Cloud

### Translation Pipeline

Two-tier Portuguese → English translation of ~40K review messages and ~11K titles:
- **Dictionary lookup** for short reviews (<10 chars) using a curated mapping (2,507 mapped)
- **Claude Haiku Batch API** for longer reviews — 49,651 requests processed asynchronously at 50% cost
- Final dataset: **98,410** reviews with **40,209** translated messages and **11,174** translated titles

### Sentiment Analysis

Multi-model comparison on 41,940 translated reviews across three paradigms — lexicon-based, classical ML, and LLM-based:

| Model | Accuracy | F1 Macro |
|-------|----------|----------|
| TF-IDF + Logistic Regression | 69.43% | 0.3941 |
| **TF-IDF + LinearSVC (balanced, tuned)** | **67.67%** | **0.4294** |
| LR balanced - Word2Vec | 58.79% | 0.4432 |
| LinearSVC balanced - Word2Vec | 66.95% | 0.4211 |
| LinearSVC balanced - GloVe | 63.59% | 0.3935 |
| LSTM | 51.01% | 0.1351 |
| **Claude (LLM)** | **83.19%** | — |

Key findings:
- VADER struggles with factual complaints — 36% neutral rate on 1-2 star reviews
- TF-IDF + LinearSVC (balanced, tuned) is the best traditional ML approach (5-class)
- GloVe underperforms domain-trained Word2Vec due to Wikipedia/news domain mismatch
- LSTM fails on short reviews with severe class imbalance
- **Claude (LLM) achieves 83.2% accuracy** on 41,818 reviews (3-class) — a 14 percentage point improvement over the best classical model. 94% of 1-star reviews correctly labeled negative, 93% of 5-star reviews correctly labeled positive

### Streamlit App

Interactive multi-page application combining outputs from Phase 3 (ML) and Phase 4 (LLM):

- **Sentiment Explorer** — Model leaderboard comparing all 13+ models, live review tester with real-time predictions from 5 approaches (VADER, TF-IDF, Word2Vec, GloVe, Claude), and sentiment distribution analysis
- **Seller Intelligence** — Seller scorecard combining ML segmentation, delivery predictions, and Claude sentiment; segment analysis, geographic Mapbox maps, filterable scorecard table, and individual seller deep dives
- **Natural Language Query** — Claude Sonnet translates plain English questions into SQL, executes against DuckDB, and provides business insights on the results

### Deliverables
- `llm_outputs.translated_reviews` — Batch API translations (39,946 reviews)
- `llm_outputs.review_translations_final` — Combined translations from all sources (98,410 reviews)
- `llm_outputs.review_sentiments` — Claude sentiment classifications (41,940 reviews)
- Streamlit app with 3 interactive pages (sentiment explorer, seller intelligence, NL query)

**[View Phase 4 detailed documentation →](phase4-llm/README.md)**

---

## Skills Demonstrated

### Analytics Engineering:
* dbt (Data Build Tool)
* Dimensional modeling (star schema)
* Data quality testing (30+ tests)
* SQL optimization
* Cross-database SQL compatibility
* Seed files for reference data management

### Data Science & Machine Learning:
* **Exploratory Data Analysis** - Multi-dimensional analysis with actionable findings
* **K-Means Clustering** - Unsupervised segmentation with log transforms, elbow/silhouette evaluation
* **XGBoost Regression** - Gradient boosting with hyperparameter tuning (RandomizedSearchCV)
* **Feature Engineering** - Haversine distance, temporal trends, holiday proximity, freight ratios
* **Model Interpretability** - SHAP values, partial dependence plots, feature importance analysis
* **Experiment Design** - Segmented modeling, correlated feature analysis, baseline comparison

### NLP & Applied AI:
* **LLM APIs** - Anthropic Claude (Haiku + Sonnet) for translation, sentiment classification, and NL-to-SQL
* **Batch API Processing** - Asynchronous large-scale LLM inference at reduced cost
* **Sentiment Analysis** - Multi-model comparison (VADER, TF-IDF classifiers, Word2Vec, GloVe, LSTM, LLM)
* **Text Pre-processing** - Tokenization, lemmatization, stopword removal, TF-IDF vectorization
* **Word Embeddings** - Domain-trained Word2Vec vs pretrained GloVe comparison
* **Deep Learning** - LSTM sequence models with class weight balancing
* **Natural Language Query** - LLM-powered SQL generation with schema context and business insight summarization

### Interactive Applications:
* **Streamlit** - Multi-page app with sentiment explorer, seller intelligence, and NL query interface
* **Cross-Phase Integration** - Merging ML clustering (Phase 3) with LLM sentiment (Phase 4) into unified dashboards
* **Real-Time ML Inference** - Live predictions from multiple models (VADER, TF-IDF, Word2Vec, GloVe, Claude) in-app
* **Geographic Visualization** - Interactive Mapbox maps with metric-driven coloring

### Data Visualization & Business Intelligence:
* **Tableau Public** - Advanced dashboard development
* **LOD Expressions** - FIXED calculations for complex aggregations
* **Parameters** - Dynamic metric selection and view switching
* **Dual-Axis Charts** - Multiple measures with independent scales
* **Calculated Fields** - Table calculations, conditional logic, custom formatting
* **Interactive Design** - Dashboard actions, filters, cross-chart filtering
* **Advanced Chart Types** - Bullet charts, dual encoding, reference bands
* **Data Storytelling** - Executive-level insight delivery
* **Multi-Dashboard Navigation** - Seamless UX across multiple views

### Data Engineering:
* Docker containerization (centralized multi-service orchestration)
* Shared DuckDB database across phases (ML outputs → dbt sources)
* Python data pipelines
* Snowflake cloud data warehouse
* Multi-environment deployment
* Version control (Git)

### Cloud & Infrastructure:
* Snowflake architecture and configuration
* MotherDuck (cloud DuckDB) for Streamlit Cloud deployment
* Streamlit Cloud hosting with environment-aware database connections
* SSH key-pair authentication
* Environment variable management
* Cost optimization strategies (auto-suspend, XSMALL compute)
* Dual-target deployment (dev/prod)

### Best Practices:
* Modular code architecture
* Comprehensive documentation
* Automated testing
* Reusable components (macros, tests)
* Professional dashboard design (color theory, layout, UX)
* Executive presentation standards

---

## 👤 Author

**Shreyeshi Somya**
- **Education:** MS Business Analytics (UCLA) | BS Computer Science (VIT Vellore)
- **Current Role:** Enterprise Analytics at Peloton
- **Skills:** dbt, Snowflake, Airflow, SQL, Python, Tableau
- **LinkedIn:** [linkedin.com/in/sshreyeshi](https://www.linkedin.com/in/sshreyeshi/)
- **Email:** sshreyeshi@gmail.com
