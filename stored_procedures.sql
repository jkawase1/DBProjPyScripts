delimiter //

#Useful Views
DROP VIEW IF EXISTS AllWeapons;
CREATE VIEW AllWeapons AS
    SELECT DISTINCT Weapon
    FROM SHR;

DROP VIEW IF EXISTS AllCityStates;
CREATE VIEW AllCityStates AS
    SELECT DISTINCT County
    FROM UCR;

DROP VIEW IF EXISTS MinMaxYearsSHR;
CREATE VIEW MinMaxYearsSHR AS
    SELECT DISTINCT MIN(Year), MAX(Year)
    FROM SHR;

DROP VIEW IF EXISTS MinMaxYearsUCR;
CREATE VIEW MinMaxYearsUCR AS
    SELECT DISTINCT MIN(Year), MAX(Year)
    FROM UCR;

#Specific Queries
/*Query 1*/
DROP PROCEDURE IF EXISTS AverageNumVictimsByState;
CREATE PROCEDURE AverageNumVictimsByState(IN state VARCHAR(50), startYear INTEGER, endYear INTEGER)
BEGIN
    SELECT AVG(NumMurders) FROM UCR WHERE Year BETWEEN startYear AND endYear GROUP BY state;
END //

/*Query 2*/
DROP PROCEDURE IF EXISTS LowestClearanceRateByYear;
CREATE PROCEDURE LowestClearanceRateByYear(IN year INTEGER)
BEGIN
    SELECT DISTINCT S.county AS County, S.clRate
    FROM (
        SELECT county, NumSolved/NumMurders as clRate 
        FROM UCR 
        WHERE Year = year) AS S
    WHERE S.clRate = (
        SELECT MIN(NumSolved/NumMurders)
        FROM UCR 
        WHERE Year = year);
END //

/*Query 3*/
DROP PROCEDURE IF EXISTS ClearanceRateUnder50ByCounty;
CREATE PROCEDURE ClearanceRateUnder50ByCounty(IN firstYear INTEGER, secondYear INTEGER)
BEGIN
    SELECT DISTINCT county1 AS County
    FROM (
        SELECT county AS county1
        FROM UCR
        WHERE NumSolved/NumMurders < .5 AND Year = firstYear) AS S
    JOIN (
        SELECT county AS county2
        FROM UCR
        WHERE NumSolved/NumMurders < .5 AND Year = secondYear) AS T 
    ON S.county1 = T.county2;
END //

/*Query 4*/
DROP PROCEDURE IF EXISTS ActiveSerialKillerDuringHighestNumCases;
CREATE PROCEDURE ActiveSerialKillerDuringHighestNumCases(IN solved VARCHAR(8))
BEGIN
    IF (solved = 'solved') THEN
        SELECT SKD.Name
        FROM SKD, (
            SELECT G.Year
            FROM (
                SELECT Year, sum(NumSolved) as TotSolved
                FROM UCR
                GROUP BY Year) AS G
            WHERE G.TotSolved = (
                SELECT max(R.TotSolved) 
                FROM (
                    SELECT sum(NumSolved) as TotSolved
                    FROM UCR
                    GROUP BY Year) AS R)
        ) AS S
        WHERE S.Year BETWEEN SKD.YearStarted AND SKD.YearEnded;
    ELSE
        SELECT SKD.Name
        FROM SKD, (
            SELECT G.Year
            FROM (
                SELECT Year, sum(NumMurders)-sum(NumSolved) AS NumUnsolvedMurders
                FROM UCR
                GROUP BY Year) AS G
            WHERE G.NumUnsolvedMurders = (
                SELECT max(T.NumUnsolvedMurders)
                FROM (
                    SELECT sum(numMurders)-sum(NumSolved) AS NumUnsolvedMurders 
                    FROM UCR 
                    GROUP BY Year) AS T)
        ) AS S
        WHERE S.Year BETWEEN SKD.YearStarted AND SKD.YearEnded;
    END IF;
END //

/*Query 5*/
DROP PROCEDURE IF EXISTS MostUnsolvedMurdersByWeaponGenderAge;
CREATE PROCEDURE MostUnsolvedMurdersByWeaponGenderAge(IN murderWeapon VARCHAR(50), gender VARCHAR(6), age INTEGER)
BEGIN
    SELECT S.City, S.State
    FROM (
        SELECT City, State, count(Weapon) as numWeaponCases
        FROM SHR
        WHERE Weapon = weapon AND Solved = 'No' AND VictimSex = gender AND VictimAge < age
        GROUP BY City, State) AS S
    WHERE S.numWeaponCases = (SELECT MAX(T.numWeaponCases)
        FROM (
            SELECT City, State, count(Weapon) as numWeaponCases
            FROM SHR
            WHERE Weapon = weapon AND Solved = 'No' AND VictimSex = gender AND VictimAge < age
            GROUP BY City, State) AS T);
END //

/*Query 6*/
DROP PROCEDURE IF EXISTS PoliceDeptInvestigationsByWeapon;
CREATE PROCEDURE PoliceDeptInvestigationsByWeapon(IN numWeaponCases INTEGER)
BEGIN
    SELECT DISTINCT S.Agency 
    FROM SHR AS S
    WHERE NOT EXISTS (
        SELECT Weapon
        FROM AllWeapons
        WHERE Weapon NOT IN (
            SELECT T.Weapon 
            FROM (
                SELECT Agency, Weapon, count(Weapon) as WeaponCount
                FROM SHR
                GROUP BY Agency, Weapon) AS T
            WHERE T.WeaponCount >= numWeaponCases AND T.Agency = S.Agency)
    );
END //

#General Queries
/*Query 7*/
DROP PROCEDURE IF EXISTS SerialKillersActiveByYear;
CREATE PROCEDURE SerialKillersActiveByYear(IN yearActive INTEGER)
BEGIN
    SELECT Name
    FROM SKD
    WHERE yearActive BETWEEN YearStarted AND YearEnded;
END //

/*Query 8*/
DROP PROCEDURE IF EXISTS MurderClearanceRateByState;
CREATE PROCEDURE MurderClearanceRateByState(IN stateName VARCHAR(50))
BEGIN
    SELECT sum(NumSolved)/sum(NumMurders) AS ClearanceRate
    FROM UCR
    WHERE state = stateName
    GROUP BY state;
END //

/*Query 9*/
DROP PROCEDURE IF EXISTS MurderByWeapon;
CREATE PROCEDURE MurderByWeapon(IN murderWeapon VARCHAR(50))
BEGIN
    SELECT *
    FROM SHR AS S
    WHERE S.Weapon = murderWeapon;
END //

/*Query 10*/
DROP PROCEDURE IF EXISTS SerialKillersByProvenVictims;
CREATE PROCEDURE SerialKillersByProvenVictims(IN numVics INTEGER)
BEGIN
    SELECT Name, ProvenVictims
    FROM SKD
    WHERE ProvenVictims > numVics;
END //

/*Query 11*/
DROP PROCEDURE IF EXISTS LessThanMurdersByState;
CREATE PROCEDURE LessThanMurdersByState(IN murders INTEGER)
BEGIN
    SELECT T.state from (
                            SELECT DISTINCT state, sum(NumMurders) as TotMurders
                            FROM UCR
                            GROUP BY state) as T
    WHERE T.TotMurders < murders;
END //

/*Query 12*/
DROP PROCEDURE IF EXISTS UnsolvedMurdersByAge;
CREATE PROCEDURE UnsolvedMurdersByAge(IN vicAge INTEGER)
BEGIN
    SELECT *
    FROM SHR
    WHERE Solved = 'No' AND VictimAge = vicAge;
END //
