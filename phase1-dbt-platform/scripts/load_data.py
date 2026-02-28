import duckdb

# Connect to DuckDB
con = duckdb.connect('/app/data/analytics.duckdb')

# Create raw schema
con.execute("CREATE SCHEMA IF NOT EXISTS raw")

# Define all tables and their file paths
tables = {
    'customers':  '/app/raw_data/raw/olist_customers_dataset.csv',
    'geolocation':  '/app/raw_data/raw/olist_geolocation_dataset.csv',
    'order_items':  '/app/raw_data/raw/olist_order_items_dataset.csv',
    'order_payments':  '/app/raw_data/raw/olist_order_payments_dataset.csv',
    'order_reviews':  '/app/raw_data/raw/olist_order_reviews_dataset.csv',
    'orders':  '/app/raw_data/raw/olist_orders_dataset.csv',
    'products':  '/app/raw_data/raw/olist_products_dataset.csv',
    'sellers':  '/app/raw_data/raw/olist_sellers_dataset.csv',
    'product_category_name':  '/app/raw_data/raw/product_category_name_translation.csv',
}

# Load each table
for table_name, file_path in tables.items():
    print(f"Loading {table_name}...")
    con.execute(f"""
        CREATE OR REPLACE TABLE raw.{table_name} AS 
        SELECT * FROM read_csv_auto('{file_path}', header=true)
    """)
    
    # Get row count to verify
    count = con.execute(f"SELECT COUNT(*) FROM raw.{table_name}").fetchone()[0]
    print(f"✓ {table_name} loaded - {count:,} rows")

con.close()