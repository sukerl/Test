DROP TABLE IF EXISTS Metrics;
DROP TABLE IF EXISTS Magnitudes;
DROP TABLE IF EXISTS RatingCodes;
DROP TABLE IF EXISTS Periods;
DROP TABLE IF EXISTS Symbols;

CREATE TABLE IF NOT EXISTS Symbols (
Symbol_ID SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
Symbol VARCHAR(20) NOT NULL,
SymbolText VARCHAR(200),
CONSTRAINT unique_content UNIQUE (Symbol)
);

CREATE TABLE IF NOT EXISTS Magnitudes (
Magnitude_ID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
Peak DECIMAL(6,3) NOT NULL,
Average DECIMAL(6,3) NOT NULL,
Low DECIMAL(6,3) NOT NULL
);

CREATE TABLE IF NOT EXISTS RatingCodes (
RatingCode_ID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
RatingCode VARCHAR(10) NOT NULL,
High DECIMAL(6,3) NOT NULL,
Low DECIMAL(6,3) NOT NULL,
CONSTRAINT unique_content UNIQUE (RatingCode)
);

CREATE TABLE IF NOT EXISTS Periods (
Period_ID SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
PeriodName VARCHAR(100) NOT NULL,
PeriodMinus5 SMALLINT UNSIGNED NOT NULL,
PeriodMinus4 SMALLINT UNSIGNED NOT NULL,
PeriodMinus3 SMALLINT UNSIGNED NOT NULL,
PeriodMinus2 SMALLINT UNSIGNED NOT NULL,
PeriodMinus1 SMALLINT UNSIGNED NOT NULL,
PeriodPlus1 SMALLINT UNSIGNED NOT NULL,
PeriodPlus2 SMALLINT UNSIGNED NOT NULL,
PeriodPlus3 SMALLINT UNSIGNED NOT NULL,
CONSTRAINT unique_content UNIQUE (PeriodName, PeriodMinus1, PeriodMinus2, PeriodMinus3, PeriodMinus4, PeriodMinus5, PeriodPlus1, PeriodPlus2, PeriodPlus3)
);

CREATE TABLE IF NOT EXISTS Metrics (
Metric_ID BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
PriceTime TIMESTAMP NOT NULL,
Period_ID SMALLINT UNSIGNED NOT NULL,
Symbol_ID SMALLINT UNSIGNED NOT NULL,
Complete BOOLEAN,
PM5_Magnitude_ID INT NOT NULL,
PM4_Magnitude_ID INT NOT NULL,
PM3_Magnitude_ID INT NOT NULL,
PM2_Magnitude_ID INT NOT NULL,
PM1_Magnitude_ID INT NOT NULL,
PP1_Magnitude_ID INT NOT NULL,
PP2_Magnitude_ID INT NOT NULL,
PP3_Magnitude_ID INT NOT NULL,
CONSTRAINT fk_me_period_id FOREIGN KEY (Period_ID) REFERENCES Periods(Period_ID),
CONSTRAINT fk_me_symbol_id FOREIGN KEY (Symbol_ID) REFERENCES Symbols(Symbol_ID),
CONSTRAINT fk_me_pm5_mag_id FOREIGN KEY (PM5_Magnitude_ID) REFERENCES Magnitudes(Magnitude_ID),
CONSTRAINT fk_me_pm4_mag_id FOREIGN KEY (PM4_Magnitude_ID) REFERENCES Magnitudes(Magnitude_ID),
CONSTRAINT fk_me_pm3_mag_id FOREIGN KEY (PM3_Magnitude_ID) REFERENCES Magnitudes(Magnitude_ID),
CONSTRAINT fk_me_pm2_mag_id FOREIGN KEY (PM2_Magnitude_ID) REFERENCES Magnitudes(Magnitude_ID),
CONSTRAINT fk_me_pm1_mag_id FOREIGN KEY (PM1_Magnitude_ID) REFERENCES Magnitudes(Magnitude_ID),
CONSTRAINT fk_me_pp1_mag_id FOREIGN KEY (PP1_Magnitude_ID) REFERENCES Magnitudes(Magnitude_ID),
CONSTRAINT fk_me_pp2_mag_id FOREIGN KEY (PP2_Magnitude_ID) REFERENCES Magnitudes(Magnitude_ID),
CONSTRAINT fk_me_pp3_mag_id FOREIGN KEY (PP3_Magnitude_ID) REFERENCES Magnitudes(Magnitude_ID),
CONSTRAINT unique_content UNIQUE (PriceTime, Period_ID, Symbol_ID)
);

CREATE INDEX IF NOT EXISTS MetricsPriceTime_Index ON Metrics(PriceTime);

CREATE OR REPLACE VIEW Average_Metrics AS
SELECT M.Metric_ID, M.PriceTime, M.Period_ID, M.Symbol_ID, MM5.Average AS M5_Avg, MM4.Average AS M4_Avg, MM3.Average AS M3_Avg, MM2.Average AS M2_Avg, MM1.Average AS M1_Avg, MP1.Peak AS P1_Peak, MP1.Average AS P1_Avg, MP1.Low AS P1_Low, MP2.Peak AS P2_Peak, MP2.Average AS P2_Avg, MP2.Low AS P2_Low, MP3.Peak AS P3_Peak, MP3.Average AS P3_Avg, MP3.Low AS P3_Low
FROM Metrics M
JOIN Magnitudes MM5 ON MM5.Magnitude_ID=M.PM5_Magnitude_ID
JOIN Magnitudes MM4 ON MM4.Magnitude_ID=M.PM4_Magnitude_ID
JOIN Magnitudes MM3 ON MM3.Magnitude_ID=M.PM3_Magnitude_ID
JOIN Magnitudes MM2 ON MM2.Magnitude_ID=M.PM2_Magnitude_ID
JOIN Magnitudes MM1 ON MM1.Magnitude_ID=M.PM1_Magnitude_ID
JOIN Magnitudes MP1 ON MP1.Magnitude_ID=M.PP1_Magnitude_ID
JOIN Magnitudes MP2 ON MP2.Magnitude_ID=M.PP2_Magnitude_ID
JOIN Magnitudes MP3 ON MP3.Magnitude_ID=M.PP3_Magnitude_ID
ORDER BY M.Metric_ID;

CREATE OR REPLACE VIEW Ratings_By_Average_Metrics AS
SELECT AM.Period_ID, AM.Symbol_ID, RM5.RatingCode AS RC_M5, RM4.RatingCode AS RC_M4, RM3.RatingCode AS RC_M3, RM2.RatingCode AS RC_M2, RM1.RatingCode AS RC_M1, AVG(P1_Peak) as Avg_P1_Peak, AVG(P1_Avg) as Avg_P1_Avg, AVG(P1_Low) as Avg_P1_Low, AVG(P2_Peak) as Avg_P2_Peak, AVG(P2_Avg) as Avg_P2_Avg, AVG(P2_Low) as Avg_P2_Low, AVG(P3_Peak) as Avg_P3_Peak, AVG(P3_Avg) as Avg_P3_Avg, AVG(P3_Low) as Avg_P3_Low, COUNT(*) AS RatingCount
FROM Average_Metrics AM
JOIN RatingCodes RM5 ON AM.M5_Avg BETWEEN RM5.Low AND RM5.High
JOIN RatingCodes RM4 ON AM.M4_Avg BETWEEN RM4.Low AND RM4.High
JOIN RatingCodes RM3 ON AM.M3_Avg BETWEEN RM3.Low AND RM3.High
JOIN RatingCodes RM2 ON AM.M2_Avg BETWEEN RM2.Low AND RM2.High
JOIN RatingCodes RM1 ON AM.M1_Avg BETWEEN RM1.Low AND RM1.High
GROUP BY AM.Period_ID, AM.Symbol_ID, RM5.RatingCode, RM4.RatingCode, RM3.RatingCode, RM2.RatingCode, RM2.RatingCode;

INSERT INTO Symbols (Symbol_ID, Symbol, SymbolText) VALUES (1, 'SCUSDT', 'Siacoin / Tether');

INSERT INTO Magnitudes (Magnitude_ID, Peak, Average, Low) VALUES (1, 2.5, 0.5, -0.1);
INSERT INTO Magnitudes (Magnitude_ID, Peak, Average, Low) VALUES (2, 1.8, 1.7, 0.5);
INSERT INTO Magnitudes (Magnitude_ID, Peak, Average, Low) VALUES (3, -2.4, -1.5, -3.6);
INSERT INTO Magnitudes (Magnitude_ID, Peak, Average, Low) VALUES (4, 4.6, 0.2, 0.1);
INSERT INTO Magnitudes (Magnitude_ID, Peak, Average, Low) VALUES (5, 4.0, 1.7, -5.0);
INSERT INTO Magnitudes (Magnitude_ID, Peak, Average, Low) VALUES (6, 4.2, 1.5, -1.0);
INSERT INTO Magnitudes (Magnitude_ID, Peak, Average, Low) VALUES (7, 4.4, 1.2, -2.0);
INSERT INTO Magnitudes (Magnitude_ID, Peak, Average, Low) VALUES (8, 4.6, 1.0, -1.50);
INSERT INTO Magnitudes (Magnitude_ID, Peak, Average, Low) VALUES (9, 9.2, 1.0, -1.99);

INSERT INTO RatingCodes (RatingCode_ID, RatingCode, High, Low) VALUES (1, 'A', 0.50, 0.21);
INSERT INTO RatingCodes (RatingCode_ID, RatingCode, High, Low) VALUES (2, 'AA', 1.00, 0.51);
INSERT INTO RatingCodes (RatingCode_ID, RatingCode, High, Low) VALUES (3, 'AAA', 2.00, 1.01);
INSERT INTO RatingCodes (RatingCode_ID, RatingCode, High, Low) VALUES (4, 'AAAA', 100.00, 2.01);
INSERT INTO RatingCodes (RatingCode_ID, RatingCode, High, Low) VALUES (5, 'A-', 0.20, -0.5);
INSERT INTO RatingCodes (RatingCode_ID, RatingCode, High, Low) VALUES (6, 'AA-', -0.51, -1.00);
INSERT INTO RatingCodes (RatingCode_ID, RatingCode, High, Low) VALUES (7, 'AAA-', -1.01, -2.00);
INSERT INTO RatingCodes (RatingCode_ID, RatingCode, High, Low) VALUES (8, 'AAAA-', -2.01, -100.00);

INSERT INTO Periods (Period_ID, PeriodName, PeriodMinus5, PeriodMinus4, PeriodMinus3, PeriodMinus2, PeriodMinus1, PeriodPlus1, PeriodPlus2, PeriodPlus3) VALUES (1, '180-90-45-15-5-5-45-120', 180, 90, 45, 15, 5, 5, 45, 120);

INSERT INTO Metrics (Metric_ID, PriceTime, Period_ID, Symbol_ID, Complete, PM5_Magnitude_ID, PM4_Magnitude_ID, PM3_Magnitude_ID, PM2_Magnitude_ID, PM1_Magnitude_ID, PP1_Magnitude_ID, PP2_Magnitude_ID, PP3_Magnitude_ID) VALUES (1, '2020-07-06 07:00:00', 1, 1, null, 1, 2, 3, 4, 5, 6, 7, 8);
INSERT INTO Metrics (Metric_ID, PriceTime, Period_ID, Symbol_ID, Complete, PM5_Magnitude_ID, PM4_Magnitude_ID, PM3_Magnitude_ID, PM2_Magnitude_ID, PM1_Magnitude_ID, PP1_Magnitude_ID, PP2_Magnitude_ID, PP3_Magnitude_ID) VALUES (2, '2020-07-06 07:01:00', 1, 1, null, 2, 3, 4, 5, 6, 7, 8, 1);
INSERT INTO Metrics (Metric_ID, PriceTime, Period_ID, Symbol_ID, Complete, PM5_Magnitude_ID, PM4_Magnitude_ID, PM3_Magnitude_ID, PM2_Magnitude_ID, PM1_Magnitude_ID, PP1_Magnitude_ID, PP2_Magnitude_ID, PP3_Magnitude_ID) VALUES (3, '2020-07-06 07:02:00', 1, 1, null, 3, 4, 5, 6, 7, 8, 1, 2);
INSERT INTO Metrics (Metric_ID, PriceTime, Period_ID, Symbol_ID, Complete, PM5_Magnitude_ID, PM4_Magnitude_ID, PM3_Magnitude_ID, PM2_Magnitude_ID, PM1_Magnitude_ID, PP1_Magnitude_ID, PP2_Magnitude_ID, PP3_Magnitude_ID) VALUES (4, '2020-07-06 07:03:00', 1, 1, null, 1, 2, 3, 4, 5, 6, 7, 9);
