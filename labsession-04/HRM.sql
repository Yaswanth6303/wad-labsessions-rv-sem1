CREATE DATABASE IF NOT EXISTS wad_lab_4_sem1;
USE wad_lab_4_sem1;

CREATE TABLE employee(
    fname VARCHAR(20),
    minit VARCHAR(1),
    lname VARCHAR(20),
    ssn BIGINT,
    bdate DATE,
    address VARCHAR(20),
    sex ENUM('M', 'F'),
    salary INT,
    super_ssn BIGINT,
    deptno INT,
    CONSTRAINT pk_employee PRIMARY KEY (ssn),
    CONSTRAINT fk_super_ssn FOREIGN KEY (super_ssn) REFERENCES employee(ssn)
);

CREATE TABLE department(
    deptno INT,
    dname VARCHAR(20),
    mgr_ssn BIGINT,
    mgr_start_date DATE,
    CONSTRAINT pk_department PRIMARY KEY (deptno),
    CONSTRAINT fk_mgr_ssn FOREIGN KEY (mgr_ssn) REFERENCES employee(ssn)
);

ALTER TABLE employee
ADD CONSTRAINT fk_deptno FOREIGN KEY (deptno) REFERENCES department(deptno);

CREATE TABLE deptlocations(
    deptno INT,
    dlocation VARCHAR(20),
    CONSTRAINT pk_deptlocations PRIMARY KEY (deptno, dlocation),
    CONSTRAINT fk_dl_deptno FOREIGN KEY (deptno) REFERENCES department(deptno)
);

CREATE TABLE project(
    pno INT,
    pname VARCHAR(20),
    plocation VARCHAR(20),
    budget INT,
    deptno INT,
    start_date DATE,
    end_date DATE,
    CONSTRAINT pk_project PRIMARY KEY (pno),
    CONSTRAINT fk_proj_dept FOREIGN KEY (deptno) REFERENCES department(deptno)
);

CREATE TABLE works_on(
    essn BIGINT,
    pno INT,
    hours DECIMAL(5,1),
    CONSTRAINT pk_works_on PRIMARY KEY (essn, pno),
    CONSTRAINT fk_wo_emp FOREIGN KEY (essn) REFERENCES employee(ssn),
    CONSTRAINT fk_wo_proj FOREIGN KEY (pno) REFERENCES project(pno)
);

CREATE TABLE dependent(
    essn BIGINT,
    dependent_name VARCHAR(20),
    sex ENUM('M', 'F'),
    bdate DATE,
    relationship VARCHAR(20),
    CONSTRAINT pk_dependent PRIMARY KEY (essn, dependent_name),
    CONSTRAINT fk_dep_emp FOREIGN KEY (essn) REFERENCES employee(ssn)
);

-- Insert Managers
INSERT INTO employee VALUES
('Rajesh','K','Sharma',100,'1975-01-10','Delhi','M',90000,NULL,NULL),
('Sunil','M','Verma',200,'1978-05-15','Mumbai','M',85000,NULL,NULL),
('Amit','R','Gupta',300,'1980-03-20','Pune','M',88000,NULL,NULL);

-- Insert Departments
INSERT INTO department VALUES
(1,'Finance',100,'2010-01-01'),
(2,'R&D',200,'2011-06-01'),
(3,'HR',300,'2012-03-15'),
(4,'Marketing',100,'2013-07-01');

-- Update deptno for managers
UPDATE employee SET deptno = 1 WHERE ssn = 100;
UPDATE employee SET deptno = 2 WHERE ssn = 200;
UPDATE employee SET deptno = 3 WHERE ssn = 300;

-- Insert Employees
INSERT INTO employee VALUES
('Pooja','S','Mehta',101,'1990-07-12','Delhi','F',40000,100,1),
('Ravi','T','Singh',102,'1992-11-25','Noida','M',42000,100,1),
('Neha','A','Patel',201,'1991-02-14','Mumbai','F',60000,200,2),
('Vikram','B','Joshi',202,'1989-08-30','Pune','M',62000,200,2),
('Sana','D','Khan',203,'1993-04-18','Mumbai','F',58000,200,2),
('Arjun','E','Nair',204,'1994-09-05','Chennai','M',59000,200,2),
('Priya','G','Das',301,'1988-12-01','Kolkata','F',70000,300,3),
('Kiran','H','Reddy',302,'1991-06-22','Hyderabad','M',72000,300,3),
('Deepa','I','Iyer',303,'1990-10-10','Chennai','F',68000,300,3),
('Manoj','J','Pillai',304,'1987-03-03','Bangalore','M',65000,300,3),
('Sneha','L','Rao',401,'1995-01-28','Hyderabad','F',75000,100,4),
('Rahul','N','Bose',402,'1993-07-07','Kolkata','M',73000,100,4);

-- Insert Projects
INSERT INTO project VALUES
(1,'ProjectAlpha','Mumbai',500000,2,'2024-01-01','2026-12-31'),
(2,'ProjectBeta','Pune',600000,2,'2024-02-01','2026-10-01'),
(3,'ProjectGamma','Chennai',400000,2,'2024-03-01','2026-08-01'),
(4,'ProjectDelta','Mumbai',300000,2,'2023-01-01','2023-12-31'),
(5,'ProjectEpsilon','Delhi',200000,1,'2024-01-15','2026-09-01'),
(6,'ProjectZeta','Delhi',1000000,1,'2023-01-01','2023-10-01'),
(7,'ProjectEta','Kolkata',350000,3,'2024-04-01','2026-07-01'),
(8,'ProjectTheta','Hyderabad',450000,3,'2023-02-01','2023-11-01'),
(9,'ProjectIota','Bangalore',550000,4,'2024-05-01','2026-11-01'),
(10,'ProjectKappa','Hyderabad',1000000,4,'2023-03-01','2023-12-01');

-- Works_on for Query 2 (ongoing R&D)
INSERT INTO works_on VALUES
(201,1,20.0),
(201,2,18.0),
(201,3,15.0);

-- Additional Works_on for Query 4 & 5 (completed projects)
INSERT INTO works_on VALUES
(202,4,10.0),
(203,4,8.0),
(204,6,7.0),
(201,6,5.0);

-- Insert Dependents (for Query 5)
INSERT INTO dependent VALUES
(201,'Anu','F','2015-05-01','Daughter'),
(204,'Rahul','M','2014-03-12','Son'),
(202,'Meera','F','2016-07-21','Daughter');

-- Query 1
-- List the f_Name, l_Name, dept_Name of the employer who draws a salary
-- greater than the average salary of employees working for Finance department.
SELECT fname, lname,
    (SELECT dname FROM department WHERE deptno = e.deptno) AS dept_name
FROM employee e
WHERE salary > (
    SELECT AVG(salary)
    FROM employee
    WHERE deptno = (SELECT deptno FROM department WHERE dname = 'Finance')
);

SELECT e.fname, e.lname, d.dname AS dept_name
FROM employee e
JOIN department d ON e.deptno = d.deptno
WHERE e.salary > (
    SELECT AVG(salary)
    FROM employee
    WHERE deptno = (
        SELECT deptno FROM department WHERE dname = 'Finance'
    )
);


-- Query 2
-- List the name and department of the employee who is currently working
-- on more than two project controlled by R&D department.
SELECT fname, lname,
    (SELECT dname FROM department WHERE deptno = e.deptno) AS dept_name
FROM employee e
WHERE (
    SELECT COUNT(*)
    FROM works_on w
    WHERE w.essn = e.ssn
    AND w.pno IN (
        SELECT pno
        FROM project
        WHERE end_date >= CURDATE()
        AND deptno = (SELECT deptno FROM department WHERE dname = 'R&D')
    )
) > 2;

SELECT e.fname, e.lname, d.dname AS dept_name
FROM employee e
JOIN department d ON e.deptno = d.deptno
JOIN works_on w ON e.ssn = w.essn
JOIN project p ON w.pno = p.pno
WHERE p.end_date >= CURDATE()
AND p.deptno = (
    SELECT deptno FROM department WHERE dname = 'R&D'
)
GROUP BY e.ssn
HAVING COUNT(p.pno) > 2;


-- Query 3
-- List all the ongoing projects controlled by all the departments.
SELECT (SELECT dname FROM department WHERE deptno = p.deptno) AS dept_name,
       pno, pname, plocation, budget
FROM project p
WHERE end_date >= CURDATE();

SELECT d.dname AS dept_name,
       p.pno, p.pname, p.plocation, p.budget
FROM project p
JOIN department d ON p.deptno = d.deptno
WHERE p.end_date >= CURDATE();

-- Query 4
-- Give the details of the supervisor who is supervising more than 3
-- employees who have completed at least one project.
SELECT * FROM employee s
WHERE s.ssn IN (
    SELECT e.super_ssn
    FROM employee e
    WHERE e.super_ssn IS NOT NULL
    AND (
        SELECT COUNT(*)
        FROM works_on w
        WHERE w.essn = e.ssn
        AND w.pno IN (
            SELECT pno
            FROM project
            WHERE end_date < CURDATE()
        )
    ) >= 1
    GROUP BY e.super_ssn -- OR GROUP BY 1
    HAVING COUNT(e.ssn) > 3
);

SELECT s.*
FROM employee s
JOIN employee e ON s.ssn = e.super_ssn
JOIN works_on w ON e.ssn = w.essn
JOIN project p ON w.pno = p.pno
WHERE p.end_date < CURDATE()
GROUP BY s.ssn
HAVING COUNT(DISTINCT e.ssn) > 3;

-- Query 5
-- List the name of the dependents employee who has completed a total_projects worth 10L.
SELECT dependent_name
FROM dependent d
WHERE d.essn IN (
    SELECT w.essn
    FROM works_on w
    WHERE w.pno IN (
        SELECT pno
        FROM project
        WHERE end_date < CURDATE()
    )
    GROUP BY w.essn
    HAVING SUM(
        (SELECT budget FROM project WHERE project.pno = w.pno)
    ) >= 1000000
);

SELECT d.dependent_name
FROM dependent d
WHERE d.essn IN (
    SELECT w.essn
    FROM works_on w
    JOIN project p ON w.pno = p.pno
    WHERE p.end_date < CURDATE()
    GROUP BY w.essn
    HAVING SUM(p.budget) >= 1000000
);

-- Query 6
-- List the department and employee details whose project is in more than one city.
SELECT 
    (SELECT dname FROM department d WHERE d.deptno = e.deptno) AS dept_name,
    e.*
FROM employee e
WHERE e.deptno IN (
    SELECT deptno
    FROM project
    GROUP BY deptno
    HAVING COUNT(DISTINCT plocation) > 1
);

SELECT dep.dname AS dept_name, e.*
FROM employee e
JOIN department dep ON e.deptno = dep.deptno
WHERE e.deptno IN (
    SELECT deptno
    FROM project
    GROUP BY deptno
    HAVING COUNT(DISTINCT plocation) > 1
);

-- DROP DATABASE IF EXISTS wad_lab_4_sem1;