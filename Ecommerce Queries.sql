# Retail Transaction Data Analysis

## Introduction

## This analysis uses a retail transaction dataset containing sales data for a UK-based online retail between 01/12/2010 and 09/12/2011. The dataset includes important information such as invoice numbers, product codes and descriptions, quantities sold, invoice dates, unit prices, customer IDs, and countries of customers.

## The primary objectives of this analysis are to:
## 1. Clean the data and handle any missing or inconsistent entries.
## 2. Perform exploratory data analysis (EDA) to understand the dataset.
## 3. Conduct a time series analysis to identify sales trends over time.
## 4. Calculate RFM (Recency, Frequency, Monetary) metrics for customer segmentation.
## 5. Visualize key findings to derive actionable insights.

-- This query selects the first few rows of the dataset to understand its structure and contents.

SELECT * FROM retail_transactions
LIMIT 10;

## DATA CLEANING
-- This query checks for missing values in the dataset.

SELECT 
    SUM(CASE WHEN CustomerID IS NULL THEN 1 ELSE 0 END) AS MissingCustomerID,
    SUM(CASE WHEN Quantity IS NULL THEN 1 ELSE 0 END) AS MissingQuantity,
    SUM(CASE WHEN InvoiceDate IS NULL THEN 1 ELSE 0 END) AS MissingInvoiceDate,
    SUM(CASE WHEN UnitPrice IS NULL THEN 1 ELSE 0 END) AS MissingUnitPrice
FROM retail_data;

-- This query removes rows with missing CustomerID and converts InvoiceDate to a datetime format.

DELETE FROM retail_data WHERE CustomerID IS NULL;

-- Assuming InvoiceDate is already in datetime format, if not, use this query:
-- UPDATE retail_data SET InvoiceDate = STR_TO_DATE(InvoiceDate, '%d-%m-%Y %H:%i');

-- Removing duplicate rows
DELETE FROM retail_data WHERE InvoiceNo IN (
    SELECT InvoiceNo
    FROM (
        SELECT InvoiceNo, COUNT(*) AS cnt
        FROM retail_data
        GROUP BY InvoiceNo
        HAVING cnt > 1
    ) AS duplicates
);

-- This query modifies the data type
ALTER TABLE retail_transactions 
MODIFY COLUMN CustomerID TEXT,
MODIFY COLUMN UnitPrice DOUBLE,
MODIFY COLUMN InvoiceDate DATETIME,
MODIFY COLUMN InvoiceNo TEXT;

## EXPLORATORY DATA ANALYSIS
-- This query generates summary statistics of the dataset to get an understanding of the data distribution.
-- It also calculates the number of unique customers and the number of sales per country.

-- Summary statistics
SELECT 
    MIN(Quantity) AS MinQuantity,
    MAX(Quantity) AS MaxQuantity,
    AVG(Quantity) AS AvgQuantity,
    MIN(UnitPrice) AS MinUnitPrice,
    MAX(UnitPrice) AS MaxUnitPrice,
    AVG(UnitPrice) AS AvgUnitPrice
FROM retail_data;

-- Unique customers
SELECT COUNT(DISTINCT CustomerID) AS UniqueCustomers FROM retail_data;

-- Sales per country
SELECT Country, COUNT(InvoiceNo) AS SalesCount
FROM retail_data
GROUP BY Country
ORDER BY SalesCount DESC;

## TIME SERIES ANALYSIS
-- Narrative Summary:
-- This query performs a time series analysis by creating a new column for the month and year of each transaction.
-- It then calculates the total quantity of items sold per month to identify sales trends over time.

-- Monthly sales
SELECT 
    DATE_FORMAT(InvoiceDate, '%Y-%m') AS InvoiceMonth, 
    SUM(Quantity) AS TotalQuantity
FROM retail_data
GROUP BY InvoiceMonth
ORDER BY InvoiceMonth;

## CUSTOMER SEGMENTATION (RFM ANALYSIS)
-- This query calculates Recency, Frequency, and Monetary (RFM) metrics for each customer.
-- Recency is the number of days since the last purchase, Frequency is the number of transactions,
-- and Monetary is the total amount spent by the customer.

-- Define the reference date
SET @reference_date = '2011-12-10';

-- Calculate RFM metrics
SELECT 
    CustomerID,
    DATEDIFF(@reference_date, MAX(InvoiceDate)) AS Recency,
    COUNT(InvoiceNo) AS Frequency,
    SUM(UnitPrice * Quantity) AS Monetary
FROM retail_data
GROUP BY CustomerID;

## Conclusion

## In this analysis, we have explored a retail transaction dataset to uncover insights into customer behavior and sales trends. Here are the key takeaways:

## 1. **Data Cleaning**: Successfully handled missing values, corrected data types, and removed duplicates to prepare the dataset for analysis.
## 2. **Exploratory Data Analysis**: Generated summary statistics and identified key metrics such as the number of unique customers and sales distribution across countries.
## 3. **Time Series Analysis**: Identified monthly sales trends, which can help in understanding seasonality and planning for inventory and marketing.
## 4. **Customer Segmentation**: Calculated RFM metrics to segment customers based on their recency, frequency, and monetary value, providing a foundation for targeted marketing strategies.
## 5. **Visualizations**: Created visual representations of sales trends and customer segmentation to aid in decision-making and presenting insights to stakeholders.

## This analysis provides a comprehensive overview of the retail transactions and can be extended further for more advanced analytics and predictive modeling.
