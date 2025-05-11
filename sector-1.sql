CREATE TABLE budget (
    date DATE,
    location VARCHAR(255),
    budget_code VARCHAR(50),
    name VARCHAR(255),
    department VARCHAR(255),
    budget DECIMAL(15, 2)
);

CREATE TABLE employee_data (
    emp_no INT PRIMARY KEY,
    emp_name VARCHAR(255),
    location_group VARCHAR(255),
    location VARCHAR(255),
    hire_date DATE,
    position VARCHAR(255),
    attendance INT
);

CREATE TABLE sales_data (
    chain_name VARCHAR(255),
    store_name VARCHAR(255),
    storename3 VARCHAR(255),
    salesperson_id INT,
    salesperson_name VARCHAR(255),
    division_name VARCHAR(255),
    brand_name VARCHAR(255),
    dept_name VARCHAR(255),
    tran_type VARCHAR(50),
    qty INT,
    resale_value DECIMAL(15, 2),
    legacy_department VARCHAR(255)
);

-- Insert sample data into budget table
INSERT INTO budget (date, location, budget_code, name, department, budget)
VALUES
('2025-01-01', 'New York', 'B001', 'Store A', 'Electronics', 100000.00),
('2025-01-01', 'Los Angeles', 'B002', 'Store B', 'Clothing', 150000.00),
('2025-01-01', 'Chicago', 'B003', 'Store C', 'Furniture', 120000.00);

-- Insert sample data into employee_data table
INSERT INTO employee_data (emp_no, emp_name, location_group, location, hire_date, position, attendance)
VALUES
(1, 'John Doe', 'Group A', 'New York', '2020-05-15', 'tailor supervisor', 25),
(2, 'Jane Smith', 'Group B', 'Los Angeles', '2019-03-10', 'cashier', 28),
(3, 'Alice Johnson', 'Group A', 'New York', '2021-07-20', 'service staff', 30),
(4, 'Bob Brown', 'Group C', 'Chicago', '2018-11-05', 'storekeeper', 27),
(5, 'Charlie Davis', 'Group B', 'Los Angeles', '2022-01-12', 'tailor', 26);

-- Insert sample data into sales_data table
INSERT INTO sales_data (chain_name, store_name, storename3, salesperson_id, salesperson_name, division_name, brand_name, dept_name, tran_type, qty, resale_value, legacy_department)
VALUES
('Chain X', 'Store A', 'Group A', 101, 'Salesperson 1', 'Division 1', 'Brand X', 'Electronics', 'Retail', 50, 50000.00, 'Electronics'),
('Chain X', 'Store B', 'Group B', 102, 'Salesperson 2', 'Division 2', 'Brand Y', 'Clothing', 'Retail', 70, 120000.00, 'Clothing'),
('Chain Y', 'Store C', 'Group C', 103, 'Salesperson 3', 'Division 3', 'Brand Z', 'Furniture', 'Wholesale', 30, 90000.00, 'Furniture');


-- Calculate incentives based on sales performance
WITH sales_performance AS (
    SELECT 
        s.store_name,
        s.storename3,
        s.legacy_department,
        SUM(s.resale_value) AS total_sales,
        b.budget AS target_budget,
        (SUM(s.resale_value) / b.budget) * 100 AS achievement_percentage
    FROM 
        sales_data s
    INNER JOIN 
        budget b
    ON 
        s.store_name = b.name AND s.legacy_department = b.department
    GROUP BY 
        s.store_name, s.storename3, s.legacy_department, b.budget
),
incentive_calculation AS (
    SELECT 
        sp.store_name,
        sp.storename3,
        sp.legacy_department,
        sp.total_sales,
        sp.target_budget,
        sp.achievement_percentage,
        CASE 
            WHEN sp.achievement_percentage >= 150 THEN 3.0
            WHEN sp.achievement_percentage >= 120 THEN 2.5
            WHEN sp.achievement_percentage >= 100 THEN 2.0
            WHEN sp.achievement_percentage >= 80 THEN 1.0
            ELSE 0
        END AS total_incentive_percentage,
        CASE 
            WHEN sp.achievement_percentage >= 150 THEN 3.0 * 0.25
            WHEN sp.achievement_percentage >= 120 THEN 2.5 * 0.25
            WHEN sp.achievement_percentage >= 100 THEN 2.0 * 0.25
            WHEN sp.achievement_percentage >= 80 THEN 1.0 * 0.25
            ELSE 0
        END AS individual_incentive_percentage,
        CASE 
            WHEN sp.achievement_percentage >= 150 THEN 3.0 * 0.75
            WHEN sp.achievement_percentage >= 120 THEN 2.5 * 0.75
            WHEN sp.achievement_percentage >= 100 THEN 2.0 * 0.75
            WHEN sp.achievement_percentage >= 80 THEN 1.0 * 0.75
            ELSE 0
        END AS team_incentive_percentage
    FROM 
        sales_performance sp
),
final_incentive_distribution AS (
    SELECT 
        ic.store_name,
        ic.storename3,
        ic.legacy_department,
        ic.total_sales,
        ic.target_budget,
        ic.achievement_percentage,
        ic.total_incentive_percentage,
        ic.individual_incentive_percentage,
        ic.team_incentive_percentage,
        e.emp_no,
        e.emp_name,
        e.location_group
    FROM 
        incentive_calculation ic
    INNER JOIN 
        employee_data e
    ON 
        ic.storename3 = e.location_group
)
SELECT 
    store_name,
    storename3,
    legacy_department,
    total_sales,
    target_budget,
    achievement_percentage,
    total_incentive_percentage,
    individual_incentive_percentage,
    team_incentive_percentage,
    emp_no,
    emp_name
FROM 
    final_incentive_distribution;

    -- Calculate incentives for support team ( fixed incentive irrespective of budget
WITH sales_performance AS (
    SELECT 
        s.store_name,
        s.storename3,
        s.legacy_department,
        SUM(s.resale_value) AS total_sales,
        b.budget AS target_budget,
        (SUM(s.resale_value) / b.budget) * 100 AS achievement_percentage
    FROM 
        sales_data s
    INNER JOIN 
        budget b
    ON 
        s.store_name = b.name AND s.legacy_department = b.department
    GROUP BY 
        s.store_name, s.storename3, s.legacy_department, b.budget
),
incentive_calculation AS (
    SELECT 
        sp.store_name,
        sp.storename3,
        sp.legacy_department,
        sp.total_sales,
        sp.target_budget,
        sp.achievement_percentage,
        CASE 
            WHEN sp.achievement_percentage >= 150 THEN 3.0
            WHEN sp.achievement_percentage >= 120 THEN 2.5
            WHEN sp.achievement_percentage >= 100 THEN 2.0
            WHEN sp.achievement_percentage >= 80 THEN 1.0
            ELSE 0
        END AS total_incentive_percentage,
        CASE 
            WHEN sp.achievement_percentage >= 150 THEN 3.0 * 0.25
            WHEN sp.achievement_percentage >= 120 THEN 2.5 * 0.25
            WHEN sp.achievement_percentage >= 100 THEN 2.0 * 0.25
            WHEN sp.achievement_percentage >= 80 THEN 1.0 * 0.25
            ELSE 0
        END AS individual_incentive_percentage,
        CASE 
            WHEN sp.achievement_percentage >= 150 THEN 3.0 * 0.75
            WHEN sp.achievement_percentage >= 120 THEN 2.5 * 0.75
            WHEN sp.achievement_percentage >= 100 THEN 2.0 * 0.75
            WHEN sp.achievement_percentage >= 80 THEN 1.0 * 0.75
            ELSE 0
        END AS team_incentive_percentage
    FROM 
        sales_performance sp
),
final_incentive_distribution AS (
    SELECT 
        ic.store_name,
        ic.storename3,
        ic.legacy_department,
        ic.total_sales,
        ic.target_budget,
        ic.achievement_percentage,
        ic.total_incentive_percentage,
        ic.individual_incentive_percentage,
        ic.team_incentive_percentage,
        e.emp_no,
        e.emp_name,
        e.location_group,
        e.position,
        CASE 
            WHEN e.position = 'tailor supervisor' THEN 250
            WHEN e.position = 'tailor' THEN 250
            WHEN e.position = 'cashier supervisor' THEN 500
            WHEN e.position = 'cashier' THEN 300
            WHEN e.position = 'service staff' THEN 150
            WHEN e.position = 'storekeeper' THEN 150
            ELSE 0
        END AS fixed_incentive
    FROM 
        incentive_calculation ic
    INNER JOIN 
        employee_data e
    ON 
        ic.storename3 = e.location_group
)
SELECT 
    store_name,
    storename3,
    legacy_department,
    total_sales,
    target_budget,
    achievement_percentage,
    total_incentive_percentage,
    individual_incentive_percentage,
    team_incentive_percentage,
    emp_no,
    emp_name,
    position,
    fixed_incentive
FROM 
    final_incentive_distribution;
