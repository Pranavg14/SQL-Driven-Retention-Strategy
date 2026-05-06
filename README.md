# Decoding Customer Value: A SQL-Driven Retention Strategy

## Project Overview

This project focuses on solving a critical business problem for a Direct-to-Consumer (D2C) fashion brand:

> Is the business building a genuinely loyal customer base, or is it dependent on continuous promotional activity?

Using customer behavioral and transactional data, the project aims to:

* Identify loyal vs discount-driven customers
* Understand what drives customer value
* Analyze category and geography-level trends
* Reduce discount dependency without hurting revenue
* Build a data-backed retention strategy

This project combines:

* Python for data cleaning and feature engineering
* SQL for segmentation and business analysis
* Power BI for dashboarding and storytelling
* Strategic business recommendations

---

# Dataset Description

The dataset contains customer-level behavioral information for approximately 3900 customers.

## Available Columns

| Column Name            | Description                    |
| ---------------------- | ------------------------------ |
| customer_id            | Unique customer identifier     |
| age                    | Customer age                   |
| gender                 | Gender of customer             |
| item_purchased         | Product purchased              |
| category               | Product category               |
| purchase_amount_(usd)  | Purchase value in USD          |
| location               | Customer location              |
| size                   | Product size                   |
| color                  | Product color                  |
| season                 | Purchase season                |
| review_rating          | Customer review score          |
| subscription_status    | Whether customer is subscribed |
| shipping_type          | Shipping preference            |
| discount_applied       | Whether discount was applied   |
| promo_code_used        | Whether promo code was used    |
| previous_purchases     | Number of previous purchases   |
| payment_method         | Payment type                   |
| frequency_of_purchases | Purchase frequency behavior    |

---

# Project Workflow

The project was completed in 5 major stages:

1. Data Cleaning
2. Feature Engineering
3. SQL-Based Customer Segmentation
4. Dashboard Development
5. Strategic Recommendations

---

# Step 1: Data Cleaning (Python)

## Objective

Prepare the raw dataset for analysis by:

* Standardizing column names
* Handling inconsistencies
* Creating analysis-ready variables

---

## 1.1 Import Libraries

```python
import pandas as pd
import numpy as np
```

---

## 1.2 Load Dataset

```python
df = pd.read_csv("Dataset.csv")
```

---

## 1.3 Standardize Column Names

```python
df.columns = (
    df.columns
    .str.strip()
    .str.lower()
    .str.replace(' ', '_')
)
```

---

## 1.4 Rename Complex Columns

```python
df.rename(columns={
    'purchase_amount_(usd)': 'purchase_amount'
}, inplace=True)
```

---

## 1.5 Basic Validation

```python
df.info()
df.head()
df.describe()
```

Purpose:

* Check datatypes
* Identify missing values
* Understand distribution of variables

---

# Step 2: Feature Engineering

## Objective

The dataset does not contain direct loyalty or retention labels.

Therefore, customer intelligence must be constructed using behavioral signals.

This is the most important stage of the project.

---

# 2.1 Promo Dependency Score

## Business Logic

Customers who only buy during discounts are less loyal.

We convert promotional usage into a measurable signal.

```python
df['promo_dependency'] = df['discount_applied'].map({
    'Yes': 1,
    'No': 0
})
```

### Interpretation

| Value | Meaning                       |
| ----- | ----------------------------- |
| 1     | Customer depends on discounts |
| 0     | Customer buys organically     |

---

# 2.2 Frequency Feature

## Business Logic

Frequent purchases indicate stronger engagement.

```python
freq_map = {
    'Weekly': 52,
    'Fortnightly': 26,
    'Monthly': 12,
    'Quarterly': 4,
    'Annually': 1
}


df['frequency'] = df['frequency_of_purchases'].map(freq_map)
```

---

# 2.3 Customer Value Score

## Business Logic

High-value customers:

* Spend more
* Purchase frequently
* Have purchase history

```python
df['value_score'] = (
    df['purchase_amount'] * 0.5 +
    df['previous_purchases'] * 0.3 +
    df['frequency'] * 0.2
)
```

---

# 2.4 Loyalty Score (Version 1)

## Behavioral Loyalty

This definition assumes:

> Loyal customers buy frequently without needing discounts.

```python
df['loyalty_v1'] = (
    df['frequency'] * (1 - df['promo_dependency'])
)
```

---

# 2.5 Loyalty Score (Version 2)

## Value-Based Loyalty

This definition assumes:

> Loyal customers generate high revenue and repeat purchases.

```python
df['loyalty_v2'] = (
    df['purchase_amount'] * df['previous_purchases']
)
```

---

# 2.6 Satisfaction Flag

## Business Logic

Satisfied customers are more likely to return.

```python
df['satisfaction_flag'] = df['review_rating'] > 4
```

---

# 2.7 Value Tier Segmentation

## Business Logic

Customers are segmented into:

* Low Value
* Medium Value
* High Value

```python
df['value_tier'] = pd.qcut(
    df['purchase_amount'],
    q=3,
    labels=['Low', 'Medium', 'High']
)
```

---

# 2.8 Promo Segment Classification

```python
def promo_segment(x):
    if x == 1:
        return 'Discount Buyer'
    else:
        return 'Organic Buyer'


df['promo_segment'] = df['promo_dependency'].apply(promo_segment)
```

---

# Step 3: Export Cleaned Dataset

## Objective

Prepare the engineered dataset for SQL and Power BI.

```python
df.to_csv("customers_cleaned.csv", index=False)
```

---

# Step 4: SQL Analysis

## Objective

Use SQL to answer strategic business questions.

---

# 4.1 High-Value Customer Analysis

```sql
SELECT value_tier,
       COUNT(*) AS customers,
       AVG(purchase_amount) AS avg_spend,
       AVG(loyalty_v1) AS avg_loyalty
FROM customers
GROUP BY value_tier;
```

## Insight

* High-value customers contribute disproportionate revenue
* They also show stronger loyalty behavior

---

# 4.2 Promo Dependency vs Loyalty

```sql
SELECT promo_segment,
       AVG(frequency) AS avg_frequency,
       AVG(loyalty_v1) AS avg_loyalty,
       COUNT(*) AS customers
FROM customers
GROUP BY promo_segment;
```

## Insight

* Organic buyers show stronger retention behavior
* Discount buyers are less stable long-term customers

---

# 4.3 Category-Level Analysis

```sql
SELECT category,
       AVG(loyalty_v1) AS avg_loyalty,
       AVG(purchase_amount) AS avg_spend,
       COUNT(*) AS customers
FROM customers
GROUP BY category
ORDER BY avg_loyalty DESC;
```

## Insight

* Some categories act as entry products
* Others drive long-term retention

---

# 4.4 Geography Analysis

```sql
SELECT location,
       AVG(purchase_amount) AS avg_spend,
       AVG(promo_dependency) AS promo_usage,
       COUNT(*) AS customers
FROM customers
GROUP BY location
ORDER BY avg_spend DESC;
```

## Insight

* High spend + low promo usage indicates strong brand pull
* High promo dependency indicates weak organic demand

---

# 4.5 Payment Behavior Analysis

```sql
SELECT payment_method,
       AVG(loyalty_v1) AS avg_loyalty,
       AVG(purchase_amount) AS avg_spend,
       COUNT(*) AS customers
FROM customers
GROUP BY payment_method;
```

## Insight

* Certain payment behaviors correlate with stronger customer value

---

# Step 5: Power BI Dashboard

## Objective

Build a founder-friendly dashboard focused on strategic decision-making.

---

# Dashboard Components

## 1. Customer Pyramid

### Purpose

Show how revenue is distributed across customer segments.

### Visual

* Bar chart
* Value tiers vs customer count/revenue

---

## 2. Promo Dependency vs Loyalty

### Purpose

Understand which customers require discounts.

### Visual

* Scatter plot
* X-axis: Promo dependency
* Y-axis: Loyalty score

---

## 3. Geographic Opportunity Map

### Purpose

Identify strong organic markets.

### Visual

* Filled map
* Color intensity by spend
* Tooltip with promo dependency

---

## 4. Category Funnel

### Purpose

Understand entry vs retention categories.

### Visual

* Funnel or stacked bar chart
* Categories vs loyalty behavior

---

# Step 6: Business Recommendations

## Objective

Translate analysis into actionable business decisions.

---

# 6.1 Promotional Sunset Plan

## Segment

High-value organic buyers

## Recommendation

Gradually reduce discounts for this segment.

## Why?

These customers already buy without heavy incentives.

## Expected Impact

* Improved margins
* Reduced promotional dependency
* Better profitability

## Risk

Short-term reduction in conversion rates

## Monitoring Metrics

* Repeat purchase rate
* Revenue per customer
* Loyalty score trend

---

# 6.2 High-Value Discount Buyers

## Recommendation

Replace discounts with:

* Loyalty rewards
* Exclusive access
* Membership perks

## Goal

Convert discount-driven behavior into brand-driven behavior.

---

# 6.3 Low-Value Discount Buyers

## Recommendation

Reduce acquisition spend and avoid aggressive discounts.

## Reason

Low profitability and weak retention potential.

---

# Step 7: Ideal Customer Profile

## Characteristics

The ideal customer:

* Purchases frequently
* Has high purchase amount
* Uses fewer discounts
* Gives high ratings
* Shows repeat purchase behavior
* Engages across multiple categories

---

# Final Strategic Conclusion

The business currently shows partial dependency on promotions for customer acquisition and revenue generation.

However, a strong base of high-value organic customers exists.

The long-term opportunity lies in:

* Reducing blanket discounting
* Building loyalty-led engagement
* Focusing on high-value segments
* Expanding in geographies with strong organic demand

The project demonstrates that customer loyalty can be constructed and measured using behavioral signals, even in the absence of direct churn or loyalty labels.

---

# Tools & Technologies Used

| Tool             | Purpose                               |
| ---------------- | ------------------------------------- |
| Python           | Data cleaning and feature engineering |
| Pandas           | Data manipulation                     |
| MySQL            | SQL analysis and segmentation         |
| Power BI         | Dashboard development                 |
| Jupyter Notebook | Workflow execution                    |

---

# Deliverables

The final project includes:

* Cleaned and engineered dataset
* SQL segmentation queries
* Power BI founder dashboard
* Strategic retention playbook
* Executive summary and recommendations

---

# Learning Outcomes

This project demonstrates practical skills in:

* Business analytics
* Customer segmentation
* Feature engineering
* SQL-based analysis
* Dashboard storytelling
* Strategic thinking
* Retention and loyalty analytics

---

# Author

Prepared as part of the Summer Projects '26 consulting and analytics challenge.
