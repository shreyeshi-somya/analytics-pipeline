# Phase 3: Data Science & ML

## Overview
Exploratory data analysis and machine learning models built on the Olist Brazilian e-commerce dataset, using the clean dbt marts from Phase 1.

## Dataset
- **110,189** delivered order items across **96,470** orders
- **93,350** unique customers, **2,970** sellers, **32,214** products
- Date range: Sep 2016 – Aug 2018
- Total revenue: R\$15.4M

## Infrastructure

This phase runs as the `data-science` service in the root `docker-compose.yml`. It shares a DuckDB database (`data/analytics.duckdb`) with the dbt service, enabling ML outputs to flow directly into the dbt pipeline without intermediate CSV files.

## Folder Structure
```
phase3-data-science/
├── Dockerfile
├── requirements.txt
├── notebooks/
│   ├── 01_eda.ipynb
│   ├── 02_seller_segmentation.ipynb
│   └── 03_delivery_prediction.ipynb
├── outputs/
│   ├── 01–07: EDA visualizations
│   ├── 08–12: Seller segmentation charts
│   └── 13–22: Delivery prediction analysis
└── README.md
```

## Notebooks

### 1. EDA (01_eda.ipynb)

Comprehensive exploratory analysis across six dimensions: growth trends, geography, delivery performance, seller concentration, product categories, and payment behavior.

**Key findings:**
- **Growth:** Strong order growth through Nov 2017, then plateaued at ~7K orders/month. AOV stable ~R\$160
- **Geography:** São Paulo = 42% of orders. Southeast region = 69%. North region averages 1.5x longer delivery times compared to other regions
- **Delivery:** 92.1% on-time rate, median 10 days. Cross-region shipments significantly slower
- **Sellers:** Highly concentrated — 19% of sellers drive 80% of revenue. Median seller has 7 orders. Faster delivery correlates with higher review scores
- **Categories:** Home & Living = highest revenue (R\$4.2M) but lowest avg review score. Books & Food = highest reviewed. Gifts & Party = highest late delivery rate
- **Customers:** 97% are one-time buyers

| Output | Description |
|--------|-------------|
| `01_monthly_trends.png` | Orders, revenue, customers, and AOV over time |
| `02_geographic_distribution.png` | Top states, revenue by region, delivery days by region |
| `03_delivery_performance.png` | Delivery distribution, on-time vs late, seller→customer region heatmap |
| `04_seller_overview.png` | Orders per seller, sellers by region, revenue by region |
| `05_seller_performance.png` | Review score vs delivery days, revenue concentration (Lorenz curve) |
| `06_category_analysis.png` | Revenue, reviews, late rates, and price vs delivery by category |

---

### 2. Seller Segmentation (02_seller_segmentation.ipynb)

K-Means clustering on 2,970 sellers using 8 features across three dimensions: volume, business type, and quality.

**Approach:**
- Feature engineering from order-item level data with proper deduplication for order-level metrics
- Correlation analysis to remove redundant features (dropped `total_items`, `unique_categories`)
- Log transformation of skewed volume features (`total_orders`, `total_revenue`, `avg_price`, `unique_products`)
- Evaluated K=3 vs K=4 using silhouette scores and business interpretability — chose K=4 for better segment separation

**Four seller segments identified:**

| Segment | Sellers | Revenue Share | Avg Review | On-Time Rate | Avg Delivery |
|---------|---------|--------------|------------|-------------|-------------|
| **Small & Reliable** | 1,206 (41%) | 2.7% | 4.38 | 97% | 9.8 days |
| **Top Performers** | 763 (26%) | 79.1% | 4.15 | 92% | 12.1 days |
| **Mid-Tier** | 876 (29%) | 17.6% | 4.14 | 92% | 12.7 days |
| **Underperformers** | 125 (4%) | 0.7% | 2.66 | 29% | 30.9 days |

**Key insight — Mid-Tier growth opportunity:** Mid-Tier sellers already match Top Performers on quality (4.14 vs 4.15 reviews, both 92% on-time). The gap is entirely in scale — orders (91.5% gap), revenue (80.6%), and catalog size (85.7%). They're strong candidates for growth programs since the hardest part (delivery and customer satisfaction) is already solved.

**Business recommendations:**
- **Small & Reliable:** Seller growth programs, featured placement, category expansion nudges
- **Top Performers:** Priority support, loyalty incentives, retention programs (platform backbone)
- **Mid-Tier:** Marketing support, catalog expansion incentives, visibility boosts
- **Underperformers:** Delivery audits, logistics support, potential delisting if no improvement

| Output | Description |
|--------|-------------|
| `07_correlation_matrix.png` | Feature correlation matrix for feature selection |
| `08_optimal_k_without_log.png` | Elbow + silhouette curves (raw features) |
| `09_optimal_k_with_log.png` | Elbow + silhouette curves (log-transformed features) |
| `10_cluster_profiles_log.png` | Normalized feature profiles per cluster |
| `11_pca_clusters.png` | PCA projection (PC1=scale 34.9%, PC2=quality 24.3%) |
| `12_cluster_gap_analysis.png` | Mid-Tier vs Top Performers gap analysis |

Results are written to the shared DuckDB database as `ml_outputs.seller_clusters` (seller_id, cluster, cluster_name), which is consumed by the dbt mart layer in `mart_order_items` to enrich order items with seller segment labels.

---

### 3. Delivery Prediction (03_delivery_prediction.ipynb)

Regression model predicting actual delivery time (days) for each order using geography, product attributes, seller profile, and temporal features.

**Feature engineering (22 features):**
- **Geographic:** Haversine distance (seller→customer), same-state/region flags, lat/lon coordinates
- **Order attributes:** Item count, price, freight, freight-to-price ratio
- **Product physical:** Weight, volume
- **Seller profile:** Total historical orders, tenure days
- **Temporal:** Purchase hour, day of week, month, order month number (trend feature)
- **Holiday:** Near-holiday flag, days to next holiday

**Modeling approach:**
- Temporal train/test split (80/20) — train: Sep 2016–May 2018, test: May–Aug 2018
- Compared 4 models: Linear Regression, Ridge, Random Forest, XGBoost
- Log-transformed target to handle right-skewed delivery distribution
- Added `order_month_num` to capture the improving delivery trend over time (train avg 13.4 days → test avg 8.7 days)

**Model comparison (after log target + temporal feature):**

| Model | MAE (days) | RMSE | R² |
|-------|-----------|------|-----|
| Naive (predict median) | 4.91 | 6.35 | -0.155 |
| Linear Regression | 4.71 | 6.29 | -0.133 |
| Ridge Regression | 4.71 | 6.29 | -0.133 |
| Random Forest | 3.54 | 5.41 | 0.164 |
| **XGBoost (tuned)** | **3.44** | **5.18** | **0.232** |

**Feature importance analysis:**
- Initial model showed `same_state` dominating at 83% importance — a classic case of correlated feature dominance
- Removed `same_state` and retrained: identical MAE (3.48), marginally better R² (0.206 vs 0.203), confirming it was redundant
- Without `same_state`, importance is healthier: `distance_km` (33%), `order_month_num` (8%), `same_region` (8%), `num_sellers` (7%)
- SHAP analysis revealed `days_to_next_holiday` has high impact when used (jumped from 20th in XGBoost importance to 4th in SHAP)

**Hyperparameter tuning:** RandomizedSearchCV (50 iterations, 3-fold CV) improved MAE from 3.48 to 3.44 days. Small gain expected since the main limitation is missing logistics data, not model complexity.

**Error analysis:**
- 79.4% of predictions within 5 days of actual delivery
- Same-state orders predicted nearly perfectly (MAE 2.4 days)
- Cross-state orders slightly overpredicted (MAE 4.0 days)
- Extreme deliveries (30+ days, 4.4% of orders) are inherently unpredictable from available features

**Segmented modeling experiment:** Tested splitting orders into Standard (same region or <1000km) and High Risk segments with separate models. Standard segment improved to MAE 2.95 days, but high-risk degraded. Single model on all data remained the best overall approach.

**Comparison vs Olist's existing estimates:**

| Approach | MAE (days) | Within 5 days |
|----------|-----------|---------------|
| Olist Estimate | 13.22 | 17.8% |
| **XGBoost Model** | **3.44** | **79.4%** |

Olist systematically overestimates by ~12.7 days (intentional "under-promise, over-deliver" strategy). The model's value is in internal logistics planning, smarter customer-facing buffers, and proactive alerting for at-risk orders.

| Output | Description |
|--------|-------------|
| `13_target_distribution.png` | Delivery days distribution (raw and log) |
| `14_delivery_time_by_features.png` | Delivery time by region, distance, weight, freight |
| `15_feature_correlations_target.png` | Feature correlations with target variable |
| `16_feature_importance.png` | XGBoost feature importance (with same_state) |
| `17_feature_importance_without_same_state.png` | Feature importance after removing same_state |
| `18_shap_summary.png` | SHAP summary plot (direction + magnitude) |
| `19_shap_bar.png` | SHAP global feature importance |
| `20_partial_dependence.png` | Partial dependence for top 5 features |
| `21_error_analysis.png` | Actual vs predicted, error distribution, MAE by segment |
| `22_olist_vs_model.png` | Side-by-side comparison with Olist estimates |

Results are written to the shared DuckDB database as `ml_outputs.delivery_predictions` (order_id, days_to_delivery, predicted, error, abs_error).

---

## Pipeline Integration

ML outputs are written directly to the shared DuckDB database (`ml_outputs` schema) and consumed by the dbt project as sources:
- **Seller clusters** → joined into `mart_order_items` via `source('ml_outputs', 'seller_clusters')`, adding `cluster_name` to every order item row
- **Delivery predictions** → available in `ml_outputs.delivery_predictions` for future downstream use

## Tech Stack
Python, Pandas, NumPy, Scikit-learn, XGBoost, LightGBM, SHAP, Matplotlib, Seaborn, DuckDB, Docker, Jupyter
