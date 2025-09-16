# HR Analytics Dashboard

## Problem Statement
HR leaders often struggle to get a unified view of workforce demographics, performance, and employee expectations because data is fragmented across multiple systems (employee records, recruitment, training, surveys).

This creates challenges such as:

- Limited visibility into employee demographics (age, gender, education).
- Difficulty in linking performance insights with workforce characteristics.
- Lack of clarity on workforce experience and expectations (tenure, job titles, salary ranges).
- Inability to proactively track hiring trends and attrition risks.
- Without a consolidated view, HR decision-making becomes reactive rather than data-driven.

---

## Project Overview
This project integrates multiple HR datasets into **Snowflake** and builds an **interactive Tableau dashboard** to deliver actionable workforce insights.  
The dashboard provides HR leaders with a unified view of workforce demographics, performance, and expectations.  

The analysis focuses on:

- Track **employee headcount trends** and **department-wise distribution**  
- Analyze **demographic profiles** (gender, age, education)  
- Assess **performance patterns** by education level  
- Understand **workforce experience** (job titles, tenure, salary ranges)  
- Identify **hiring trends, attrition risks, and engagement gaps**
  
---

## Dataset
Source: [Kaggle – HR Employee Dataset](https://www.kaggle.com/datasets/ravindrasinghrana/employeedataset/data)  

The dataset contains 4 CSV files covering:  
- Employee Records  
- Engagement Survey Results  
- Recruitment Data  
- Training Data  

---

## Tech Stack
- **Snowflake** – Cloud Data Warehouse  
- **AWS S3** – Data Lake for raw CSVs  
- **SQL** – Data cleaning & transformation  
- **Tableau** – Dashboarding & visualization 

---

## Project Workflow  

1. **Data Storage** – Raw HR datasets stored in **AWS S3**  
2. **Data Integration** – Loaded into **Snowflake** for centralized storage  
3. **Data Cleaning & Transformation** – Performed using **SQL** (joins, derived fields, handling nulls)  
4. **Data Modeling** – Created relationships across employee, survey, recruitment, and training data  
5. **Dashboard Development** – Built an **interactive Tableau dashboard** with KPIs, demographics, performance, and workforce insights  
6. **Insights Delivery** – Enabled HR leaders to track hiring trends, attrition risks, and engagement gaps  

---

## Dashboard Features
The Tableau dashboard provides:  
- **Headcount Overview** – Active vs. terminated employees  
- **Departmental Split** – Department-wise active/terminated distribution  
- **Demographics** – Gender, age group, and education split  
- **Performance Analysis** – Performance distribution across education levels  
- **Workforce Experience & Expectations** – Tenure distribution, job titles, salary ranges 
