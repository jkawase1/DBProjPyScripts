delimiter //

#Useful Views
DROP VIEW IF EXISTS AllWeapons;
CREATE VIEW AllWeapons AS
    SELECT DISTINCT Weapons
    FROM SHR;

DROP VIEW IF EXISTS AllCityStates;
CREATE VIEW AllCityStates AS
    SELECT DISINCT County
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
DROP PROCEDURE IF EXISTS AverageNumVictimsByState;
CREATE PROCEDURE AverageNumVictimsByState(IN state VARCHAR(50), startYear INTEGER, endYear INTEGER)
BEGIN
    SELECT AVG(NumMurders) FROM UCR WHERE Year BETWEEN startYear AND endYear GROUP BY state;
END //

DROP PROCEDURE IF EXISTS LowestClearanceRateByYear;
CREATE PROCEDURE LowestClearanceRateByYear(IN year INTEGER)
BEGIN
    SELECT S.county, min(S.clRate)
    FROM (SELECT county, NumSolved/NumMurders as clRate FROM UCR WHERE Year = year) AS S;
END //

DROP PROCEDURE IF EXISTS ClearanceRateUnder50ByCounty;
CREATE PROCEDURE ClearanceRateUnder50ByCounty(IN firstYear INTEGER, secondYear INTEGER)
BEGIN
    SELECT *
    FROM (
        SELECT county
        FROM UCR
        WHERE NumSolvedMurders/NumMurders < .5 AND Year = firstYear) AS S
        JOIN (
            SELECT county
            FROM UCR
            WHERE NumSolvedMurders/NumMurders < .5 AND Year = secondYear) AS T ON S.county = T.county;
END //

DROP PROCEDURE IF EXISTS ActiveSerialKillerDuringHighestNumCases;
CREATE PROCEDURE ActiveSerialKillerDuringHighestNumCases(IN solved VARCHAR(3))
BEGIN
    IF (solved = 'Yes') THEN
        SELECT SKD.Name
        FROM SKD, (SELECT Year, NumSolved
                   FROM UCR
                   WHERE NumUnsolved = (SELECT max(NumSolved) FROM UCR)) AS S
        WHERE S.Year BETWEEN SKD.YearStarted AND SKD.YearEnded;
    ELSE
        SELECT SKD.Name
        FROM SKD, (SELECT Year, NumMurders-NumSolvedMurder AS NumUnsolvedMurders
                   FROM UCR
                   WHERE NumUnsolvedMurders = (SELECT max(NumMurders - NumSolvedMurder) FROM UCR)) AS S
        WHERE S.Year BETWEEN SKD.YearStarted AND SKD.YearEnded;
    END IF;
END //

DROP PROCEDURE IF EXISTS MostUnsolvedMurdersByWeaponGenderAge;
CREATE PROCEDURE MostUnsolvedMurdersByWeaponGenderAge(IN murderWeapon VARCHAR(50), gender VARCHAR(6), age INTEGER)
BEGIN
    SELECT S.City, S.State
    FROM (
        SELECT City, State, count(Weapon) as numWeaponCases
        FROM SHR
        WHERE Weapon = weapon AND Solved = “No” AND VictimSex = gender AND VictmAge < age
        GROUP BY City, State) AS S WHERE S.numWeaponCases = (
            SELECT max(T.totWeapon)
            FROM (
                SELECT City, State, count(Weapon) as totWeapon
                FROM SHR
                WHERE Weapon = murderWeapon AND Solved = “No” AND VictimSex = gender AND VictmAge < age
                GROUP BY City, State) as T
            );
END //

DROP PROCEDURE IF EXISTS PoliceDeptInvestigationsByWeapon;
CREATE PROCEDURE PoliceDeptInvestigationsByWeapon(IN numWeaponCases INTEGER)
BEGIN
    SELECT S.Agency FROM SHR AS S
    WHERE NOT EXISTS (
        (SELECT DISTINCT Weapon
        FROM SHR) NOT IN (
            SELECT R.Weapon
            FROM SHR AS R, (
                SELECT City, State, Weapon, count(Weapon) as WeaponCount
                FROM SHR
                GROUP BY City, State) as T
            WHERE R.City = S.City AND R.State = S.State AND R.Agency = S.Agency AND T.City = R.City AND T.State = R.State
              AND T.weaponCount >= NumWeaponCases AND T.Weapon = R.Weapon)
        );
END //

#General Queries
DROP PROCEDURE IF EXISTS SerialKillersActiveByYear;
CREATE PROCEDURE SerialKillersActiveByYear(IN yearActive INTEGER)
BEGIN
    SELECT Name
    FROM SKD
    WHERE yearActive BETWEEN YearStarted AND YearEnded;
END //

DROP PROCEDURE IF EXISTS MurderClearanceRateByState;
CREATE PROCEDURE MurderClearanceRateByState(IN stateName VARCHAR(50))
BEGIN
    SELECT sum(NumMurders)/sum(NumSolved) AS ClearanceRate
    FROM UCR
    WHERE state = stateName
    GROUP BY state;
END //

DROP PROCEDURE IF EXISTS MurdersByWeapon;
CREATE PROCEDURE MurderByWeapon(IN murderWeapon VARCHAR(20))
BEGIN
    SELECT *
    FROM SHR
    WHERE Weapon = murderWeapon;
END //

DROP PROCEDURE IF EXISTS SerialKillersByProvenVictims;
CREATE PROCEDURE SerialKillersByProvenVictims(IN numVics INTEGER)
BEGIN
    SELECT Name, ProvenVictims
    FROM SKD
    WHERE ProvenVictims > numVics;
END //

DROP PROCEDURE IF EXISTS LessThanMurdersByState;
CREATE PROCEDURE LessThanMurdersByState(IN murders INTEGER)
BEGIN
    SELECT T.state from (
                            SELECT DISTINCT state, sum(NumMurders) as TotMurders
                            FROM UCR
                            GROUP BY state) as T
    WHERE T.TotMurders < murders;
END //

DROP PROCEDURE IF EXISTS UnsolvedMurdersByAge;
CREATE PROCEDURE UnsolvedMurdersByAge(IN vicAge INTEGER)
BEGIN
    SELECT *
    FROM SHR
    WHERE Solved = 'No' AND VictimAge = vicAge;
END //
