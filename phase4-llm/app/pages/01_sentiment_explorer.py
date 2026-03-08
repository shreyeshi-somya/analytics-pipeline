import streamlit as st
import pandas as pd
import plotly.express as px
import sys
import anthropic
from utils.models import load_models, predict_vader, predict_tfidf, predict_w2v, predict_glove, clean_text
from utils.db import run_query

sys.path.append('/app')

st.set_page_config(page_title="Sentiment Explorer", layout="wide")

st.markdown("""
    <style>
        .block-container { padding-top: 1rem; }
        div[data-testid="stRadio"] { margin-bottom: 0rem; }
        div[data-testid="stPlotlyChart"] { margin-top: 0rem; }
    </style>
""", unsafe_allow_html=True)

if st.button("← Back to Home"):
    st.switch_page("streamlit_app.py")

st.title("🔍 Sentiment Explorer")
st.markdown("Comparing five NLP approaches on 40K+ Brazilian e-commerce reviews.")
st.markdown("---")


tab1, tab2, tab3 = st.tabs(["🏆 Model Leaderboard", "🧪 Live Review Tester", "📊 Sentiment Distribution"])

with tab1:
    model_results = pd.DataFrame([
    {'Model': 'TF-IDF + Logistic Regression', 'Accuracy': 0.6943, 'F1 Macro': 0.3941, 'Approach': 'TF-IDF'},
    {'Model': 'TF-IDF + Logistic Regression (balanced)', 'Accuracy': 0.5752, 'F1 Macro': 0.4396, 'Approach': 'TF-IDF'},
    {'Model': 'TF-IDF + LinearSVC', 'Accuracy': 0.6836, 'F1 Macro': 0.4025, 'Approach': 'TF-IDF'},
    {'Model': 'TF-IDF + LinearSVC (balanced, tuned)', 'Accuracy': 0.6767, 'F1 Macro': 0.4294, 'Approach': 'TF-IDF'},
    {'Model': 'TF-IDF + Random Forest', 'Accuracy': 0.6723, 'F1 Macro': 0.3445, 'Approach': 'TF-IDF'},
    {'Model': 'TF-IDF + Random Forest (balanced)', 'Accuracy': 0.6420, 'F1 Macro': 0.3727, 'Approach': 'TF-IDF'},
    {'Model': 'Word2Vec + LR (balanced)', 'Accuracy': 0.5881, 'F1 Macro': 0.4432, 'Approach': 'Word Embeddings'},
    {'Model': 'Word2Vec + LinearSVC (balanced)', 'Accuracy': 0.6693, 'F1 Macro': 0.4211, 'Approach': 'Word Embeddings'},
    {'Model': 'GloVe + LR (balanced)', 'Accuracy': 0.5435, 'F1 Macro': 0.4113, 'Approach': 'Word Embeddings'},
    {'Model': 'GloVe + LinearSVC (balanced)', 'Accuracy': 0.6359, 'F1 Macro': 0.3935, 'Approach': 'Word Embeddings'},
    {'Model': 'LSTM', 'Accuracy': 0.5101, 'F1 Macro': 0.1351, 'Approach': 'Deep Learning'},
    {'Model': 'LSTM (balanced)', 'Accuracy': 0.1466, 'F1 Macro': 0.0512, 'Approach': 'Deep Learning'},
    {'Model': 'Claude (LLM)', 'Accuracy': 0.8319, 'F1 Macro': None, 'Approach': 'LLM'},
    ])

    # Color palette - no red
    approach_colors = {
        'TF-IDF': '#4C9BE8',
        'Word Embeddings': '#F4A261',
        'Deep Learning': '#8B8FA8',
        'LLM': '#2EC4B6'
    }

    st.markdown("### Model Leaderboard")
    st.caption("F1 Macro is unavailable for Claude as it uses a 3-class evaluation (positive/negative/neutral) vs 5-class for other models.")

    metric = st.radio("Sort by", ["Accuracy", "F1 Macro"], horizontal=True)

    display_df = model_results.copy()
    if metric == "F1 Macro":
        display_df = display_df[display_df['F1 Macro'].notna()]
    display_df = display_df.sort_values(metric, ascending=False).reset_index(drop=True)

    # Chart
    fig = px.bar(
        display_df.sort_values(metric, ascending=True),
        x=metric,
        y='Model',
        orientation='h',
        color='Approach',
        color_discrete_map=approach_colors,
        title=f'Model Comparison — {metric}',
        text=display_df.sort_values(metric, ascending=True)[metric].apply(lambda x: f'{x:.1%}'),
        height=500
    )
    fig.update_traces(textposition='outside')
    fig.update_layout(
        yaxis={'categoryorder': 'total ascending'},
        xaxis=dict(tickformat='.0%')
    )
    st.plotly_chart(fig, use_container_width=True)

    # Table - no scrollbar
    table_df = display_df.copy()
    table_df.index += 1
    table_df['Accuracy'] = table_df['Accuracy'].apply(lambda x: f'{x:.1%}')
    table_df['F1 Macro'] = table_df['F1 Macro'].apply(lambda x: f'{x:.1%}' if pd.notna(x) else '—')

    st.dataframe(
        table_df,
        use_container_width=True,
        height=(len(table_df) + 1) * 35 + 3  # dynamic height based on row count
    )

with tab2:
    st.markdown("### 🧪 Live Review Tester")
    st.markdown("Test a review against all models and compare results side by side.")

    # Example reviews
    examples = {
        "Select an example...": "",
        "😊 'Excellent product! Arrived before estimated delivery...'": "Excellent product! Arrived before the estimated delivery date, well packaged and exactly as described. Very satisfied with the purchase.",
        "😐 'The product is okay, but the delivery took longer...'": "The product is okay, but the delivery took longer than expected. The quality is decent for the price but I expected better packaging.",
        "🤔 'I received the product. It works.'": "I received the product. It works.",
        "😞 'I did not receive my order. It has been 3 weeks...'": "I did not receive my order. It has been 3 weeks and the seller has not responded to any of my messages. Very disappointed.",
        "😡 'TERRIBLE! The product arrived completely broken...'": "TERRIBLE! The product arrived completely broken and different from what was advertised. I want a full refund immediately!",
    }

    selected = st.selectbox("Try an example", options=list(examples.keys()))
    review_text = st.text_area(
        "Or paste your own review",
        value=examples[selected],
        height=100,
        placeholder="Paste any product review here..."
    )

    if st.button("Analyze Sentiment", type="primary", use_container_width=True):
        if not review_text.strip():
            st.warning("Please enter a review to analyze.")
        else:
            models, stop_words, lemmatizer = load_models()
            
            with st.spinner("Running models..."):
                # VADER
                vader_sentiment, vader_score = predict_vader(review_text, models)
                
                # TF-IDF
                tfidf_pred = predict_tfidf(review_text, models, stop_words, lemmatizer)
                
                # Word2Vec
                w2v_pred = predict_w2v(review_text, models)
                
                # GloVe
                glove_pred = predict_glove(review_text, models)
                
                # Claude
                client = anthropic.Anthropic()
                message = client.messages.create(
                    model="claude-haiku-4-5-20251001",
                    max_tokens=100,
                    messages=[{
                        "role": "user",
                        "content": f"""Analyze the sentiment of this e-commerce review.
                                    Respond with exactly one word only: positive, negative, or neutral. No explanation.
                                    Review: {review_text}"""
                    }]
                )
                claude_sentiment = message.content[0].text.strip().lower()

            # Sentiment emoji mapping
            sentiment_emoji = {'positive': '🟢', 'negative': '🔴', 'neutral': '🟡'}
            score_emoji = {1: '⭐', 2: '⭐⭐', 3: '⭐⭐⭐', 4: '⭐⭐⭐⭐', 5: '⭐⭐⭐⭐⭐'}

            # Display results
            st.markdown("#### Results")
            col1, col2, col3, col4, col5 = st.columns(5)

            with col1:
                st.markdown("**VADER**")
                st.markdown(f"{sentiment_emoji.get(vader_sentiment, '⚪')} {vader_sentiment.capitalize()}")
                st.caption(f"Compound: {vader_score:.2f}")

            with col2:
                st.markdown("**TF-IDF + LinearSVC**")
                st.markdown(f"{score_emoji[tfidf_pred]} {tfidf_pred} star")
                st.caption("Balanced, tuned")

            with col3:
                st.markdown("**Word2Vec + LinearSVC**")
                st.markdown(f"{score_emoji[w2v_pred]} {w2v_pred} star")
                st.caption("Domain trained")

            with col4:
                st.markdown("**GloVe + LinearSVC**")
                st.markdown(f"{score_emoji[glove_pred]} {glove_pred} star")
                st.caption("Pretrained")

            with col5:
                st.markdown("**Claude (LLM)**")
                st.markdown(f"{sentiment_emoji.get(claude_sentiment, '⚪')} {claude_sentiment.capitalize()}")
                st.caption("claude-haiku-4-5")

with tab3:
    st.markdown("### 📊 Sentiment Distribution")
    st.markdown("Claude sentiment labels across 41,818 translated reviews.")



    # Load sentiment data
    sentiment_data = run_query("""
        SELECT 
            r.review_score,
            s.claude_sentiment,
            COUNT(*) as count
        FROM llm_outputs.review_sentiments s
        LEFT JOIN llm_outputs.review_translations_final r USING (review_id)
        WHERE r.review_score IS NOT NULL
        AND s.claude_sentiment != 'unknown'
        GROUP BY r.review_score, s.claude_sentiment
        ORDER BY r.review_score, s.claude_sentiment
    """)

    col1, col2 = st.columns(2)

    with col1:
        # Stacked bar - sentiment by score
        fig1 = px.bar(
            sentiment_data,
            x='review_score',
            y='count',
            color='claude_sentiment',
            title='Sentiment Distribution by Review Score',
            labels={'review_score': 'Review Score', 'count': 'Count', 'claude_sentiment': 'Sentiment'},
            color_discrete_map={
                'positive': '#2EC4B6',
                'negative': '#E76F51',
                'neutral': '#8B8FA8'
            },
            barmode='stack'
        )
        fig1.update_layout(xaxis=dict(tickmode='linear'))
        st.plotly_chart(fig1, use_container_width=True)

    with col2:
        # Normalized stacked bar - proportions
        sentiment_pct = run_query("""
            SELECT 
                r.review_score,
                s.claude_sentiment,
                COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY r.review_score) as pct
            FROM llm_outputs.review_sentiments s
            LEFT JOIN llm_outputs.review_translations_final r USING (review_id)
            WHERE r.review_score IS NOT NULL
            AND s.claude_sentiment != 'unknown'
            GROUP BY r.review_score, s.claude_sentiment
            ORDER BY r.review_score, s.claude_sentiment
        """)

        fig2 = px.bar(
            sentiment_pct,
            x='review_score',
            y='pct',
            color='claude_sentiment',
            title='Sentiment Proportion by Review Score',
            labels={'review_score': 'Review Score', 'pct': 'Proportion (%)', 'claude_sentiment': 'Sentiment'},
            color_discrete_map={
                'positive': '#2EC4B6',
                'negative': '#E76F51',
                'neutral': '#8B8FA8'
            },
            barmode='stack'
        )
        fig2.update_layout(xaxis=dict(tickmode='linear'))
        st.plotly_chart(fig2, use_container_width=True)

    # KPI metrics
    total = run_query("""
        SELECT claude_sentiment, COUNT(*) as count
        FROM llm_outputs.review_sentiments
        WHERE claude_sentiment != 'unknown'
        GROUP BY claude_sentiment
    """)

    total_reviews = total['count'].sum()
    col1, col2, col3 = st.columns(3)

    with col1:
        pos = total[total['claude_sentiment'] == 'positive']['count'].values[0]
        st.metric("Positive Reviews", f"{pos:,}")
        st.markdown(f"<span style='font-size: 0.9rem; margin-top: -1rem; display: block; color: #2EC4B6;'>{pos/total_reviews:.1%} of total</span>", unsafe_allow_html=True)

    with col2:
        neu = total[total['claude_sentiment'] == 'neutral']['count'].values[0]
        st.metric("Neutral Reviews", f"{neu:,}")
        st.markdown(f"<span style='font-size: 0.9rem; margin-top: -1rem; display: block; color: #8B8FA8;'>{neu/total_reviews:.1%} of total</span>", unsafe_allow_html=True)

    with col3:
        neg = total[total['claude_sentiment'] == 'negative']['count'].values[0]
        st.metric("Negative Reviews", f"{neg:,}")
        st.markdown(f"<span style='font-size: 0.9rem; margin-top: -1rem; display: block; color: #E76F51;'>{neg/total_reviews:.1%} of total</span>", unsafe_allow_html=True)
