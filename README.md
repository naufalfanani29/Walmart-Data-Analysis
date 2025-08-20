# 🛒 Walmart Sales Analysis - MySQL Project

This project analyzes the sales dataset of a Walmart store using MySQL. The analysis includes data cleaning, feature engineering, and exploratory data analysis (EDA) to gain insights into sales performance, customer behavior, product performance, and other business metrics.

---

## 📁 Dataset Information

The dataset consists of **17 columns and 1,000 rows**. Below is a brief description of the columns:

| Column                   | Description                                      | Data Type     |
| ------------------------|--------------------------------------------------|---------------|
| invoice_id              | Sales transaction ID                             | VARCHAR(30)   |
| branch                  | Store branch                                      | VARCHAR(5)    |
| city                    | City location of the branch                      | VARCHAR(30)   |
| customer_type           | Type of customer                                  | VARCHAR(30)   |
| gender                  | Customer's gender                                 | VARCHAR(10)   |
| product_line            | Type of product sold                              | VARCHAR(100)  |
| unit_price              | Price per unit of product                         | DECIMAL(10,2) |
| quantity                | Quantity purchased                                | INT           |
| VAT                     | Value-added tax                                   | FLOAT(6,4)    |
| total                   | Total transaction value                           | DECIMAL(10,2) |
| date                    | Transaction date                                  | DATE          |
| time                    | Transaction time                                  | TIMESTAMP     |
| payment_method          | Payment method used                               | VARCHAR       |
| cogs                    | Cost of goods sold                                | DECIMAL(10,2) |
| gross_margin_percentage | Gross margin percentage                           | FLOAT(11,9)   |
| gross_income            | Gross income                                      | DECIMAL(10,2) |
| rating                  | Customer rating                                   | FLOAT(2,1)    |

---


---

## 🔧 Data Wrangling

### 🔍 Duplicate Check
Used `ROW_NUMBER()` window function to detect duplicate rows based on all columns.

### ❌ Null Value Check
Checked all columns for `NULL` values using `OR` conditions.

### 🔲 Blank Value Check
Detected any blank (empty string) values in categorical fields like `invoice_id`, `branch`, `city`, etc.

### ✅ Category Cleaning
Ensured there were no typos or anomalies in categorical columns:
- `branch`, `city`, `customer_type`, `product_line`, `payment`

---

## ⚙️ Feature Engineering

### 🕒 Add `time_of_day`
Created a new column (`time_of_day`) based on `time`:
- Morning: 06:00 – 11:59
- Afternoon: 12:00 – 17:59
- Evening: 18:00 – 21:00

### 📆 Date Conversion
- Converted `date` from string to `DATE` type.
- Extracted `month_name` and `day_name` using `STR_TO_DATE()` and `MONTHNAME()`, `DAYNAME()`.

### 📅 Add `day_type`
Categorized `day_name` as:
- `Weekend`: Saturday, Sunday
- `Weekdays`: Monday–Friday

---

## 📊 Exploratory Data Analysis (EDA)

### 🌍 General Info
- Number of unique cities in data.
- Number of unique product lines.
- Distribution of cities and product lines.

### 🧾 Sales Analysis
- **Top 3 Most Used Payment Methods**  
- **Most Sold Product Line by Quantity**
- **Monthly Revenue Trend**
- **Month with Highest COGS**
- **Product Line with Highest Revenue**
- **City with Highest Revenue**
- **Product Line Contributing Highest VAT**
- **Product Line Performance Classification**: Good or Bad compared to average revenue.
- **Branch Performance Compared to Average Quantity Sold**

### 👫 Gender-Based Insights
- Most frequently bought product line per gender using `RANK()`.
- Average rating per product line.

### 🕑 Time-Based Sales
- Total sales by day and time of day.
- Revenue by customer type.
- VAT contribution by city and customer type.

---

## 👥 Customer Behavior

### 🎯 Customer Types
- Number of unique customer types.
- Transaction count by customer type.
- Total quantity purchased by customer type.

### 🔄 Payment Methods
- Number of unique payment methods.

### 👤 Gender Analysis
- Most frequent gender of customers.
- Gender distribution by branch.

---

## ⭐ Rating Analysis

### ⏱ Time of Day
- Time of day with highest number of ratings.
- Time of day with highest ratings per branch.

### 📅 Weekly Ratings
- Best average rating by day of the week.
- Best average rating per day and per branch.

---

## ✅ Conclusion Highlights

- The **most sold product line** is revealed along with top contributing product lines in revenue and VAT.
- **Afternoon** is the most profitable time of day.
- **Branch and city performance** identifies which areas to focus marketing and inventory.
- **Customer type segmentation** shows which customer type contributes more to sales and tax.
- **Rating patterns** indicate optimal times and days for customer satisfaction.

---

## 🛠️ Tools Used

- MySQL 8.0.42.0.

- SQL: DDL, DML, Window Functions, CTE, Aggregations

---

## 📌 Project Structure

- `sales` → raw dataset
- `sales_step1` → added `time_of_day`
- `sales_step2` → added date conversion, `month_name`, `day_name`

---

## 📅 Author

**Data Analyst:** *Naufal Nur Fanani*  
**Project:** Walmart Sales EDA  
**Tools:** SQL (MySQL)  


