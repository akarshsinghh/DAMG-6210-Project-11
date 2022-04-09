begin 
for rec in (
           select table_name  from user_tables 
           where  not   
           regexp_like(table_name, 'keep_tab1|keep_tab2|^ASB')  
           ) 
loop  
    begin  
    execute immediate 'drop table '||rec.table_name;  
    exception when others then   
    dbms_output.put_line(rec.table_name||':'||sqlerrm);  
    end;  
end loop;               
end;  
/

CREATE TABLE LOAN 
(LoanAccNumber number NOT NULL PRIMARY KEY,
Customer_ID int CONSTRAINT positive_customer_id CHECK (Customer_ID > 0),
LOANIFSC Char(11),
Principal decimal (10,2) CONSTRAINT positive_principal CHECK (Principal > 0) ,
Outstanding Decimal (10,2)  CONSTRAINT positive_outstanding CHECK (Outstanding > 0),
Loan_Type number(1) CHECK (Loan_Type > 0),
Status Varchar (20),
Approved_By_ID int,
Sanction_Date date,
Duration decimal (2,2),
CONSTRAINT check_loan_period
  CHECK (Duration between 0 and 50)
);


CREATE TABLE LOAN_TYPE
( Loan_Type number(1) NOT NULL PRIMARY KEY CHECK (Loan_Type > 0),
Interest_Rate decimal (2,2) CONSTRAINT positive_interest_rate CHECK (Interest_Rate > 0),
Category varchar (20) NOT NULL
);

CREATE TABLE LOAN_TRANSACTIONS
(LOAN_TRANS_ID number generated by default as identity NOT NULL PRIMARY KEY,
 BRANCHIFSC CHAR (11) NOT NULL,
 LOANIFSC CHAR (11) NOT NULL,
 LoanAccNumber number NOT NULL,
 Amount Decimal (10,2) NOT NULL CONSTRAINT positive_amount CHECK (Amount > 0),
 Transaction_Date Date NOT NULL
);

CREATE TABLE LOAN_INTEREST
( INTEREST_ID number generated by default as identity NOT NULL PRIMARY KEY,
 Account_Number number not null,
 BRANCHIFSC char (11) NOT NULL,
 Deposit_Date Date NOT NULL
 );
 
 
 
 
 