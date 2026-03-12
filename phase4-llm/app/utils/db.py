import duckdb
import pandas as pd
import streamlit as st
import sys
import os

token = os.getenv('MOTHERDUCK_TOKEN')
api_key = os.getenv('ANTHROPIC_API_KEY')

DB_PATH = '/app/data/analytics.duckdb'

@st.cache_resource
def get_connection():
    motherduck_token = os.getenv('MOTHERDUCK_TOKEN')
    
    if motherduck_token:
        # Production - Streamlit Cloud
        return duckdb.connect(f'md:analytics?motherduck_token={motherduck_token}')
    else:
        # Local development
        return duckdb.connect('/app/data/analytics.duckdb', read_only=True)

@st.cache_data
def run_query(query: str) -> pd.DataFrame:
    conn = get_connection()
    return conn.execute(query).df()

@st.cache_data
def get_schema() -> str:
    conn = get_connection()
    tables = conn.execute("""
        SELECT table_schema, table_name 
        FROM information_schema.tables 
        WHERE table_schema NOT IN ('information_schema', 'pg_catalog')
        ORDER BY table_schema, table_name
    """).df()
    
    schema_str = ""
    for _, row in tables.iterrows():
        schema_str += f"\n{row['table_schema']}.{row['table_name']}\n"
        cols = conn.execute(f"""
            SELECT column_name, data_type 
            FROM information_schema.columns 
            WHERE table_schema = '{row['table_schema']}' 
            AND table_name = '{row['table_name']}'
        """).df()
        for _, col in cols.iterrows():
            schema_str += f"  - {col['column_name']} ({col['data_type']})\n"
    
    return schema_str