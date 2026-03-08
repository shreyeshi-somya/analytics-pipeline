import streamlit as st
import anthropic
import sys
sys.path.append('/app')
from utils.db import run_query, get_schema

st.set_page_config(page_title="NL Query", layout="wide")

st.markdown("""
    <style>
        .block-container { padding-top: 1rem; }
    </style>
""", unsafe_allow_html=True)

if st.button("← Back to Home"):
    st.switch_page("streamlit_app.py")

st.title("💬 Natural Language Query")
st.markdown("Ask questions about the Olist dataset in plain English. Claude generates SQL, runs it, and explains the results.")
st.markdown("---")

# Example questions
examples = {
    "Select an example...": "",
    "Which product categories have the worst sentiment?": "Which product categories have the worst sentiment?",
    "Which sellers have the highest negative review rate?": "Which sellers have the highest negative review rate?",
    "How does delivery speed affect review scores?": "How does delivery speed affect review scores?",
    "Which regions have the most negative sentiment?": "Which regions have the most negative sentiment?",
    "What is the relationship between freight cost and review score?": "What is the relationship between freight cost and review score?",
    "Which broad categories have the most orders and best sentiment?": "Which broad categories have the most orders and best sentiment?",
}

selected = st.selectbox("Try an example question", list(examples.keys()))
question = st.text_input(
    "Or ask your own question",
    value=examples[selected],
    placeholder="e.g. Which product categories have the lowest review scores?"
)

if st.button("Generate & Run Query", type="primary"):
    if not question.strip():
        st.warning("Please enter a question.")
    else:
        client = anthropic.Anthropic()
        schema = get_schema()

        with st.spinner("Generating SQL..."):
            # Generate SQL
            sql_response = client.messages.create(
                model="claude-sonnet-4-20250514",
                max_tokens=1000,
                messages=[{
                    "role": "user",
                    "content": f"""You are a SQL expert working with a DuckDB database containing Brazilian e-commerce data.

                                    Here is the database schema:
                                    {schema}

                                    Important notes:
                                    - Use only the tables listed in the schema
                                    - Use only columns available in the tables
                                    - Prefer fact.fact_order_items as it has the most enriched data
                                    - Never add aggregate functions in group by
                                    - For sentiment use llm_outputs.review_sentiments joined via review_id through core.fact_order
                                    - Return ONLY the SQL query, no explanation, no markdown backticks

                                Question: {question}"""
                }]
            )
            sql_query = sql_response.content[0].text.strip()
            # Clean up any accidental backticks
            sql_query = sql_query.replace('```sql', '').replace('```', '').strip()

        st.markdown("#### Generated SQL")
        st.code(sql_query, language='sql')

        # Run query
        try:
            with st.spinner("Running query..."):
                results = run_query(sql_query)

            st.markdown(f"#### Results — {len(results):,} rows")
            st.dataframe(results, use_container_width=True, height=(min(len(results), 20) + 1) * 35 + 3)

            # Explain results
            with st.spinner("Explaining results..."):
                explain_response = client.messages.create(
                    model="claude-sonnet-4-20250514",
                    max_tokens=500,
                    messages=[{
                        "role": "user",
                        "content": f"""Given this question: "{question}"
                        
                                        And these results:
                                        {results.head(10).to_string()}

                                        Provide a concise 2-3 sentence business insight explaining what the data shows. Focus on actionable findings."""
                    }]
                )
            
            st.markdown("#### 💡 Insight")
            st.info(explain_response.content[0].text)

        except Exception as e:
            st.error(f"Query failed: {e}")
            st.markdown("Try rephrasing your question or selecting a different example.")