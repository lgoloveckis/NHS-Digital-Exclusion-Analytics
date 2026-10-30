-- =====================================================
-- NHS DIGITAL EXCLUSION - DATA ANALYSIS
-- =====================================================
--
-- Project: NHS Digital Exclusion Analytics
-- Database: nhs_digital_exclusion_analytics
--
-- Purpose:
-- Analyse GP booking attempts, booking failures,
-- patient risk levels and assisted booking tickets.
--
-- Dataset:
-- 300 synthetic patients
-- 900 booking attempts
-- 209 assisted booking tickets
--
-- Tools:
-- MySQL Workbench
-- Power BI
--
-- =====================================================
USE nhs_digital_exclusion_analytics;

-- ==========================================
-- QUESTION 1
-- How many booking attempts are recorded?
-- ==========================================

SELECT
    COUNT(*) AS total_booking_attempts
FROM booking_attempts;


-- ==========================================
-- QUESTION 2
-- How many bookings succeeded or failed?
-- ==========================================

SELECT
    booking_outcome,
    COUNT(*) AS total_bookings
FROM booking_attempts
GROUP BY booking_outcome;


-- ==========================================
-- QUESTION 3
-- How many unique patients have booking attempts in each risk category?
-- ==========================================

SELECT
    risk_level,
    COUNT(DISTINCT patient_id) AS total_patients
FROM booking_attempts
GROUP BY risk_level
ORDER BY total_patients DESC;


-- =====================================
-- QUESTION 4
-- What are the most common booking failure reasons?
-- =====================================

SELECT
    failure_reason,
    COUNT(*) AS total_failures
FROM booking_attempts
WHERE booking_outcome = 'Failed'
GROUP BY failure_reason
ORDER BY total_failures DESC;


-- =====================================
-- QUESTION 5
-- What percentage of bookings failed?
-- =====================================

SELECT
    ROUND(
        SUM(CASE
            WHEN booking_outcome = 'Failed' THEN 1
            ELSE 0
        END) * 100.0 / COUNT(*),
        2
    ) AS failure_percentage
FROM booking_attempts;


-- =====================================
-- QUESTION 6
-- How many support tickets are in each status?
-- =====================================

SELECT
    support_status,
    COUNT(*) AS total_tickets
FROM assisted_booking_tickets
GROUP BY support_status
ORDER BY total_tickets DESC;


-- =====================================
-- QUESTION 7
-- Which staff members have the most assigned tickets?
-- =====================================

SELECT
    assigned_staff,
    COUNT(*) AS total_tickets
FROM assisted_booking_tickets
WHERE assigned_staff IS NOT NULL
GROUP BY assigned_staff
ORDER BY total_tickets DESC;


-- =====================================
-- QUESTION 8
-- What is the average resolution time?
-- =====================================

SELECT
    ROUND(
        AVG(TIMESTAMPDIFF(MINUTE, created_date, resolved_date) / 60.0),
        2
    ) AS average_resolution_hours
FROM assisted_booking_tickets
WHERE support_status = 'Resolved';


-- =====================================
-- QUESTION 9
-- Which problems take the longest to resolve?
-- =====================================

SELECT
    reason,
    ROUND(
        AVG(TIMESTAMPDIFF(MINUTE, created_date, resolved_date) / 60.0),
        2
    ) AS average_resolution_hours
FROM assisted_booking_tickets
WHERE support_status = 'Resolved'
GROUP BY reason
ORDER BY average_resolution_hours DESC;


-- =====================================
-- QUESTION 10
-- How many booking failures occur each month?
-- =====================================

SELECT
    DATE_FORMAT(attempt_datetime, '%Y-%m') AS booking_month,
    COUNT(*) AS total_failures
FROM booking_attempts
WHERE booking_outcome = 'Failed'
GROUP BY DATE_FORMAT(attempt_datetime, '%Y-%m')
ORDER BY booking_month;


-- =====================================
-- QUESTION 11
-- Which patients experienced multiple failed bookings?
-- =====================================

SELECT
    p.patient_id,
    p.nhs_number,
    p.first_name,
    p.last_name,
    COUNT(*) AS failed_bookings
FROM patients p
INNER JOIN booking_attempts b
    ON p.patient_id = b.patient_id
WHERE b.booking_outcome = 'Failed'
GROUP BY
    p.patient_id,
    p.nhs_number,
    p.first_name,
    p.last_name
HAVING COUNT(*) > 1
ORDER BY failed_bookings DESC;


-- =====================================
-- QUESTION 12
-- How many high-risk bookings have support tickets?
-- =====================================

SELECT
    COUNT(DISTINCT b.booking_id) AS high_risk_bookings_with_tickets
FROM booking_attempts b
INNER JOIN assisted_booking_tickets t
    ON b.booking_id = t.booking_id
WHERE b.risk_level = 'High';


