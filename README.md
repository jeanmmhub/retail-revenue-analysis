# Retail Revenue Analysis
## Introduction
This project analyzes retail transaction dataset to identify key revenue drivers, customer behavior patterns, and product concentration using SQL and Power BI.
## &nbsp;
## Key Insights (Quick View)
- Revenue peaks during Sept - Nov (+73% vs baseline)
- Growth driven by customer expansion, not spending increase
- Top 20% of products generate **~79.5% of revenue**
- Repeat customers (10+ orders) drive majority of order volume
## &nbsp;
## Tools Used
- SQL (PostgreSQL)
- Power BI
- Microsoft Excel (Data Staging)
## &nbsp;
## Executive Summary

This analysis examines a 25-month retail transaction dataset to identify the key drivers of revenue performance, customer behavior, and product contribution.

Revenue is generated almost entirely from core merchandise sales, with non-merchandise transactions functioning primarily as financial adjustments rather than independent revenue sources.

Revenue exhibits a strong seasonal pattern, increasing by approximately **73% during the September–November peak period,** while remaining relatively stable throughout the rest of the year. This growth is driven primarily by an expansion in active customers, while purchasing behavior—measured through order frequency and revenue per customer—remains largely unchanged.

Product performance is highly concentrated, with approximately **20% of SKUs generating ~79.5% of total revenue**, indicating that overall performance depends on a relatively small subset of high-impact products.

Customer activity is sustained primarily by repeat purchasing behavior, with high-frequency customers contributing the majority of total order volume, while one-time buyers contribute minimally to overall transactions.

Overall, the business is characterized by **stable baseline demand, strong seasonal expansion driven by customer participation, and structural reliance on high-performing products**, with consistent purchasing behavior across the observed period.
## &nbsp;
## Methodology
### Dataset
The analysis uses the **Online Retail Transaction Dataset**, which contains
historical transaction records from a UK-based retail company.
**Key attributes include:**
- Invoice ID
- StockCode (product identifier)
- Description
- Quantity
- InvoiceDate
- UnitPrice
- CustomerID
- Country

The dataset contains approximately **1067371 transaction rows**
representing retail purchases between **2009–2011.**

**SOURCE: https://www.kaggle.com/datasets/mashlyn/online-retail-ii-uci**
## &nbsp;
### Data Cleaning & Preparation

Initial preprocessing focused on ensuring transaction consistency and removing potential duplication.
**Key steps included:**
- Deduplicating transactional records to construct a **clean canonical event table**
- Standardizing product identifiers using **UPPER(TRIM(stockcode))**
- Filtering invalid or missing values in key transactional fields
- Separating identifiable customers from transactions without customer IDs for behavioral analysis

These steps produced a cleaned transaction table **fact\_event\_line\_clean** used for all subsequent analysis.
## &nbsp;
### Data Modeling

A simple analytical data model was constructed to support revenue decomposition.
**The primary tables include:**

- **fact\_event\_line\_clean\_mat**
  - Canonical event table containing invoice-level transactions, quantities, prices, timestamps, customer identification, and normalized product codes.
 
- **dim\_product\_mat**
  - Product dimension used to classify stock codes into:
  - structural categories (merchandise vs operational codes)
  - economic categories (core merchandise, platform fees, bad debt, shipping income, etc.)

This structure allowed transaction-level revenue to be aggregated across different analytical dimensions.
## &nbsp;
### Analytical Framework
The analysis was conducted across three primary analytical perspectives:

#### Seasonality
Seasonality was analyzed using monthly trends rather than fiscal quarters, as the dataset revealed a peak demand window between September and November that does not align perfectly with standard calendar quarter definitions.

#### Revenue Structure
Revenue was decomposed by **economic category** to understand the contribution of merchandise sales versus operational adjustments such as platform fees, bad debt, and manual corrections.

#### Product Performance
Product-level revenue distribution was evaluated using **Pareto analysis** to measure concentration across the merchandise catalog.

#### Customer Behavior
Customer activity was examined through three complementary metrics:
- **Customer concentration** – revenue distribution across identifiable customers
- **Repeat purchase behavior** – order frequency per customer
- **Monthly active customers (MAC)** – changes in active customer participation over time

Transactions without customer identifiers were excluded from customer-level behavioral metrics to prevent distortion of concentration measurements.
## &nbsp;
#### Key Metrics
- **Revenue**
  - SUM(quantity × price)
- **Monthly Active Customers (MAC)**
  - COUNT(DISTINCT customerid) per month
- **Orders per Customer**
  - COUNT(DISTINCT invoiceid) / COUNT(DISTINCT customerid)
- **Revenue per Customer**
  - SUM(quantity × price) / COUNT(DISTINCT customerid)
- **Product Pareto Contribution**
  - Cumulative share of total merchandise revenue ordered by SKU revenue.

These metrics were used to evaluate seasonality, purchasing intensity, and revenue concentration across the product catalog and customer base.
## &nbsp;
## Key Findings
### Revenue Structure
- Core merchandise generates nearly all net revenue.
- Non-merchandise categories (platform fees, bad debt, manual adjustments) primarily function as financial offsets and contribute minimally to total revenue.

### Seasonality
- Revenue increases by approximately 73% during the **September–November period** compared to other months.
- Revenue outside peak periods remains relatively stable, fluctuating within a range of approximately **−3% to +8%.**

### Product Concentration
- Approximately **20% of the 5,070 SKUs generate ~79.5%** of total revenue.
- The top 10 products contribute **~7.6% of total revenue.**

### Customer Behavior Remains Stable Across Seasonal Periods
#### Customer Concentration
- Transactions without customer identifiers account for **~13.6% of total revenue.**
- Among identifiable customers:
  - Top 10 customers contribute **~13.42% of revenue**
  - Top 20% of customers contribute **~66.9% of revenue**
#### Repeat Purchase Behavior
- Customers with **10 or more purchases account for ~63% of total orders.**
- One-time buyers contribute approximately **3.26% of total order volume.**
#### Customer Activity
- Monthly active customers (MAC) average approximately **1,080**, with fluctuations of **+631 / −393** across the observed period.
- Orders per customer average **~1.65**, with variation of **+0.22 / −0.31.**
- Revenue per customer averages **~595.85**, with variation of **+117.94 / −122.86.**
## &nbsp;
## Analytical Insights
### Revenue Growth is Driven by Customer Expansion
Revenue growth is primarily explained by changes in the number of active customers rather than changes in purchasing behavior.

During peak periods, total revenue increases alongside customer count, while individual-level metrics—such as order frequency and revenue per customer—remain stable. This reflects a demand pattern where growth is driven by increased participation rather than higher spending per customer.

### Revenue is Structurally Concentrated in High-Performing Products
Revenue is unevenly distributed across the product catalog, with a subset of SKUs contributing a disproportionate share of total revenue.

This creates a structural dependence on high-performing products, where overall revenue performance is closely tied to the availability and performance of a limited number of items.

### Customer Revenue is Moderately Concentrated but Broadly Distributed
Customer revenue distribution reflects a balance between concentration and diversification.

While higher-value customers contribute a significant portion of revenue, purchasing activity remains distributed across a wider base of customers, preventing reliance on a small number of buyers.

### Transaction Volume is Sustained by Repeat Customers
Order activity is primarily driven by customers with frequent purchase histories, while one-time buyers contribute minimally to overall transaction volume.

However, without cohort-level analysis, it is not possible to determine whether this reflects low retetion or natural distribution of purchasing frequency.

### A Portion of Customer Activity Remains Unobservable
A share of transaction cannot be linked to identifiable customers, limiting visibility into customer-level behavior.

Thie introduces uncertainty in measuring customer concentration, repeat puchasing patterns, and long-term customer acitivity.
## &nbsp;
## Business Implications
- **Prioritize customer acquisition leading into peak periods.**

  Revenue growth is primarily driven by increase in active customers, making pre-season customer activation and acquisition critical to maximizing peak performance.

- **Ensure availability and visibility of high-performing products.**

  A disproportionate share of revenue depends on a subset of SKUs, making inventory planning, stock reliability, and product positioning essential to sustaining revenue.

- **Strengthen customer retention to sustain transaction volume.**

  A large share of order activity is generated by repeat customers, making retention and re-engagement key to maintaining consistent transaction flow.

- **Maintain a balanced customer strategy across segments.**

  Revenue is supported by both high-value customers and a broad base of buyers, requiring dual approach that supports key contributors while maintaining overall customer diversity

- **Focus long-term growth on expanding the active customer base.**

  Stable purchasing behavior indicated limited organic increase in per-customer spending, making customer growth the primary lever for sustained revenue expansion.

- **Improve customer identification to enhance analytical accuracy.**

  A portion of transactions cannot be linked to identifiable customers, limiting visibility into behavior and reducing the precision of customer-level insights.
## Insights & Visualization
The following visualization provide supporting evidence for the key findings and analytical insights, illustrating how revenue, customer activity, and product performance interact across time.
### **Revenue Performance Overview**
Revenue follows a clear seasonal pattern, with peak periods concentrated between September and November, while remaining relatively stable during off-peak months
![Dashboard](visuals/dashboard.jpg)

### **Drivers of Seasonal Revenue Growth (Indexed Analysis)**
Customer growth increases significantly during peak periods, while purchasing behavior remains stable, confirming that revenue growth is driven by customer expansion.
![Indexed Analysis](visuals/mac_analysis.jpg)

### **Customer Segmentation and Revenue Stucture**
Transaction volume is dominated by high-frequency repeat customers, while revenue is primarily generated from core merchandise categories.
![Segmentation and EC](visuals/segmentation_and_ec.jpg)

## Technical Notes
### Stock Code Normalization
Product stock codes were normalized using: *UPPER(TRIM(stockcode))*
This step ensured consistent product identification by removing trailing spaces and standardizing letter casing. Without normalization, identical product codes with inconsistent formatting could appear as separate SKUs and distort aggregation results.
### Structural vs Economic Classification
Product codes were first categorized using **structural classification** based on their format (numeric-first merchandise codes vs alphabetic operational codes).
This step allowed the analysis to isolate operational transaction codes before defining **economic categories** such as:
- core merchandise
- platform fees
- bad debt
- manual adjustments
- shipping income

Separating structural and economic classification ensured that operational codes were correctly identified before revenue interpretation.

### Deduplicated Event Table
The analysis was performed using a cleaned canonical event table *fact\_event\_line\_clean\_mat* derived from the original dataset.
This table represents deduplicated transactional records and was used as the primary fact table for all revenue calculations.

### Anonymous Customer Handling
Transactions without identifiable *customerid* values account for approximately **13.6% of total revenue**.
These transactions were included in revenue analysis but **excluded from customer-level behavioral metrics** (such as customer concentration and repeat purchase analysis) to prevent distortion of customer-level results.

### Operational Categories in Product Analysis
Operational transaction categories (platform fees, bad debt, adjustments, etc.) were excluded from product-level Pareto analysis because they do not represent merchandise sales.
Pareto analysis therefore focuses only on **core merchandise revenue**, allowing product concentration to be evaluated independently from operational financial adjustments.

