CREATE DATABASE SQL_PROJECT_2;
USE SQL_PROJECT_2;

################## CALLING THE TABLES ################
SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM members;
SELECT * FROM return_status;
SELECT * FROM issued_status;


############### Data Modelling ########################

-- In MySQL, This is not possible to have alter the data becoz here lenght can be varied with the value so modifiaction is required in this.
-- For branch table :

DESCRIBE branch;
ALTER TABLE branch MODIFY branch_id VARCHAR(20);
ALTER TABLE branch ADD PRIMARY KEY (branch_id);

-- For employees table :

DESCRIBE employees;
ALTER TABLE employees MODIFY branch_id VARCHAR(20);  -- MODIFICATION 
ALTER TABLE employees MODIFY emp_id VARCHAR(30);


ALTER TABLE employees 
ADD FOREIGN KEY (branch_id) -- BUILDING THE PARENT CHILD RELATIONSHIP 
REFERENCES branch(branch_id); 

ALTER TABLE employees ADD PRIMARY KEY (emp_id);

-- For issued_status :

ALTER TABLE issued_status MODIFY issued_emp_id VARCHAR(20);
ALTER TABLE issued_status
ADD FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id);

-- For members:

DESCRIBE members;

ALTER TABLE members MODIFY member_id VARCHAR(20);
ALTER TABLE members ADD PRIMARY KEY (member_id);

-- For issued_status 

DESCRIBE issued_status;
ALTER TABLE issued_status MODIFY issued_member_id VARCHAR(20);

ALTER TABLE issued_status MODIFY issued_member_id VARCHAR(20);
ALTER TABLE issued_status 
ADD FOREIGN KEY (issued_member_id) 
REFERENCES members(member_id);



-- For books:

DESCRIBE books;

ALTER TABLE books MODIFY isbn VARCHAR(20);
ALTER TABLE books ADD PRIMARY KEY (isbn);

-- For issued_status:

DESCRIBE issued_status;

ALTER TABLE issued_status MODIFY issued_book_isbn VARCHAR(20);
ALTER TABLE issued_status
ADD FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn);

-- FOR return_status;

SET SQL_SAFE_UPDATES = 0;

DELETE FROM return_status
WHERE issued_id NOT IN (SELECT issued_id FROM issued_status);

DESCRIBE return_status;
ALTER TABLE return_status MODIFY issued_id VARCHAR(20);
ALTER TABLE return_Status
ADD FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id);

-- For issued_status:

DESCRIBE issued_status;

ALTER TABLE issued_status MODIFY issued_id VARCHAR(20);
ALTER TABLE issued_status ADD PRIMARY KEY (issued_id);

################# Questions are as follow : ###########

-- Task 1. Create a New Book Record
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"?

SELECT * FROM books;

INSERT INTO books (isbn, book_title, category, rental_price, status, author, publisher)
VALUES
		('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

-- Task 2: Update an Existing Member's Address

-- Task 3: Delete a Record from the Issued Status Table
-- Objective: Delete the record with issued_id = 'IS104' from the issued_status table.

SET SQL_SAFE_UPDATE = 0;

DELETE FROM issued_status
WHERE issued_id = 'IS104';

SELECT * FROM issued_status;

-- Task 4: Retrieve All Books Issued by a Specific Employee
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * 
FROM issued_status
WHERE issued_emp_id = 'E101';

-- Task 5: List Members Who Have Issued More Than One Book ?

SELECT COUNT(issued_id), issued_member_id
FROM issued_status
GROUP BY 2
HAVING COUNT(issued_id) > 1
ORDER BY 1;

-- Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt?

CREATE TABLE summary
SELECT issued_book_name, COUNT(issued_id)
FROM issued_status
GROUP BY 1;


SELECT * FROM summary
ORDER BY issued_book_name;

-- Task 7. **Retrieve All Books in a Specific Category ?

SELECT book_title, category
FROM books
GROUP BY 1,2
ORDER BY 2;

-- Task 8: Find Total Rental Income by Category:?

SELECT category, SUM(rental_price)  AS total_rental_price
FROM books
GROUP BY 1
ORDER BY 1;

-- Task 9. **List Members Who Registered in the Last 180 Days**:?

SET SQL_SAFE_UPDATES = 0;

UPDATE members
SET reg_date = '2025-02-12'
WHERE member_id IN ('C118');

SET SQL_SAFE_UPDATES = 0;

UPDATE members
SET reg_date = '2025-01-12'
WHERE member_id IN ('C119');

SELECT *
FROM members
WHERE reg_date >= DATE_ADD(CURRENT_DATE() , INTERVAL -180 DAY);

-- Task 10: List Employees with Their Branch Manager's Name and their branch details:

SELECT *
FROM employees AS e
JOIN branch As b ON e.branch_id = b.branch_id;

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold?

CREATE TABLE threshold_table 
SELECT *
FROM books 
WHERE rental_price > (SELECT AVG(rental_price) FROM books);

SELECT * FROM threshold_table;

-- Task 12: Retrieve the List of Books Not Yet Returned?

SELECT DISTINCT issued_book_name 
FROM issued_status
WHERE issued_id  NOT IN (SELECT issued_id FROM return_status);

-- Task 13: Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's name, book title, issue date, and days overdue.

SELECT 
    r.return_id,
    r.issued_id,
    i.issued_book_name,
    i.issued_date,
    return_date,
    DAY(i.issued_date) + DAY(r.return_date) AS number_of_days
FROM
    issued_status AS i
        JOIN
    return_status AS r ON i.issued_id = r.issued_id
WHERE
    DAY(i.issued_date) + DAY(r.return_date) > 30;
    
-- Task 14: Update Book Status on Return
-- Write a query to update the status of books in the books table to "available" when they are returned (based on entries in the return_status table)?


 SET SQL_SAFE_UPDATES = 0;
 
 UPDATE books
        RIGHT JOIN
    issued_status ON books.isbn = issued_status.issued_book_isbn
        LEFT JOIN
    return_status ON issued_status.issued_id = return_status.issued_id 
SET 
    status = 'Available'
WHERE
    issued_status.issued_id IN (SELECT 
            issued_id
        FROM
            return_status) ;


SELECT 
    *
FROM
    books;

-- Task 15: Branch Performance Report
-- Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total
-- revenue generated from book rentals?

SELECT 
    b.branch_address,
    COUNT(ist.issued_id) AS total_number_of_books_issued,
    COUNT(return_id) AS total_number_of_books_return,
    SUM(rental_price) AS total_revenue
FROM
    branch AS b
        JOIN
    employees AS e ON b.branch_id = e.branch_id
        JOIN
    issued_status AS ist ON e.emp_id = ist.issued_emp_id
        LEFT JOIN
    return_status AS rst ON ist.issued_id = rst.issued_id
        JOIN
    books AS bo ON ist.issued_book_isbn = bo.isbn
GROUP BY 1
ORDER BY 4 DESC;

-- Task 16: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 6 months.


SELECT   m.member_name, COUNT(issued_id)
FROM members AS m
JOIN issued_status AS ist ON m.member_id = ist.issued_member_id
WHERE issued_date < DATE_SUB('2024-09-30',  INTERVAL 6 MONTH)
GROUP BY 1
HAVING COUNT(issued_date) >= 1;

-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch?

SELECT emp_id, emp_name, branch_address, COUNT(issued_emp_id)
FROM branch AS b 
JOIN employees AS e ON b.branch_id = e.branch_id
JOIN issued_status AS ist ON e.emp_id = ist.issued_emp_id
GROUP BY 1,2,3
ORDER BY 4  DESC
LIMIT 3;

-- Task 18: Identify Members Issuing High-Risk Books
-- Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.    

SET SQL_SAFE_UPDATES = 0;

UPDATE books AS b
JOIN issued_status AS ist ON b.isbn = ist.issued_book_isbn
JOIN members AS m ON ist.issued_member_id = m.member_id
JOIN return_status AS rst ON ist.issued_id = rst.issued_id
SET b.status = 'Damaged'
WHERE DAY(return_date) > 20;

SELECT m.member_name, b.book_title, COUNT(ist.issued_id)
 FROM books AS b
JOIN issued_status AS ist ON b.isbn = ist.issued_book_isbn
JOIN members AS m ON ist.issued_member_id = m.member_id
JOIN return_status AS rst ON ist.issued_id = rst.issued_id
WHERE status = 'Damaged' 
GROUP BY 1,2
HAVING COUNT(ist.issued_id) >= 1;

-- Task 19: Stored Procedure
-- Objective: Create a stored procedure to manage the status of books in a library system.
--    Description: Write a stored procedure that updates the status of a book based on its issuance or return. Specifically:
--    If a book is issued, the status should change to 'no'.
--    If a book is returned, the status should change to 'yes'?

CREATE TABLE lib
SELECT 
    ist.issued_id,
    b.book_title,
    ist.issued_date,
    rst.return_date,
    CASE 
		WHEN 
			rst.return_date IS NULL THEN 'No'
            ELSE  'Yes'
		END AS status
FROM
    issued_status AS ist
        LEFT JOIN
    return_status AS rst ON ist.issued_id = rst.issued_id
        JOIN
    books AS b ON b.isbn = ist.issued_book_isbn;
   
   
SELECT *  FROM lib;

-- Task 20: Create Table As Select (CTAS)
-- Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines. for more than 20 days ?
CREATE TABLE overdues
SELECT 
    ist.issued_id,
    issued_book_name,
    ist.issued_date,
    IFNULL(rst.return_date, 0) AS return_date,
	IFNULL(DATEDIFF(return_date, issued_date), 'Not Avialable') AS number_of_days,
    CASE 
		WHEN  DATEDIFF(return_date, issued_date) > 20 
			  THEN (DATEDIFF(return_date, issued_date) - 20)*0.5
        ELSE 0
	END AS charge_money
FROM
    issued_status AS ist
        LEFT JOIN
    return_status AS rst ON ist.issued_id = rst.issued_id
        JOIN
    books AS b ON b.isbn = ist.issued_book_isbn;
SELECT * FROM overdues;    
DROP TABLE overdues;


-- Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include:
--    The number of overdue books.
--    The total fines, with each day's fine calculated at $0.50.
--    The number of books issued by each member.
--    The resulting table should show:
--    Member ID
--    Number of overdue books
--    Total fines

CREATE TABLE overdues_1
SELECT 
    m.member_id,
    b.book_title,
    ist.issued_date,
    IFNULL(rst.return_date, 'Not Avialable') AS return_date,
	IFNULL(DATEDIFF(return_date, issued_date), 0) AS number_of_days,
    CASE 
		WHEN  DATEDIFF(return_date, issued_date)  > 30 
			  THEN (DATEDIFF(return_date, issued_date) - 30)*0.5
        ELSE 0
	END AS charge_money_in_dollor
FROM
    issued_status AS ist
        LEFT JOIN
    return_status AS rst ON ist.issued_id = rst.issued_id
        JOIN
    books AS b ON b.isbn = ist.issued_book_isbn
		JOIN 
	members AS m ON m.member_id = ist.issued_member_id;
SELECT * FROM overdues_1;    
DROP TABLE overdues_1;

