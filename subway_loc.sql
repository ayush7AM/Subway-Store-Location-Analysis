--  SUBWAY USA LOCATION ANALYTICS — MySQL Project 

CREATE DATABASE IF NOT EXISTS subway_analytics;
USE subway_analytics;

DROP TABLE IF EXISTS stores;
DROP TABLE IF EXISTS cities;
DROP TABLE IF EXISTS states;
DROP VIEW  IF EXISTS vw_executive_summary;

-- ============================================================
-- SECTION 1: SCHEMA
-- ============================================================

CREATE TABLE states (
    state_id    INT          AUTO_INCREMENT PRIMARY KEY,
    state_code  CHAR(2)      NOT NULL UNIQUE,
    state_name  VARCHAR(50)  NOT NULL UNIQUE,
    region      ENUM('Northeast','South','Midwest','West') NOT NULL,
    population  INT          NOT NULL COMMENT 'Population in thousands'
);

CREATE TABLE cities (
    city_id    INT          AUTO_INCREMENT PRIMARY KEY,
    city_name  VARCHAR(100) NOT NULL,
    state_id   INT          NOT NULL,
    FOREIGN KEY (state_id) REFERENCES states(state_id),
    UNIQUE KEY uq_city_state (city_name, state_id)
);

CREATE TABLE stores (
    store_id   INT          AUTO_INCREMENT PRIMARY KEY,
    store_name VARCHAR(150) NOT NULL DEFAULT 'Subway',
    address    VARCHAR(255),
    city_id    INT          NOT NULL,
    zip_code   CHAR(5),
    latitude   DECIMAL(9,6),
    longitude  DECIMAL(9,6),
    phone      VARCHAR(20),
    date_added DATE         COMMENT 'When record was added to dataset',
    FOREIGN KEY (city_id) REFERENCES cities(city_id),
    INDEX idx_zip    (zip_code),
    INDEX idx_latlon (latitude, longitude)
);

-- ============================================================
-- SECTION 2: SAMPLE DATA
-- ============================================================

INSERT INTO states (state_code, state_name, region, population) VALUES
('AL','Alabama','South',5024),('AK','Alaska','West',733),
('AZ','Arizona','West',7151),('AR','Arkansas','South',3011),
('CA','California','West',39538),('CO','Colorado','West',5774),
('CT','Connecticut','Northeast',3606),('DE','Delaware','Northeast',989),
('FL','Florida','South',21538),('GA','Georgia','South',10712),
('HI','Hawaii','West',1455),('ID','Idaho','West',1839),
('IL','Illinois','Midwest',12812),('IN','Indiana','Midwest',6785),
('IA','Iowa','Midwest',3190),('KS','Kansas','Midwest',2938),
('KY','Kentucky','South',4506),('LA','Louisiana','South',4658),
('ME','Maine','Northeast',1362),('MD','Maryland','South',6177),
('MA','Massachusetts','Northeast',7030),('MI','Michigan','Midwest',10077),
('MN','Minnesota','Midwest',5706),('MS','Mississippi','South',2962),
('MO','Missouri','Midwest',6154),('MT','Montana','West',1084),
('NE','Nebraska','Midwest',1961),('NV','Nevada','West',3104),
('NH','New Hampshire','Northeast',1377),('NJ','New Jersey','Northeast',9289),
('NM','New Mexico','West',2117),('NY','New York','Northeast',20201),
('NC','North Carolina','South',10439),('ND','North Dakota','Midwest',779),
('OH','Ohio','Midwest',11800),('OK','Oklahoma','South',3959),
('OR','Oregon','West',4238),('PA','Pennsylvania','Northeast',13003),
('RI','Rhode Island','Northeast',1098),('SC','South Carolina','South',5119),
('SD','South Dakota','Midwest',887),('TN','Tennessee','South',6910),
('TX','Texas','South',29145),('UT','Utah','West',3272),
('VT','Vermont','Northeast',643),('VA','Virginia','South',8631),
('WA','Washington','West',7706),('WV','West Virginia','South',1794),
('WI','Wisconsin','Midwest',5894),('WY','Wyoming','West',577);

INSERT INTO cities (city_name, state_id) VALUES
('Los Angeles',  (SELECT state_id FROM states WHERE state_code='CA')),
('San Francisco',(SELECT state_id FROM states WHERE state_code='CA')),
('San Diego',    (SELECT state_id FROM states WHERE state_code='CA')),
('Houston',      (SELECT state_id FROM states WHERE state_code='TX')),
('Dallas',       (SELECT state_id FROM states WHERE state_code='TX')),
('Austin',       (SELECT state_id FROM states WHERE state_code='TX')),
('Miami',        (SELECT state_id FROM states WHERE state_code='FL')),
('Orlando',      (SELECT state_id FROM states WHERE state_code='FL')),
('Tampa',        (SELECT state_id FROM states WHERE state_code='FL')),
('New York City',(SELECT state_id FROM states WHERE state_code='NY')),
('Buffalo',      (SELECT state_id FROM states WHERE state_code='NY')),
('Chicago',      (SELECT state_id FROM states WHERE state_code='IL')),
('Columbus',     (SELECT state_id FROM states WHERE state_code='OH')),
('Phoenix',      (SELECT state_id FROM states WHERE state_code='AZ')),
('Denver',       (SELECT state_id FROM states WHERE state_code='CO')),
('Seattle',      (SELECT state_id FROM states WHERE state_code='WA')),
('Atlanta',      (SELECT state_id FROM states WHERE state_code='GA')),
('Charlotte',    (SELECT state_id FROM states WHERE state_code='NC')),
('Boston',       (SELECT state_id FROM states WHERE state_code='MA')),
('Philadelphia', (SELECT state_id FROM states WHERE state_code='PA'));

INSERT INTO stores (address, city_id, zip_code, latitude, longitude) VALUES
('123 Main St',      1,'90001', 34.052235,-118.243683),
('456 Sunset Blvd',  1,'90028', 34.098000,-118.326000),
('789 Market St',    2,'94103', 37.779300,-122.419200),
('321 Elm St',       4,'77001', 29.760400, -95.369800),
('654 Oak Ave',      4,'77002', 29.752800, -95.366900),
('987 Pine Rd',      7,'33101', 25.774300, -80.193700),
('111 Broadway',    10,'10001', 40.748800, -73.985600),
('222 5th Ave',     10,'10018', 40.753700, -73.993100),
('333 Michigan Ave',12,'60601', 41.885800, -87.623200),
('444 High St',     13,'43215', 39.961200, -82.998800),
('555 Central Ave', 14,'85001', 33.448400,-112.074000),
('666 Colfax Ave',  15,'80202', 39.739200,-104.984900),
('777 Pike St',     16,'98101', 47.608900,-122.335800),
('888 Peachtree',   17,'30301', 33.749000, -84.388000),
('999 Tryon St',    18,'28201', 35.227100, -80.843100),
('101 Boylston',    19,'02101', 42.356200, -71.062000),
('202 Market St',   20,'19101', 39.952800, -75.163900),
('303 La Brea',      1,'90036', 34.079200,-118.340600),
('404 Westheimer',   4,'77056', 29.740900, -95.461600),
('505 Collins Ave',  7,'33139', 25.792000, -80.130000);


-- ============================================================
-- SECTION 3: BUSINESS ANALYSIS QUERIES (run one at a time)
-- Tip: highlight a query and press Cmd+Enter to run just that one
-- ============================================================

-- Q1. Which states have the most Subway locations?
SELECT
    s.state_name,
    s.region,
    COUNT(st.store_id)                             AS total_stores,
    RANK() OVER (ORDER BY COUNT(st.store_id) DESC) AS national_rank
FROM stores st
JOIN cities c ON st.city_id = c.city_id
JOIN states s ON c.state_id = s.state_id
GROUP BY s.state_id, s.state_name, s.region
ORDER BY total_stores DESC;

-- Q2. Store density — stores per 100k population (market saturation)
SELECT
    s.state_name,
    s.region,
    COUNT(st.store_id)                                 AS store_count,
    s.population                                       AS pop_thousands,
    ROUND(COUNT(st.store_id) / s.population * 100, 2) AS stores_per_100k,
    CASE
        WHEN COUNT(st.store_id) / s.population * 100 > 10 THEN 'Saturated'
        WHEN COUNT(st.store_id) / s.population * 100 > 6  THEN 'Balanced'
        ELSE 'Untapped'
    END AS market_status
FROM stores st
JOIN cities c ON st.city_id = c.city_id
JOIN states s ON c.state_id = s.state_id
GROUP BY s.state_id, s.state_name, s.region, s.population
ORDER BY stores_per_100k DESC;

-- Q3. Regional breakdown — % share of national total
SELECT
    s.region,
    COUNT(st.store_id)                                AS total_stores,
    ROUND(COUNT(st.store_id) * 100.0 /
        (SELECT COUNT(*) FROM stores), 2)             AS pct_of_national
FROM stores st
JOIN cities c ON st.city_id = c.city_id
JOIN states s ON c.state_id = s.state_id
GROUP BY s.region
ORDER BY total_stores DESC;

-- Q4. Top 10 cities by store count
SELECT
    c.city_name,
    s.state_name,
    COUNT(st.store_id) AS store_count
FROM stores st
JOIN cities c ON st.city_id = c.city_id
JOIN states s ON c.state_id = s.state_id
GROUP BY c.city_id, c.city_name, s.state_name
ORDER BY store_count DESC
LIMIT 10;

-- Q5. Expansion targets — underserved states (CTE)
WITH state_density AS (
    SELECT
        s.state_id, s.state_name, s.region, s.population,
        COUNT(st.store_id)                      AS store_count,
        COUNT(st.store_id) / s.population * 100 AS stores_per_100k
    FROM stores st
    JOIN cities c ON st.city_id = c.city_id
    JOIN states s ON c.state_id = s.state_id
    GROUP BY s.state_id, s.state_name, s.region, s.population
),
national_avg AS (
    SELECT AVG(stores_per_100k) AS avg_density FROM state_density
)
SELECT
    sd.state_name, sd.region, sd.store_count,
    sd.population                AS pop_thousands,
    ROUND(sd.stores_per_100k,2)  AS stores_per_100k,
    ROUND(na.avg_density,2)      AS national_avg,
    'Expansion Target'           AS recommendation
FROM state_density sd, national_avg na
WHERE sd.stores_per_100k < na.avg_density
  AND sd.population > (SELECT AVG(population) FROM states)
ORDER BY sd.stores_per_100k ASC;

-- Q6. States with NO Subway stores (LEFT JOIN gap analysis)
SELECT
    s.state_name, s.region, s.population AS pop_thousands
FROM states s
LEFT JOIN cities c  ON s.state_id = c.state_id
LEFT JOIN stores st ON c.city_id  = st.city_id
WHERE st.store_id IS NULL
ORDER BY s.population DESC;

-- Q7. Running cumulative total by state (SUM OVER window)
SELECT
    s.state_name, s.region,
    COUNT(st.store_id) AS state_stores,
    SUM(COUNT(st.store_id)) OVER (
        ORDER BY COUNT(st.store_id) DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total,
    ROUND(
        SUM(COUNT(st.store_id)) OVER (
            ORDER BY COUNT(st.store_id) DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) * 100.0 / (SELECT COUNT(*) FROM stores)
    , 1) AS cumulative_pct
FROM stores st
JOIN cities c ON st.city_id = c.city_id
JOIN states s ON c.state_id = s.state_id
GROUP BY s.state_id, s.state_name, s.region
ORDER BY state_stores DESC;

-- Q8. Rank states within each region (PARTITION BY)
SELECT
    s.region, s.state_name,
    COUNT(st.store_id) AS store_count,
    RANK() OVER (
        PARTITION BY s.region
        ORDER BY COUNT(st.store_id) DESC
    ) AS rank_in_region
FROM stores st
JOIN cities c ON st.city_id = c.city_id
JOIN states s ON c.state_id = s.state_id
GROUP BY s.state_id, s.state_name, s.region
ORDER BY s.region, rank_in_region;

-- Q9. Supply chain hubs — top 10% states by store count
--     FIXED: uses NTILE(10) instead of PERCENTILE_CONT
WITH state_counts AS (
    SELECT
        s.state_name,
        COUNT(st.store_id) AS store_count
    FROM stores st
    JOIN cities c ON st.city_id = c.city_id
    JOIN states s ON c.state_id = s.state_id
    GROUP BY s.state_id, s.state_name
),
ranked AS (
    SELECT
        state_name, store_count,
        NTILE(10) OVER (ORDER BY store_count) AS decile
    FROM state_counts
)
SELECT
    state_name, store_count,
    'Distribution Hub Candidate' AS supply_chain_note
FROM ranked
WHERE decile = 10
ORDER BY store_count DESC;

-- Q10. High-density cities (HAVING + DENSE_RANK)
SELECT
    c.city_name, s.state_name, s.region,
    COUNT(st.store_id)                                   AS store_count,
    DENSE_RANK() OVER (ORDER BY COUNT(st.store_id) DESC) AS city_rank
FROM stores st
JOIN cities c ON st.city_id = c.city_id
JOIN states s ON c.state_id = s.state_id
GROUP BY c.city_id, c.city_name, s.state_name, s.region
HAVING store_count >= 2
ORDER BY store_count DESC;

-- Q11. Each state vs its regional average (CTE + JOIN)
WITH region_avgs AS (
    SELECT
        s.region,
        ROUND(AVG(sub.store_count), 1) AS region_avg
    FROM (
        SELECT c.state_id, COUNT(st.store_id) AS store_count
        FROM stores st
        JOIN cities c ON st.city_id = c.city_id
        GROUP BY c.state_id
    ) sub
    JOIN states s ON sub.state_id = s.state_id
    GROUP BY s.region
)
SELECT
    s.state_name, s.region,
    COUNT(st.store_id)                           AS state_stores,
    ra.region_avg,
    ROUND(COUNT(st.store_id) - ra.region_avg, 1) AS vs_region_avg,
    CASE
        WHEN COUNT(st.store_id) > ra.region_avg THEN 'Above average'
        WHEN COUNT(st.store_id) < ra.region_avg THEN 'Below average'
        ELSE 'At average'
    END AS performance
FROM stores st
JOIN cities      c  ON st.city_id = c.city_id
JOIN states      s  ON c.state_id = s.state_id
JOIN region_avgs ra ON s.region   = ra.region
GROUP BY s.state_id, s.state_name, s.region, ra.region_avg
ORDER BY s.region, state_stores DESC;

-- Q12. ZIP code hotspots (micro-level clustering)
SELECT
    st.zip_code, c.city_name, s.state_name,
    COUNT(st.store_id) AS stores_in_zip
FROM stores st
JOIN cities c ON st.city_id = c.city_id
JOIN states s ON c.state_id = s.state_id
WHERE st.zip_code IS NOT NULL
GROUP BY st.zip_code, c.city_name, s.state_name
HAVING stores_in_zip > 1
ORDER BY stores_in_zip DESC
LIMIT 20;

-- Q13. Opportunity score — population-weighted expansion metric
SELECT
    s.state_name, s.region,
    s.population                                            AS pop_thousands,
    COUNT(st.store_id)                                      AS current_stores,
    ROUND(s.population / NULLIF(COUNT(st.store_id),0), 1)  AS residents_per_store,
    ROUND(
        (s.population / NULLIF(COUNT(st.store_id),0)) *
        LOG(s.population + 1) / 100
    , 2) AS opportunity_score
FROM stores st
JOIN cities c ON st.city_id = c.city_id
JOIN states s ON c.state_id = s.state_id
GROUP BY s.state_id, s.state_name, s.region, s.population
ORDER BY opportunity_score DESC
LIMIT 15;

-- Q14. Month-over-month store additions (date functions)
SELECT
    DATE_FORMAT(date_added, '%Y-%m') AS month,
    COUNT(*)                         AS stores_added,
    SUM(COUNT(*)) OVER (
        ORDER BY DATE_FORMAT(date_added, '%Y-%m')
    ) AS cumulative_total
FROM stores
WHERE date_added IS NOT NULL
GROUP BY month
ORDER BY month;

-- Q15. Executive summary VIEW (reusable for reporting)
CREATE OR REPLACE VIEW vw_executive_summary AS
SELECT
    s.region, s.state_name, s.state_code,
    s.population                                       AS pop_thousands,
    COUNT(st.store_id)                                 AS total_stores,
    ROUND(COUNT(st.store_id) / s.population * 100, 2) AS stores_per_100k,
    RANK() OVER (ORDER BY COUNT(st.store_id) DESC)     AS national_rank,
    RANK() OVER (
        PARTITION BY s.region ORDER BY COUNT(st.store_id) DESC
    )                                                  AS regional_rank,
    CASE
        WHEN COUNT(st.store_id) / s.population * 100 > 10 THEN 'Saturated'
        WHEN COUNT(st.store_id) / s.population * 100 > 6  THEN 'Balanced'
        ELSE 'Untapped'
    END AS market_status
FROM stores st
JOIN cities c ON st.city_id = c.city_id
JOIN states s ON c.state_id = s.state_id
GROUP BY s.state_id, s.state_name, s.state_code, s.region, s.population;

SELECT * FROM vw_executive_summary ORDER BY national_rank;
