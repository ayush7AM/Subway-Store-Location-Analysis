# 🥖 Subway USA Location Analytics — MySQL Project

A end-to-end SQL project analyzing 20,000+ Subway restaurant locations across the United States. Built to demonstrate real-world database design and business intelligence skills using MySQL.

---

## 📌 Project Overview

This project uses the [Subway Restaurant Locations USA dataset](https://www.kaggle.com/datasets/thedevastator/subway-the-fastest-growing-franchise-in-the-world) from Kaggle to answer business questions relevant to a supply chain or expansion team:

- Which states are **saturated** vs **untapped**?
- Where are the best **expansion opportunities**?
- Which cities are **high-density** markets?
- Which states should be prioritized as **distribution hubs**?

---

## 🗄️ Database Schema

Three normalized tables following **3NF (Third Normal Form)**:

```
states
├── state_id (PK)
├── state_code
├── state_name
├── region
└── population

cities
├── city_id (PK)
├── city_name
└── state_id (FK → states)

stores
├── store_id (PK)
├── store_name
├── address
├── city_id (FK → cities)
├── zip_code
├── latitude
├── longitude
├── phone
└── date_added
```

**Why 3NF?** Separating states, cities, and stores eliminates data redundancy — changing a state's population only requires updating one row, not thousands.

---

## 📊 Business Analysis Queries

15 SQL queries covering a range of techniques:

| # | Question | Techniques Used |
|---|----------|----------------|
| Q1 | Which states have the most Subway locations? | `GROUP BY`, `RANK()` window |
| Q2 | Store density per 100k population | Derived metrics, `CASE` |
| Q3 | Regional share of national total | Subquery in `SELECT` |
| Q4 | Top 10 cities by store count | 3-table `JOIN` |
| Q5 | Expansion opportunity states | `CTE`, `AVG()` filter |
| Q6 | States with zero Subway stores | `LEFT JOIN` gap analysis |
| Q7 | Cumulative store count by state | `SUM() OVER` running window |
| Q8 | Rank states within each region | `PARTITION BY` |
| Q9 | Top 10% states — supply chain hubs | `NTILE(10)` percentile |
| Q10 | High-density urban markets | `HAVING`, `DENSE_RANK()` |
| Q11 | Each state vs its regional average | CTE + self-join pattern |
| Q12 | ZIP code hotspot clustering | Micro-level `GROUP BY` |
| Q13 | Population-weighted opportunity score | Composite metric, `LOG()` |
| Q14 | Month-over-month store additions | `DATE_FORMAT`, running `SUM` |
| Q15 | Executive summary | `CREATE VIEW` |

---

## 🔍 Key Findings

> Based on sample data — results scale with the full Kaggle dataset.

- **California, Texas, and Florida** account for the largest share of US locations, making them natural distribution hub candidates
- **Connecticut** leads in store density (~14.8 stores per 100k) — nearly 3× the national average
- **Nevada, Utah, and Colorado** are fast-growing states with low store density — strong expansion targets
- The **top 5 states** account for ~38% of all US locations, creating supply chain clustering advantages
- **12+ states** fall below the national average density threshold with above-average populations — untapped markets

---

## 🛠️ Tech Stack

- **Database:** MySQL 8.0
- **IDE:** MySQL Workbench
- **Dataset:** Kaggle — Subway Restaurant Locations USA
- **Concepts:** Schema design, normalization, window functions, CTEs, aggregate analysis

---

## 🚀 How to Run

**1. Clone this repo**
```bash
git clone https://github.com/YOUR_USERNAME/subway-sql-analytics.git
```

**2. Open MySQL Workbench and connect to your local instance**

**3. Open and run the SQL file**
```
File → Open SQL Script → subway_mysql_project.sql
Press Cmd+Shift+Enter (Mac) or Ctrl+Shift+Enter (Windows)
```

**4. Load the real Kaggle dataset** *(optional — sample data included)*
- Download `subway.csv` from [Kaggle](https://www.kaggle.com/datasets/thedevastator/subway-the-fastest-growing-franchise-in-the-world)
- Use the Table Data Import Wizard in Workbench, or the Python snippet below:

```python
pip install pandas sqlalchemy pymysql

import pandas as pd
from sqlalchemy import create_engine

df = pd.read_csv('subway.csv')
engine = create_engine('mysql+pymysql://root:YOUR_PASSWORD@localhost/subway_analytics')
df.to_sql('stores_raw', engine, if_exists='replace', index=False)
print(f'Loaded {len(df)} rows')
```

**5. Run individual queries**
Highlight any query in Workbench and press `Cmd+Enter` to run just that one.

---

## 📁 File Structure

```
subway-sql-analytics/
│
├── subway_mysql_project.sql   # Full project: schema + data + 15 queries
└── README.md                  # This file
```

---

## 💼 Skills Demonstrated

- Relational database design (3NF normalization)
- Foreign key constraints and indexing
- Multi-table JOINs (2 and 3 table)
- Aggregate functions with GROUP BY and HAVING
- Common Table Expressions (CTEs)
- Window functions: `RANK()`, `DENSE_RANK()`, `NTILE()`, `SUM() OVER`, `PARTITION BY`
- Business metric derivation (density, opportunity scoring)
- Reusable SQL VIEWs for reporting
- Date-based trend analysis

---

