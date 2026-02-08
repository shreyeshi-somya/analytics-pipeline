> 🚧 **Work in Progress** — This project is actively being developed.

# End-to-End Analytics Pipeline

A comprehensive data analytics project showcasing modern data engineering and analytics practices across multiple phases.

## Project Overview

This project demonstrates end-to-end analytics capabilities from data ingestion through visualization, using real-world e-commerce data.

### Phases

- **Phase 1: dbt Analytics Platform (DuckDB)** ✅ *Complete*
   - **Phase 1.5: Cloud Migration (Snowflake)** ✅ *Complete*
- Phase 2: Visualization & Analytics (Tableau)
- Phase 3: Data Science & ML
- Phase 4: Applied AI (LLM Insights)
- Phase 5: Integration & Polish

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
phase1-dbt-platform/
├── dbt_project/
│   ├── models/
│   │   ├── staging/        # Clean, typed data from sources (9 models)
│   │   ├── intermediate/   # Business logic & transformations (9 models)
│   │   └── marts/          # Final analytical models (6 models)
│   ├── macros/             # Custom reusable SQL functions (3 macros)
│   ├── tests/              # Data quality tests (30+ tests)
│   └── seeds/              # Reference data (Brazilian holidays)
├── data/
│   └── raw/               # Source CSV files (not committed)
├── scripts/
│   └── load_data.py       # Data ingestion script
├── Dockerfile
└── docker-compose.yml
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
- `dim_customers` - Customer lifetime metrics and behavior
- `dim_products` - Product performance and attributes
- `dim_sellers` - Seller performance and ratings
- `fact_orders` - Order-level transactions with delivery tracking and holiday flags
- `fact_order_items` - Item-level details with product, seller, and order context
- `mart_order_items` - Wide denormalized table pre-joined for BI tool performance

### Highlights

**Custom Transformations:**
- Timezone conversions for all timestamps
- Intelligent review deduplication logic
- Payment method aggregation and categorization
- Missing data imputation (order approval timestamps)
- Geolocation deduplication by zip code

**Data Quality Insights:**
- Identified data quality issues (5 canceled orders with delivery dates)
- Implemented threshold-based monitoring
- Documented edge cases and business rules

**Reference Data:**
- Brazilian holidays seed file (26 holidays, 2016-2018)
- Enables holiday shopping pattern analysis

### Getting Started

**Prerequisites:**
- Docker Desktop
- Git
- (Optional) Snowflake account for cloud deployment

**Setup - Local Development (DuckDB):**
```bash
# Clone the repository
git clone https://github.com/shreyeshi-somya/analytics-pipeline.git
cd analytics-pipeline/phase1-dbt-platform

# Start the environment
docker compose build
docker compose up -d

# Enter the container
docker compose exec dbt bash

# Load data
python /app/scripts/load_data.py

# Run dbt pipeline
dbt seed              # Load Brazilian holidays
dbt run               # Build all models
dbt test              # Run all tests
dbt docs generate     # Generate documentation
```

**Setup - Cloud Production (Snowflake):**
```bash
# Deploy to Snowflake
dbt seed --target snowflake
dbt run --target snowflake
dbt test --target snowflake
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
- ✅ Seed data (Brazilian holidays reference table)
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
└── SEEDS (1, brazilian_holidays)
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

## Phase 2: Visualization & Analytics (Tableau)

**Status:** Planned

Interactive dashboards and visual analytics.

### Planned Deliverables
- Executive KPI dashboard
- Delivery performance analytics
- Customer behavior analysis
- Product & seller performance metrics
- Time-series analysis (weekend/peak patterns)

---

## Phase 3: Data Science & ML

**Status:** Planned

Machine learning models for predictive analytics.

### Planned Models
- Customer churn prediction
- Delivery time estimation
- Product recommendation engine
- Review sentiment analysis

---

## Phase 4: Applied AI (LLM Insights)

**Status:** Planned

LLM-powered features and insights.

### Planned Features
- Review translation (Portuguese → English)
- Automated insight generation
- Natural language query interface

---

## Skills Demonstrated

**Analytics Engineering:**
- dbt (Data Build Tool)
- Dimensional modeling
- Data quality testing
- SQL optimization
- Cross-database SQL compatibility

**Data Engineering:**
- Docker containerization
- Python data pipelines
- DuckDB database
- Snowflake cloud data warehouse
- Multi-environment deployment
- Version control (Git)

**Cloud & Infrastructure:**
- Snowflake architecture and configuration
- Environment variable management
- Cost optimization strategies (auto-suspend, XSMALL compute)
- Dual-target deployment (dev/prod)

**Best Practices:**
- Modular code architecture
- Comprehensive documentation
- Automated testing
- Reusable components (macros, tests)

---

## 👤 Author

**Shreyeshi Somya**
- **Education:** MS Business Analytics (UCLA) | BS Computer Science (VIT Vellore)
- **Current Role:** Enterprise Analytics at Peloton
- **Skills:** dbt, Snowflake, Airflow, SQL, Python, Tableau
- **LinkedIn:** [linkedin.com/in/sshreyeshi](https://www.linkedin.com/in/sshreyeshi/)
- **Email:** sshreyeshi@gmail.com
