/* ============================================================================
   FinTrust Digital Bank — Week 2 SQL Business Analysis
   Data Analytics Track | Part B
   Environment: PostgreSQL 16
   Source tables: Cleaned_Customer_Data, Cleaned_Transaction_Data

   Purpose:
   To analyse customer behaviour, transaction activity,transaction performance across different segments, and patterns in the synthetic Risk_Review_Flag
   
   ============================================================================ */

-- Creating Tables
CREATE TABLE Customer_Data (
    Customer_ID VARCHAR(15) PRIMARY KEY,
    Customer_Name VARCHAR(100),
    Age INTEGER,
    Gender VARCHAR(20),
    City VARCHAR(50),
    Customer_Segment VARCHAR(30),
    Account_Type VARCHAR(30),
    Tenure_Months INTEGER,
    Digital_Engagement_Score NUMERIC(6,2),
    Monthly_Income_Band VARCHAR(30),
    Preferred_Channel VARCHAR(30),
    Account_Status VARCHAR(30),
    DQ_Note VARCHAR(20)
);




CREATE TABLE Transaction_Data (
    Transaction_ID VARCHAR(20) PRIMARY KEY,
    Customer_ID VARCHAR(15) REFERENCES Customer_Data(Customer_ID),
    Transaction_DateTime TIMESTAMP,
    Transaction_Type VARCHAR(30),
    Amount_NGN NUMERIC(14,2),
    Channel VARCHAR(30),
    Device_Type VARCHAR(30),
    Location VARCHAR(50),
    International_Transaction VARCHAR(5),
    Transaction_Status VARCHAR(30),
    Risk_Review_Flag VARCHAR(5),
    Amount_Outlier_Flag VARCHAR(5),
    Customer_Account_Status VARCHAR(30),
    Status_Anomaly_Flag VARCHAR(20)
);
/*
====================================================================
DATA PREVIEW
========================================================
*/
select *
from Customer_Data;

select * 
from Transaction_Data;


/*======================================================================
Q1. BUSINESS QUESTION (Customer Segments / Transaction Value):
How does transaction activity and value differ across customer segments?
========================================================================*/
SELECT c.Customer_Segment,
       COUNT(*) AS Transaction_Count,
       ROUND(SUM(t.Amount_NGN),2) AS Total_Value_NGN,
       ROUND(AVG(t.Amount_NGN),2) AS Avg_Value_NGN
FROM Transaction_Data t
JOIN Customer_Data c ON t.Customer_ID = c.Customer_ID
GROUP BY c.Customer_Segment
ORDER BY Total_Value_NGN DESC;

/* RESULT: 
Everyday customers generate the highest aggregate transaction value and transaction volume. 
SME customers have the highest average transaction value.
   
BUSINESS INTERPRETATION: 
 The  difference in aggregate transaction value appear to be driven mainlu bu transaction volume, wile SMEs have relatively
 higher average transaction size. This means that each SME transaction is worth more, which matters for pricing
   strategy even though Everyday drives aggregate volume.

BUSINESS IMPLICATIONS:
Fintrust should consider both transaction frequency and transaction size when analysing customer value rather than relying on one measure. 
*/


/* ========================================================================================================
Q2. BUSINESS QUESTION (Customer Behaviour):
Does account type affect how actively customers transact or how much they spend
per transaction?
===========================================================================================================*/
SELECT c.Account_Type,
       COUNT(DISTINCT c.Customer_ID) AS Num_Customers,
       COUNT(t.Transaction_ID) AS Total_Transactions,
       ROUND(COUNT(t.Transaction_ID)::numeric / COUNT(DISTINCT c.Customer_ID), 2) AS Avg_Transactions_Per_Customer,
       ROUND(AVG(t.Amount_NGN),2) AS Avg_Transaction_Value_NGN
FROM Customer_Data c
JOIN Transaction_Data t ON c.Customer_ID = t.Customer_ID
GROUP BY c.Account_Type
ORDER BY Avg_Transactions_Per_Customer DESC;

/* Savings, Current and Premium customers all average ~8.0 transactions each
   (8.01 / 8.00 / 7.98) which is identical for each segment engagement. Average transaction value is also
   is almost the same across the customer segments ranging from NGN44.6K-47.4K.
   
   BUSINESS INTERPRETATION: This implies that Account_Type does not differentiate transaction
   behaviour in this data. 
   
   BUSINESS IMPLICATION:
   Therefore FinTrust should not assume Premium account holders are more
   active if engagement-based targeting is planned. Further customer analysis may benefit from considering Customer_Segment,
   Digital_Engagement_score, Trasaction_Type, and channel alongside account type.

   LIMITATION:
   This comparison does not establish that account type has no effect on transaction behaviour*/


/*===============================================================================================================
Q3. BUSINESS QUESTION (Transaction Activity):
How does monthly transaction activity vary across the observed period
(Jan-Mar 2026)?
=================================================================================================================*/
SELECT TO_CHAR(Transaction_DateTime, 'YYYY-MM') AS Month,
       COUNT(*) AS Transaction_Count,
       ROUND(SUM(Amount_NGN),2) AS Total_Value_NGN
FROM Transaction_Data
GROUP BY TO_CHAR(Transaction_DateTime, 'YYYY-MM')
ORDER BY Month;

/* RESULT: 
   March records has the highest total transaction value, while February has lover transaction activity.
   
   INTERPRETATION: 
   Monthly totals should be interpreted together with average daily activity because February contains fewer calender days.
   .

   BUSINESS IMPLICATION AND LIMITATIONS:
   Daily-normalised measures provide more useful basis for comparing monthly activity than raw monthly totals alone.
   The available data covers only a short period. A three-month period is insufficient to establish a long-term growth
   or decline trend. March should also be confirmed as complete month befor emaking month-end comparisons.
 */


/* ====================================================================================
Q4. BUSINESS QUESTION (Transaction Type / Value):
Which transaction types generate the most activty and transaction value?
============================================================================== */
SELECT Transaction_Type,
       COUNT(*) AS Transaction_Count,
       ROUND(SUM(Amount_NGN),2) AS Total_Value_NGN,
       ROUND(AVG(Amount_NGN),2) AS Avg_Value_NGN
FROM Transaction_Data
GROUP BY Transaction_Type
ORDER BY Avg_Value_NGN DESC;

/* RESULT;
   Deposit has the highest average value (NGN98,633) but is only the 4th most frequent
   type (1,328 transactions). Transfer is both high-frequency (3,549) and  high-value (avg NGN67,038),
   making it the top total-value contributor (NGN237.9M). Airtime/Data is smallest on both
   counts (avg NGN8,250).
   
   BUSINESS INTERPRETATION: 
   Different transaction types contribute differently to transaction volume and monetary value.

   BUSINESS IMPLICATIONS
   Fintrust can monitor high-value transactions separately from high-frequency low-value 
   transaction types when analysing customer activity.
  */


/* ========================================================================================================
Q5. BUSINESS QUESTION (Transaction Status):
What proportion of transactions fail to complete successfully, and how much
value is tied up in non-successful transactions?
=========================================================================================================== */
SELECT Transaction_Status,
       COUNT(*) AS Count,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS Pct_Of_All_Transactions,
       ROUND(SUM(Amount_NGN),2) AS Total_Value_NGN
FROM Transaction_Data
GROUP BY Transaction_Status
ORDER BY Count DESC;

/* RESULT:
 Sucessful transactions account for approximately 90.47% while failed contribues to about 5.25%. Reversed contributes about 2.72%   
 Pending gives about 1.57%. About 9.53% of transactions (NGN49.7M) did NOT complete cleanly.
   
   BUSINESS INTERPRETATION AND IMPLICATIONS: 
   The non-successful transactions requires monitoring with the Failed, Reversed, and Pending transaction require separate analysis
   because they represent different transaction outcomes. 
   A non-successful transaction does not necessarily mean the same type of customer problem occured. Additional operational information
   would be required to identify the underlying causes.
 */


/* ====================================================================================================
Q6. BUSINESS QUESTION (Transaction Channel):
How transaction failure rate vary across channels
==================================================================================================== */
SELECT Channel,
       COUNT(*) AS Total_Transactions,
       SUM(CASE WHEN Transaction_Status = 'Failed' THEN 1 ELSE 0 END) AS Failed_Count,
       ROUND(SUM(CASE WHEN Transaction_Status = 'Failed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Failure_Rate_Pct
FROM Transaction_Data
GROUP BY Channel
ORDER BY Failure_Rate_Pct DESC;

/* RESULT:
    Mobile App has both the most transactions (5,102) and the highest failure rate
   (5.80%), while ATM has the lowest failure rate (4.18%). The spread across channels is narrow
   (4.18%-5.80%).
   
   BUSINESS INTERPRETATION AND IMPLICATION:
   The Mobile App channel could be examined further to determine whether the higher observed failure rate is 
   associated  with the particular transaction types, devices or any operational characteristics.
   The analysis identifies an assosiation in the dataset but does not establish the technical cause of the difference.
   */


/* ===========================================================================================================
Q7. BUSINESS QUESTION (Transaction Channel / Risk):
Which channel has the highest risk-review flag rate?
=========================================================================================================== */
SELECT Channel,
       COUNT(*) AS Total_Transactions,
       SUM(CASE WHEN Risk_Review_Flag = 'Yes' THEN 1 ELSE 0 END) AS Flagged_Count,
       ROUND(SUM(CASE WHEN Risk_Review_Flag = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Risk_Flag_Rate_Pct
FROM Transaction_Data
GROUP BY Channel
ORDER BY Risk_Flag_Rate_Pct DESC;

/* RESULT: 
   Web (21.35%) and ATM (21.18%) have the highest risk-flag rates. Mobile App, despite
   having the most volume, has a lower rate (19.40%) and USSD has lowest (17.32%) risk-flag rate.
   Thus the synethetic flag rate vaires across transaction channels.
   
   BUSINESS IMPLICATION AND LIMITATIONS

   The channel differences can be investigated further by examining transaction type, transaction value, and customer characteristics 
   Risk_Review_Flag is a synthetic training label and should not be interpreted as confirmed fraud, financial crime or actual banking risk
   */


/* =========================================================================================================
Q8. BUSINESS QUESTION (Customer Segments / Risk-Review Patterns):
Does risk-review flagging vary by customer segment?
========================================================================================================= */
SELECT c.Customer_Segment,
       COUNT(t.Transaction_ID) AS Total_Transactions,
       SUM(CASE WHEN t.Risk_Review_Flag = 'Yes' THEN 1 ELSE 0 END) AS Flagged_Count,
       ROUND(SUM(CASE WHEN t.Risk_Review_Flag = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(t.Transaction_ID), 2) AS Risk_Flag_Rate_Pct
FROM Transaction_Data t
JOIN Customer_Data c ON t.Customer_ID = c.Customer_ID
GROUP BY c.Customer_Segment
ORDER BY Risk_Flag_Rate_Pct DESC;

/* RESULT: Premium customers have the highest risk-flag rate (20.33%), followed closely by
   Student (19.75%), SME (19.40%) and Everyday (19.29%). There is limited vairation in the synethic flag rate across customer segments.
   
   BUSINESS IMPLICATION AND LIMITATIONS:
   Customer segment alone does not appear to create a large difference in the observed synthetic flag rate in this data

   Flag rated do not establish if the synthetic flagging process is fair or unbiased.
   A proper fairness assessment would require additional variables */


/* =================================================================================================
Q9. BUSINESS QUESTION (Risk-Review Patterns):
How does the synethic Risk_Review_Flag rate differ between international and domestic transactions?
==================================================================================================== */
SELECT International_Transaction,
       COUNT(*) AS Total_Transactions,
       SUM(CASE WHEN Risk_Review_Flag = 'Yes' THEN 1 ELSE 0 END) AS Flagged_Count,
       ROUND(SUM(CASE WHEN Risk_Review_Flag = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS Risk_Flag_Rate_Pct
FROM Transaction_Data
GROUP BY International_Transaction
ORDER BY Risk_Flag_Rate_Pct DESC;

/* RESULT: International transactions are flagged at 36.88% while domestic transactions are flagged at 18.88% for domestic. 
  International transactions are flagged 2x higher than domestic, despite being only 480 of 12,000 transactions (4%).
  
   BUSINESS IMPLICATIONS AND LIMITATION:
   International transaction status shows the largest descriptive difference in synthetic Risk_Review_Flag rate among the variables examined in this analysis

   This requires further investigatio by examining transaction type, amount, channel and other available transaction attributes

   The observed does not establish that international transaction status causes a transaction to receive a synthetic risk-review flag.
   */


/* ===============================================================================================================
Q10. BUSINESS QUESTION (Customer Behaviour / Value):
Who are FinTrust's top 10 customers by total transaction value?
========================================================================================================== */
SELECT c.Customer_ID, c.Customer_Name, c.Customer_Segment,
       COUNT(t.Transaction_ID) AS Transaction_Count,
       ROUND(SUM(t.Amount_NGN),2) AS Total_Value_NGN
FROM Customer_Data c
JOIN Transaction_Data t ON c.Customer_ID = t.Customer_ID
GROUP BY c.Customer_ID, c.Customer_Name, c.Customer_Segment
ORDER BY Total_Value_NGN DESC
LIMIT 10;

/* RESULT: Top 10 customers by value range from NGN1.31M-NGN1.71M each; 6 of the 10 are
   "Everyday" segment, not Premium - the top customer (Ibrahim Mohammed, FT-C01075) is
   Everyday, not Premium. Customer segment alone does not identify all of the highest-value individual customer


   
BUSINESS IMPLICATION AND LIMITATION:
Customer-level transaction value can complement segment-level analysis when
identifying customers with high observed transaction activity.

High transaction value does not necessarily mean high profitability or customer
lifetime value because the dataset does not contain costs, fees, margins, or
customer lifetime value measures. */




/* ============================================================================
   END OF WEEK 2 SQL ANALYSIS
   ============================================================================ */
