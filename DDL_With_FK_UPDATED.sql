--create user appadmin identified by "NEU@BostonCampus2022#";

--grant connect,resource to appadmin;

--alter user appadmin default tablespace data ;

--alter user appadmin quota unlimited on data;

SET SERVEROUTPUT ON;

declare
    constr all_constraints.constraint_name%TYPE;
begin
    for constr in
        (select constraint_name from all_constraints
        where table_name = 'D'
        and owner = 'TRANEE')
    loop
        execute immediate 'alter table D disable constraint '||constr.constraint_name;
    end loop;
end;
/


begin 
for rec in (
           select table_name from user_tables 
           where  not   
           regexp_like(table_name, 'keep_tab1|keep_tab2|^ASB')
           
           
           ) 
loop  
    begin  
    execute immediate 'drop table '||rec.table_name || ' cascade constraints';  
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
Duration decimal (4,2),
CONSTRAINT check_loan_period
  CHECK (Duration between 0 and 50),
CONSTRAINT left_to_pay
  CHECK (Principal> Outstanding)
  
);


CREATE TABLE LOAN_TRANSACTIONS
(LOAN_TRANS_ID number generated by default as identity PRIMARY KEY,
 BRANCHIFSC CHAR (11) NOT NULL,
 LOANIFSC CHAR (11) NOT NULL,
 LoanAccNumber number NOT NULL,
 Amount Decimal (10,2) NOT NULL CONSTRAINT positive_amount CHECK (Amount > 0),
 Transaction_Date Date NOT NULL
);

CREATE TABLE LOAN_INTEREST
( INTEREST_ID number generated by default as identity PRIMARY KEY,
 LoanAccNumber number not null,
 BRANCHIFSC char (11) NOT NULL,
 Loan_Type number(1),
 Deposit_Date Date NOT NULL
 );
 


CREATE TABLE Account_Interest(
Interest_ID INT GENERATED BY DEFAULT AS IDENTITY,
Account_Number Number NOT NULL,
BranchIFSC VARCHAR(11) NOT NULL,
Created_Date DATE NOT NULL,
PRIMARY KEY (Interest_ID)
);

CREATE TABLE Account_Status(
Status_ID INT GENERATED BY DEFAULT AS IDENTITY,
Account_Number NUMBER NOT NULL,
Status VARCHAR(20) NOT NULL,
Created_Date DATE NOT NULL,
PRIMARY KEY (Status_ID)
);

CREATE TABLE WORKS_WITH(
Customer_ID INT NOT NULL,
Employee_ID INT NOT NULL,
Relationship varchar(20),
PRIMARY KEY (Customer_ID,Employee_ID)
);

CREATE TABLE Branch_Supplier (
Supplier_ID int PRIMARY KEY,
Supplier_Name  VARCHAR(20) NOT NULL,
Supplier_Type  VARCHAR(20),
Branch_ID NUMBER
);



CREATE TABLE EMPLOYEE 
   (
    EMPLOYEE_ID NUMBER NOT NULL, 
	BRANCH_ID NUMBER(10,0) NOT NULL, 
	DEPARTMENT VARCHAR2(20 BYTE) NOT NULL, 
	FIRST_NAME VARCHAR2(20 BYTE) NOT NULL, 
	LAST_NAME VARCHAR2(20 BYTE), 
	SEX CHAR(1), 
	DOB DATE, 
	SALARY NUMBER(10,2), 
	EMP_ROLE VARCHAR2(20 BYTE), 
	EMAIL_ID VARCHAR2(40 BYTE) UNIQUE, 
	CONTACT_NO NUMBER(10,0) NOT NULL UNIQUE, 
	SUPERVISOR_ID NUMBER, 
	 CONSTRAINT "EMP_EMPLOYEE_ID" CHECK ( Employee_Id > 0 ), 
	 CONSTRAINT "EMP_BRANCH_ID" CHECK (Branch_Id > 0 ), 
	 CONSTRAINT "GENDER_CHECK" CHECK (Sex IN ('F','M','O')), 
	 CONSTRAINT "SAL_CHECK" CHECK (Salary > 0 ), 
	 CONSTRAINT "CONTACT_CHECK" CHECK ( LENGTH(CONTACT_NO) = 10 ), 
	 PRIMARY KEY ("EMPLOYEE_ID")
    ); 
    

CREATE TABLE TRANSACTIONS(

    Tansaction_ID   int primary key,
    Debit_Account   number,
    Credit_Account  number,
    IFSC_Code_Debit char(11),
    IFSC_Code_Credit char (11),
    Amount          Decimal(10,2) not null constraint amt_check check( Amount > 0),
    Transaction_date date,
    Message         varchar(100),
    Status          varchar(20)

);



CREATE TABLE CUSTOMER(
Customer_ID INT PRIMARY KEY,
First_Name VARCHAR(20) NOT NULL,
Last_Name VARCHAR(20) NOT NULL,
DOB Date,
Works_at VARCHAR(20),
Sex VARCHAR(1) CONSTRAINT Genders CHECK(Sex IN ('M','F','O')),
Apt_No VARCHAR(20),
Street VARCHAR(20),
City VARCHAR(20),
CState VARCHAR(2),
Zipcode int CONSTRAINT Zip_Length CHECK (LENGTH(Zipcode)=5),
Phone int UNIQUE CONSTRAINT Phone_Length CHECK(LENGTH(Phone)=10)
);


CREATE TABLE Account(
AccountNumber NUMBER NOT NULL,
Account_Type VARCHAR(20) NOT NULL,
BranchIFSC CHAR(11) NOT NULL,
Customer_ID INT,
Account_Balance DECIMAL NOT NULL CONSTRAINT Balance_Positive CHECK (Account_Balance > 0),
PRIMARY KEY (AccountNumber)
);

 CREATE TABLE LOAN_TYPE
( Loan_Type number(1) PRIMARY KEY CHECK (Loan_Type > 0),
Interest_Rate decimal (4,2) CONSTRAINT positive_interest_rate CHECK (Interest_Rate > 0),
Category varchar (20) NOT NULL
);

CREATE TABLE Branch (
BranchIFSC Char(11) PRIMARY KEY CONSTRAINT elevenchar CHECK (length(BranchIFSC)=11),
Branch_ID   int UNIQUE,
Address  VARCHAR(20) NOT NULL,
Street  VARCHAR(20)NOT NULL,
City   VARCHAR(20) NOT NULL,
State Char(2) NOT NULL,
Zipcode int,
Manager_ID int CONSTRAINT Positive_Manager_ID CHECK(Manager_ID>0)
);

-- Branch (NO FK)


-- Branch Supplier
ALTER TABLE Branch_Supplier ADD CONSTRAINT FK_Branch_ID FOREIGN KEY (Branch_ID) REFERENCES Branch(Branch_ID) ON DELETE CASCADE;

-- Transactions
ALTER TABLE Transactions ADD CONSTRAINT FK_Debit_Account FOREIGN KEY (Debit_Account) REFERENCES Account(AccountNumber)ON DELETE CASCADE;
ALTER TABLE Transactions ADD CONSTRAINT FK_Credit_Account FOREIGN KEY (Credit_Account) REFERENCES Account(AccountNumber)ON DELETE CASCADE;

-- Account Status
ALTER TABLE Account_Status ADD CONSTRAINT FK_Acc_Number FOREIGN KEY (Account_Number) REFERENCES Account(AccountNumber)ON DELETE CASCADE;

-- Account Interest
ALTER TABLE Account_Interest ADD CONSTRAINT FK_AccInterest_Acc_Number FOREIGN KEY (Account_Number) REFERENCES Account(AccountNumber)ON DELETE CASCADE;

-- Account
ALTER TABLE Account ADD CONSTRAINT FK_Account_Customer_ID FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID) ON DELETE CASCADE;

-- Loan
ALTER TABLE Loan ADD CONSTRAINT FK_Customer_ID FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID)ON DELETE CASCADE;
ALTER TABLE Loan ADD CONSTRAINT FK_Loan_Type FOREIGN KEY (Loan_Type) REFERENCES Loan_Type(Loan_Type)ON DELETE CASCADE;
ALTER TABLE Loan ADD CONSTRAINT FK_Loan_IFSC FOREIGN KEY (LOANIFSC) REFERENCES Branch(BranchIFSC)ON DELETE CASCADE;
ALTER TABLE Loan ADD CONSTRAINT FK_Sanction_ID FOREIGN KEY (Approved_By_ID) REFERENCES Employee(Employee_ID)ON DELETE CASCADE;

-- Loan Transactions

ALTER TABLE Loan_Transactions ADD CONSTRAINT FK_LIFSC FOREIGN KEY (LoanIFSC) REFERENCES Branch(BranchIFSC)ON DELETE CASCADE;
ALTER TABLE Loan_Transactions ADD CONSTRAINT FK_LoanAccNumber FOREIGN KEY (LoanAccNumber) REFERENCES Loan(LoanAccNumber)ON DELETE CASCADE;

-- Loan Interest
ALTER TABLE Loan_Interest ADD CONSTRAINT FK_Interest_LoanAccNumber FOREIGN KEY (LoanAccNumber) REFERENCES Loan(LoanAccNumber)ON DELETE CASCADE;
ALTER TABLE Loan_Interest ADD CONSTRAINT FK_Loan_Interest_IFSC FOREIGN KEY (BranchIFSC) REFERENCES Branch(BranchIFSC)ON DELETE CASCADE;
ALTER TABLE Loan_Interest ADD CONSTRAINT FK_Loan_Interst_Loan_Type FOREIGN KEY (Loan_Type) REFERENCES Loan_Type(Loan_Type) ON DELETE CASCADE;
--
-- Loan_Type (NO FK) 

-- Works With
ALTER TABLE Works_With ADD CONSTRAINT FK_Works_With_Emp FOREIGN KEY (Employee_ID) REFERENCES Employee(Employee_ID) ON DELETE CASCADE;
ALTER TABLE Works_With ADD CONSTRAINT FK_Works_With_Customer FOREIGN KEY (Customer_ID) REFERENCES Customer(Customer_ID) ON DELETE CASCADE;

-- Employee
ALTER TABLE Employee ADD CONSTRAINT FK_Emp_Branch FOREIGN KEY (Branch_ID) REFERENCES Branch(Branch_ID) ON DELETE CASCADE;

-- Customer (NO FK)


-- Data Inserting Branch
INSERT INTO BRANCH VALUES ('DMDD0454500',1,'405 Huntington Ave','Park Street','Boston','MA',02120,012324);
INSERT INTO BRANCH VALUES ('DMDD0101022',2,'111 Howard Ave','Tremont Street','Boston','MA',02180,055564);
INSERT INTO BRANCH VALUES ('DMDD0333100',3,'333 Longwood Ave','Milk Street','Boston','MA',02190,037567);

-- Branch Supplier

INSERT INTO Branch_Supplier VALUES (1,'Secure Tech','Security',1);
INSERT INTO Branch_Supplier VALUES (2,'Paper and Co','Envelops',2);
INSERT INTO Branch_Supplier VALUES (3,'Baggit','Fabric Bag',3);
INSERT INTO Branch_Supplier VALUES (4,'Electroplast','Hardware',1);
INSERT INTO Branch_Supplier VALUES (5,'HomeDepot','Stationary',2);
INSERT INTO Branch_Supplier VALUES (6,'BestBuy',' ',3);

-- Data Inserting Employee
INSERT INTO EMPLOYEE VALUES (012324, 1, 'Research', 'Akarsh', 'Singh', 'M',TO_DATE('1999-03-09','YYYY-MM-DD'), 120000, 'Branch Manager', 'akarshsinghh@gmail.com', 7710037766, '');
INSERT INTO EMPLOYEE VALUES (055564, 2, 'Sales', 'Alex', 'ONeil', 'M',TO_DATE('1997-10-06','YYYY-MM-DD'), 115000, 'Branch Manager', 'neilalex32@gmail.com', 8910037766, '');
INSERT INTO EMPLOYEE VALUES (037567, 3, 'Sales', 'Kylie', 'James', 'F',TO_DATE('1992-11-01','YYYY-MM-DD'), 130000, 'Branch Manager', 'thekyliejames@outlook.com', 8910032459, '');
INSERT INTO EMPLOYEE VALUES (036940, 3, 'Sales', 'Megan', 'Smith', 'F',TO_DATE('1999-06-30','YYYY-MM-DD'), 67000, 'Accountant', 'megans30@outlook.com', 8910076403, 037567);
INSERT INTO EMPLOYEE VALUES (036113, 3, 'Software', 'Ravi', 'Teja', 'M',TO_DATE('1998-06-13','YYYY-MM-DD'), 90000, 'Developer', 'tejaravi_tv@gmail.com', 8570076403, '');
INSERT INTO EMPLOYEE VALUES (036999, 3, 'Sales', 'Charlottee', 'Malik', 'F',TO_DATE('1997-02-12','YYYY-MM-DD'), 75000, 'Relationship Officer', 'mcharlottee@outlook.com', 8579076403, 037567);
INSERT INTO EMPLOYEE VALUES (036941, 3, 'Marketing', 'Chang', 'Cho', 'O',TO_DATE('1995-03-24','YYYY-MM-DD'), 77000, 'Head', 'chochangg@outlook.com', 8910076507, '');
INSERT INTO EMPLOYEE VALUES (036942, 3, 'Operations', 'John', 'Ledger', 'M',TO_DATE('1998-06-17','YYYY-MM-DD'), 85000, 'Associate', 'johnl@yahoo.com', 8910071122, 011818);
INSERT INTO EMPLOYEE VALUES (036933, 3, 'Operations', 'Mark', 'Benetton', 'M',TO_DATE('1997-10-30','YYYY-MM-DD'), 84000, 'Associate', 'markbene@outlook.com', 8910072241, 011818);
INSERT INTO EMPLOYEE VALUES (011818, 3, 'Operations', 'Grace', 'Fernandes', 'F',TO_DATE('1982-09-27','YYYY-MM-DD'), 93000, 'Senior Associate', 'gracefernandes30@gmail.com', 8910078979, 037567);
INSERT INTO EMPLOYEE VALUES (056940, 2, 'Sales', 'Josh', 'Jacobs', 'M',TO_DATE('1987-07-18','YYYY-MM-DD'), 69000, 'Accountant', 'srjjacobs@outlook.com', 7120076403,055564);
INSERT INTO EMPLOYEE VALUES (056941, 2, 'Sales', 'Megan', 'Smith', 'F',TO_DATE('1999-06-30','YYYY-MM-DD'), 67000, 'Accountant', 'megansmithh@yahoo.com', 7770076403,055564);
INSERT INTO EMPLOYEE VALUES (056942, 2, 'Operations', 'Elle', 'Bridge', 'F',TO_DATE('1996-08-29','YYYY-MM-DD'), 72000, 'Associate', 'bridgeelle101@outlook.com', 8880072403, 059999);
INSERT INTO EMPLOYEE VALUES (056943, 2, 'Operations', 'Blake', 'Springer', 'M',TO_DATE('1994-06-30','YYYY-MM-DD'), 87000, 'Associate', 'springer.blake@gmail.com', 8999076403, 059999);
INSERT INTO EMPLOYEE VALUES (059999, 2, 'Operations', 'Ajit', 'Poonawala','O',TO_DATE('1975-10-21','YYYY-MM-DD'), 105000, 'Lead Associate', 'poonawal.ajit1@gmail.com', 8999076400, 055564);
INSERT INTO EMPLOYEE VALUES (016940, 1, 'Sales', 'Ram', 'Charan', 'M',TO_DATE('1986-04-18','YYYY-MM-DD'), 69000, 'Accountant', 'rcharan@outlook.com', 8120076403,012324);
INSERT INTO EMPLOYEE VALUES (016941, 1, 'Sales', 'Sharvi', 'Jaffery', 'F',TO_DATE('1999-04-17','YYYY-MM-DD'), 67000, 'Accountant', 'sharvijj@gmail.com', 8770076403,012324);
INSERT INTO EMPLOYEE VALUES (016942, 1, 'Operations', 'Darren', 'Franco', 'M',TO_DATE('1993-08-29','YYYY-MM-DD'), 77000, 'Associate', 'd.franco@outlook.com', 8780076403, 019999);
INSERT INTO EMPLOYEE VALUES (016943, 1, 'Operations', 'Cherry', 'Chan', 'O',TO_DATE('1997-01-05','YYYY-MM-DD'), 72000, 'Associate', 'chancherry05@gmail.com', 7699076403, 019999);
INSERT INTO EMPLOYEE VALUES (019999, 1, 'Operations', 'Nick', 'Bilzerian','M',TO_DATE('1971-11-22','YYYY-MM-DD'), 107000, 'Lead Associate', 'bilznick71@gmail.com', 8000076403, 012324);

INSERT INTO Employee values(100101, 1,'Insurance','Ayushi','Patel', 'F',DATE '1980-11-08',25000,'Accountant','ayushipatel@gmail.com',7856912345, 012324);
INSERT INTO Employee values(101101, 1,'Insurance','Ruchika','Sinha', 'F',DATE '1983-10-08',25000,'Accountant','ruchika19gmail.com',7856912389, 012324);
INSERT INTO Employee values(102101, 2, 'Credit cards','Akshit','Arora', 'M',DATE '1990-10-08',60000,'clerk','akshit20arora@gmail.com',7856912333,055564);
INSERT INTO Employee values(199111, 3,'Credit cards','Eddy','Sharma', 'M',DATE '1980-05-08',50000,'Provisionary Officer','eddysharma123@gmail.com',9999988889, 037567);
INSERT INTO Employee values(104131, 1,'Insurance','Aditya','Tilak', 'M',DATE '1989-10-08',50000,'Banker','adityatilak@gmail.com',7856912322, 012324);
INSERT INTO Employee values(105534, 3,'Private banking','Megshi','Thakur', 'F',DATE '1980-11-08',50000,'Clerk','megshithakur@gmail.com',7856912344, 037567);
INSERT INTO Employee values(105745, 2,'Credit cards','Rinita','Srivastva', 'F',DATE '1967-10-08',50000,'Provisionary Officer','rini@yahoo.com',7856913214, 055564);
INSERT INTO Employee values(107310, 3,'Credit cards','Sneha','Mohan', 'F',DATE '1999-10-08',90000,'Accountant','sneha@yahoo.com',7856913213, 037567);
INSERT INTO Employee values(109557, 2,'Insurance','Sidhant','Kohli', 'M',DATE '1995-10-04',30000,'LIC','sid@yahoo.com',7856913220, 055564);
INSERT INTO Employee values(110644, 3,'Private banking','Yash','Navadiya', 'M',DATE '1989-10-08',30000,'Accountant','yash@yahoo.com',7856913221, 037567);
INSERT INTO Employee values(111101, 1,'Private banking','Virendra','Singh', 'M',DATE '1986-10-08',70000,'Clerk','viv@yahoo.com',7856913229, 012324);
INSERT INTO Employee values(113104, 2,'Insurance','Radhika','Madan', 'F',DATE '1981-10-08',70000,'LIC','radhika@yahoo.com',7856913005, 055564);
INSERT INTO Employee values(114107, 1,'Private banking','Boney','Singh', 'M',DATE '1980-10-08',70000,'LIC','bon@yahoo.com',7856913008, 02324);
INSERT INTO Employee values(115005, 3,'Private banking','Disha','Parmar', 'F',DATE '1968-10-07',70000,'LIC','disha@yahoo.com',7856913007, 037567);
INSERT INTO Employee values(118202, 2,'Private banking','Barkha','Duta', 'F',DATE '1966-11-08',70000,'Banker','barkhadutt@yahoo.com',7856913777, 055564);
INSERT INTO Employee values(119324, 1,'Private banking','Mrinal','Sharma', 'F',DATE '1967-10-08',70000,'Banker','mrinal42@yahoo.com',7856914007, 012324);
INSERT INTO Employee values(120424, 1,'Private banking','Apsara','Sharma', 'F',DATE '1964-10-08',70000,'Banker','mrinal@yahoo.com',7856914003, 012324);

-- Customer
INSERT INTO Customer values(100000,'John','Sander',TO_DATE('1998-05-19','YYYY-MM-DD'),'NE','M','14','Calumet St', 'Boston', 'MA', '12345', '9999999999');
INSERT INTO Customer values(100001,'Adam','Levine',TO_DATE('1990-04-18','YYYY-MM-DD'),'NE','M','14','Milk Street', 'Boston', 'MA', '12345', '9658365933');
INSERT INTO Customer values(100002,'Josh', 'Curry',TO_DATE('1990-03-13','YYYY-MM-DD'),'NE','M','15','Park Street', 'Boston', 'MA', '12345', '8572212077');
INSERT INTO Customer values(100003,'Lakshana','Kolur',TO_DATE('1997-02-14','YYYY-MM-DD'),'SE','F','05','South End Street', 'Boston', 'MA', '12345', '7575838485');
INSERT INTO Customer values(100004,'Clara','Goerge',TO_DATE('1972-03-19','YYYY-MM-DD'),'SE','F','03','Hill Road', 'Boston', 'MA', '12345', '7863542435');
INSERT INTO Customer values(100005,'Meghan','Ritter',TO_DATE('1973-06-16','YYYY-MM-DD'),'NE','F','14','Carter Street', 'Boston', 'MA', '12345', '8755235554');
INSERT INTO Customer values(100006,'Rajdeep','Mamtani',TO_DATE('1979-03-12','YYYY-MM-DD'),'SE','M','14','Mac Street', 'Allston', 'MA', '12345', '7843563450');
INSERT INTO Customer values(100007,'Sonal','Singh',TO_DATE('1988-01-18','YYYY-MM-DD'),'SE','F','23','Shipman Street', 'Allston', 'MA', '12345', '8954398443');
INSERT INTO Customer values(100008,'Jayashree','Kumari',TO_DATE('1984-06-14','YYYY-MM-DD'),'SE','F','14','India Street', 'Allston', 'MA', '12345', '9787837854');
INSERT INTO Customer values(100009,'Harper','Selter',TO_DATE('1966-06-06','YYYY-MM-DD'),'SE','F','11','Mass Ave', 'Cambridge', 'MA', '12345', '9827354354');
INSERT INTO Customer values(100010,'Amol', 'Srivatsav',TO_DATE('1987-05-09','YYYY-MM-DD'),'SE','O','08','Dennis Ave', 'Cambridge', 'MA', '12345', '9873455445');
INSERT INTO Customer values(100011,'Abhimanyu','Sarda',TO_DATE('1990-05-12','YYYY-MM-DD'),'NE','O','14','Huntington Ave', 'Cambridge', 'MA', '12345', '8754493433');
INSERT INTO Customer values(100012,'Amy', 'Hazarika',TO_DATE('1987-05-11','YYYY-MM-DD'),'NE','F','14','7th Ave', 'Cambridge', 'MA', '12345', '9865489380');
INSERT INTO Customer values(100013, 'Tracy' ,'Zelensky',TO_DATE('1988-05-12','YYYY-MM-DD'),'SE','F','14','Light Road', 'Boston', 'MA', '12345', '7893548993');
INSERT INTO Customer values(100014,'Sharron', 'Naim',TO_DATE('1988-07-13','YYYY-MM-DD'),'SE','F','14','Sea Street', 'Boston', 'MA', '12345', '8889876543');
INSERT INTO Customer values(100015,'Charlie', 'Watson',TO_DATE('1990-02-10','YYYY-MM-DD'),'NE','F','14','13th Street', 'Amherst', 'MA', '12345', '7878676887');
INSERT INTO Customer values(100016,'Mrinal', 'Kumar',TO_DATE('1991-08-08','YYYY-MM-DD'),'NE','M','14','Curry Road', 'Amherst', 'MA', '12345', '7665687670');
INSERT INTO Customer values(100017,'Margot', 'Pincha',TO_DATE('1996-03-13','YYYY-MM-DD'),'SE','F','21','Belmont St', 'Amherst', 'MA', '12345', '8765432109');
INSERT INTO Customer values(100019,'Sowmya', 'Raghavan',TO_DATE('1994-04-19','YYYY-MM-DD'),'NE','M','14','Oak Road', 'Amherst', 'MA', '12345', '8765409876');
INSERT INTO Customer values(100020,'Anukriti','Joshi',TO_DATE('1989-03-15','YYYY-MM-DD'),'NE','M','14','Darling St', 'Cambridge', 'MA', '12345', '8754290454');

--Account 
INSERT INTO Account VALUES (3719713158855555, 'Savings', 'DMDD0454500', 100000, 16500);
INSERT INTO Account VALUES (3719713158835300, 'Savings', 'DMDD0454500', 100001, 1500);
INSERT INTO Account VALUES (71086643758945400, 'Savings', 'DMDD0101022',100002, 2090);
INSERT INTO Account VALUES (3690859741294280, 'Savings', 'DMDD0454500', 100003, 8056);
INSERT INTO Account VALUES (37530666568966100, 'Savings', 'DMDD0333100', 100004, 3098);
INSERT INTO Account VALUES (70048841700216300, 'Savings', 'DMDD0454500', 100005, 5054);
INSERT INTO Account VALUES (89135767380499400, 'Savings', 'DMDD0101022', 100006, 25456);
INSERT INTO Account VALUES (12494980148173100, 'Checking', 'DMDD0333100', 100007, 35535);
INSERT INTO Account VALUES (8744336085399580, 'Checking', 'DMDD0101022', 100008, 1890);
INSERT INTO Account VALUES (64289489845768000, 'Checking', 'DMDD0454500', 100009, 10516);
INSERT INTO Account VALUES (70149340835549500, 'Checking', 'DMDD0333100', 100010, 10538);
INSERT INTO Account VALUES (1359713158835400, 'Savings', 'DMDD0333100', 100011, 1564.96);
INSERT INTO Account VALUES (7599713158835400, 'Savings', 'DMDD0454500', 100012, 18000.56);
INSERT INTO Account VALUES (9009713158835400, 'Savings', 'DMDD0101022', 100013, 7795);
INSERT INTO Account VALUES (1212713158835400, 'Savings', 'DMDD0333100', 100014, 900.99);
INSERT INTO Account VALUES (8880713158835400, 'Savings', 'DMDD0454500', 100015, 3486);
INSERT INTO Account VALUES (1289713158835400, 'Savings', 'DMDD0101022', 100016, 4200);
INSERT INTO Account VALUES (9560713158835400, 'Savings', 'DMDD0333100', 100017, 34600);
INSERT INTO Account VALUES (3719713158839988, 'Savings', 'DMDD0101022', 100019, 13003);
INSERT INTO Account VALUES (3719713158837659, 'Savings', 'DMDD0333100', 100020, 6305);
INSERT INTO Account VALUES (13719713158835300, 'Checking', 'DMDD0101022', 100011, 1890);
INSERT INTO Account VALUES (1086643758945400, 'Checking', 'DMDD0454500', 100012, 10516);
INSERT INTO Account VALUES (53153834006064000, 'Checking', 'DMDD0333100', 100013, 10538);

--Account Interest

INSERT INTO Account_Interest(account_number, branchifsc, created_date) VALUES (3719713158835300, 'DMDD0454500', '01-JAN-21');
INSERT INTO Account_Interest(account_number, branchifsc, created_date) VALUES (71086643758945400, 'DMDD0101022', '01-FEB-21');
INSERT INTO Account_Interest(account_number, branchifsc, created_date) VALUES (3690859741294280, 'DMDD0454500', '01-MAR-21');
INSERT INTO Account_Interest(account_number, branchifsc, created_date) VALUES (37530666568966100, 'DMDD0333100', '01-APR-21');
INSERT INTO Account_Interest(account_number, branchifsc, created_date) VALUES (70048841700216300, 'DMDD0454500', '01-MAY-21');
INSERT INTO Account_Interest(account_number, branchifsc, created_date) VALUES (89135767380499400, 'DMDD0101022', '01-JUN-21');
INSERT INTO Account_Interest(account_number, branchifsc, created_date) VALUES (12494980148173100, 'DMDD0333100', '01-JUL-21');
INSERT INTO Account_Interest(account_number, branchifsc, created_date) VALUES (8744336085399580, 'DMDD0101022', '01-AUG-21');
INSERT INTO Account_Interest(account_number, branchifsc, created_date) VALUES (64289489845768000, 'DMDD0454500', '01-SEP-21');
INSERT INTO Account_Interest(account_number, branchifsc, created_date) VALUES (70149340835549500, 'DMDD0333100', '01-OCT-21');
INSERT INTO Account_Interest(account_number, branchifsc, created_date) VALUES (8880713158835400, 'DMDD0454500', '01-JAN-21');

--Account Status

INSERT INTO Account_Status(account_number, status, created_date) VALUES (3719713158835300, 'Active', '05-JAN-21');
INSERT INTO Account_Status(account_number, status, created_date) VALUES (71086643758945400, 'Active', '09-FEB-21');
INSERT INTO Account_Status(account_number, status, created_date) VALUES (3690859741294280, 'Active', '08-MAR-21');
INSERT INTO Account_Status(account_number, status, created_date) VALUES (37530666568966100, 'Active', '07-APR-21');
INSERT INTO Account_Status(account_number, status, created_date) VALUES (70048841700216300, 'Active', '06-MAY-21');
INSERT INTO Account_Status(account_number, status, created_date) VALUES (89135767380499400, 'Active', '05-JUN-21');
INSERT INTO Account_Status(account_number, status, created_date) VALUES (12494980148173100, 'Active', '04-JUL-21');
INSERT INTO Account_Status(account_number, status, created_date) VALUES (8744336085399580, 'Active', '03-AUG-21');
INSERT INTO Account_Status(account_number, status, created_date) VALUES (64289489845768000, 'Active', '02-SEP-21');
INSERT INTO Account_Status(account_number, status, created_date) VALUES (70149340835549500, 'Active', '21-OCT-21');


--Loan Type

INSERT INTO LOAN_TYPE values (1,5.50,'Personal Loan');
INSERT INTO LOAN_TYPE values (2,10.00,'Home Loan');
INSERT INTO LOAN_TYPE values (3,8.00,'Business Loan');
INSERT INTO LOAN_TYPE values (4,7.50,'Education Loan');
-- Loan
INSERT INTO LOAN values(44689319,100000,'DMDD0333100',500,399, 1,'Active',100101,TO_DATE('2021-01-09','YYYY-MM-DD'),5.50);
INSERT INTO LOAN values(77489838,100001,'DMDD0101022',2000,800, 2,'Active',104131,TO_DATE('2020-03-11','YYYY-MM-DD'),10.00);
INSERT INTO LOAN values(63892734,100002,'DMDD0454500',690,0.1, 3,'Inactive',056942,TO_DATE('2015-05-20','YYYY-MM-DD'),8.00);
INSERT INTO LOAN values(63234734,100003,'DMDD0101022',8090,5070, 1,'Active',016940,TO_DATE('2018-10-10','YYYY-MM-DD'),5.50);
INSERT INTO LOAN values(18467484,100004,'DMDD0454500',5000,0.1, 2,'Inactive',036942,TO_DATE('2021-11-20','YYYY-MM-DD'),10.00);
INSERT INTO LOAN values(13892736,100005,'DMDD0333100',2000,800, 3,'Active',019999,TO_DATE('2010-09-20','YYYY-MM-DD'),8.00);
INSERT INTO LOAN values(53892734,100006,'DMDD0101022',600,500, 4,'Active',102101,TO_DATE('2000-06-02','YYYY-MM-DD'),7.50);
INSERT INTO LOAN values(61292734,100007,'DMDD0454500',20000,10000, 2,'Active',115005,TO_DATE('1991-05-10','YYYY-MM-DD'),10.00);

--Loan Transactions


INSERT INTO LOAN_TRANSACTIONS VALUES (1,'DMDD0333100','DMDD0333100',44689319,30,TO_DATE('2021-02-06','YYYY-MM-DD'));
INSERT INTO LOAN_TRANSACTIONS VALUES (2,'DMDD0333100','DMDD0333100',44689319,30,TO_DATE('2021-03-06','YYYY-MM-DD'));
INSERT INTO LOAN_TRANSACTIONS VALUES (3,'DMDD0333100','DMDD0333100',44689319,39,TO_DATE('2021-04-06','YYYY-MM-DD'));
INSERT INTO LOAN_TRANSACTIONS VALUES (4,'DMDD0101022','DMDD0101022',77489838,600,TO_DATE('2020-11-06','YYYY-MM-DD'));
INSERT INTO LOAN_TRANSACTIONS VALUES (5,'DMDD0101022','DMDD0101022',77489838,600,TO_DATE('2021-11-06','YYYY-MM-DD'));
INSERT INTO LOAN_TRANSACTIONS VALUES (6,'DMDD0454500','DMDD0454500',63892734,689.99,TO_DATE('2021-11-06','YYYY-MM-DD'));
INSERT INTO LOAN_TRANSACTIONS VALUES (7,'DMDD0101022','DMDD0101022',63234734,1200,TO_DATE('2018-11-06','YYYY-MM-DD'));
INSERT INTO LOAN_TRANSACTIONS VALUES (8,'DMDD0101022','DMDD0101022',63234734,1200,TO_DATE('2019-10-06','YYYY-MM-DD'));
INSERT INTO LOAN_TRANSACTIONS VALUES (9,'DMDD0101022','DMDD0101022',63234734,620,TO_DATE('2020-10-06','YYYY-MM-DD'));
INSERT INTO LOAN_TRANSACTIONS VALUES (10,'DMDD0454500','DMDD0454500',18467484,2500,TO_DATE('2021-12-06','YYYY-MM-DD'));
INSERT INTO LOAN_TRANSACTIONS VALUES (11,'DMDD0454500','DMDD0454500',18467484,2499.99,TO_DATE('2022-02-06','YYYY-MM-DD'));


-- TRANSACTIONS

insert into TRANSACTIONS(Tansaction_ID, Debit_Account,Credit_Account,IFSC_Code_Debit,IFSC_Code_Credit, Amount,  Transaction_date,Message,Status) Values
(1203876940301, 13719713158835300, 1086643758945400, 'DMDD0454500','DMDD0101022','20.00',DATE '2021-03-08','sent $20', 'Success');
insert into TRANSACTIONS(Tansaction_ID, Debit_Account,Credit_Account,IFSC_Code_Debit,IFSC_Code_Credit, Amount,  Transaction_date,Message,Status) Values
(1103876940301, 53153834006064000, 3719713158855555, 'DMDD0101022','DMDD0454500','40.00',DATE '2021-04-11','Amount $40 Transferred', 'Success');
insert into TRANSACTIONS(Tansaction_ID, Debit_Account,Credit_Account,IFSC_Code_Debit,IFSC_Code_Credit, Amount,  Transaction_date,Message,Status) Values
(1103876940302, 37530666568966100, 70048841700216300, 'DMDD0333100','DMDD0454500','250.00',DATE '2022-10-10','sent $250', 'Pending');
insert into TRANSACTIONS(Tansaction_ID, Debit_Account,Credit_Account,IFSC_Code_Debit,IFSC_Code_Credit, Amount,  Transaction_date,Message,Status) Values
(1203876940303, 89135767380499400, 12494980148173100, 'DMDD0101022','DMDD0333100','50.00',DATE '2020-11-08','sent $50', 'Success');
insert into TRANSACTIONS(Tansaction_ID, Debit_Account,Credit_Account,IFSC_Code_Debit,IFSC_Code_Credit, Amount,  Transaction_date,Message,Status) Values
(1203876940304, 8744336085399580, 64289489845768000, 'DMDD0101022','DMDD0454500','330.00',DATE '2021-04-08','sent $330', 'Success');
insert into TRANSACTIONS(Tansaction_ID, Debit_Account,Credit_Account,IFSC_Code_Debit,IFSC_Code_Credit, Amount,  Transaction_date,Message,Status) Values
(1203876940305, 70149340835549500, 13719713158835300, 'DMDD0333100','DMDD0454500','150.00',DATE '2020-05-18','sent $150', 'Success');
insert into TRANSACTIONS(Tansaction_ID, Debit_Account,Credit_Account,IFSC_Code_Debit,IFSC_Code_Credit, Amount,  Transaction_date,Message,Status) Values
(1203876940306,9560713158835400 ,9009713158835400 , 'DMDD0454500','DMDD0101022','120.00',DATE '2021-02-23','sent $120', 'Success');
insert into TRANSACTIONS(Tansaction_ID, Debit_Account,Credit_Account,IFSC_Code_Debit,IFSC_Code_Credit, Amount,  Transaction_date,Message,Status) Values
(1103876940307, 53153834006064000, 3690859741294280, 'DMDD0101022','DMDD0454500','400.00',DATE '2020-08-05','Amount $400 Transferred', 'Success');
insert into TRANSACTIONS(Tansaction_ID, Debit_Account,Credit_Account,IFSC_Code_Debit,IFSC_Code_Credit, Amount,  Transaction_date,Message,Status) Values
(1103876940308, 37530666568966100, 70048841700216300, 'DMDD0333100','DMDD0454500','500.00',DATE '2022-01-18','sent $500', 'Success');
insert into TRANSACTIONS(Tansaction_ID, Debit_Account,Credit_Account,IFSC_Code_Debit,IFSC_Code_Credit, Amount,  Transaction_date,Message,Status) Values
(1203876940309, 89135767380499400, 12494980148173100, 'DMDD0101022','DMDD0333100','350.00',DATE '2021-07-28','sent $350', 'Success');
insert into TRANSACTIONS(Tansaction_ID, Debit_Account,Credit_Account,IFSC_Code_Debit,IFSC_Code_Credit, Amount,  Transaction_date,Message,Status) Values
(1203876940310, 8744336085399580, 64289489845768000, 'DMDD0101022','DMDD0454500','444.00',DATE '2021-10-04','sent $444', 'Success');
insert into TRANSACTIONS(Tansaction_ID, Debit_Account,Credit_Account,IFSC_Code_Debit,IFSC_Code_Credit, Amount,  Transaction_date,Message,Status) Values
(1203876940311, 70149340835549500, 13719713158835300, 'DMDD0333100','DMDD0454500','100.00',DATE '2021-02-11','sent $100', 'Success');
insert into TRANSACTIONS(Tansaction_ID, Debit_Account,Credit_Account,IFSC_Code_Debit,IFSC_Code_Credit, Amount,  Transaction_date,Message,Status) Values
(1203876940312, 13719713158835300, 1086643758945400, 'DMDD0454500','DMDD0101022','1000.00',DATE '2021-03-08','sent $1000', 'Success');
insert into TRANSACTIONS(Tansaction_ID, Debit_Account,Credit_Account,IFSC_Code_Debit,IFSC_Code_Credit, Amount,  Transaction_date,Message,Status) Values
(1103876940313, 53153834006064000, 3690859741294280, 'DMDD0101022','DMDD0454500','700.00',DATE '2021-08-29','Amount $700 Transferred', 'Success');
insert into TRANSACTIONS(Tansaction_ID, Debit_Account,Credit_Account,IFSC_Code_Debit,IFSC_Code_Credit, Amount,  Transaction_date,Message,Status) Values
(1103876940314, 37530666568966100, 70048841700216300, 'DMDD0333100','DMDD0454500','750.00',DATE '2021-10-10','sent $750', 'Pending');
insert into TRANSACTIONS(Tansaction_ID, Debit_Account,Credit_Account,IFSC_Code_Debit,IFSC_Code_Credit, Amount,  Transaction_date,Message,Status) Values
(1203876940315, 89135767380499400, 12494980148173100, 'DMDD0101022','DMDD0333100','55.00',DATE '2020-11-09','sent $55', 'Success');
insert into TRANSACTIONS(Tansaction_ID, Debit_Account,Credit_Account,IFSC_Code_Debit,IFSC_Code_Credit, Amount,  Transaction_date,Message,Status) Values
(1203876940316, 8744336085399580, 64289489845768000, 'DMDD0101022','DMDD0454500','360.00',DATE '2021-06-03','sent $360', 'Success');
insert into TRANSACTIONS(Tansaction_ID, Debit_Account,Credit_Account,IFSC_Code_Debit,IFSC_Code_Credit, Amount,  Transaction_date,Message,Status) Values
(1203876940317, 70149340835549500, 13719713158835300, 'DMDD0333100','DMDD0454500','66.00',DATE '2020-09-03','sent $66', 'Success');
insert into TRANSACTIONS(Tansaction_ID, Debit_Account,Credit_Account,IFSC_Code_Debit,IFSC_Code_Credit, Amount,  Transaction_date,Message,Status) Values
(1203876940318, 13719713158835300, 1086643758945400, 'DMDD0454500','DMDD0101022','450.00',DATE '2021-08-01','sent $450', 'Success');
insert into TRANSACTIONS(Tansaction_ID, Debit_Account,Credit_Account,IFSC_Code_Debit,IFSC_Code_Credit, Amount,  Transaction_date,Message,Status) Values
(1103876940319, 53153834006064000, 3690859741294280, 'DMDD0101022','DMDD0454500','600.00',DATE '2021-01-01','Amount $600 Transferred', 'Success');
insert into TRANSACTIONS(Tansaction_ID, Debit_Account,Credit_Account,IFSC_Code_Debit,IFSC_Code_Credit, Amount,  Transaction_date,Message,Status) Values
(1103876940320, 37530666568966100, 70048841700216300, 'DMDD0333100','DMDD0454500','60.00',DATE '2022-04-13','sent $60', 'Success');

--  Works With
--INSERT INTO WORKS_WITH VALUES  (100000,,)



-- FIrst Create a script to define users and specific acess
-- Login as users who has full acess
-- run the script


