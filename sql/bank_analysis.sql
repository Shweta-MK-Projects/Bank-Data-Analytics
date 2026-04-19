create database banking_analysis;

use banking_analysis;

describe bank_trnx;

select*from bank_trnx;

-- 1.) List of Bank Names .. 
select 'Axis Bank' as Bank union all select 'Kotak Mahindra Bank'union all
select 'ICICI Bank'union all select 'Punjab National Bank'union all 
select 'HDFC Bank'union all select 'State Bank of India';
  
 -- 2.) Total number of Bank Customers
select COUNT(distinct Account_Number) as Number_of_Customers
from bank_trnx;	

### Table creation
 
CREATE TABLE Bank_Trans (
    Customer_ID VARCHAR(50),
    Customer_Name VARCHAR(100),
    Account_Number VARCHAR(20),
    Transaction_Date DATETIME,
    Month VARCHAR(20),
    Transaction_Type VARCHAR(10),
    Amount DECIMAL(15,2),
    Customer_Trnx_Category VARCHAR(20),
    Transaction_Category VARCHAR(50),
    High_Value_Flag VARCHAR(3),
    Balance DECIMAL(15,2),
    Percent_Current_Balance DECIMAL(10,4),
    Amount_Sign DECIMAL(15,2),
    Description VARCHAR(100),
    Bank_Name VARCHAR(50),
    Branch VARCHAR(50),
    Transaction_Method VARCHAR(50),
    Currency VARCHAR(10)
);
select * from bank_trans;

describe bank_trans;
 
 show tables;
 
 ##DDL Commands 
ALTER TABLE bank_trnx ADD Email VARCHAR(100);
ALTER TABLE bank_trnx MODIFY Amount DECIMAL(15,2);
ALTER TABLE bank_trnx RENAME COLUMN  Remarks to Description ;
ALTER TABLE bank_transactions RENAME TO bank_trans;

select * from bank_trans;
 
INSERT INTO bank_trans VALUES
('CUST001', 'John Smith', 'ACC123456789', '2024-01-20 13:25:00', 'January', 'Debit', 85.75, 'Dining', 'Food & Beverage', 'No', 13463.75, 0.6372, -85.75, 'Restaurant Payment', 'ABC Bank', 'Downtown', 'Card Payment', 'INR'),
('CUST002', 'Sarah Johnson', 'ACC987654321', '2024-01-21 15:40:00', 'January', 'Debit', 4500.00, 'Loan EMI', 'Financial', 'Yes', 20500.00, 21.9512, -4500.00, 'Home Loan EMI', 'XYZ Bank', 'Uptown', 'Auto Debit', 'INR'),
('CUST004', 'Emily Wilson', 'ACC111222333', '2024-01-22 12:00:00', 'January', 'Credit', 3000.00, 'Freelance', 'Income', 'No', 8300.00, 36.1446, 3000.00, 'Freelance Payment', 'ABC Bank', 'Eastside', 'Bank Transfer', 'INR');

select * from bank_trans;

### Creating Stored Procedure

select * from bank_trans;

###  Get Customer Transaction Summary
CALL GetCustomerTransactionSummary('CUST001');

select * from bank_trans;

### Creating Trigger
DELIMITER $$

CREATE TRIGGER trg_set_amount_sign
BEFORE INSERT ON Bank_Trans	
FOR EACH ROW
BEGIN
    IF NEW.Transaction_Type = 'Credit' THEN
        SET NEW.Amount_Sign = NEW.Amount;
    ELSEIF NEW.Transaction_Type = 'Debit' THEN
        SET NEW.Amount_Sign = (NEW.Amount * -1);
    END IF;
END $$

DELIMITER ;

INSERT INTO Bank_Trans (
    Customer_ID, Customer_Name, Account_Number, Transaction_Date,
    Month, Transaction_Type, Amount, Customer_Trnx_Category,
    Transaction_Category, High_Value_Flag, Balance,
    Percent_Current_Balance, Amount_Sign,
    Description, Bank_Name, Branch, Transaction_Method, Currency
) VALUES (
    UUID(), 'Group Four', 1234567890, CURDATE(),
    'March', 'Debit', 5000, 'Medium',
    'Shopping', 'NO', 20000,
    0.25, -5000,
    'Test transaction', 'Test Bank', 'Main Branch', 'Credit Card', 'INR'
);

SELECT Amount, High_Value_Flag
FROM Bank_Trans
WHERE Customer_Name = 'Sarah Johnson';


select * from bank_trnx;

### Customer Transaction Ranking (Windows Function)
SELECT 
    Bank_Name,
    Month,
    COUNT(*) as Transaction_Count,
    SUM(Amount) as Total_Amount,
    RANK() OVER (PARTITION BY Month ORDER BY SUM(Amount) DESC) as Bank_Rank
FROM Bank_Trnx 
GROUP BY Bank_Name, Month 
ORDER BY Month, Bank_Rank;

-- 3.)Transaction Type Details (Credit/ Debit)
select 
    Transaction_Type,
    count(*) as Transaction_Count,
    concat('₹', round(sum(Amount), 2)) AS Total_Amount
FROM bank_trnx
GROUP BY Transaction_Type;

-- 4.) Bank Wise Customer Count
select 
    Bank_Name,
    count(distinct Account_Number) as Number_of_Customers
from bank_trnx
where Bank_Name in (
    'Axis Bank', 
    'Kotak Mahindra Bank', 
    'ICICI Bank', 
    'Punjab National Bank', 
    'HDFC Bank', 
    'State Bank of India')
group by Bank_Name;

-- 5.) Bank Wise Total Credit and Debit Transactions Details
SELECT 
    Bank_Name,
    CONCAT('₹', CAST(SUM(CASE WHEN Transaction_Type = 'Credit' THEN COALESCE(Amount, 0) ELSE 0 END) AS DECIMAL(18,2))) AS Total_Credit_Amount,
    CONCAT('₹', CAST(SUM(CASE WHEN Transaction_Type = 'Debit' THEN COALESCE(Amount, 0) ELSE 0 END) AS DECIMAL(18,2))) AS Total_Debit_Amount,
    CONCAT('₹', CAST(SUM(CASE WHEN Transaction_Type = 'Credit' THEN COALESCE(Amount, 0) ELSE -COALESCE(Amount, 0) END) AS DECIMAL(18,2))) AS Net_Amount,
    COUNT(CASE WHEN Transaction_Type = 'Credit' THEN 1 END) AS Number_of_Credit_Transactions,
    COUNT(CASE WHEN Transaction_Type = 'Debit' THEN 1 END) AS Number_of_Debit_Transactions
FROM bank_trnx
GROUP BY Bank_Name
ORDER BY SUM(CASE WHEN Transaction_Type = 'Credit' THEN COALESCE(Amount, 0) ELSE -COALESCE(Amount, 0) END) DESC;

-- 6.) Monthly Transactions done by Banks
select Bank_Name, Month,
    count(*) as Transaction_Count,
    concat('₹', round(sum(Amount), 2)) as Total_Amount
from bank_trnx
group by Bank_Name, Month
order by Bank_Name, min(Transaction_Date);

-- 7.)Top 5 Customers by Transaction Count and Amount
select Bank_Name, Customer_Name, count(*) as Transaction_Count,
round(sum(Amount), 2) as Total_Amount
from bank_trnx 
group by Bank_Name, Customer_Name order by Total_Amount desc limit 5;

 -- 8.) Account Activity for a Specific Customer
select * from bank_trnx
where Customer_Name = 'Michael Smith'
order by Transaction_Date;

-- 9.) Top 10 Customers with Highest Balance After Transactions
select Bank_Name, Branch, Customer_Name, 
    concat('₹', round(max(Balance),2)) as Highest_Balance
from bank_trnx
group by Bank_Name,Branch, Customer_Name
order by Highest_Balance desc limit 10;

-- 10.) Details of Transaction Method
select Transaction_Method,
    count(*) as Number_of_Transactions,
   concat('₹',  round(sum(Amount) ,2)) as Total_Amount
from bank_trnx
group by Transaction_Method
order by Number_of_Transactions desc;

-- 11.) Top 3 Bank by Transaction Volume
select 
    Bank_Name,
    Branch,
    count(*) as Transaction_Count
from bank_trnx
group by Bank_Name, Branch
order by Transaction_Count desc limit 3;

-- 12.) List of All Online Shopping Transactions

SELECT * FROM bank_trnx
WHERE Description LIKE '%Online Shopping%';

-- 13.) Total Transaction Amount per Bank
select Bank_Name, 
concat('₹', round(sum(Amount), 2)) as Total_Amount
from bank_trnx
group by Bank_Name;

-- 14. Net Flow of Cash by Bank and Branch
SELECT 
    Bank_Name,
    Branch,
    CONCAT('₹', FORMAT(SUM(CASE WHEN Transaction_Type = 'Credit' THEN Amount ELSE 0 END), 2)) AS Total_Credit,
    CONCAT('₹', FORMAT(SUM(CASE WHEN Transaction_Type = 'Debit' THEN Amount ELSE 0 END), 2)) AS Total_Debit,
    CONCAT('₹', FORMAT((SUM(CASE WHEN Transaction_Type = 'Credit' THEN Amount ELSE 0 END) - 
           SUM(CASE WHEN Transaction_Type = 'Debit' THEN Amount ELSE 0 END)), 2)) AS Net_Flow
FROM bank_trnx
GROUP BY Bank_Name, Branch
ORDER BY Bank_Name, Branch;


-- 15. Credit Percentage Calculations By Brnk and Branch
SELECT 
    Bank_Name,
    Branch,
    CONCAT('₹', FORMAT(SUM(CASE WHEN Transaction_Type = 'Credit' THEN Amount ELSE 0 END), 2)) AS Total_Credit,
    CONCAT('₹', FORMAT(SUM(CASE WHEN Transaction_Type = 'Debit' THEN Amount ELSE 0 END), 2)) AS Total_Debit,
    CONCAT('₹', FORMAT((SUM(CASE WHEN Transaction_Type = 'Credit' THEN Amount ELSE 0 END) - 
           SUM(CASE WHEN Transaction_Type = 'Debit' THEN Amount ELSE 0 END)), 2)) AS Net_Flow,
    CONCAT(FORMAT((SUM(CASE WHEN Transaction_Type = 'Credit' THEN Amount ELSE 0 END) / 
           (SUM(CASE WHEN Transaction_Type = 'Credit' THEN Amount ELSE 0 END) + 
            SUM(CASE WHEN Transaction_Type = 'Debit' THEN Amount ELSE 0 END)) * 100), 2), '%') AS Credit_Percentage
FROM bank_trnx
GROUP BY Bank_Name, Branch
ORDER BY Bank_Name, Branch;

-- 16.) Top 10 Busiest Branches 
SELECT 
    Bank_Name,
    Branch,
    Transaction_Date,
    COUNT(*) AS Transaction_Count
FROM bank_trnx
GROUP BY Bank_Name, Branch, Transaction_Date
ORDER BY Transaction_Count DESC
LIMIT 10;

-- 17.) High Value Transactions By Banks
SELECT
    Bank_Name,
    Branch, 
    High_Value_Flag,
    COUNT(*) AS Count,
    CONCAT('₹', ROUND(AVG(Amount), 2)) AS Avg_Amount,
    CONCAT('₹', ROUND(SUM(Amount), 2)) AS Total_Amount
FROM bank_trnx
GROUP BY Bank_Name, Branch, High_Value_Flag;

-- 18.) Percentage of Transactions by Category
SELECT 
    Transaction_Category,
    COUNT(*) AS Count,
    CONCAT(ROUND((COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()), 2), '%') AS Percentage
FROM bank_trnx
GROUP BY Transaction_Category
ORDER BY Count DESC;

-- 19.) Customer Transaction Behavior
SELECT Customer_Name,
    COUNT(*) AS Total_Transactions,
    CONCAT('₹', FORMAT(SUM(CASE WHEN Transaction_Type = 'Credit' THEN Amount ELSE 0 END), 2)) AS Total_Credit,
    CONCAT('₹', FORMAT(SUM(CASE WHEN Transaction_Type = 'Debit' THEN Amount ELSE 0 END), 2)) AS Total_Debit,
    CONCAT('₹', FORMAT(
         SUM(CASE WHEN Transaction_Type = 'Credit' THEN Amount ELSE 0 END) - 
         SUM(CASE WHEN Transaction_Type = 'Debit' THEN Amount ELSE 0 END), 2)) AS Net_Amount
FROM bank_trnx
GROUP BY Customer_Name
HAVING COUNT(*) > 5;

-- 20 Most Active Transaction Methods
SELECT 
    Transaction_Method,
    COUNT(*) AS Usage_Count,
    CONCAT(ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM bank_trnx)), 2), '%') AS Usage_Percentage
FROM bank_trnx
GROUP BY Transaction_Method
ORDER BY Usage_Count DESC;

-- 21.) Seasonal Spending Patterns
SELECT 
Bank_Name,
Branch,
    Month,
    Transaction_Category,
    COUNT(*) AS Transaction_Count,
    concat('₹', round(sum(Amount), 2)) as Total_Amount
FROM bank_trnx
WHERE Transaction_Type = 'Debit'
GROUP BY Bank_Name, Branch,Month, Transaction_Category
ORDER BY Month, Total_Amount DESC;

-- 22.)Customer Balance Analysis (Max-Min)
SELECT 
    Bank_Name,
    Branch,
    Customer_Name,
    CONCAT('₹', ROUND(AVG(Balance), 2)) AS Avg_Balance,
    CONCAT('₹', ROUND(MAX(Balance), 2)) AS Max_Balance,
    CONCAT('₹', ROUND(MIN(Balance), 2)) AS Min_Balance
FROM bank_trnx
GROUP BY Bank_Name, Branch, Customer_Name
ORDER BY AVG(Balance) DESC;

-- 23.) Branch Performance Analysis
SELECT 
    Branch,
    Bank_Name,
    COUNT(*) AS Transaction_Count,
    CONCAT('₹', ROUND(SUM(Amount), 2)) AS Total_Amount,
    CONCAT('₹', ROUND(AVG(Amount), 2)) AS Avg_Transaction_Size
FROM bank_trnx
GROUP BY Branch, Bank_Name
ORDER BY SUM(Amount) DESC;

-- 24.) Customer Segmentation by Activity
SELECT 
    Customer_Name,
    CASE 
        WHEN COUNT(*) >= 10 THEN 'High Frequency'
        WHEN COUNT(*) BETWEEN 5 AND 9 THEN 'Medium Frequency'
        ELSE 'Low Frequency'
    END AS Activity_Level,
    COUNT(*) AS Transaction_Count,
    SUM(Amount) AS Total_Amount
FROM bank_trnx
GROUP BY Customer_Name;

-- 25.)  Refund Analysis
SELECT 
    Customer_Name,
    COUNT(*) AS Refund_Count,
    CONCAT('₹', ROUND(SUM(Amount), 2)) AS Total_Refund_Amount,
    CONCAT('₹', ROUND(AVG(Amount), 2)) AS Avg_Refund_Amount
FROM bank_trnx
WHERE Description LIKE '%Refund%'
GROUP BY Customer_Name
HAVING COUNT(*) > 1
ORDER BY Total_Refund_Amount DESC;

-- 26.) Income vs Expense Analysis
SELECT 
    Customer_Name,
    CONCAT('₹', FORMAT(SUM(CASE WHEN Transaction_Type = 'Credit' THEN Amount ELSE 0 END), 2)) AS Total_Income,
    CONCAT('₹', FORMAT(SUM(CASE WHEN Transaction_Type = 'Debit' THEN Amount ELSE 0 END), 2)) AS Total_Expenses,
    CONCAT('₹', FORMAT((SUM(CASE WHEN Transaction_Type = 'Credit' THEN Amount ELSE 0 END) - 
     SUM(CASE WHEN Transaction_Type = 'Debit' THEN Amount ELSE 0 END)), 2)) AS Net_Savings
FROM bank_trnx
GROUP BY Customer_Name
ORDER BY (SUM(CASE WHEN Transaction_Type = 'Credit' THEN Amount ELSE 0 END) - 
          SUM(CASE WHEN Transaction_Type = 'Debit' THEN Amount ELSE 0 END)) DESC;

-- 27.)  Customer Loyalty by Bank 
SELECT 
    Customer_Name,
    Bank_Name,
    COUNT(*) AS Transaction_Count,
    concat('₹', round(sum(Amount), 2)) as Total_Amount
FROM bank_trnx
GROUP BY Customer_Name, Bank_Name
HAVING COUNT(*) >= 3
ORDER BY Transaction_Count DESC;

-- 28.) Popular Transaction Categories by Bank
SELECT 
    Bank_Name,
    Transaction_Category,
    COUNT(*) AS Transaction_Count,
   concat('₹', round(sum(Amount), 2)) as Total_Amount
FROM bank_trnx
GROUP BY Bank_Name, Transaction_Category
ORDER BY Bank_Name, Transaction_Count DESC;

-- 29.) Transaction Method Preference by Age Group
SELECT 
    CASE 
        WHEN Customer_Name LIKE 'Mr.%' OR Customer_Name LIKE 'Mrs.%' OR Customer_Name LIKE 'Dr.%' THEN 'Senior'
        ELSE 'General'
    END AS Customer_Type,
    Transaction_Method,
    COUNT(*) AS Usage_Count,
     concat('₹', round(AVG(Amount),2)) AS Avg_Transaction_Amount
FROM bank_trnx
GROUP BY Customer_Type, Transaction_Method
ORDER BY Customer_Type, Usage_Count DESC;

-- 30.) Transaction Size Distribution
SELECT 
    CASE 
        WHEN Amount <= 1000 THEN 'Small (<=1K)'
        WHEN Amount BETWEEN 1001 AND 5000 THEN 'Medium (1K-5K)'
        WHEN Amount BETWEEN 5001 AND 10000 THEN 'Large (5K-10K)'
        ELSE 'Very Large (>10K)'
    END AS Amount_Range,
    COUNT(*) AS Transaction_Count,
    concat('₹', round(sum(Amount), 2)) as Total_Amount
FROM bank_trnx
GROUP BY Amount_Range
ORDER BY MIN(Amount);





