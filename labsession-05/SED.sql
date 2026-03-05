CREATE DATABASE wad_lab_5_sem1;
USE wad_lab_5_sem1;

CREATE TABLE distributor (
    tin VARCHAR(10),
    distributor_name VARCHAR(20) NOT NULL,
    address VARCHAR(20),
    contact_details VARCHAR(50),

    CONSTRAINT pk_distributor PRIMARY KEY (TIN)
);

CREATE TABLE solarpanel (
    pv_module_no VARCHAR(30),
    pv_type VARCHAR(30),
    price DECIMAL(10,2),
    capacity INT,
    warranty INT,

    CONSTRAINT pk_solarpanel PRIMARY KEY (pv_module_no)
);

CREATE TABLE users (
    building_no VARCHAR(30),
    user_name VARCHAR(100),
    address VARCHAR(100),

    CONSTRAINT pk_users PRIMARY KEY (building_no)
);

CREATE TABLE sells (
    pv_module_no VARCHAR(30),
    tin VARCHAR(10),

    CONSTRAINT pk_sells PRIMARY KEY (pv_module_no, tin),

    CONSTRAINT fk_sells_pv
        FOREIGN KEY (pv_module_no)
        REFERENCES solarpanel (pv_module_no),

    CONSTRAINT fk_sells_distributor
        FOREIGN KEY (tin)
        REFERENCES distributor (tin)
);

CREATE TABLE purchases (
    pv_module_no VARCHAR(30),
    building_no VARCHAR(30),

    CONSTRAINT pk_purchases PRIMARY KEY (pv_module_no, building_no),

    CONSTRAINT fk_purchases_pv
        FOREIGN KEY (pv_module_no)
        REFERENCES solarpanel (pv_module_no),

    CONSTRAINT fk_purchases_users
        FOREIGN KEY (building_no)
        REFERENCES users (building_no)
);

CREATE TABLE installs (
    pv_module_no VARCHAR(30),
    tin VARCHAR(10),
    building_no VARCHAR(30),
    installsdate DATE NOT NULL,
    area_type VARCHAR(30),
    installation_charge DECIMAL(10,2) CHECK (installation_charge >= 0),

    CONSTRAINT pk_installs PRIMARY KEY (pv_module_no, tin, building_no),

    CONSTRAINT fk_installs_pv
        FOREIGN KEY (pv_module_no)
        REFERENCES solarpanel (pv_module_no),

    CONSTRAINT fk_installs_distributor
        FOREIGN KEY (tin)
        REFERENCES Distributor (tin),

    CONSTRAINT fk_installs_users
        FOREIGN KEY (building_no)
        REFERENCES users (building_no)
);


INSERT INTO distributor VALUES
('TIN001', 'SolarOne', 'Chennai', '9000011111'),
('TIN002', 'GreenVolt', 'Bangalore', '9000022222'),
('TIN003', 'SunPower', 'Hyderabad', '9000033333');

INSERT INTO solarpanel VALUES
('PV001', 'Monocrystalline', 150000.00, 5, 15),
('PV002', 'Polycrystalline', 120000.00, 10, 25),
('PV003', 'Monocrystalline', 180000.00, 8, 15),
('PV004', 'Polycrystalline', 200000.00, 12, 25);		

INSERT INTO users VALUES
('H101', 'Ramesh', 'Hyderabad'),
('H102', 'Suresh', 'Hyderabad'),
('O201', 'RV Office', 'Bangalore'),
('H103', 'Mahesh', 'Chennai'),
('O202', 'Hotel Grand', 'Chennai');

INSERT INTO sells VALUES
('PV001', 'TIN001'),
('PV002', 'TIN001'),
('PV003', 'TIN002'),
('PV004', 'TIN003');

INSERT INTO purchases VALUES
('PV001', 'H101'),
('PV002', 'H102'),
('PV003', 'O201'),
('PV004', 'O202'),
('PV001', 'H103');

INSERT INTO installs VALUES
('PV001', 'TIN001', 'H101', '2015-01-10', 'Domestic', 40000),
('PV002', 'TIN001', 'H102', '2016-05-15', 'Domestic', 60000),
('PV001', 'TIN001', 'H103', '2014-03-20', 'Domestic', 40000),
('PV003', 'TIN002', 'O201', '2017-07-01', 'Commercial', 40000),
('PV004', 'TIN003', 'O202', '2013-11-25', 'Commercial', 60000);

-- Query 1
-- List the distributor with most installsations in domestic places
SELECT distributor_name
FROM Distributor
WHERE tin IN (
    SELECT tin
    FROM installs
    WHERE area_type = 'Domestic'
    GROUP BY tin
    HAVING COUNT(*) >= ALL (
        SELECT COUNT(*)
        FROM installs
        WHERE area_type = 'Domestic'
        GROUP BY tin
    )
);

SELECT d.distributor_name
FROM Distributor d
JOIN (
    SELECT tin, COUNT(*) AS cnt
    FROM installs
    WHERE area_type = 'Domestic'
    GROUP BY tin
) t ON d.tin = t.tin
WHERE t.cnt >= ALL (
    SELECT COUNT(*)
    FROM installs
    WHERE area_type = 'Domestic'
    GROUP BY tin
);


-- Query 2
-- List the place name with highest capacity panel installsed
SELECT address FROM users WHERE building_no IN (
    SELECT building_no FROM installs WHERE pv_module_no IN (
        SELECT pv_module_no FROM solarpanel WHERE capacity >= ALL (
            SELECT capacity FROM solarpanel
        )
    )
);

SELECT u.address
FROM users u
JOIN installs i ON u.building_no = i.building_no
JOIN solarpanel s ON i.pv_module_no = s.pv_module_no
WHERE s.capacity >= ALL (
    SELECT sp.capacity
    FROM solarpanel sp
    JOIN installs ins ON sp.pv_module_no = ins.pv_module_no
);

-- Query 3
-- Display the area where monocrystalline panels are installsed
SELECT address FROM users WHERE building_no IN (
    SELECT building_no FROM installs WHERE pv_module_no IN (
        SELECT pv_module_no FROM solarpanel WHERE pv_type = 'Monocrystalline'
    )
);

SELECT address FROM users WHERE building_no IN (
	SELECT building_no FROM purchases WHERE pv_module_no IN (
		SELECT pv_module_no FROM solarpanel WHERE pv_type = 'Monocrystalline'
	)
);

SELECT DISTINCT u.address
FROM users u
JOIN installs i ON u.building_no = i.building_no
JOIN solarpanel s ON i.pv_module_no = s.pv_module_no
WHERE s.pv_type = 'Monocrystalline';

-- Query 4
-- For the specific area display the total installsation charges for both type of PV modules
SELECT
    (SELECT address FROM users WHERE building_no = i.building_no) AS address,
    (SELECT pv_type FROM solarpanel WHERE pv_module_no = i.pv_module_no) AS pv_type,
    SUM(i.installation_charge) AS total_installsation_charge
FROM installs i
GROUP BY i.building_no, i.pv_module_no;

SELECT u.address, s.pv_type, SUM(i.installation_charge) AS total_installation_charge
FROM installs i
JOIN users u ON i.building_no = u.building_no
JOIN solarpanel s ON i.pv_module_no = s.pv_module_no
GROUP BY u.address, s.pv_type;

-- Query 5
-- List the details of distributors and panel that is the oldest installsation
SELECT * FROM distributor WHERE tin IN (
    SELECT tin FROM installs WHERE installsdate = (
        SELECT MIN(installsdate) FROM installs
    )
);

SELECT * FROM solarpanel WHERE pv_module_no IN (
    SELECT pv_module_no FROM installs WHERE installsdate = (
        SELECT MIN(installsdate) FROM installs
    )
);

SELECT d.*, s.*
FROM installs i
JOIN distributor d ON i.tin = d.tin
JOIN solarpanel s ON i.pv_module_no = s.pv_module_no
WHERE i.installsdate = (
    SELECT MIN(installsdate) FROM installs
);

-- Query 6
-- Find the average sales of both type of panels in only commercial places
SELECT
    (SELECT pv_type FROM solarpanel WHERE pv_module_no = i.pv_module_no) AS pv_type,
    AVG((SELECT price FROM solarpanel WHERE pv_module_no = i.pv_module_no)) AS avg_sales
FROM installs i
WHERE i.area_type = 'Commercial'
GROUP BY i.pv_module_no;

SELECT s.pv_type, AVG(s.price) AS avg_sales
FROM installs i
JOIN solarpanel s ON i.pv_module_no = s.pv_module_no
WHERE i.area_type = 'Commercial'
GROUP BY s.pv_type;

SELECT s.pv_type, AVG(s.price) AS avg_sales
FROM solarpanel s
JOIN installs i ON i.pv_module_no = s.pv_module_no
WHERE i.area_type = 'Commercial'
GROUP BY s.pv_type;

-- DROP DATABASE IF EXISTS wad_lab_5_sem1;