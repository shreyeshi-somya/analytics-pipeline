# Phase 2: Tableau Data Visualization

Interactive executive dashboards built with Tableau Public, showcasing advanced visualization techniques and business intelligence best practices for Brazilian e-commerce analytics.

---

## 📊 Overview

This phase transforms analytics-ready data from Phase 1 into actionable executive dashboards. The project demonstrates proficiency in:
- Advanced Tableau features (LODs, parameters, dual-axis charts)
- Interactive dashboard design
- Data storytelling and business insight delivery
- Professional UI/UX for executive audiences

---

## 🛠️ Tech Stack

- **Visualization:** Tableau Public
- **Data Source:** `mart_order_items` (from Phase 1 dbt pipeline)
- **Data Volume:** 95,442 delivered orders, 94,386 customers
- **Time Period:** February 2017 - August 2018
- **Geographic Scope:** 27 Brazilian states

---

## 📈 Dashboard 1: Executive Overview

**Purpose:** High-level business performance monitoring for executive leadership

**Published Dashboard:** [View on Tableau Public](#) *(Add your link)*

---

### **Features:**

#### **KPI Cards (5)**
- **Total Revenue:** R$15.24M (delivered orders only)
- **Total Orders:** 95,442
- **Average Order Value (AOV):** R$160
- **Average Review Score:** 4.0/5.0
- **Total Customers:** 94,386

#### **Monthly Trend Analysis**
- **Dual-axis chart:** Revenue bars + MoM% change line
- **Color-coded trends:** Green = growth, Red = decline
- **Insights:** Strong seasonality (Black Friday spikes), volatile MoM performance

#### **Geographic Analysis - Brazil Map**
- **Dynamic coloring:** Updates based on metric selector parameter
- **State-level detail:** Full state names with regional groupings
- **Key Finding:** São Paulo dominates revenue (37%), but northern states show higher AOV

#### **Top 10 Categories**
- **Parameter-driven:** Dynamically ranks by selected metric
- **Top performers:** Health & Beauty (R$1.39M), Watches/Gifts (R$1.25M)

#### **Payment Distribution**
- **Breakdown by type:** Credit Card (78%), Boleto (18%), Others (4%)
- **Insight:** Credit card dominance typical of Brazilian e-commerce

---

### **Interactive Controls:**

**1. Metric Selector Parameter (6 options):**
- Revenue (Delivered)
- Orders (Delivered)
- Number of Customers
- Average Order Value
- Review Score
- **Effect:** Changes 4 charts simultaneously (Trend, Map, Categories, custom formatting)

**2. Filters:**
- **Date Range Slider:** Feb 2017 - Aug 2018
- **State Multi-Select:** Full state names
- **Region Checkboxes:** 5 Brazilian regions (North, Northeast, Central-West, Southeast, South)
- **Product Category Groups:** 10 broad categories (from 71 granular)

**3. Dashboard Actions:**
- Click state on map → filters all charts
- Automatic cross-filtering across visualizations

---

### **Key Insights:**

**Revenue Patterns:**
- Peak month: November 2017 (R$1.16M) - Black Friday effect
- MoM volatility: +45% peak growth, -27% max decline
- Steady revenue despite customer acquisition challenges

**Geographic Distribution:**
- Southeast region dominates: ~60% of revenue
- **Paradox discovered:** High-population states = lower AOV, Low-population states = higher AOV
- Hypothesis: Urban areas have frequent small purchases, rural areas have infrequent large baskets

**Customer Behavior:**
- Low repeat rate: Only 3% of customers make multiple purchases
- High satisfaction: 4.0/5.0 average despite delivery challenges
- Payment preference: Strong credit card adoption (installment culture)

---

### **Skills Demonstrated:**

✅ **Parameters:** Dynamic metric selection affecting multiple charts  
✅ **Calculated Fields:** Complex string formatting, conditional logic, MoM% calculations  
✅ **Table Calculations:** Month-over-Month % change with LOOKUP()  
✅ **Dual-Axis Charts:** Bars + line with independent scales  
✅ **Dashboard Actions:** Click-to-filter cross-chart interactivity  
✅ **Custom Formatting:** Currency formatting, number abbreviations (K/M), conditional colors  
✅ **Geographic Mapping:** Brazil states with custom regional hierarchies  
✅ **Data Enrichment:** Seed files for state names, regions, category rollups  

---

## 🚚 Dashboard 2: Delivery Performance (Operations Deep Dive)

**Purpose:** Operational analytics for delivery optimization and performance monitoring

**Published Dashboard:** [View on Tableau Public](#) *(Add your link)*

---

### **Three-Tab Design:**

**Tab 1: Deliveries Overview**  
**Tab 2: State - Deep Dive**  
**Tab 3: Category - Deep Dive**

*Implemented using parameter-driven view switching with overlapping floating containers*

---

### **Tab 1: Deliveries Overview**

#### **KPI Cards (5)**
- **Total Orders:** 95,442
- **Median Delivery Days:** 10 (more realistic than avg)
- **Avg Days to Delivery:** 12.38
- **% On-Time Deliveries:** 91.8% (vs estimated delivery date)
- **% Deliveries on Target:** 51.8% (vs 10-day company goal)

#### **Delivery Trend (Dual-Axis with Advanced Features)**
- **Blue line:** Average delivery days over time
- **Orange line:** % On-Time deliveries
- **Reference band:** Gray shaded area (10-14 days acceptable range)
- **Trend line:** Shows delivery time improving overall
- **Parameter:** Date granularity switcher (Week/Month/Quarter)

**Key Insight:** Dramatic improvement in late 2018 (18→8 days), but on-time % dropped (paradox: faster deliveries but worse promise-keeping)

#### **Days to Delivery Histogram**
- **Distribution:** Right-skewed, most orders 6-12 days
- **Parameter:** Dynamic bin size (1, 3, 5, 7, 10 days)
- **Filter:** Limited to 0-60 days (removed extreme outliers)

---

### **Tab 2: State - Deep Dive**

#### **State Delivery Performance (Bullet Chart)**
- **Green bars:** Actual avg delivery days per state
- **Black dots:** State-specific estimated delivery (what was promised)
- **Red dashed line:** Company target (10 days)
- **Color gradient:** Green (beating estimate) → Red (missing estimate)

**Triple Benchmark Comparison:**
1. **Actual vs Estimated:** Most states beat their promises ✅
2. **Actual vs Target:** Most states miss 10-day stretch goal ⚠️
3. **State-to-state variation:** Northern states slower (distance effect)

**Advanced Features:**
- **LOD calculation:** Dynamic target per state (not fixed)
- **Tooltip with indicators:** 🟢 Beating Estimate / 🔴 Missing Estimate
- **Dual-axis:** Bars + dots overlaid
- **Diverging color palette:** Centered on 0 variance

**Top Performers:** São Paulo (8.6 days), Distrito Federal (12.7 days)  
**Needs Improvement:** Amapá (28.2 days), Roraima (28.6 days) - remote northern states

---

### **Tab 3: Category - Deep Dive**

#### **Category Delivery Performance (LOD + Dual Encoding)**
- **Bar length:** Avg delivery days by category
- **Bar color:** Variance from overall avg (Green = faster, Red = slower)
- **Circle size:** Order volume (bigger = more orders)
- **Circle color:** Navy blue (neutral)
- **Labels:** +/- days variance from avg

**Dual Insights:**
1. **Speed:** Food/Drinks fastest (-1.66 days vs avg), Electronics slowest (+0.63)
2. **Volume:** Electronics has HUGE volume despite being slow (operational bottleneck!)
3. **Actionable:** High-volume + slow categories = priority for improvement

**LOD Expression Used:**
```tableau
Variance from Overall Avg = 
  {FIXED [Product Category]: AVG([Days To Delivery])} - 
  {FIXED : AVG([Days To Delivery])}
```

**Top Insights:**
- **Electronics & Tech:** Slowest but highest volume (16K orders) - needs process improvement
- **Food, Drinks & Pets:** Fastest delivery (-1.66 days) - perishable goods priority
- **Home & Living:** Very slow (+0.49 days) with massive volume (26K orders) - bulky items challenge

---

### **Skills Demonstrated:**

✅ **LOD Expressions (FIXED):** Calculate variance from overall average  
✅ **Parameter-Driven View Switching:** Three tabs with show/hide logic  
✅ **Floating Containers:** Overlapping charts for tab functionality  
✅ **Dual-Axis Charts:** Multiple measures with different scales  
✅ **Reference Bands:** Shaded acceptable range zones  
✅ **Trend Lines:** Linear regression showing improvement trajectory  
✅ **Parameter-Controlled Bins:** Dynamic histogram bin sizing  
✅ **Bullet Charts:** Actual vs estimated vs target triple comparison  
✅ **Dual Encoding:** Size + color conveying different metrics  
✅ **Diverging Color Palettes:** Red-Green centered on zero  
✅ **Custom Tooltips:** Conditional indicators and formatted text  
✅ **Dynamic Date Granularity:** Week/Month/Quarter parameter switching  

---

## 🎨 Design Principles

### **Color Palette**
- **Primary:** Teal/Turquoise (#4ECDC4) - main data
- **Secondary:** Navy Blue (#1A535C) - accents, volume indicators
- **Success:** Green (#2ECC71) - positive trends, beating targets
- **Warning:** Red (#E74C3C) - negative trends, missing targets
- **Neutral:** Grays for backgrounds and secondary text

### **Layout Philosophy**
- **F-pattern reading flow:** Critical metrics top-left, details bottom-right
- **Visual hierarchy:** Size and position indicate importance
- **White space:** Clean, uncluttered executive-friendly design
- **Consistent spacing:** 10px padding throughout

### **Interactivity Strategy**
- **Progressive disclosure:** Overview → Deep dive on demand
- **Single-click actions:** Minimal effort for maximum insight
- **Clear navigation:** Prominent buttons between dashboards
- **Parameter controls:** Visible, accessible, intuitive

---

## 📊 Data Enhancements (from Phase 1)

### **Seed Files Added:**

**1. Brazilian States & Regions** (`brazilian_states.csv`)
- Maps 2-letter codes (SP, RJ) → Full names (São Paulo, Rio de Janeiro)
- Groups into 5 regions (North, Northeast, Central-West, Southeast, South)
- Joined in `stg_geolocation`

**2. Product Category Rollups** (`product_category_rollup.csv`)
- Consolidates 71 granular categories → 10 broad groups:
  - Electronics & Tech
  - Health, Beauty & Personal Care
  - Home & Living
  - Fashion & Accessories
  - Sports, Leisure & Toys
  - Food, Drinks & Pets
  - Auto & Industrial
  - Books, Stationery & Media
  - Gifts & Party
  - Other / Misc
- Joined in `stg_products`

---

## 🔍 Key Business Insights

### **Revenue Performance:**
- **Total:** R$15.24M over 19 months
- **Growth:** Volatile with seasonal peaks (Black Friday, holidays)
- **Average Order:** R$160 (stable despite volume fluctuations)

### **Customer Behavior:**
- **Acquisition:** 94,386 unique customers
- **Retention Challenge:** Only 3% repeat rate (single-transaction dominated)
- **Satisfaction:** 4.0/5.0 despite delivery inconsistencies

### **Geographic Patterns:**
- **Revenue:** Population-correlated (SP, RJ, MG dominate)
- **AOV:** Inverse pattern (rural > urban)
- **Delivery Speed:** Distance-correlated (North slower than Southeast)

### **Delivery Operations:**
- **Speed Improving:** Avg delivery dropped from 14→8 days (2017→2018)
- **Promise-Keeping Challenge:** 91.8% on-time vs estimated, but only 51.8% meet 10-day target
- **Category Bottlenecks:** Electronics (high volume + slow) needs process improvement
- **State Challenges:** Remote northern states 2-3x slower than urban centers

### **Payment Insights:**
- **Credit Card Dominance:** 78% of revenue (Brazilian installment culture)
- **Boleto Usage:** 18% (popular for unbanked/prefer cash equivalent)
- **Low Digital Wallet Adoption:** Minimal voucher/debit usage

---

## 🚀 Advanced Tableau Techniques Used

### **Parameters (3)**
1. **Metric Selector:** Changes 4+ charts simultaneously
2. **Date Granularity:** Week/Month/Quarter switching
3. **Analysis View:** Tab navigation (Overview/State/Category)

### **Calculated Fields (15+)**
- MoM% with LOOKUP()
- Dynamic bins with CASE + parameter
- LOD expressions (FIXED at state/category/overall levels)
- Variance calculations
- Conditional formatting logic
- Custom label formatting

### **Chart Types (8)**
- Dual-axis line charts
- Bullet charts
- Histograms
- Horizontal bar charts
- Choropleth maps
- KPI cards
- Combination charts (bar + circle dual encoding)

### **Interactive Features**
- Dashboard actions (filter on click)
- Parameter controls (dropdowns, sliders)
- Show/hide logic (floating container swapping)
- Cross-dashboard navigation (buttons)
- Hierarchical filters (Region → State)

---

## 📂 Project Structure
```
phase2-tableau-data-vis/
├── dashboards/
│   └── (Workbooks not in repo - see Tableau Public)
├── screenshots/
│   ├── dashboard1/
│   │   └── overview.png
│   └── dashboard2/
│       ├── deliveries-overview.png
│       ├── deliveries-state.png
│       └── deliveries-category.png
├── data/
│   └── mart_order_items.csv (exported from Snowflake)
└── README.md
```

---

## 🔗 Live Dashboards

**📊 Dashboard 1: Executive Overview**  
[View on Tableau Public](#) *(Add link)*

**🚚 Dashboard 2: Delivery Performance**  
[View on Tableau Public](#) *(Add link)*

---

## 💡 Lessons Learned

### **What Worked Well:**
✅ **Parameter-driven design:** Single control affecting multiple charts = elegant UX  
✅ **LOD expressions:** Enabled complex comparisons (actual vs avg) without data prep  
✅ **Dual encoding:** Conveyed two metrics simultaneously (size + color)  
✅ **Seed file integration:** Reference data in dbt = clean, maintainable analytics  
✅ **Floating containers:** Achieved tab-like functionality without complex workarounds  

### **Challenges Overcome:**
⚠️ **Tableau Public limitations:** No live Snowflake connection (CSV export required)  
⚠️ **Reference lines on dynamic charts:** Don't work well with parameter-driven date granularity  
⚠️ **Overlapping charts:** Floating positioning can be finicky for exact alignment  
⚠️ **Tab-like interface:** Native tabs don't exist, required creative parameter + filter logic  

### **Future Enhancements:**
💡 **Dashboard 3:** Customer & Product Deep Dive (RFM segmentation, cohort analysis)  
💡 **Seller Performance:** Scorecard with weighted metrics (revenue + on-time + reviews)  
💡 **Predictive Analytics:** Forecast delivery times based on category/state/season  
💡 **Mobile Responsive:** Optimize layouts for tablet/phone viewing  

---

## 🎓 Skills Portfolio Summary

This project demonstrates mastery of:

**Tableau Expertise:**
- Advanced calculated fields (LODs, table calculations, parameters)
- Interactive dashboard design (actions, filters, navigation)
- Data storytelling (insight delivery, visual hierarchy)
- Professional formatting (color theory, typography, layout)

**Business Intelligence:**
- KPI selection and monitoring
- Trend analysis and forecasting
- Segmentation and comparative analysis
- Operational metrics vs strategic goals

**Data Engineering Integration:**
- dbt seed files for reference data
- Snowflake cloud warehouse connection
- Data quality and filtering decisions
- Cross-phase data pipeline consistency

---

## 👤 Author

**Shreyeshi Somya**  
MS Business Analytics (UCLA) | BS Computer Science (VIT Vellore)  
Enterprise Analytics @ Peloton

**Portfolio:** [Your Website](#)  
**LinkedIn:** [Your Profile](#)  
**GitHub:** [analytics-pipeline](https://github.com/yourusername/analytics-pipeline)  

---

## 📚 Resources

**Phase 1 (dbt Pipeline):** [../phase1-dbt-platform/](../phase1-dbt-platform/)  
**Dataset Source:** [Brazilian E-commerce on Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)  
**Tableau Public Profile:** [Your Profile](#)  

---

*Phase 2 Complete | Dashboards 1 & 2 Published*  
*Last Updated: February 2026*
