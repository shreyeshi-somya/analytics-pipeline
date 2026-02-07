> 🚧 **Work in Progress** — This project is actively being developed.

# End-to-End Analytics Pipeline

A comprehensive data analytics project showcasing modern data engineering and analytics practices across multiple phases.

## Project Overview

This project demonstrates end-to-end analytics capabilities from data ingestion through visualization, using real-world e-commerce data.

### Phases

- **Phase 1: dbt Analytics Platform (DuckDB)** ⬅️ *Current*
    - Phase 1.5: Cloud Migration (Snowflake)
- Phase 2: Visualization & Analytics (Tableau)
- Phase 3: Data Science & ML
- Phase 4: Applied AI (LLM Insights)
- Phase 5: Integration & Polish

---

## Phase 1: dbt Analytics Platform

Building a production-grade data transformation pipeline using dbt, DuckDB, and Docker.

### Tech Stack

- **Transformation:** dbt (Data Build Tool)
- **Database:** DuckDB (local development)
- **Orchestration:** Docker & Docker Compose
- **Language:** SQL, Python
- **Data:** Brazilian E-commerce (Olist dataset)

### Project Structure
```
phase1-dbt-platform/
├── dbt_project/
│   ├── models/
│   │   ├── staging/        # Clean, typed data from sources
│   │   ├── intermediate/   # Business logic & transformations
│   │   └── marts/          # Final analytical models
│   ├── macros/             # Reusable SQL functions
│   └── tests/              # Data quality tests
├── data/
│   └── raw/               # Source CSV files (not committed)
├── scripts/
│   └── load_data.py       # Data ingestion script
├── Dockerfile
└── docker-compose.yml
```

### Features

- ✅ Dockerized development environment
- ✅ dbt best practices (staging → intermediate → marts)
- ✅ Custom macros (timezone conversions, data quality)
- ✅ Comprehensive data quality testing (generic + singular tests)
- ✅ Multi-layer transformation pipeline
- ✅ Complete documentation with lineage

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

# Run dbt models
dbt run

# Run tests
dbt test

# Generate documentation
dbt docs generate
```

### Data Model

The project uses the Brazilian E-commerce dataset from Olist, containing:
- 100k+ orders
- Customer demographics
- Product catalog with dimensions
- Reviews & ratings
- Payment information (multiple payment methods, installments)
- Seller & geolocation data

### Current Progress

**Completed:**
- ✅ Docker environment setup
- ✅ Data ingestion pipeline
- ✅ Source configuration (8 source tables)
- ✅ Staging layer (8 models with type casting, timezone conversion)
- ✅ Intermediate layer (6+ models with business logic)
- ✅ Data quality framework (20+ tests: generic, singular, custom)
- ✅ Custom macros (timezone conversion, data validation)
- ✅ dbt packages (dbt_utils)

**In Progress:**
- 🔄 Marts layer (fact and dimension tables)
- 🔄 Final documentation and lineage review
- 🔄 Performance optimization

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

## 👤 Author

**[Shreyeshi Somya]**
- **Current Role:** Enterprise Analytics at Peloton
- **LinkedIn:** [Shreyeshi Somya](https://www.linkedin.com/in/sshreyeshi/)
- **Email:** sshreyeshi@gmail.com
