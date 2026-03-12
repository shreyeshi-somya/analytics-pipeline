import streamlit as st

st.set_page_config(
    page_title="Olist Analytics",
    page_icon="🛒",
    layout="wide"
)


st.markdown("""
    <style>
        .block-container {
            padding-top: 2.5rem;
        }
    </style>
""", unsafe_allow_html=True)

st.title("🛒 Olist E-Commerce Analytics")
st.markdown("""
This app showcases an end-to-end analytics pipeline built on the 
[Olist Brazilian E-Commerce dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce), 
combining data engineering, machine learning, and applied AI.
""")

st.markdown("""
### Pipeline Overview

This project is a four-phase analytics pipeline that takes raw Brazilian e-commerce data through transformation,
visualization, machine learning, and AI-powered analysis. Each phase builds on the outputs of the previous one,
with a shared DuckDB database connecting all stages.

| Phase | Focus | Key Tools |
|-------|-------|-----------|
| **Phase 1** | Data modeling & warehousing — 15+ dbt models transforming raw CSVs into analytics-ready tables | dbt, DuckDB, Snowflake |
| **Phase 2** | Business intelligence — Executive overview and delivery performance dashboards | Tableau |
| **Phase 3** | Machine learning — K-Means seller segmentation and XGBoost delivery prediction | Scikit-learn, XGBoost |
| **Phase 4** | Applied AI — Portuguese→English translation, multi-model sentiment analysis, and this Streamlit app | Claude API, NLTK, Gensim, Streamlit |

👉 **Full source code & documentation:** [github.com/shreyeshi-somya/analytics-pipeline](https://github.com/shreyeshi-somya/analytics-pipeline)

> **Note:** This Streamlit app is built to showcase the results from **Phase 3** (ML-based seller segmentation and delivery prediction) and **Phase 4** (sentiment analysis and AI-powered querying). Earlier phases — dbt modeling (Phase 1) and Tableau dashboards (Phase 2) — are not included in the app but can be explored in the full repository.
""")

st.markdown("---")

col1, col2, col3 = st.columns(3)

with col1:
    st.markdown("### 🔍 Sentiment Explorer")
    st.markdown("""
    Explore how five different NLP approaches — VADER, TF-IDF, Word2Vec, GloVe, LSTM, and Claude —
    compare on the task of sentiment analysis across 40K+ translated reviews.
    """)

with col2:
    st.markdown("### 🏪 Seller Intelligence")
    st.markdown(""" Seller scorecards combining ML-based segmentation from Phase 3 with Claude
    sentiment analysis from Phase 4, enriched with delivery performance and geographic data.
    """)

with col3:
    st.markdown("### 💬 NL Query Interface")
    st.markdown("""
    Ask questions about the data in plain English. Claude translates your question
    into SQL, runs it against DuckDB, and explains the results.
    """)

# Row 2 - buttons
col1, col2, col3 = st.columns(3)

with col1:
    if st.button("Go to Sentiment Explorer", use_container_width=True):
        st.switch_page("pages/01_sentiment_explorer.py")

with col2:
    if st.button("Go to Seller Intelligence", use_container_width=True):
        st.switch_page("pages/02_seller_intelligence.py")

with col3:
    if st.button("Go to NL Query", use_container_width=True):
        st.switch_page("pages/03_nl_query.py")