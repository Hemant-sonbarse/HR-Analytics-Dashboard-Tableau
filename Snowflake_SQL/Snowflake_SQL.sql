-- ----------------------------------------------------------------------------------------
-- 1. Create Database & Schemas
-- ----------------------------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS HR_ANALYTICS;
USE DATABASE HR_ANALYTICS;

CREATE SCHEMA IF NOT EXISTS HR_ANALYTICS.RAW;       -- Raw CSV data from S3
CREATE SCHEMA IF NOT EXISTS HR_ANALYTICS.STAGE;     -- Cleaned / intermediate layer
CREATE SCHEMA IF NOT EXISTS HR_ANALYTICS.CURATED;   -- Star schema, analysis-ready

-- ----------------------------------------------------------------------------------------
-- 2. Storage Integration with AWS S3
-- ----------------------------------------------------------------------------------------
CREATE OR REPLACE STORAGE INTEGRATION s3_hr_integration
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = S3
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam---------------/hr-analytics-project-role'
  STORAGE_ALLOWED_LOCATIONS = ('s3://hr-analytics-project/');

-- Retrieve External ID and ARN for trust setup
DESC STORAGE INTEGRATION s3_hr_integration;

-- Create Stage
CREATE OR REPLACE STAGE hr_raw_stage
  STORAGE_INTEGRATION = s3_hr_integration
  URL = 's3://hr-analytics-project/'
  FILE_FORMAT = (TYPE = CSV FIELD_OPTIONALLY_ENCLOSED_BY='"' SKIP_HEADER=1);

-- ----------------------------------------------------------------------------------------
-- 3. Create RAW Layer Tables
-- ----------------------------------------------------------------------------------------

-- Employee Data
CREATE OR REPLACE TABLE HR_ANALYTICS.RAW.EMPLOYEE_DATA (
    EmpID VARCHAR,
    FirstName VARCHAR,
    LastName VARCHAR,
    StartDate VARCHAR,
    ExitDate VARCHAR,
    Title VARCHAR,
    Supervisor VARCHAR,
    ADEmail VARCHAR,
    BusinessUnit VARCHAR,
    EmployeeStatus VARCHAR,
    EmployeeType VARCHAR,
    PayZone VARCHAR,
    EmployeeClassificationType VARCHAR,
    TerminationType VARCHAR,
    TerminationDescription VARCHAR,
    DepartmentType VARCHAR,
    Division VARCHAR,
    DOB VARCHAR,
    State VARCHAR,
    JobFunctionDescription VARCHAR,
    GenderCode VARCHAR,
    LocationCode VARCHAR,
    RaceDesc VARCHAR,
    MaritalDesc VARCHAR,
    PerformanceScore VARCHAR,
    CurrentEmployeeRating VARCHAR
);

-- Employee Engagement Survey
CREATE OR REPLACE TABLE HR_ANALYTICS.RAW.EMPLOYEE_ENGAGEMENT_SURVEY (
    EMP_ID VARCHAR,
    SurveyDate VARCHAR,
    EngagementScore VARCHAR,
    SatisfactionScore VARCHAR,
    WorkLifeBalanceScore VARCHAR
);

-- Recruitment Data
CREATE OR REPLACE TABLE HR_ANALYTICS.RAW.RECRUITMENT_DATA (
    ApplicantID VARCHAR,
    ApplicationDate VARCHAR,
    FirstName VARCHAR,
    LastName VARCHAR,
    Gender VARCHAR,
    DateOfBirth VARCHAR,
    PhoneNumber VARCHAR,
    Email VARCHAR,
    Address VARCHAR,
    City VARCHAR,
    State VARCHAR,
    ZipCode VARCHAR,
    Country VARCHAR,
    EducationLevel VARCHAR,
    YearsOfExperience VARCHAR,
    DesiredSalary VARCHAR,
    JobTitle VARCHAR,
    Status VARCHAR
);

-- Training Data
CREATE OR REPLACE TABLE HR_ANALYTICS.RAW.TRAINING (
    EmployeeID VARCHAR,
    TrainingDate VARCHAR,
    TrainingProgramName VARCHAR,
    TrainingType VARCHAR,
    TrainingOutcome VARCHAR,
    Location VARCHAR,
    Trainer VARCHAR,
    TrainingDurationDays VARCHAR,
    TrainingCost VARCHAR
);

-- ----------------------------------------------------------------------------------------
-- 4. Load Data into RAW Layer
-- ----------------------------------------------------------------------------------------
COPY INTO HR_ANALYTICS.RAW.EMPLOYEE_DATA
FROM @hr_raw_stage/employee_data.csv
FILE_FORMAT = (TYPE = CSV FIELD_OPTIONALLY_ENCLOSED_BY='"' SKIP_HEADER=1)
ON_ERROR = 'CONTINUE';

COPY INTO HR_ANALYTICS.RAW.EMPLOYEE_ENGAGEMENT_SURVEY
FROM @hr_raw_stage/employee_engagement_survey_data.csv
FILE_FORMAT = (TYPE = CSV FIELD_OPTIONALLY_ENCLOSED_BY='"' SKIP_HEADER=1)
ON_ERROR = 'CONTINUE';

COPY INTO HR_ANALYTICS.RAW.RECRUITMENT_DATA
FROM @hr_raw_stage/recruitment_data.csv
FILE_FORMAT = (TYPE = CSV FIELD_OPTIONALLY_ENCLOSED_BY='"' SKIP_HEADER=1)
ON_ERROR = 'CONTINUE';

COPY INTO HR_ANALYTICS.RAW.TRAINING
FROM @hr_raw_stage/training_and_development_data.csv
FILE_FORMAT = (TYPE = CSV FIELD_OPTIONALLY_ENCLOSED_BY='"' SKIP_HEADER=1)
ON_ERROR = 'CONTINUE';

-- ----------------------------------------------------------------------------------------
-- 5. Stage Layer: Clean & Transform
-- ----------------------------------------------------------------------------------------

-- Employee Data
CREATE OR REPLACE TABLE HR_ANALYTICS.STAGE.EMPLOYEE_DATA AS
SELECT
    EmpID,
    FirstName,
    LastName,
    TRY_TO_DATE(StartDate, 'DD-MON-YY') AS StartDate,
    TRY_TO_DATE(ExitDate, 'DD-MON-YY') AS ExitDate,
    Title,
    Supervisor,
    ADEmail,
    BusinessUnit,
    EmployeeStatus,
    EmployeeType,
    PayZone,
    EmployeeClassificationType,
    TerminationType,
    TerminationDescription,
    DepartmentType,
    Division,
    TRY_TO_DATE(DOB, 'DD-MM-YYYY') AS DOB,
    State,
    JobFunctionDescription,
    GenderCode,
    LocationCode,
    RaceDesc,
    MaritalDesc,
    PerformanceScore,
    TRY_TO_NUMBER(CurrentEmployeeRating) AS CurrentEmployeeRating
FROM HR_ANALYTICS.RAW.EMPLOYEE_DATA;

-- Engagement Survey
CREATE OR REPLACE TABLE HR_ANALYTICS.STAGE.EMPLOYEE_ENGAGEMENT_SURVEY AS
SELECT
    EMP_ID,
    TRY_TO_DATE(SurveyDate, 'DD-MM-YYYY') AS SurveyDate,
    TRY_TO_NUMBER(EngagementScore) AS EngagementScore,
    TRY_TO_NUMBER(SatisfactionScore) AS SatisfactionScore,
    TRY_TO_NUMBER(WorkLifeBalanceScore) AS WorkLifeBalanceScore
FROM HR_ANALYTICS.RAW.EMPLOYEE_ENGAGEMENT_SURVEY;

-- Recruitment Data
CREATE OR REPLACE TABLE HR_ANALYTICS.STAGE.RECRUITMENT_DATA AS
SELECT
    ApplicantID,
    TRY_TO_DATE(ApplicationDate, 'DD-MON-YY') AS ApplicationDate,
    FirstName,
    LastName,
    Gender,
    TRY_TO_DATE(DateOfBirth, 'DD-MM-YYYY') AS DateOfBirth,
    PhoneNumber,
    Email,
    Address,
    City,
    State,
    ZipCode,
    Country,
    EducationLevel,
    TRY_TO_NUMBER(YearsOfExperience) AS YearsOfExperience,
    TRY_TO_NUMBER(DesiredSalary) AS DesiredSalary,
    JobTitle,
    Status
FROM HR_ANALYTICS.RAW.RECRUITMENT_DATA;

-- Training Data
CREATE OR REPLACE TABLE HR_ANALYTICS.STAGE.TRAINING AS
SELECT
    EmployeeID,
    TRY_TO_DATE(TrainingDate, 'DD-MON-YY') AS TrainingDate,
    TrainingProgramName,
    TrainingType,
    TrainingOutcome,
    Location,
    Trainer,
    TRY_TO_NUMBER(TrainingDurationDays) AS TrainingDurationDays,
    TRY_TO_NUMBER(TrainingCost) AS TrainingCost
FROM HR_ANALYTICS.RAW.TRAINING;

-- ----------------------------------------------------------------------------------------
-- 6. Curated Layer: Star Schema
-- ----------------------------------------------------------------------------------------

-- Dimension: Employee
CREATE OR REPLACE TABLE HR_ANALYTICS.CURATED.DIM_EMPLOYEE AS
SELECT DISTINCT
    e.EmpID,
    e.FirstName,
    e.LastName,
    e.GenderCode,
    e.RaceDesc,
    e.MaritalDesc,
    e.DOB,
    e.State,
    e.LocationCode,
    e.JobFunctionDescription,
    e.Title,
    e.Supervisor,
    e.BusinessUnit,
    e.DepartmentType,
    e.Division,
    e.EmployeeType,
    e.EmployeeStatus,
    e.PayZone,
    e.EmployeeClassificationType,
    r.EducationLevel
FROM HR_ANALYTICS.STAGE.EMPLOYEE_DATA e
LEFT JOIN HR_ANALYTICS.STAGE.RECRUITMENT_DATA r
    ON e.EmpID = r.ApplicantID;

-- Dimension: Date
CREATE OR REPLACE TABLE HR_ANALYTICS.CURATED.DIM_DATE AS
SELECT DISTINCT TRY_TO_DATE(StartDate) AS DateValue
FROM HR_ANALYTICS.STAGE.EMPLOYEE_DATA WHERE StartDate IS NOT NULL
UNION
SELECT DISTINCT SurveyDate FROM HR_ANALYTICS.STAGE.EMPLOYEE_ENGAGEMENT_SURVEY WHERE SurveyDate IS NOT NULL
UNION
SELECT DISTINCT ApplicationDate FROM HR_ANALYTICS.STAGE.RECRUITMENT_DATA WHERE ApplicationDate IS NOT NULL
UNION
SELECT DISTINCT TrainingDate FROM HR_ANALYTICS.STAGE.TRAINING WHERE TrainingDate IS NOT NULL;

-- Fact: Employee Status
CREATE OR REPLACE TABLE HR_ANALYTICS.CURATED.FACT_EMPLOYEE_STATUS AS
SELECT
    EmpID,
    StartDate,
    ExitDate,
    CurrentEmployeeRating,
    PerformanceScore
FROM HR_ANALYTICS.STAGE.EMPLOYEE_DATA;

-- Fact: Engagement
CREATE OR REPLACE TABLE HR_ANALYTICS.CURATED.FACT_ENGAGEMENT AS
SELECT
    EMP_ID AS EmpID,
    SurveyDate,
    EngagementScore,
    SatisfactionScore,
    WorkLifeBalanceScore
FROM HR_ANALYTICS.STAGE.EMPLOYEE_ENGAGEMENT_SURVEY;

-- Fact: Recruitment
CREATE OR REPLACE TABLE HR_ANALYTICS.CURATED.FACT_RECRUITMENT AS
SELECT
    ApplicantID,
    ApplicationDate,
    Gender,
    DateOfBirth,
    EducationLevel,
    YearsOfExperience,
    DesiredSalary,
    JobTitle,
    Status
FROM HR_ANALYTICS.STAGE.RECRUITMENT_DATA;

-- Fact: Training
CREATE OR REPLACE TABLE HR_ANALYTICS.CURATED.FACT_TRAINING AS
SELECT
    EmployeeID AS EmpID,
    TrainingDate,
    TrainingProgramName,
    TrainingType,
    TrainingOutcome,
    Location,
    Trainer,
    TrainingDurationDays,
    TrainingCost
FROM HR_ANALYTICS.STAGE.TRAINING;

-- ----------------------------------------------------------------------------------------
-- 7. Enriched Employee Status Fact
-- ----------------------------------------------------------------------------------------
CREATE OR REPLACE TABLE HR_ANALYTICS.CURATED.FACT_EMPLOYEE_STATUS_ENRICHED AS
SELECT
  EmpID,
  StartDate,
  ExitDate,
  CurrentEmployeeRating,
  PerformanceScore,
  CASE WHEN ExitDate IS NULL THEN 1 ELSE 0 END AS is_active,
  CASE WHEN DOB IS NOT NULL THEN DATEDIFF(year, DOB, CURRENT_DATE) END AS age,
  CASE WHEN StartDate IS NOT NULL THEN DATEDIFF(month, StartDate, COALESCE(ExitDate, CURRENT_DATE)) / 12.0 END AS tenure_years
FROM HR_ANALYTICS.STAGE.EMPLOYEE_DATA;

-- Add Termination Reason
CREATE OR REPLACE TABLE HR_ANALYTICS.CURATED.FACT_EMPLOYEE_STATUS_ENRICHED AS
SELECT
    f.*,
    COALESCE(NULLIF(TRIM(s.TerminationType), ''), NULLIF(TRIM(s.TerminationDescription), ''), 'Unknown') AS TerminationReason
FROM HR_ANALYTICS.STAGE.EMPLOYEE_DATA s
JOIN HR_ANALYTICS.CURATED.FACT_EMPLOYEE_STATUS_ENRICHED f ON s.EmpID = f.EmpID;

-- ----------------------------------------------------------------------------------------
-- 8. Data Quality Checks
-- ----------------------------------------------------------------------------------------
-- Duplicates
SELECT EmpID, COUNT(*) FROM HR_ANALYTICS.STAGE.EMPLOYEE_DATA GROUP BY EmpID HAVING COUNT(*) > 1;
SELECT ApplicantID, COUNT(*) FROM HR_ANALYTICS.CURATED.FACT_RECRUITMENT GROUP BY ApplicantID HAVING COUNT(*) > 1;

-- Null Keys
SELECT COUNT(*) AS NullEmpIDs FROM HR_ANALYTICS.CURATED.DIM_EMPLOYEE WHERE EmpID IS NULL;
SELECT COUNT(*) AS NullEmpIDs FROM HR_ANALYTICS.CURATED.FACT_EMPLOYEE_STATUS WHERE EmpID IS NULL;

-- Lifecycle Validation
SELECT EmpID, StartDate, ExitDate FROM HR_ANALYTICS.CURATED.FACT_EMPLOYEE_STATUS WHERE ExitDate IS NOT NULL AND ExitDate < StartDate;
SELECT ApplicantID, DateOfBirth, ApplicationDate FROM HR_ANALYTICS.CURATED.FACT_RECRUITMENT WHERE DateOfBirth > ApplicationDate;

-- ----------------------------------------------------------------------------------------
-- 9. Analytical Queries
-- ----------------------------------------------------------------------------------------
-- Headcount
SELECT COUNT(DISTINCT EmpID) AS total_hired FROM HR_ANALYTICS.CURATED.FACT_EMPLOYEE_STATUS_ENRICHED WHERE StartDate IS NOT NULL;
SELECT COUNT(*) AS active_employees FROM HR_ANALYTICS.CURATED.FACT_EMPLOYEE_STATUS_ENRICHED WHERE is_active = 1;
SELECT COUNT(DISTINCT EmpID) AS terminated_employees FROM HR_ANALYTICS.CURATED.FACT_EMPLOYEE_STATUS_ENRICHED WHERE ExitDate IS NOT NULL;

-- Age Distribution
SELECT CASE
        WHEN age BETWEEN 20 AND 30 THEN '20–30'
        WHEN age BETWEEN 31 AND 40 THEN '31–40'
        WHEN age BETWEEN 41 AND 50 THEN '41–50'
        WHEN age BETWEEN 51 AND 60 THEN '51–60'
        ELSE '61+' END AS age_group,
       COUNT(*) AS employee_count
FROM HR_ANALYTICS.CURATED.FACT_EMPLOYEE_STATUS_ENRICHED
WHERE is_active = 1
GROUP BY age_group
ORDER BY age_group;

-- Education Level Distribution
SELECT d.EducationLevel, COUNT(f.EmpID) AS employee_count
FROM HR_ANALYTICS.CURATED.FACT_EMPLOYEE_STATUS_ENRICHED f
JOIN HR_ANALYTICS.CURATED.DIM_EMPLOYEE d ON f.EmpID = d.EmpID
WHERE f.is_active = 1
GROUP BY d.EducationLevel
ORDER BY employee_count DESC;

-- Tenure Distribution
SELECT CASE
    WHEN tenure_years < 1 THEN '<1 yr'
    WHEN tenure_years < 3 THEN '1-3 yrs'
    WHEN tenure_years < 5 THEN '3-5 yrs'
    ELSE '5+ yrs' END AS tenure_bucket,
    COUNT(DISTINCT EmpID) AS emp_count
FROM HR_ANALYTICS.CURATED.FACT_EMPLOYEE_STATUS_ENRICHED
GROUP BY tenure_bucket
ORDER BY tenure_bucket;
