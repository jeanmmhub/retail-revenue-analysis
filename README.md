# Retail Revenue Analysis
## Introduction
This project analyzes retail transaction dataset to identify key revenue drivers, customer behavior patterns, and product concentration using SQL and Power BI
## Key Insights (Quick View)
- Revenue peaks during Sept - Nov (+73% vs baseline)
- Growth driven by customer expansion, not spending increase
- Top 20% of products generate **~79.5% of revenue**
- Repeat customers (10+ orders) drive majority of order volume

## Tools Used
- SQL (PostgreSQL)
- Power BI
- Microsoft Excel (Data Staging)

## Executive Summary

This analysis examines a retail transaction dataset to understand revenue structure, product performance, and customer behavior over a 25-month period. Results show that nearly all net revenue is generated through core merchandise sales, while non-merchandise transactions such as platform fees, bad debt, and manual adjustments primarily function as financial offsets rather than independent revenue sources.

Revenue demonstrates strong seasonal concentration, with seasonal peak window (September–November) generating approximately **73% higher revenue** than other seasonal quarters, while off-season period maintain relatively stable performance. Further customer activity analysis indicates that this seasonal surge is primarily driven by **an increase in the number of active customers rather than higher purchasing intensity**, suggesting that peak demand periods expand the customer base rather than changing individual purchasing behavior.

Product performance follows a **Pareto-like distribution**, where roughly **20% of the 5,070 SKUs generate approximately 79.5% of total revenue**, indicating meaningful reliance on a subset of high-performing products. In contrast, customer revenue concentration remains more moderate: among identifiable buyers, the **top 20% customers contribute approximately 66.84% of total revenue**, shows  that revenue distribution is more diverse.

Overall, the analysis shows a retail business characterized by **stable baseline demand, strong seasonal expansion of customer participation, and revenue concentration within a subset of high-performing products**, while purchasing activity remains broadly distributed across a diverse customer base.

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
### Revenue Growth is Driven by Customer Expansion, Not Behavioral Change
Revenue growth is primarily explained by changes in the number of active customers rather than changes in purchasing behavior.

While revenue increases significantly during peak periods, individual-level metrics—such as order frequency and revenue per customer—remain relatively stable over time. This indicates that seasonal performance is driven by increased customer participation rather than higher spending from existing customers.

### Revenue is Structurally Concentrated in High-Performing Products
Revenue distribution across products is uneven, with a small subset of SKUs accounting for a disproportionate share of total revenue.

This concentration indicates that overall business performance is closely tied to the performance of a limited group of high-impact products within a broader catalog.

### Customer Revenue is Moderately Concentrated but Broadly Distributed
Customer revenue distribution shows a balance between concentration and diversification.

While higher-value customers contribute a significant portion of revenue, overall purchasing activity remains distributed across a wider customer base.

### Transaction Volume is Sustained by Repeat Customers
A large share of total order volume is generated by customers with frequent purchase histories.

This indicates that recurring customers play a central role in maintaining transaction activity, while one-time buyers contribute relatively little to overall volume.

### A Portion of Customer Activity Remains Unobservable
A meaningful share of transactions cannot be linked to identifiable customers.

This limits full visibility into customer behavior and introduces uncertainty in customer-level analysis.

## Business Implications
- Merchandise sales constitute the core revenue engine of the business, with operational categories primarily reflecting financial adjustments rather than independent revenue streams. This indicates that overall performance is largely determined by product sales rather than operational services.
- The strong **seasonal revenue concentration during the September–November period** suggests that the business operates within a demand cycle typical of retail or gift-oriented markets, where peak demand periods expand the active customer base rather than increasing purchasing intensity among existing customers.
- Revenue distribution across products shows meaningful concentration, with a relatively small subset of SKUs accounting for a large share of total revenue. This highlights the structural importance of maintaining availability and performance of high-impact products within the catalog.
- Customer revenue distribution shows moderate concentration among identifiable buyers. While higher-value customers contribute a significant share of revenue, overall purchasing activity remains distributed across a broad customer base.
- Repeat purchasing plays a substantial role in sustaining transaction volume, as customers with frequent purchase histories generate the majority of order activity. This indicates that returning customers are an important component of the business’s ongoing demand.
- Customer activity levels remain relatively stable outside seasonal peaks, with consistent order frequency and revenue per customer throughout the year. The Q4 revenue surge is therefore primarily explained by increased participation from additional customers rather than changes in purchasing behavior.
- A meaningful portion of transactions lacks identifiable customer IDs, representing a limitation for customer-level behavioral analysis and suggesting that part of the customer base cannot be directly tracked over time.

## Analytical Insights
### Revenue Growth is Driven by Customer Expansion, Not Behavioral Change
Revenue growth is primarily explained by changes in the number of active customers rather than changes in purchasing behavior.

While revenue increases significantly during peak periods, individual-level metrics—such as order frequency and revenue per customer—remain relatively stable over time. This indicates that seasonal performance is driven by increased customer participation rather than higher spending from existing customers.

## Insights & Visualization
The following visualizations support and validate the key findings outlined above, illustrating how revenue, customer activity, and product performance interact across time.
### **Revenue Performance Overview**
This dashboard summarizes overall revenue trends, customer activity, and revenue concentration.
Revenue exhibits a clear seasonal pattern, with pronounced peaks during the **September–November period**, while maintaining relatively stable performance during off-peak months.
At the same time, Pareto analysis shows that:
- A small proportion of products contributes the majority of revenue
- Customer revenue is more broadly distributed compared to product concentration

Together, these patterns indicate a business with predictable seasonal demand and structural dependence on high-performing products, supported by a relatively diverse customer base.

![Dashboard](visuals/dashboard.jpg)

### **Drivers of Seasonal Revenue Growth (Indexed Analysis)**
To enable direct comparison across metrics with different scales, customer count, orders per customer, and revenue per customer were normalized using an index **(base = 100)**.

The visualization shows a clear divergence between customer growth and purchasing behavior:
- Active customers increase significantly during peak periods
- Orders per customer and revenue per customer remain relatively stable

This confirms that revenue growth is primarily driven by **customer expansion rather than increased purchasing intensity**, indicating that seasonal demand is fueled by higher participation rather than changes in individual behavior.

**Key Insight: Revenue growth is driven by customer expansion**

![Indexed Analysis](visuals/mac_analysis.jpg)

### **Customer Segmentation and Revenue Stucture**
Customer activity and revenue composition reveal two key structural characteristics:
- **Order volume is heavily driven by high-frequency repeat customers**, with customers making 10+ purchases contributing the majority of transactions
- **Revenue is overwhelmingly generated by core merchandise**, while other categories contribute minimally

These findings indicate that the business relies on a combination of:
- Strong **customer retention and repeat purchasing behavior**
- A **product-centric revenue model**, where merchandise sales dominate overall performance

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

