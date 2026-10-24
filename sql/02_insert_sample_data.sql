-- Property Management Data Warehouse sample data

-- Properties
INSERT INTO raw.properties
    (property_id, property_name, property_type, address, city, postcode, bedrooms)
VALUES
    (1, 'Oak House', 'Apartment', '10 King Street', 'Manchester', 'M1 1AA', 2),
    (2, 'Maple Court', 'House', '25 Park Road', 'Liverpool', 'L1 2AB', 3),
    (3, 'Pine Lodge', 'Apartment', '8 Station Road', 'Manchester', 'M2 3BC', 1),
    (4, 'Cedar House', 'House', '42 Garden Avenue', 'Leeds', 'LS1 4CD', 3),
    (5, 'Birch Cottage', 'House', '6 Mill Lane', 'Salford', 'M5 5EF', 2);

-- Tenants
INSERT INTO raw.tenants
    (tenant_id, first_name, last_name, email, phone)
VALUES
    (101, 'John', 'Smith', 'john.smith@example.com', '07111111111'),
    (102, 'Sarah', 'Jones', 'sarah.jones@example.com', '07222222222'),
    (103, 'Michael', 'Brown', 'michael.brown@example.com', '07333333333'),
    (104, 'Emma', 'Wilson', 'emma.wilson@example.com', '07444444444');

-- Leases
INSERT INTO raw.leases
    (lease_id, property_id, tenant_id, start_date, end_date, agreed_monthly_rent, 
    billing_frequency, rent_due_day, lease_status)
VALUES
    (1001, 1, 101, '2025-12-01', NULL, 1200.00, 'monthly', 1, 'active'),
    (1002, 2, 102, '2025-11-15', NULL, 1500.00, 'monthly', 5, 'active'),
    (1003, 3, 103, '2025-10-01', NULL, 950.00, 'monthly', 1, 'active'),
    (1004, 4, 104, '2025-12-01', NULL, 1300.00, 'monthly', 10, 'active');

-- Rent charges
INSERT INTO raw.rent_charges
    (charge_id, lease_id, period_start, period_end, due_date, amount_due, charge_status)
VALUES
    (4001, 1001, '2026-01-01', '2026-01-31', '2026-01-01', 1200.00, 'due'),
    (4002, 1001, '2026-02-01', '2026-02-28', '2026-02-01', 1200.00, 'due'),
    (4003, 1002, '2026-01-01', '2026-01-31', '2026-01-05', 1500.00, 'due'),
    (4004, 1002, '2026-02-01', '2026-02-28', '2026-02-05', 1500.00, 'due'),
    (4005, 1003, '2026-01-01', '2026-01-31', '2026-01-01', 950.00, 'due'),
    (4006, 1003, '2026-02-01', '2026-02-28', '2026-02-01', 950.00, 'due'),
    (4007, 1004, '2026-01-01', '2026-01-31', '2026-01-10', 1300.00, 'due'),
    (4008, 1004, '2026-02-01', '2026-02-28', '2026-02-10', 1300.00, 'due');

-- Rent payments
INSERT INTO raw.rent_payments
    (payment_id, payment_date, amount, payment_method, payment_status, transaction_reference)
VALUES
    (5001, '2026-01-01', 1200.00, 'Bank transfer', 'paid', 'TXN-001'),
    (5002, '2026-02-01', 600.00, 'Bank transfer', 'paid', 'TXN-002'),
    (5003, '2026-01-05', 1500.00, 'Direct debit', 'failed', 'TXN-003'),
    (5004, '2026-01-08', 1500.00, 'Bank transfer', 'paid', 'TXN-004'),
    (5005, '2026-01-02', 950.00, 'Bank transfer', 'paid', 'TXN-005'),
    (5006, NULL, 950.00, 'Direct debit', 'pending', 'TXN-006'),
    (5007, '2026-02-06', 1500.00, 'Bank transfer', 'paid', 'TXN-007'),
    (5008, '2026-01-10', 1300.00, 'Bank transfer', 'paid', 'TXN-008'),
    (5009, '2026-02-10', 1300.00, 'Bank transfer', 'paid', 'TXN-009');

-- Payment allocations
INSERT INTO raw.payment_allocations
    (allocation_id, payment_id, charge_id, allocated_amount, allocation_date)
VALUES
    (6001, 5001, 4001, 1200.00, '2026-01-01'),
    (6002, 5002, 4002, 600.00, '2026-02-02'),
    (6003, 5004, 4003, 1500.00, '2026-01-08'),
    (6004, 5005, 4005, 950.00, '2026-01-02'),
    (6005, 5007, 4004, 1500.00, '2026-02-06'),
    (6006, 5008, 4007, 1300.00, '2026-01-10'),
    (6007, 5009, 4008, 1300.00, '2026-02-10');

-- Expenses
INSERT INTO raw.expenses
    (expense_id, property_id, expense_date, expense_category, description, amount, 
    invoice_reference)
VALUES
    (7001, 1, '2026-01-15', 'Plumbing', 'Leaking kitchen tap repair', 85.00, 'INV-001'),
    (7002, 2, '2026-01-20', 'Maintenance', 'Boiler service', 180.00, 'INV-002'),
    (7003, 4, '2026-02-03', 'Electrical', 'Electrical safety repairs', 250.00, 'INV-003'),
    (7004, 5, '2026-02-10', 'Maintenance', 'Roof repairs', 450.00, 'INV-004');


-- Property availability
INSERT INTO raw.property_availability
    (availability_id, property_id, effective_from, effective_to, is_available, 
    availability_reason)
VALUES
    (8001, 5, '2026-01-01', '2026-03-31', FALSE, 'Maintenance'),
    (8002, 5, '2026-04-01', NULL, TRUE, 'Ready to rent'),
    (8003, 3, '2026-03-01', NULL, TRUE, 'Ready to rent');