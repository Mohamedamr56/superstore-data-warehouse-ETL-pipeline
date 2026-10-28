# End-to-End Superstore Data Warehouse: Python ETL Pipeline & Advanced T-SQL Analytics

End-to-End Data Warehouse Pipeline: Automated ETL using Python & Pandas, Star Schema Dimensional Modeling, and Advanced Business Analytics in Microsoft SQL Server."




## 📁 Repository Structure

- `Sample - Superstore.csv`: Raw transactional dataset used as the source for the ETL pipeline.
- `Superstore_ETL.ipynb`: Jupyter Notebook containing data profiling, data cleaning, star schema dimensional modeling, and programmatic DDL execution using SQLAlchemy.
- `superstore_analytics.sql`: Production-grade T-SQL scripts including views, CTEs, dynamic stored procedures, and analytical window functions.
- `README.md`: Complete project documentation, architecture diagram, and business insights.

### 1. Data Profiling, Exploration & Cleaning

<img width="777" height="888" alt="1" src="https://github.com/user-attachments/assets/cb7b9c45-df2d-48d0-aa53-b0d26f4993b8" />

- **Data Profiling & Granularity Checks:** Profiled primary entity identifiers (`Product ID`, `Customer ID`) using aggregation and `nunique()` to identify many-to-one inconsistencies across naming and segmentation hierarchies before modeling.
- **Data Quality & Integrity Verification:** Evaluated missing values (`isnull`), duplicate records, and validated critical business logic—such as ensuring chronological order sequence where `Ship Date >= Order Date`.
- **Standardization & Text Preprocessing:** Standardized structural column headers to clean `snake_case`, trimmed leading/trailing whitespace across all categorical text attributes, and resolved leading-zero truncation issues in `Postal Code` using `.str.zfill(5)`.<img width="795"

  ### 2. Dimensional Modeling & Fact Table Construction (ETL)



<img width="795" height="886" alt="photo_5983335098184568938_y (1)" src="https://github.com/user-attachments/assets/74291cd4-7ef3-4d01-bcb0-ca542a65b50e" />


  - **Date Dimension Engineering:** Generated a comprehensive `dim_date` table extracted from transaction date ranges, engineering analytical date attributes (calendar hierarchy, ISO weeks, day/month names, and weekend indicators) with an integer surrogate key (`YYYYMMDD`).
- **Surrogate Key Generation:** Transformed denormalized flat data into distinct dimensional entities (`dim_product`, `dim_customer`, `dim_location`, `dim_ship_mode`) by deduplicating business attributes and injecting synthetic surrogate primary keys.
- **Fact Table Synthesis (Role-Playing Dimensions):** Built the centralized `fact_table` using sequential left-joins against dimension tables on business keys, mapping surrogate keys while implementing the date dimension as a role-playing dimension for both `order_date_key` and `ship_date_key`.

- ### 3. Database Connection & Automated DDL Schema Deployment

- <img width="705" height="887" alt="photo_5983335098184568936_y" src="https://github.com/user-attachments/assets/fb4f4538-2da3-41f9-90d2-9eb9cd8736ac" />

- **Database Engine Connectivity:** Established a programmatic connection to Microsoft SQL Server (`SuperstoreCR`) using `SQLAlchemy` and `pyodbc` with Windows Authentication, utilizing `fast_executemany=True` for optimized query execution and bulk transaction throughput.
- **Automated DDL Schema Execution:** Programmatically deployed the Data Definition Language (DDL) scripts directly from Python to create physical dimension tables (`dim_product`, `dim_customer`, `dim_location`, `dim_ship_mode`).
- **Constraint & Integrity Enforcement:** Configured surrogate primary keys and defined explicit data types (`VARCHAR`, `INT`) with `NOT NULL` constraints to guarantee data integrity across all dimensions.

- ### 4. Fact Table DDL & Relational Constraints Enforcement

- <img width="684" height="892" alt="photo_5983335098184568937_y" src="https://github.com/user-attachments/assets/cf0b5bdc-cac9-421a-96f9-90ab327e6498" />

- **Date Dimension Schema Definition:** Defined `dim_date` with appropriate memory-efficient data types (`SMALLINT`, `TINYINT`, `BIT`) to store full temporal attributes and flag weekend transactions.
- **Fact Table Architecture:** Designed `dbo.fact_table` with business metrics (`sales`, `quantity`, `discount`, `profit`) utilizing high-precision decimal formats (`DECIMAL(12,4)`, `DECIMAL(5,4)`) to avoid rounding errors during financial aggregations.
- **Foreign Key Constraints Enforcement:** Enforced referential integrity across the Star Schema by establishing explicit Foreign Key constraints linking `fact_table` to all dimensional surrogate keys, including dual role-playing keys for order and shipment dates.
- **Automated DDL Execution:** Executed all schema definition scripts within a transactional connection (`engine.begin()`) in SQLAlchemy to guarantee safe and complete table provisioning.

- ### 5. Physical Database Diagram & Star Schema Architecture (SSMS)

- <img width="1280" height="845" alt="photo_5983335098184568935_y" src="https://github.com/user-attachments/assets/500b1c8a-5bea-4f0c-9880-071e6e25db4e" />

- **Star Schema Dimensional Design:** Implemented a pure Star Schema architecture centered around `fact_table` with five surrounding dimension tables (`dim_customer`, `dim_product`, `dim_location`, `dim_ship_mode`, `dim_date`).
- **Referential Integrity & Relationships:** Established clean One-to-Many (`1:N`) relationships enforced by Foreign Key constraints, linking each dimension's surrogate primary key to the corresponding foreign key in the central fact table.
- **Role-Playing Dimension Implementation:** Illustrated dual independent relational links between `dim_date` and `fact_table`, mapping the calendar dimension concurrently to both `order_date_key` and `ship_date_key` without duplicate physical storage.


### Advanced SQL: Database Views, CTEs & Stored Procedures



<img width="1207" height="943" alt="photo_5983335098184568942_y" src="https://github.com/user-attachments/assets/193d3747-daac-4ce4-b36f-7a754a0bbc72" />


- **Modular Data Aggregation (Views):** Implemented `dbo.VW_Category_Performance` to encapsulate multi-table aggregations (orders, total revenue, and gross profit) across product categories and sub-categories for reusable analytics.
- **Hierarchical Profitability Analysis (CTEs & Window Functions):** Leveraged Common Table Expressions (CTEs) combined with `ROW_NUMBER() OVER (PARTITION BY ...)` to isolate the most profitable sub-category within each product category.
- **Dynamic Key Performance Metrics (Stored Procedures):** Developed `dbo.Get_Customer_KPIS` taking dynamic input parameters (`@CustomerID`) to calculate customer metrics: order frequency, total spend, profit margin calculation safely handled against division-by-zero using `NULLIF`, and customer segmentation using `CASE WHEN` logic.

### 6. Advanced SQL: Database Objects & Business Logic Automation



<img width="1010" height="970" alt="photo_5983335098184568943_y" src="https://github.com/user-attachments/assets/c51d260c-2788-4b55-869c-14775cc8cb19" />


- **Modular Data Aggregation (Views):** Implemented `dbo.VW_Category_Performance` to encapsulate multi-table aggregations (orders, revenue, and gross profit) across product categories and sub-categories for reusable analytical querying.
- **Hierarchical Profitability Analysis (CTEs & Window Functions):** Leveraged Common Table Expressions (CTEs) combined with `ROW_NUMBER() OVER (PARTITION BY ...)` to isolate the most profitable sub-category within each product category.
- **Parameterized Analytical Procedures (Stored Procedures):** Developed `dbo.Get_Customer_KPIS` taking dynamic input parameters (`@CustomerID`) to compute end-to-end customer metrics: total spend, order frequency, margin calculation handled safely with `NULLIF`, and automatic value classification via `CASE WHEN` logic.


### Customer Segmentation & Benchmark Analytics (Partitioning & Subqueries)


<img width="982" height="971" alt="photo_5983335098184568940_y" src="https://github.com/user-attachments/assets/4ccfdba1-d5aa-43be-aab8-ea9bacec8a51" />



- **Logistics & Fulfillment Performance:** Evaluated shipping channels by aggregating total revenue and gross profit across shipping modes (`dim_ship_mode`) to identify the most cost-effective fulfillment methods.
- **Segment-Level Customer Ranking (`PARTITION BY`):** Implemented a Common Table Expression (CTE) utilizing `RANK() OVER (PARTITION BY segment ORDER BY SUM(sales) DESC)` to dynamically isolate the top 3 highest-spending customers within each distinct market segment.
- **Dynamic Business Benchmarking (Aggregated Subqueries):** Applied nested subqueries within the `HAVING` clause to filter out product categories generating total sales strictly above the overall cross-category average benchmark.


## Technical Stack & Skills Demonstrated

| Domain | Technologies & Concepts |
| :--- | :--- |
| **Language & Data Processing** | Python, Pandas, NumPy, Data Profiling, Data Cleaning |
| **Database & Modeling** | Microsoft SQL Server (T-SQL), Star Schema, Dimensional Modeling, Surrogate Keys |
| **Data Warehousing & ETL** | SQLAlchemy, pyodbc, Schema Automation (DDL), Role-Playing Dimensions |
| **Advanced SQL Analytics** | Window Functions (`RANK`, `ROW_NUMBER`, `LAG`), CTEs, Subqueries, Stored Procedures, Views |


🔗 **LinkedIn:** [Mohamed Amr](https://www.linkedin.com/in/mohamed-amr-1a122231a/)


- 





