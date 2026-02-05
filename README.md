# End-to-End Analytics Pipeline

A comprehensive data analytics project showcasing modern data engineering and analytics practices across multiple phases.

## Project Overview

This project demonstrates end-to-end analytics capabilities from data ingestion through visualization, using real-world e-commerce data.

### Phases

- **Phase 1: dbt Analytics Platform** ⬅️ *Current*
- Phase 2: Data Science & ML
- Phase 3: Applied AI (LLM Insights)
- Phase 4: Visualization (Tableau)
- Phase 5: Visualization (Power BI)
- Phase 6: Integration & Polish

---

## Phase 1: dbt Analytics Platform

Building a production-grade data transformation pipeline using dbt, DuckDB, and Docker.

### Tech Stack

- **Transformation:** dbt (Data Build Tool)
- **Database:** DuckDB
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
- ✅ Custom macros for timezone conversions
- ✅ Data quality testing
- ✅ Incremental models for performance
- ✅ Complete documentation

### Getting Started

**Prerequisites:**
- Docker Desktop
- Git

**Setup:**
```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/analytics-pipeline.git
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
- Product catalog
- Reviews & ratings
- Payment information
- Geolocation data

### Current Progress

- [x] Docker environment setup
- [x] Data ingestion pipeline
- [x] Source configuration
- [x] Staging layer (orders, customers, products)
- [ ] Intermediate transformations
- [ ] Dimensional models (facts & dimensions)
- [ ] Data quality tests
- [ ] Performance optimization

---

## 👤 Author

- LinkedIn: [Shreyeshi Somya](https://www.linkedin.com/in/sshreyeshi/)
- Email: sshreyeshi@gmail.com

---
