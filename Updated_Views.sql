 CREATE or REPLACE VIEW employee_branch_count AS
SELECT BRANCH_ID,  count(EMPLOYEE_ID) AS EMPLOYEE_COUNT
  FROM Employee
  Group BY  BRANCH_ID;
  
  select * from employee_branch_count ;
  
  CREATE or REPLACE VIEW salary_range_dept AS
  SELECT MIN(SALARY) AS MIN_SALARY ,MAX(SALARY) AS MAX_SALARY, DEPARTMENT
  FROM EMPLOYEE
  GROUP BY  DEPARTMENT

SELECT * FROM salary_range_dept ;


CREATE or REPLACE VIEW branch_loan_count AS
  select  e.BRANCH_ID , count(l.LoanAccNumber) as Loan_count
  from Employee e inner join Loan l
  on e.employee_id = l.Approved_By_ID 
  GROUP BY e.BRANCH_ID;
  
  select * from branch_loan_count;
  
  CREATE or REPLACE VIEW Zip_Cust_Loan AS
    select Br.Zipcode as Zipcode, count(Cus.Count_C) as Customer_count, count(br.AccNum) as Loan_Acc_Count
    from
    (
        select b.Zipcode as Zipcode,count(bl.AccNum) as AccNum
        from 
                Branch b inner join
                ( 
                    select lt.BranchIFSC as BranchIFSC, count(l.LoanAccNumber) as AccNum
                    from LOAN_TRANSACTIONS lt 
                    inner join Loan l
                    on lt.LoanAccNumber = l.LoanAccNumber
                    group by lt.BranchIFSC) bl
                    
        on b.BranchIFSC = bl.BranchIFSC
        group by b.Zipcode) Br 
        
        inner join
    (
        select C.Zipcode as Zipcode, count(C.Customer_ID) as Count_C
        from Customer C
        group by C.Zipcode ) Cus
        
    on Br.Zipcode = Cus.Zipcode
    group by Br.Zipcode;
    
    Select * from Zip_Cust_Loan;
    
    