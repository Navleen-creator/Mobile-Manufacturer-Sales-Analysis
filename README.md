# Mobile-Manufacturer-Sales-Analysis
This project involves a comprehensive analysis of a retail mobile database containing millions of transactions across various manufacturers and global locations. The goal was to extract actionable business intelligence regarding customer purchasing behavior, manufacturer performance, and year-over-year growth trends.

**Technical Toolkit**
Database: MS SQL Server
Advanced SQL Techniques: * Common Table Expressions (CTEs): Used for multi-stage analysis and isolating top performers.
Window Functions: Applied LAG() to calculate year-over-year (YoY) percentage changes in customer spending.
Aggregation & Filtering: Extensive use of GROUP BY, HAVING, and complex JOIN logic across 4+ tables.
Set Logic: Implemented LEFT JOIN with NULL checks to identify market entry/exit trends.

**Database Schema Overview**
The analysis was performed on a Star Schema consisting of:
FACT_TRANSACTIONS: Sales data (Price, Quantity, Date).
DIM_MODEL: Product details (Model name, Unit Price).
DIM_MANUFACTURER: Brand details.
DIM_LOCATION: Geographic data (State, Zip Code, Country).
DIM_CUSTOMER: Demographics.


**Below are highlights of the analytical tasks performed:**
**Category**                **Analysis Performed**                                                                     **SQL Highlight **
Market Share              Identified the top state in the US for Samsung sales.                                        Multi-table Joins
Product Lifecycle         Found models that maintained Top 5 status for 3 consecutive years (2008–2010)                Sequential CTEs
Competitive Intelligence  Identified manufacturers that entered the market in 2010 (sold in 2010 but not 2009)         Left Anti-Join
Customer Retention        Calculated YoY percentage change in spend for the top 100 high-value customers               LAG() Window Function


**Strategic Insights (Outcomes):**
Consistency is Key:Identified specific mobile models that remained in the Top 5 by quantity for three years straight, highlighting product longevity and consumer trust.
Market Growth Analysis:By calculating the Percentage Change in Spend, I identified high-value customers whose spending is increasing, providing a segment for targeted loyalty programs.
Brand Competition:The analysis of the 2nd Top Sales Manufacturer for 2009 vs. 2010 revealed shifts in market competition, showing which brands are gaining or losing ground.
Inventory Optimization:By identifying the "Cheapest Cellphone" vs. "Top Selling Models," the analysis helps stakeholders balance low-cost acquisition models with high-margin premium models.

How to Navigate this Repository
   SQLQuery2.sql : Contains the  full code along with  the business questions.















