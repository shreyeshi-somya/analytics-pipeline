> 🚧 **Work in Progress** — This project is actively being developed.

# End-to-End Analytics Pipeline

A comprehensive data analytics project showcasing modern data engineering and analytics practices across multiple phases.

## Project Overview

This project demonstrates end-to-end analytics capabilities from data ingestion through visualization, using real-world e-commerce data.

### Phases

- **Phase 1: dbt Analytics Platform (DuckDB)** ✅ *Complete*
- Phase 1.5: Cloud Migration (Snowflake)
- Phase 2: Visualization & Analytics (Tableau)
- Phase 3: Data Science & ML
- Phase 4: Applied AI (LLM Insights)
- Phase 5: Integration & Polish

---

## Phase 1: dbt Analytics Platform ✅

Built a production-grade data transformation pipeline using dbt, DuckDB, and Docker.

### Tech Stack

- **Transformation:** dbt Core 1.7.3
- **Database:** DuckDB 0.10.0
- **Orchestration:** Docker & Docker Compose
- **Languages:** SQL, Python
- **Testing:** dbt tests (generic, singular, custom)
- **Data:** Brazilian E-commerce (Olist dataset)

### Project Structure
```
phase1-dbt-platform/
├── dbt_project/
│   ├── models/
│   │   ├── staging/        # Clean, typed data from sources (8 models)
│   │   ├── intermediate/   # Business logic & transformations (8 models)
│   │   └── marts/          # Final analytical models (5 models)
│   ├── macros/             # Custom reusable SQL functions (2 macros)
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
- 21 total models across 3 layers
- Dimensional modeling (3 dimensions + 2 facts)

✅ **Data Quality Framework**
- 30+ tests (generic, singular, custom)
- Tiered severity (WARN vs ERROR)
- Custom generic tests (positive_values, non_negative_values)

✅ **Custom Business Logic**
- Timezone conversion macro (São Paulo → Eastern Time)
- Review deduplication (intelligent 1-day window logic)
- Payment aggregation by type
- Surrogate key generation

✅ **Production Best Practices**
- Dockerized environment
- Comprehensive YAML documentation
- Version-controlled transformations
- Reusable macros and tests

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
- `fct_orders` - Order-level transactions with delivery tracking
- `fct_order_items` - Item-level details (wide denormalized table)

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

**Setup:**
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

### Phase 1 Deliverables ✅

- ✅ Docker environment setup
- ✅ Data ingestion pipeline (8 raw tables, 1M+ rows)
- ✅ Staging layer (8 models with type casting, timezone conversion)
- ✅ Intermediate layer (8 models with business logic, joins, deduplication)
- ✅ Marts layer (5 dimensional models: 3 dims + 2 facts)
- ✅ Data quality framework (30+ tests)
- ✅ Custom macros (2: timezone conversion, data validation)
- ✅ Custom generic tests (2: positive_values, non_negative_values)
- ✅ Seed data (Brazilian holidays reference table)
- ✅ Comprehensive documentation (YAML schemas, inline comments)
- ✅ Project README with architecture and screenshots

**[View Phase 1 detailed documentation →](phase1-dbt-platform/README.md)**

---

## Phase 1.5: Cloud Migration (Snowflake)

**Status:** Planned

Migrating the dbt pipeline from local DuckDB to Snowflake cloud data warehouse.

### Objectives
- Deploy models to production-grade cloud warehouse
- Maintain dual environment (local dev + cloud prod)
- Demonstrate cloud data engineering skills
- Add Snowflake to resume/portfolio

### Tech Stack
- **Cloud Warehouse:** Snowflake (AWS)
- **Deployment:** dbt with multi-target configuration

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

**Data Engineering:**
- Docker containerization
- Python data pipelines
- DuckDB database
- Version control (Git)

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