# 🛒 Zepto Inventory & Pricing Analytics

![SQL](https://img.shields.io/badge/SQL-MySQL_8.0-blue) ![Power BI](https://img.shields.io/badge/Power_BI-Visualization-yellow) ![Status](https://img.shields.io/badge/Status-Complete-success)

> **End-to-end data analytics project analyzing 10,000+ product SKUs to optimize inventory management, pricing strategy, and revenue forecasting for a quick-commerce grocery platform**

---

## 📋 Table of Contents

- [Problem Statement](#-problem-statement)
- [Project Objectives](#-project-objectives)
- [Dataset Overview](#-dataset-overview)
- [Tools & Technologies](#%EF%B8%8F-tools--technologies)
- [SQL Workflow & Analysis](#-sql-workflow--analysis)
- [Key Business Insights](#-key-business-insights)
- [Strategic Recommendations](#-strategic-recommendations)
- [Deliverables](#-deliverables)


---

## 🎯 Problem Statement

Quick-commerce platforms like Zepto operate in highly competitive, thin-margin environments where **pricing precision**, **inventory availability**, and **operational efficiency** directly impact profitability. The business faces several critical challenges:

### **Business Challenges:**
1. **Revenue Leakage** – High-value products frequently go out of stock, resulting in lost sales opportunities
2. **Discount Inefficiency** – Unclear understanding of which categories require aggressive discounting vs. those that maintain demand without promotions
3. **Inventory Imbalance** – Heavy, low-margin categories consume warehouse space while high-margin essentials remain understocked
4. **Pricing Opacity** – Lack of unit-level pricing insights (price per gram) prevents value-based bundling and promotional strategies
5. **Category Performance Gaps** – Inability to identify which product categories drive revenue vs. those that drain logistics resources

### **The Core Question:**
**How can Zepto optimize its pricing, discounting, and inventory allocation strategies to maximize revenue while minimizing stockouts and operational costs?**

---

## 🚀 Project Objectives

This project delivers **data-driven intelligence** to address the above challenges through:

### **Primary Goals:**
✅ **Clean and normalize** raw product data to ensure analytical accuracy  
✅ **Analyze pricing elasticity** across categories to identify optimal discount levels  
✅ **Quantify revenue impact** of stockouts in high-value product segments  
✅ **Optimize inventory allocation** by balancing revenue contribution vs. logistics weight  
✅ **Develop actionable KPIs** for inventory health, pricing efficiency, and category performance  

### **Business Impact:**
- **Revenue Recovery** – Reduce stockout-driven losses in premium product categories
- **Margin Improvement** – Preserve profitability in inelastic demand segments
- **Operational Efficiency** – Align warehouse logistics with revenue-generating capacity
- **Strategic Clarity** – Enable category-specific pricing and stocking policies

---

## 📊 Dataset Overview

| **Attribute**              | **Description**                                                      | **Data Type**       |
|----------------------------|----------------------------------------------------------------------|---------------------|
| `sku_id`                   | Unique product identifier                                             | INTEGER (Primary Key) |
| `category`                 | Product category (e.g., Cooking Essentials, Munchies, Personal Care) | VARCHAR(120)        |
| `name`                     | Product name                                                          | VARCHAR(150)        |
| `mrp`                      | Maximum Retail Price (before discount)                                | NUMERIC(8,2)        |
| `discountPercent`          | Discount applied (%)                                                  | NUMERIC(5,2)        |
| `discountedSellingPrice`   | Final selling price after discount                                    | NUMERIC(8,2)        |
| `availableQuantity`        | Current stock level                                                   | INTEGER             |
| `weightInGms`              | Product weight (grams) – critical for logistics planning              | INTEGER             |
| `outOfStock`               | Stock availability flag (TRUE = unavailable, FALSE = available)       | BOOLEAN             |
| `quantity`                 | Packaging quantity/unit multiplier                                    | INTEGER             |

**Dataset Size:** 10,000+ SKUs  
**Database Platform:** MySQL 8.0  
**Data Source:** Zepto product catalog (simulated/anonymized)

---

## 🛠️ Tools & Technologies

| **Tool**       | **Purpose**                                                                 |
|----------------|-----------------------------------------------------------------------------|
| **MySQL 8.0**  | Relational database for data storage, cleaning, transformation, and querying |
| **SQL**        | Core analytical engine for aggregations, filtering, and metric computation  |
| **Power BI**   | Interactive dashboard creation for executive-level insights and KPIs        |
| **GitHub**     | Version control and project documentation                                   |

---

## 🔬 SQL Workflow & Analysis

### **Phase 1: Data Ingestion & Schema Design**

**Objective:** Establish a structured, scalable database schema for analytics.

```sql
CREATE TABLE zepto (
    sku_id SERIAL PRIMARY KEY,
    category VARCHAR(120),
    name VARCHAR(150) NOT NULL,
    mrp NUMERIC(8,2),
    discountPercent NUMERIC(5,2),
    availableQuantity INTEGER,
    discountedSellingPrice NUMERIC(8,2),
    weightInGms INTEGER,
    outOfStock BOOLEAN,
    quantity INTEGER
);
```

**Outcome:**  
✔ Proper data types assigned (numeric precision for pricing, boolean for stock flags)  
✔ Primary key constraint ensures SKU-level uniqueness  
✔ Foundation set for complex joins and aggregations

---

### **Phase 2: Data Validation & Quality Audit**

**Objective:** Identify incomplete, inconsistent, or invalid records before analysis.

#### **2.1 Sample Data Inspection**
```sql
SELECT * 
FROM zepto
LIMIT 10;
```

#### **2.2 NULL Value Detection**
```sql
SELECT *
FROM zepto
WHERE name IS NULL
   OR category IS NULL
   OR mrp IS NULL
   OR discountPercent IS NULL
   OR discountedSellingPrice IS NULL
   OR weightInGms IS NULL
   OR availableQuantity IS NULL
   OR outOfStock IS NULL
   OR quantity IS NULL;
```

**Outcome:**  
✔ Identified critical fields requiring non-NULL enforcement  
✔ Ensured no silent data quality issues in revenue calculations

---

### **Phase 3: Data Cleaning & Normalization**

#### **3.1 Remove Invalid Pricing Records**

**Issue:** Products with `MRP = 0` distort revenue metrics and average price calculations.

```sql
DELETE FROM zepto
WHERE sku_id IN (
    SELECT sku_id
    FROM (
        SELECT sku_id FROM zepto WHERE mrp = 0
    ) t
);
```

**Why the subquery?**  
MySQL's safe-update mode prevents direct `DELETE` with `WHERE` on the same table. A derived table workaround ensures compliance.

#### **3.2 Convert Pricing from Paise to Rupees**

**Issue:** Prices stored in paise (1 Rupee = 100 paise) inflated monetary values.

```sql
UPDATE zepto
SET
    mrp = mrp / 100,
    discountedSellingPrice = discountedSellingPrice / 100
WHERE mrp >= 1000;
```

**Outcome:**  
✔ All pricing data normalized to standard rupee denomination  
✔ Prevented inflated revenue reporting in dashboards

#### **3.3 Boolean Stock Flag Validation**

Verified that `outOfStock` correctly reflects:
- `TRUE` → Product unavailable
- `FALSE` → Product available

No transformation required; logical consistency confirmed.

---

### **Phase 4: Exploratory Data Analysis (EDA)**

#### **4.1 Category Distribution**
```sql
SELECT DISTINCT category
FROM zepto
ORDER BY category;
```

**Purpose:** Understand product taxonomy and category breadth for segmentation.

#### **4.2 Inventory Availability Overview**
```sql
SELECT outOfStock, COUNT(sku_id) AS product_count
FROM zepto
GROUP BY outOfStock;
```

**Output Example:**

| outOfStock | product_count |
|------------|---------------|
| FALSE      | 8,742         |
| TRUE       | 1,258         |

**Insight:** ~14% stockout rate indicates moderate inventory pressure.

#### **4.3 Duplicate SKU Detection**
```sql
SELECT name, COUNT(sku_id) AS sku_count
FROM zepto
GROUP BY name
HAVING COUNT(sku_id) > 1
ORDER BY sku_count DESC;
```

**Insight:** Multiple SKUs per product name confirmed (different pack sizes/variants). Product-level aggregation requires name-based grouping.

---

### **Phase 5: Pricing & Discount Intelligence**

#### **5.1 Top Discounted Products**

**Business Question:** Which products offer maximum customer value?

```sql
SELECT DISTINCT name, mrp, discountPercent
FROM zepto
ORDER BY discountPercent DESC
LIMIT 10;
```

**Insight:**  
- Snacks and packaged foods dominate high-discount SKUs
- Suggests **acquisition-driven discounting** to build basket size

#### **5.2 Premium Products with Stockouts**

**Business Question:** Are we losing revenue on high-value items?

```sql
SELECT DISTINCT name, mrp
FROM zepto
WHERE outOfStock = TRUE
  AND mrp > 300
ORDER BY mrp DESC;
```

**Insight:**  
- Premium oils and household essentials frequently out of stock
- Direct revenue loss in **inelastic demand** categories

#### **5.3 High-MRP, Low-Discount Products**

**Business Question:** Which products maintain demand without promotions?

```sql
SELECT DISTINCT name, mrp, discountPercent
FROM zepto
WHERE mrp > 500
  AND discountPercent < 10
ORDER BY mrp DESC, discountPercent DESC;
```

**Insight:**  
- Cooking oils and health products show **price inelasticity**
- Minimal discounting required → higher margin preservation opportunity

---

### **Phase 6: Category-Level Revenue Analysis**

#### **6.1 Estimated Revenue by Category**
```sql
SELECT
    category,
    SUM(discountedSellingPrice * availableQuantity) AS total_revenue
FROM zepto
GROUP BY category
ORDER BY total_revenue DESC;
```

**Use Case:** Identifies revenue concentration and guides inventory prioritization.

#### **6.2 Average Discount Behavior by Category**
```sql
SELECT
    category,
    ROUND(AVG(discountPercent), 2) AS avg_discount
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;
```

**Insight:**  
- Perishables require higher discounts (spoilage risk)
- Indulgence categories (snacks/beverages) use discounts for impulse demand

---

### **Phase 7: Unit Economics & Value Analysis**

#### **7.1 Price Per Gram Calculation**

**Business Question:** Which products offer best unit value?

```sql
SELECT DISTINCT
    name,
    weightInGms,
    discountedSellingPrice,
    ROUND(discountedSellingPrice / weightInGms, 2) AS price_per_gram
FROM zepto
WHERE weightInGms >= 100
ORDER BY price_per_gram;
```

**Strategic Application:**  
- Bulk staples show superior unit economics
- Enables **bulk-pack promotion strategies**

#### **7.2 Weight-Based Product Segmentation**
```sql
SELECT DISTINCT
    name,
    weightInGms,
    CASE
        WHEN weightInGms < 1000 THEN 'Light'
        WHEN weightInGms < 5000 THEN 'Medium'
        ELSE 'Bulk'
    END AS weight_category
FROM zepto;
```

**Purpose:** Supports logistics planning and fulfillment cost modeling.

---

### **Phase 8: Inventory Weight & Logistics Analysis**

#### **8.1 Total Inventory Weight by Category**
```sql
SELECT
    category,
    SUM(weightInGms * availableQuantity) AS total_inventory_weight
FROM zepto
GROUP BY category
ORDER BY total_inventory_weight DESC;
```

**Critical Insight:**  
- **Cooking Essentials** and **Munchies** dominate warehouse weight
- High weight ≠ High revenue → potential logistics inefficiency

---

## 💡 Key Business Insights

### **1. Revenue Concentration Is Category-Driven**
A small subset of categories (Cooking Essentials, Munchies, Personal Care) accounts for the majority of estimated revenue. **Implication:** SKU expansion in low-revenue categories has minimal ROI impact.

### **2. Strategic Discounting, Not Blanket Discounting**
- **High discounts:** Perishables, snacks, impulse categories → demand elasticity
- **Low discounts:** Oils, health essentials → demand inelasticity

**Implication:** Zepto uses discounts as a **demand lever**, not a margin sacrifice tool.

### **3. Stockouts Disproportionately Affect High-Value SKUs**
Premium essentials (₹300+ MRP) show frequent stockouts despite low discounting. **Implication:** Lost revenue occurs in the most profitable segments.

### **4. Bulk Products Improve Unit Economics**
Products with higher weight-to-price ratios offer better customer value and lower fulfillment costs per unit. **Implication:** Underutilized opportunity for margin and efficiency gains.

### **5. Inventory Weight ≠ Revenue Contribution**
Heavy categories consume disproportionate warehouse space without corresponding revenue generation. **Implication:** Inventory allocation must balance logistics cost vs. revenue potential.

---

## 🎯 Strategic Recommendations

### **✅ 1. Prioritize Stock Availability in High-MRP Essentials**
- Maintain safety stock for premium oils, household staples
- Treat inelastic category stockouts as **high-severity revenue risks**

**Expected Impact:** Immediate reduction in lost revenue opportunities

---

### **✅ 2. Optimize Discount Strategy by Demand Elasticity**
- **Preserve margins** on low-discount, inelastic products
- **Continue aggressive discounts** for perishables and impulse categories (time-bound)

**Expected Impact:** Improved margin efficiency without volume loss

---

### **✅ 3. Leverage High-Discount Products as Acquisition Hooks**
- Bundle high-discount snacks with high-margin essentials
- Promote cross-category basket building in app UX

**Expected Impact:** Higher average order value (AOV) and customer retention

---

### **✅ 4. Expand Bulk SKU Offerings Selectively**
- Focus on high-consumption staples (rice, oils, flour, salt)
- Market as "Best Value" options with unit price transparency

**Expected Impact:** Lower per-unit fulfillment cost + improved customer loyalty

---

### **✅ 5. Align Inventory Allocation with Revenue Density**
- Re-evaluate heavy, low-revenue categories
- Optimize warehouse layout and replenishment frequency accordingly

**Expected Impact:** Reduced logistics overhead and faster inventory turnover

---

## 📦 Deliverables

| **Asset**                     | **Description**                                                          |
|-------------------------------|--------------------------------------------------------------------------|
| **SQL Scripts**               | Complete query library for data cleaning, analysis, and metric generation |
| **Power BI Dashboard**        | Interactive executive dashboard with KPIs and category-level insights    |
| **Documentation (README)**    | This document – comprehensive project walkthrough                        |
| **Business Report**           | Executive summary with strategic recommendations (see above)             |

---

## Dashboard 

<img width="997" height="551" alt="image" src="https://github.com/user-attachments/assets/c931da3e-8cdc-430c-b084-a684bd6348ab" />





<img width="996" height="543" alt="image" src="https://github.com/user-attachments/assets/22836478-f3fd-4b30-b7be-dfaf6e7fe369" />





<img width="841" height="460" alt="image" src="https://github.com/user-attachments/assets/8c08f2e0-3aaf-4f37-9b2d-72fe1770de4a" />



