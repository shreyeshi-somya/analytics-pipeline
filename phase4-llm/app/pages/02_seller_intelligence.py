import streamlit as st
import plotly.express as px
import pandas as pd
import sys
sys.path.append('/app')
from utils.db import run_query

st.set_page_config(page_title="Seller Intelligence", layout="wide")

st.markdown("""
    <style>
        .block-container { padding-top: 1rem; }
    </style>
""", unsafe_allow_html=True)

if st.button("← Back to Home"):
    st.switch_page("streamlit_app.py")

st.title("🏪 Seller Intelligence")
st.markdown("Seller scorecards combining ML segmentation, delivery predictions, and Claude sentiment analysis.")
st.markdown("---")

# Load seller scorecard
@st.cache_data
def load_seller_data():
    return run_query("""
        SELECT 
            foi.seller_id,
            foi.seller_city,
            foi.seller_state,
            foi.seller_state_name,
            foi.seller_region,
            foi.seller_geolocation_latitude,
            foi.seller_geolocation_longitude,
            sc.cluster_name,
            COUNT(DISTINCT foi.order_id) as total_orders,
            ROUND(AVG(foi.review_score), 2) as avg_review_score,
            ROUND(AVG(foi.days_to_delivery), 2) as avg_actual_delivery_days,
            SUM(CASE WHEN s.claude_sentiment = 'positive' THEN 1 ELSE 0 END) as positive_reviews,
            SUM(CASE WHEN s.claude_sentiment = 'negative' THEN 1 ELSE 0 END) as negative_reviews,
            SUM(CASE WHEN s.claude_sentiment = 'neutral' THEN 1 ELSE 0 END) as neutral_reviews,
            COUNT(DISTINCT o.review_id) as total_reviews_with_sentiment
        FROM core.fact_order_items foi
        LEFT JOIN core.fact_order o USING (order_id)
        LEFT JOIN llm_outputs.review_sentiments s USING (review_id)
        LEFT JOIN ml_outputs.seller_clusters sc USING (seller_id)
        WHERE foi.is_delivered = true             
        GROUP BY 1 ,2 ,3 ,4 ,5 ,6 ,7 ,8
    """)

df = load_seller_data()

# Compute sentiment score
df['sentiment_score'] = (
    df['positive_reviews'] / df['total_reviews_with_sentiment'].replace(0, 1)
).round(2)

# Filters
col1, col2, col3 = st.columns(3)
with col1:
    cluster_order = ['All', 'Top Performers', 'Mid-Tier', 'Small & Reliable', 'Underperformers']
    clusters = [c for c in cluster_order if c == 'All' or c in df['cluster_name'].dropna().unique().tolist()]
    selected_cluster = st.selectbox("Seller Segment", clusters)
with col2:
    min_orders = st.slider("Minimum Orders", 1, 100, 10)
with col3:
    sort_by = st.selectbox("Sort By", ['avg_review_score', 'sentiment_score', 'total_orders', 'avg_actual_delivery_days'])

# Filter
filtered = df[df['total_orders'] >= min_orders].copy()
if selected_cluster != 'All':
    filtered = filtered[filtered['cluster_name'] == selected_cluster]
filtered = filtered.sort_values(sort_by, ascending=False).reset_index(drop=True)

st.markdown(f"Showing **{len(filtered):,}** sellers")

# KPIs
col1, col2, col3, col4 = st.columns(4)
with col1:
    st.metric("Total Sellers", f"{len(filtered):,}")
with col2:
    st.metric("Avg Review Score", f"{filtered['avg_review_score'].mean():.2f}")
with col3:
    st.metric("Avg Sentiment Score", f"{filtered['sentiment_score'].mean():.1%}")
with col4:
    st.metric("Avg Delivery Days", f"{filtered['avg_actual_delivery_days'].mean():.1f}")

st.markdown("---")

tab1, tab2, tab3, tab4 = st.tabs(["📊 Segment Analysis", "🗺️ Geographic Distribution", "📋 Scorecard", "🔍 Seller Deep Dive"])

with tab1:
    col1, col2 = st.columns(2)

    with col1:
        # Avg review score by segment
        segment_stats = df.groupby('cluster_name').agg(
            avg_score=('avg_review_score', 'mean'),
            avg_sentiment=('sentiment_score', 'mean'),
            total_sellers=('seller_id', 'count')
        ).reset_index()

        fig1 = px.bar(
            segment_stats.sort_values('avg_score', ascending=True),
            x='avg_score',
            y='cluster_name',
            orientation='h',
            title='Average Review Score by Segment',
            color='avg_score',
            color_continuous_scale='Teal',
            text=segment_stats.sort_values('avg_score')['avg_score'].apply(lambda x: f'{x:.2f}')
        )
        fig1.update_traces(textposition='outside')
        fig1.update_layout(coloraxis_showscale=False)
        st.plotly_chart(fig1, use_container_width=True)

    with col2:
        # Sentiment score by segment
        fig2 = px.bar(
            segment_stats.sort_values('avg_sentiment', ascending=True),
            x='avg_sentiment',
            y='cluster_name',
            orientation='h',
            title='Average Sentiment Score by Segment',
            color='avg_sentiment',
            color_continuous_scale='Teal',
            text=segment_stats.sort_values('avg_sentiment')['avg_sentiment'].apply(lambda x: f'{x:.1%}')
        )
        fig2.update_traces(textposition='outside')
        fig2.update_layout(
            coloraxis_showscale=False,
            xaxis=dict(tickformat='.0%')
        )
        st.plotly_chart(fig2, use_container_width=True)

    # Scatter - delivery vs sentiment
    fig3 = px.scatter(
        filtered,
        x='avg_actual_delivery_days',
        y='sentiment_score',
        color='cluster_name',
        size='total_orders',
        title='Delivery Days vs Sentiment Score',
        labels={
            'avg_actual_delivery_days': 'Avg Delivery Days',
            'sentiment_score': 'Sentiment Score',
            'cluster_name': 'Segment'
        },
        hover_data=['seller_id', 'avg_review_score', 'total_orders']
    )
    fig3.update_layout(yaxis=dict(tickformat='.0%'))
    st.plotly_chart(fig3, use_container_width=True)

with tab2:
    st.markdown("### Seller Geographic Distribution")
    
    geo_metric = st.selectbox(
        "Color by",
        ['avg_review_score', 'sentiment_score', 'total_orders', 'avg_actual_delivery_days'],
        key='geo_metric'
    )
    
    geo_df = filtered[filtered['seller_geolocation_latitude'].notna()].copy()
    
    fig_map = px.scatter_mapbox(
        geo_df,
        lat='seller_geolocation_latitude',
        lon='seller_geolocation_longitude',
        color=geo_metric,
        size='total_orders',
        hover_name='seller_id',
        hover_data={
            'seller_city': True,
            'seller_state_name': True,
            'cluster_name': True,
            'avg_review_score': True,
            'sentiment_score': True,
            'total_orders': True,
            'seller_geolocation_latitude': False,
            'seller_geolocation_longitude': False
        },
        color_continuous_scale='Teal',
        mapbox_style='carto-darkmatter',
        zoom=3,
        center={"lat": -14.2, "lon": -51.9},
        title=f'Seller Distribution — {geo_metric.replace("_", " ").title()}',
        height=600
    )
    st.plotly_chart(fig_map, use_container_width=True)

    # State level aggregation
    col1, col2 = st.columns(2)
    
    with col1:
        state_stats = filtered.groupby('seller_state_name').agg(
            total_sellers=('seller_id', 'count'),
            avg_score=('avg_review_score', 'mean'),
            avg_sentiment=('sentiment_score', 'mean')
        ).reset_index().sort_values('total_sellers', ascending=False).head(15)

        fig_state = px.bar(
            state_stats.sort_values('total_sellers', ascending=True),
            x='total_sellers',
            y='seller_state_name',
            orientation='h',
            title='Top 15 States by Seller Count',
            color='total_sellers',
            color_continuous_scale='Teal',
            text='total_sellers'
        )
        fig_state.update_traces(textposition='outside')
        fig_state.update_layout(coloraxis_showscale=False)
        st.plotly_chart(fig_state, use_container_width=True)

    with col2:
        fig_region = px.pie(
            filtered.groupby('seller_region')['seller_id'].count().reset_index(),
            values='seller_id',
            names='seller_region',
            title='Sellers by Region',
            color_discrete_sequence=px.colors.qualitative.Set2
        )
        st.plotly_chart(fig_region, use_container_width=True)    

with tab3:
    # Scorecard table
    display = filtered[[
        'seller_id', 'cluster_name', 'total_orders', 'avg_review_score',
        'sentiment_score', 'avg_actual_delivery_days', 
        'positive_reviews', 'negative_reviews', 'neutral_reviews'
    ]].copy()
    display['seller_id'] = display['seller_id']
    display['sentiment_score'] = display['sentiment_score'].apply(lambda x: f'{x:.1%}')
    display['avg_review_score'] = display['avg_review_score'].apply(lambda x: f'{x:.2f}')
    display['avg_actual_delivery_days'] = display['avg_actual_delivery_days'].apply(lambda x: f'{x:.1f}')

    display.index += 1
    st.dataframe(display, use_container_width=True, height=(min(len(display), 20) + 1) * 35 + 3)                


with tab4:
    # Example sellers
    example_sellers = {
        "Select an example...": "",
        "⭐ Top Performer — High sentiment, fast delivery": df[
            (df['cluster_name'] == 'Top Performers') & 
            (df['sentiment_score'] > 0.8) & 
            (df['total_orders'] > 20)
        ]['seller_id'].iloc[0] if len(df[(df['cluster_name'] == 'Top Performers') & (df['sentiment_score'] > 0.8) & (df['total_orders'] > 20)]) > 0 else "",
        "⚠️ Underperformer — Low sentiment": df[
            (df['cluster_name'] == 'Underperformers') & 
            (df['total_orders'] > 10)
        ]['seller_id'].iloc[0] if len(df[(df['cluster_name'] == 'Underperformers') & (df['total_orders'] > 10)]) > 0 else "",
    }

    selected_example = st.selectbox("Try an example seller", list(example_sellers.keys()))
    seller_id = st.text_input(
        "Or enter a Seller ID", 
        value=example_sellers[selected_example]
    )
    
    if seller_id:
        match = df[df['seller_id'].str.startswith(seller_id)]
        if len(match) == 0:
            st.warning("No seller found with that ID.")
        else:
            row = match.iloc[0]
            
            st.markdown(f"### Seller `{row['seller_id']}`")

            col1, col2, col3, col4 = st.columns(4)
            with col1:
                st.metric("Segment", row['cluster_name'])
            with col2:
                st.metric("Avg Review Score", f"{row['avg_review_score']:.2f}")
            with col3:
                st.metric("Sentiment Score", f"{row['sentiment_score']:.1%}")
            with col4:
                delivery = f"{row['avg_actual_delivery_days']:.1f} days" if pd.notna(row['avg_actual_delivery_days']) else '—'
                st.metric("Avg Delivery Days", delivery)

            col1, col2, col3 = st.columns(3)
            with col1:
                st.metric("City", row['seller_city'].title() if pd.notna(row['seller_city']) else '—')
            with col2:
                st.metric("State", row['seller_state_name'] if pd.notna(row['seller_state_name']) else '—')
            with col3:
                st.metric("Region", row['seller_region'] if pd.notna(row['seller_region']) else '—')

            # sentiment pie
            sentiment_data = {
                'Sentiment': ['Positive', 'Neutral', 'Negative'],
                'Count': [row['positive_reviews'], row['neutral_reviews'], row['negative_reviews']]
            }
            fig = px.pie(
                sentiment_data,
                values='Count',
                names='Sentiment',
                title='Sentiment Breakdown',
                color='Sentiment',
                color_discrete_map={
                    'Positive': '#2EC4B6',
                    'Neutral': '#8B8FA8',
                    'Negative': '#E76F51'
                }
            )
            st.plotly_chart(fig, use_container_width=True)

            

            # mini map
            if pd.notna(row['seller_geolocation_latitude']):
                fig_loc = px.scatter_mapbox(
                    match,
                    lat='seller_geolocation_latitude',
                    lon='seller_geolocation_longitude',
                    mapbox_style='carto-darkmatter',
                    zoom=8,
                    center={"lat": row['seller_geolocation_latitude'], "lon": row['seller_geolocation_longitude']},
                    height=300
                )
                fig_loc.update_traces(marker=dict(size=15, color='#2EC4B6'))
                st.plotly_chart(fig_loc, use_container_width=True)


            