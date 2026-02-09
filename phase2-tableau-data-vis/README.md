# Phase 2: Tableau Data Visualization

Interactive executive dashboards built with Tableau Public, showcasing advanced visualization techniques and business intelligence best practices.

---

## Overview

This phase transforms the analytics-ready data from Phase 1 into actionable executive dashboards. The project demonstrates proficiency in business intelligence, data storytelling, and interactive dashboard design.

---

## Tech Stack

- **Visualization:** Tableau Public
- **Data Source:** mart_order_items (from Phase 1 dbt pipeline)
- **Data Volume:** 95,442 orders, 94,386 customers, 19 months of data
- **Time Period:** February 2017 - August 2018

---

## Dashboards

### Dashboard 1: Executive Overview ✅ **COMPLETE**

**Purpose:** High-level business performance monitoring for executive leadership

**Features:**
- **5 KPI Cards:** Total Revenue (R$15.24M), Total Orders (95,442), AOV (R$160), Avg Review Score (4.0), Total Customers (94,386)
- **Parameter-Driven Analysis:** Single metric selector controls 4 dynamic charts (Revenue, Orders, Customers, AOV, Review Score)
- **Monthly Trend Analysis:** Dual-axis chart with bars (selected metric) and color-coded line (MoM% - green for growth, red for decline)
- **Geographic Analysis:** Brazil map colored by selected metric, showing state-level performance with full state names
- **Top 10 Categories:** Dynamic bar chart ranking product categories by selected metric
- **Payment Distribution:** Revenue breakdown by payment method (Credit Card: R$11.9M dominant)
- **Interactive Filters:** Date range slider, State multi-select, Region checkboxes, Product category groups

**Interactivity:**
- Click state on map → filters all charts
- Change parameter → updates 4 charts simultaneously
- Dashboard actions for cross-filtering

**Skills Demonstrated:**
- Parameters & dynamic metrics
- Dual-axis charts
- Table calculations (Month-over-Month %)
- Conditional formatting (color-coded trends)
- Dashboard actions
- Professional layout & design

**Published:** [Tableau Public Link](https://public.tableau.com/app/profile/shreyeshi.somya/viz/ecomm-analytics/Dashboard1)

**Screenshots:** See `screenshots/dashboard1/`

---

### Dashboard 2: Operations & Financial Intelligence 🚧 **IN PROGRESS**

**Planned Features:**
- Delivery performance funnel
- Delivery time distribution
- State performance comparison
- Payment method analysis
- Revenue waterfall
- Seller performance scorecard

---

### Dashboard 3: Customer & Product Deep Dive 🚧 **IN PROGRESS**

**Planned Features:**
- Customer lifetime value distribution
- Product profitability matrix
- Category performance analysis
- Customer behavior patterns
- Advanced LOD calculations
- Set actions

---

## Data Pipeline
```
Phase 1 dbt Models
    ↓
Export to CSV (mart_order_items)
    ↓
Tableau Public Desktop
    ↓
Published Dashboard
```

**Note:** Tableau Public limitations mean live Snowflake connection is not possible. Data is exported as CSV and refreshed as needed.

---

## Project Structure
```
phase2-tableau-data-vis/
├── screenshots/
│   ├── dashboard1/
│   │   ├── full-dashboard.png
│   │   ├── kpi-cards.png
│   │   ├── monthly-trend.png
│   │   ├── geographic-map.png
│   │   ├── parameter-selector.png
│   │   ├── filters-applied.png
│   │   └── cross-filtering.png
│   ├── dashboard2/
│   └── dashboard3/      
└── README.md
```

---

## Key Metrics & Insights

### Business Performance (Feb 2017 - Aug 2018)

**Revenue & Orders:**
- Total Revenue: **R$15.24M**
- Total Orders: **95,442**
- Average Order Value: **R$160**
- Peak Month: November 2017 (R$1.16M) - Black Friday effect?

**Customer Base:**
- Unique Customers: **94,386**
- Customer Satisfaction: **4.0/5.0** average review score
- Repeat Customer Rate: **3%** (low - single-transaction dominated)

**Geographic Distribution:**
- Top State: **São Paulo (SP)** - R$5.7M (37% of revenue)
- Southeast Region: Dominant (SP, RJ, MG combined ~60% of revenue)
- Strong presence in: Rio de Janeiro, Minas Gerais

**Geographic Patterns - Beyond Population:**

While Revenue and Order volume closely follow population density (São Paulo dominates), **Average Order Value (AOV)** shows an inverse pattern:
- **Lower-population states** have higher AOV (R$224-R$267 range in North/Northwest)
- **High-population states** have lower AOV (SP: R$160, RJ: R$159)
- **Hypothesis:** Urban areas = more frequent, smaller purchases; Rural areas = less frequent, larger basket sizes

**Review Score geographic distribution** also differs from population:
- More uniform across states (3.7-4.2 range)
- Northern states (Roraima, Amapá) show slightly higher satisfaction (4.2)
- Suggests service quality is consistent regardless of market size

**Product Performance:**
- Top Category: **Health & Beauty** - R$1.39M
- High-value categories: Watches/Gifts (R$1.25M), Bed/Bath/Table (R$1.22M)
- Total Categories: 71 granular, 10 broad groups

**Payment Preferences:**
- Credit Card: **78%** of revenue (R$11.9M)
- Boleto (bank slip): 18% (R$2.7M)
- Installment payments common in Brazil

**Trends:**
- Strong seasonality: Black Friday (Nov) and holiday peaks
- Growth trend: +45% peak MoM growth (May 2017)
- Volatility: -27% decline (Dec 2017) - post-holiday drop

---

## Dashboard Design Principles

### Layout Strategy
- **F-pattern reading flow:** KPIs at top, key metrics left-to-right
- **Hierarchy:** Most important metrics (KPIs) → Trends → Details
- **White space:** Clean, uncluttered design for executive audience

### Color Palette
- **Primary:** Teal/turquoise (#4ECDC4) - main data visualization
- **Accent:** Dark blue (#1A535C) - headers, emphasis
- **Success:** Green (#2ECC71) - positive trends, growth
- **Warning:** Red (#E74C3C) - negative trends, decline
- **Neutral:** Grays for text and backgrounds

### Interactivity Philosophy
- **Progressive disclosure:** Start simple, allow drill-down
- **Single-click filtering:** Minimal user effort for insights
- **Visual feedback:** Highlights, tooltips, clear selection states
- **Undo-friendly:** Easy to clear filters and reset view

---

## Technical Challenges & Solutions

### Challenge 1: Sparse Early Data
**Problem:** September-December 2016 had minimal orders, causing extreme MoM% values (649,657%)  
**Solution:** Applied data source filter to focus on Feb 2017 - Aug 2018 (stable period)  
**Documentation:** Noted in dashboard info box for transparency (upper right corner)

### Challenge 2: Geographic Data
**Problem:** Tableau defaulted to US geography for ZIP codes  
**Solution:** 
1. Created "Country" calculated field = 'Brazil'
2. Added state names seed file with full names
3. Mapped state codes to names in staging layer
4. Used hierarchy: Country → State

### Challenge 3: Dynamic Metric Formatting
**Problem:** Different metrics need different formats (currency vs count)  
**Solution:** Created custom calculated field with conditional formatting:
```tableau
CASE [Metric Selector] 
   WHEN "Revenue (Delivered)" 
   THEN 'R$ ' + 
        IF [Revenue (Delivered)] >= 1000000 THEN
            STR(INT([Revenue (Delivered)]/1000000)) + ',' + 
            RIGHT('000' + STR(INT(([Revenue (Delivered)] % 1000000)/1000)), 3) + 'K'
        ELSE
            STR(ROUND([Revenue (Delivered)]/1000, 0)) + 'K'
        END
   -- Similar logic for other metrics
END
```

### Challenge 4: Category Granularity
**Problem:** 71 product categories too detailed for executive view  
**Solution:** Created rollup seed file grouping into 10 broad categories  
**Benefit:** Clearer trends, easier filtering, better decision-making

---

## Skills Demonstrated

### Tableau Expertise
✅ **Parameters:** Dynamic metric selection affecting multiple charts  
✅ **Calculated Fields:** Complex string formatting, conditional logic  
✅ **Table Calculations:** Month-over-Month % change  
✅ **Dual-Axis Charts:** Bars + line with different scales  
✅ **Dashboard Actions:** Click-to-filter, cross-chart interactivity  
✅ **Filters:** Date sliders, multi-select dropdowns, hierarchical filters  
✅ **Custom Formatting:** Conditional colors, currency formatting, number abbreviations  
✅ **Geographic Mapping:** Brazil states with custom regions  
✅ **Design:** Professional layout, color theory, executive-friendly presentation  

### Data Storytelling
✅ **Narrative Flow:** Guided user journey from high-level to details  
✅ **Context:** Clear labels, tooltips, and explanatory text  
✅ **Insights:** Surfaced actionable findings (seasonality, regional concentration)  
✅ **Visual Hierarchy:** Size, color, position convey importance  

### Business Intelligence
✅ **KPI Selection:** Chose metrics that matter to executives  
✅ **Trend Analysis:** Identified patterns in seasonality and growth  
✅ **Segmentation:** Geographic, product, payment method breakdowns  
✅ **Benchmarking:** Comparative analysis across dimensions  

---

## Data Quality Notes

**Filtering Applied:**
- Date Range: February 2017 - August 2018 (excluded sparse early months)
- Order Status: Delivered orders only (for revenue metrics)
- Rationale: Ensures consistent, reliable analysis period

**Known Limitations:**
- Low repeat customer rate (3%) limits cohort analysis
- Tableau Public doesn't support live Snowflake connection
- Data refresh requires manual CSV export
- No real-time updates

---

## Lessons Learned

### What Worked Well
✅ **Seed files in dbt:** Reference data (states, categories) integrated cleanly in staging layer  
✅ **Parameter-driven design:** Single selector controlling multiple charts = elegant UX  
✅ **MoM% coloring:** Green/red instantly communicates performance  
✅ **Dual-axis trend:** Shows absolute values + growth rate simultaneously  

### What Was Challenging
⚠️ **String formatting in Tableau:** Complex logic for currency + thousands separator  
⚠️ **Geographic mapping:** Required custom country field + state name lookup  
⚠️ **Extreme outliers:** Early sparse data created misleading MoM% values  

---

## Resources

**Tableau Public Profile:** [Your Profile Link](https://public.tableau.com/app/profile/shreyeshi.somya/vizzes)  
**Phase 1 (dbt Pipeline):** [../phase1-dbt-platform/](../phase1-dbt-platform/)  
**Dataset Source:** [Brazilian E-commerce on Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)  

---

**Last Updated:** 2025-02-09  
**Maintained By:** Shreyeshi Somya
