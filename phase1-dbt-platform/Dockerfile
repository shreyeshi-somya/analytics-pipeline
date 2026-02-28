FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install DuckDB CLI (ARM64 version for Apple Silicon)
RUN wget https://github.com/duckdb/duckdb/releases/download/v0.10.0/duckdb_cli-linux-aarch64.zip && \
    unzip duckdb_cli-linux-aarch64.zip && \
    mv duckdb /usr/local/bin/ && \
    rm duckdb_cli-linux-aarch64.zip && \
    chmod +x /usr/local/bin/duckdb

# Install Python packages
RUN pip install --no-cache-dir \
    dbt-duckdb>=1.9.0 \
    dbt-snowflake>=1.8.0 \
    duckdb>=1.1.0 \
    pandas==2.2.0 \
    snowflake-connector-python

WORKDIR /app/dbt_project

CMD ["bash"]