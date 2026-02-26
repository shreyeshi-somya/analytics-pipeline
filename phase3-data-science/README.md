# Phase 3: Data Science & ML

## Overview
Exploratory data analysis and machine learning models built on the Olist Brazilian e-commerce dataset, using the clean dbt marts from Phase 1.

## Dataset
- **110,189** delivered order items across **96,470** orders
- **93,350** unique customers, **2,970** sellers, **32,214** products
- Date range: Sep 2016 – Aug 2018
- Total revenue: R\$15.4M

## Folder Structure
```
phase3-data-science/
├── Dockerfile
├── docker-compose.yml
├── requirements.txt
├── analytics.duckdb
├── notebooks/
│   ├── 01_eda.ipynb
│   ├── 02_seller_segmentation.ipynb
│   └── 03_delivery_delay_prediction.ipynb
├── outputs/
│   └── (charts, model artifacts, CSVs)
└── README.md
```

## Completed

### ✅ EDA (01_eda.ipynb)
Key findings:
- **Growth:** Strong order growth through Nov 2017, then plateaued at ~7K orders/month. AOV stable ~R\$160
- **Geography:** São Paulo = 42% of orders. Southeast region = 69%. North region averages 1.5x longer delivery times compared to the average of all other regions
- **Delivery:** 92.1% on-time rate, median 10 days. Cross-region shipments significantly slower (North seller to North customer = 43 days)
- **Sellers:** Highly concentrated: 19% of sellers drive 80% of revenue. Median seller has 7 orders. Faster delivery correlates with higher review scores
- **Categories:** Home & Living = highest revenue (R\$4.2M) but lowest avg review score. Books & Food = highest reviewed. Gifts & Party = highest late delivery rate (9.2%)
- **Customers:** 97% are one-time buyers

### ✅ Seller Segmentation (02_seller_segmentation.ipynb)
K-Means clustering on 2,970 sellers using 8 features across three dimensions: volume, business type, and quality.

**Approach:**
- Feature engineering from order-item level data with proper deduplication for order-level metrics
- Correlation analysis to remove redundant features (dropped total_items, unique_categories)
- Compared clustering with and without log transformation of skewed features
- Evaluated K=3 and K=4 using silhouette scores and business interpretability

**Four seller segments identified:**
- **Small & Reliable** (1,206 sellers | 41% | 2.7% of revenue): Low volume but best reviews (4.38) and on-time rate (97%)
- **Top Performers** (763 sellers | 26% | 79% of revenue): Highest volume, revenue, and product diversity. Strong quality despite scale
- **Underperformers** (125 sellers | 4% | 0.7% of revenue): Worst delivery (31 days avg) and reviews (2.66). Negligible revenue but damaging customer trust
- **Mid-Tier** (876 sellers | 29% | 17.6% of revenue): Moderate volume, good quality. Already match Top Performers on delivery and reviews. Gap is purely in scale and catalog size

## Coming Up
- **Delivery Delay Prediction** (03_delivery_delay_prediction.ipynb): Supervised ML to predict late deliveries using geography, product attributes, and seller track record
- **Pipeline Integration**: Push cluster labels and predictions back into dbt as seed files for downstream visualization

## Tech Stack
Python, Pandas, NumPy, Scikit-learn, XGBoost, Matplotlib, Seaborn, DuckDB, Docker, Jupyter