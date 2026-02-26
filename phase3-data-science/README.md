# Phase 3: Data Science & ML

## Overview
Exploratory data analysis and machine learning models built on the Olist Brazilian e-commerce dataset, using the clean dbt marts from Phase 1.

## Dataset
- **110,189** delivered order items across **96,470** orders
- **93,350** unique customers, **2,970** sellers, **32,214** products
- Date range: Sep 2016 – Aug 2018
- Total revenue: R$ 15.4M

## Completed

### EDA (01_eda.ipynb)
Key findings:
- **Growth:** Strong order growth through Nov 2017, then plateaued at ~7K orders/month. AOV stable ~R$160
- **Geography:** São Paulo = 42% of orders. Southeast region = 69%. North region averages 1.5x longer delivery times compared to the average of all other regions
- **Delivery:** 92.1% on-time rate, median 10 days. Cross-region shipments significantly slower (North seller → North customer = 43 days)
- **Sellers:** Highly concentrated — 19% of sellers drive 80% of revenue. Median seller has 7 orders. Faster delivery correlates with higher review scores
- **Categories:** Home & Living = highest revenue (R$4.2M) but lowest avg review score. Books & Food = highest reviewed. Gifts & Party = highest late delivery rate (9.2%)
- **Customers:** 97% are one-time buyers

## Coming Up
- **Seller Segmentation** (02_seller_segmentation.ipynb) — K-Means clustering on seller performance, volume, delivery, and review metrics
- **Delivery Delay Prediction** (03_delivery_delay_prediction.ipynb) — Supervised ML to predict late deliveries using geography, product attributes, and seller track record

## Tech Stack
Python, Pandas, Scikit-learn, XGBoost, Matplotlib, Seaborn, DuckDB, Docker, Jupyter