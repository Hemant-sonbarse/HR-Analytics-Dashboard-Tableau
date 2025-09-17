# HR Analytics Dashboard

## Problem Statement
Organizations face challenges in understanding their workforce dynamics due to fragmented HR data spread across multiple sources. Without a consolidated view, it becomes difficult for HR leaders to track employee demographics, monitor performance, evaluate training ROI, and align workforce policies with business needs.

This lack of visibility leads to:
- Ineffective decision-making in hiring and retention  
- Limited ability to identify performance issues and attrition drivers  
- Difficulty in aligning workforce composition with organizational goals  

---

## Objectives
This project aims to provide HR leaders with actionable insights into their workforce by:
- Tracking employee headcount trends and department-wise distribution  
- Analyzing demographic profiles (gender, age, education)  
- Assessing performance patterns by education level  
- Understanding workforce composition (tenure distribution, department-wise tenure, top job titles)  

---

## Dataset
**Source:** [Kaggle – HR Employee Dataset](https://www.kaggle.com/datasets/ravindrasinghrana/employeedataset/data)  

The dataset contains 4 CSV files covering:
- Employee Records  
- Engagement Survey Results  
- Recruitment Data  
- Training Data  

---

## Tech Stack
- **AWS S3** – Data Lake for raw CSVs  
- **Snowflake** – Cloud Data Warehouse  
- **SQL** – Data cleaning & transformation  
- **Tableau** – Dashboarding & visualization  

---

## Workflow
1. **Data Storage** – Raw HR datasets stored in AWS S3  
2. **Data Integration** – Loaded into Snowflake for centralized storage  
3. **Data Cleaning & Transformation** – Using SQL (joins, derived fields, handling nulls)  
4. **Data Modeling** – Built relationships across employee, survey, recruitment, and training data  
5. **Dashboard Development** – Designed interactive Tableau dashboard with KPIs, demographics, performance, and workforce insights  
6. **Insights Delivery** – Enabled HR leaders to track hiring trends, attrition risks, and engagement gaps  

---

## Dashboard Features
The Tableau dashboard provides:
- **Headcount Overview** – Active vs. terminated employees  
- **Departmental Split** – Department-wise active/terminated distribution  
- **Demographics** – Gender, age group, and education split  
- **Performance Analysis** – Performance distribution across education levels  
- **Workforce Composition** – Tenure distribution, average tenure by department, and top 10 job titles  

---

## Key Insights
- **Production Department** has the highest headcount, dominated by *Production Technician I*.  
- **Tenure Distribution** shows most employees are within **1–3 years**, highlighting early attrition risks.  
- **Department-wise Tenure** – Technical and R&D roles show higher retention compared to Sales.  
- **Performance Trends** – Employees with postgraduate degrees show higher performance ratings.  
- **Education Demographics** – Majority of employees hold bachelor’s degrees.  
