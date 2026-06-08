---LIBRARY MANAGMENT SYSTEM PROJECT 2

DROP TABLE IF EXISTS branch;
CREATE TABLE branch1
(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(30),
            contact_no VARCHAR(15)
);


-- Create table "Employee"
DROP TABLE IF EXISTS employees;
CREATE TABLE employees2
(
            emp_id VARCHAR(10) PRIMARY KEY,
            emp_name VARCHAR(30),
            position VARCHAR(30),
            salary DECIMAL(10,2),
            branch_id VARCHAR(10),
            FOREIGN KEY (branch_id) REFERENCES  branch(branch_id)
);


-- Create table "Members"
DROP TABLE IF EXISTS members;
CREATE TABLE members3
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);



-- Create table "Books"
DROP TABLE IF EXISTS books;
CREATE TABLE books4
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);



-- Create table "IssueStatus"
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status5
(
            issued_id VARCHAR(10) PRIMARY KEY,
            issued_member_id VARCHAR(30),
            issued_book_name VARCHAR(80),
            issued_date DATE,
            issued_book_isbn VARCHAR(50),
            issued_emp_id VARCHAR(10),
            FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
            FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
            FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);



-- Create table "ReturnStatus"
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status6
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(30),
            return_book_name VARCHAR(80),
            return_date DATE,
            return_book_isbn VARCHAR(50),
            FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);



----Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
 INSERT INTO books4 
 values('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')
 
----Task 2: Update an Existing Member's Address
UPDATE members3
SET member_address =' 123 LAPTAGANZ'
where member_id='C101'

----Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table
DELETE FROM issued_status5
WHERE issued_id= 'IS121'

----Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101
SELECT * FROM issued_status5
WHERE issued_emp_id='E101'

----Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.
           SELECT COUNT(*), issued_emp_id
		   FROM  issued_status5
		   GROUP BY 2
		   HAVING COUNT(*)>1
		   
----Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
  SELECT b.book_title,b.isbn,
  COUNT(ist.issued_book_name) AS TOTAL_ISSUED
  FROM 
  books4 b
  JOIN
  issued_status5 ist
  ON b.isbn=ist.issued_book_isbn
  GROUP BY  b.isbn ,b.book_title
  
---Task 7. Retrieve All Books in a Specific Category:
  SELECT * FROM books4
  WHERE category ='Classic'
  
---Task 8: Find Total Rental Income by Category:
SELECT b.category,SUM(b.rental_price)
as total_price,count(issued_id) as total_count
FROM books4 b
JOIN 
issued_status5 ist
ON b.isbn=ist.issued_book_isbn
GROUP BY b.category

---TASK 9:List Members Who Registered in the Last 180 Days:
SELECT * FROM members3
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';

---TASK 10.List Employees with Their Branch Manager's Name and their branch details:
  SELECT e.emp_name,
  e.emp_id,
  e.position,
  e.salary,
  b.*,
  e2.emp_name as maanger_name 
  ---e2.emp_name as manager_name
  FROM
  employees2 e
  JOIN 
  branch1 b
  ON e.branch_id=b.branch_id
  JOIN 
  employees2 e2
  ON e2.emp_id=b.manager_id

---- TASK 11.Create a Table of Books with Rental Price Above a Certain Threshold:

SELECT * from books4 
WHERE rental_price>7

----task 12: Retrieve the List of Books Not Yet Returned

SELECT * FROM
issued_status5 s
 LEFT JOIN
return_status6 r
ON s.issued_id=r.issued_id
where r.return_id is null

-----ADVANCED QUERY PRACTISE

----TASK 13.Identify Members with Overdue Books
----Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

SELECT s.issued_member_id,m.member_name ,b.book_title,s.issued_date,
CURRENT_DATE - s.issued_date as owerdue_date 
FROM members3 m
JOIN
issued_status5 s
ON m.member_id=s.issued_member_id
JOIN
books4 b
ON b.isbn=s.issued_book_isbn
 left JOIN
return_status6 r
ON r.issued_id=s.issued_id
where 
r.return_date is null  and 
(current_date - s.issued_date)>30




----Task 14: Update Book Status on Return
----Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).

---Task 15: Branch Performance Report
---Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
SELECT br.branch_id,
br.manager_id ,
count(s.issued_id) as total_issued_book,
count(r.return_id) as return_books,
sum(b.rental_price) as total_rental_price 
FROM   
issued_status5 s
JOIN
employees2 e
ON e.emp_id=s.issued_emp_id
JOIN
branch1 br
ON 
e.branch_id=br.branch_id
LEFT JOIN
return_status6 r
ON 
r.issued_id=s.issued_id
JOIN
books4 as b
ON s.issued_book_isbn = b.isbn
GROUP BY 1,2;

---Task 16: CTAS: Create a Table of Active Members
----Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.
CREATE TABLE active_member as(
SELECT * FROM members3
WHERE member_id in(

SELECT *, issued_member_id
FROM issued_status5
where issued_date >= current_date - interval '1 month'

SELECT * FROM active_member

----Task 17: Find Employees with the Most Book Issues Processed
-----Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

SELECT  e.emp_name,
           b.*,
        count(s.issued_id) as total_issued_books
		 FROM 
		 employees2 e
		 JOIN
		 issued_status5 s
		 ON e.emp_id=s.issued_emp_id
		 JOIN
		 branch1 b
		ON b.branch_id=e.branch_id
		 GROUP BY 1,2
		 order by total_issued_books desc
		 limit 3


---Task 18: Identify Members Issuing High-Risk Books
----Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books
SELECT * FROM branch1
SELECT * FROM employees2
SELECT * FROM members3
SELECT * FROM books4
SELECT * FROM issued_status5
SELECT * FROM return_status6

SELECT m.member_name,b.book_title,count(s.issued_book_name) as total_issued_book,
CASE 
WHEN COUNT(s.issued_book_name)>2 THEN 'damaged'
else 'NOT DAMAGED' END AS STATUS
FROM
books4 b
JOIN
issued_status5 s
ON b.isbn=s.issued_book_isbn
 JOIN
members3 m
ON m.member_id=s.issued_member_id
GROUP BY 1,2


