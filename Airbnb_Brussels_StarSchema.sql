-- Airbnb Brussels - Star Schema Build
-- Fatima Ben khaled

USE fatima_db;

DROP TABLE IF EXISTS Fact_Listing_Snapshot;
DROP TABLE IF EXISTS Dim_Date;
DROP TABLE IF EXISTS Dim_Neighbourhood;
DROP TABLE IF EXISTS Dim_RoomType;
DROP TABLE IF EXISTS listings_staging;

CREATE TABLE listings_staging (
    ListingID          BIGINT,
    HostID             BIGINT,
    NeighbourhoodName  VARCHAR(100),
    RoomTypeName       VARCHAR(50),
    Latitude           DOUBLE,
    Longitude          DOUBLE,
    Price              DECIMAL(10,2),
    Availability365    INT,
    SnapshotDate       DATE
);


CREATE TABLE Dim_Date (
    DateID        INT AUTO_INCREMENT PRIMARY KEY,
    SnapshotDate  DATE UNIQUE NOT NULL,
    Season        VARCHAR(20) NOT NULL
);

CREATE TABLE Dim_Neighbourhood (
    NeighbourhoodID    INT AUTO_INCREMENT PRIMARY KEY,
    NeighbourhoodName  VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE Dim_RoomType (
    RoomTypeID    INT AUTO_INCREMENT PRIMARY KEY,
    RoomTypeName  VARCHAR(50) UNIQUE NOT NULL
);


CREATE TABLE Fact_Listing_Snapshot (
    ListingID         BIGINT NOT NULL,
    DateID            INT NOT NULL,
    NeighbourhoodID   INT NOT NULL,
    RoomTypeID        INT NOT NULL,
    Price             DECIMAL(10,2) NOT NULL,
    Availability365   INT,
    Latitude          DOUBLE,
    Longitude         DOUBLE,
    PRIMARY KEY (ListingID, DateID),
    FOREIGN KEY (DateID)          REFERENCES Dim_Date(DateID),
    FOREIGN KEY (NeighbourhoodID) REFERENCES Dim_Neighbourhood(NeighbourhoodID),
    FOREIGN KEY (RoomTypeID)      REFERENCES Dim_RoomType(RoomTypeID)
);


INSERT INTO Dim_Date (SnapshotDate, Season)
SELECT DISTINCT
    SnapshotDate,
    CASE
        WHEN MONTH(SnapshotDate) = 6 THEN 'Summer'
        WHEN MONTH(SnapshotDate) = 9 THEN 'Autumn'
        ELSE 'Other'
    END
FROM listings_staging
ORDER BY SnapshotDate;

INSERT INTO Dim_Neighbourhood (NeighbourhoodName)
SELECT DISTINCT NeighbourhoodName
FROM listings_staging
ORDER BY NeighbourhoodName;

INSERT INTO Dim_RoomType (RoomTypeName)
SELECT DISTINCT RoomTypeName
FROM listings_staging
ORDER BY RoomTypeName;


INSERT INTO Fact_Listing_Snapshot
SELECT
    s.ListingID,
    d.DateID,
    n.NeighbourhoodID,
    r.RoomTypeID,
    s.Price,
    s.Availability365,
    s.Latitude,
    s.Longitude
FROM listings_staging s
JOIN Dim_Date          d ON s.SnapshotDate      = d.SnapshotDate
JOIN Dim_Neighbourhood n ON s.NeighbourhoodName = n.NeighbourhoodName
JOIN Dim_RoomType      r ON s.RoomTypeName      = r.RoomTypeName;


SELECT 'Dim_Date'              AS table_name, COUNT(*) AS row_count FROM Dim_Date
UNION ALL SELECT 'Dim_RoomType',           COUNT(*) FROM Dim_RoomType
UNION ALL SELECT 'Dim_Neighbourhood',      COUNT(*) FROM Dim_Neighbourhood
UNION ALL SELECT 'Fact_Listing_Snapshot',  COUNT(*) FROM Fact_Listing_Snapshot;




-- Row counts per snapshot
SELECT d.SnapshotDate, d.Season, COUNT(*) AS row_count
FROM Fact_Listing_Snapshot f
JOIN Dim_Date d ON f.DateID = d.DateID
GROUP BY d.SnapshotDate, d.Season
ORDER BY d.SnapshotDate;


-- Median price per snapshot
WITH ranked AS (
    SELECT
        d.SnapshotDate,
        f.Price,
        ROW_NUMBER() OVER (PARTITION BY d.SnapshotDate ORDER BY f.Price) AS rn,
        COUNT(*)     OVER (PARTITION BY d.SnapshotDate)                  AS total
    FROM Fact_Listing_Snapshot f
    JOIN Dim_Date d ON f.DateID = d.DateID
)
SELECT SnapshotDate, ROUND(AVG(Price), 2) AS median_price
FROM ranked
WHERE rn IN ((total + 1) DIV 2, (total + 2) DIV 2)
GROUP BY SnapshotDate
ORDER BY SnapshotDate;


-- Median price by room type and snapshot
WITH ranked AS (
    SELECT
        r.RoomTypeName,
        d.SnapshotDate,
        f.Price,
        ROW_NUMBER() OVER (PARTITION BY r.RoomTypeName, d.SnapshotDate ORDER BY f.Price) AS rn,
        COUNT(*)     OVER (PARTITION BY r.RoomTypeName, d.SnapshotDate)                  AS total
    FROM Fact_Listing_Snapshot f
    JOIN Dim_RoomType r ON f.RoomTypeID = r.RoomTypeID
    JOIN Dim_Date     d ON f.DateID     = d.DateID
)
SELECT RoomTypeName, SnapshotDate, ROUND(AVG(Price), 2) AS median_price
FROM ranked
WHERE rn IN ((total + 1) DIV 2, (total + 2) DIV 2)
GROUP BY RoomTypeName, SnapshotDate
ORDER BY RoomTypeName, SnapshotDate;


-- Median price by neighbourhood
WITH ranked AS (
    SELECT
        n.NeighbourhoodName,
        f.Price,
        ROW_NUMBER() OVER (PARTITION BY n.NeighbourhoodName ORDER BY f.Price) AS rn,
        COUNT(*)     OVER (PARTITION BY n.NeighbourhoodName)                  AS total
    FROM Fact_Listing_Snapshot f
    JOIN Dim_Neighbourhood n ON f.NeighbourhoodID = n.NeighbourhoodID
)
SELECT NeighbourhoodName, ROUND(AVG(Price), 2) AS median_price
FROM ranked
WHERE rn IN ((total + 1) DIV 2, (total + 2) DIV 2)
GROUP BY NeighbourhoodName
ORDER BY median_price DESC;


-- Median price by room type (combined both snapshots)
WITH ranked AS (
    SELECT
        r.RoomTypeName,
        f.Price,
        ROW_NUMBER() OVER (PARTITION BY r.RoomTypeName ORDER BY f.Price) AS rn,
        COUNT(*)     OVER (PARTITION BY r.RoomTypeName)                  AS total
    FROM Fact_Listing_Snapshot f
    JOIN Dim_RoomType r ON f.RoomTypeID = r.RoomTypeID
)
SELECT RoomTypeName, ROUND(AVG(Price), 2) AS median_price
FROM ranked
WHERE rn IN ((total + 1) DIV 2, (total + 2) DIV 2)
GROUP BY RoomTypeName
ORDER BY median_price DESC;
