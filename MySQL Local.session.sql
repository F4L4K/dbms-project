CREATE TABLE Criminal (
    criminal_id VARCHAR(20) PRIMARY KEY,
    criminal_name VARCHAR(20) NOT NULL,
    dob DATE,
    age INT,
    gender VARCHAR(10) CHECK (gender IN('Male', 'Female')),
    contact VARCHAR(20),
    address VARCHAR(200)
);

CREATE TABLE Crimes (
    crime_id VARCHAR(20) PRIMARY KEY,
    crime_type VARCHAR(20) NOT NULL,
    date DATE,
    time TIME,
    location VARCHAR(200),
    details VARCHAR(200),
    criminal_id VARCHAR(20),
    FOREIGN KEY (criminal_id) REFERENCES Criminal(criminal_id)
);

CREATE TABLE Victim (
    victim_id VARCHAR(20) PRIMARY KEY,
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    dob DATE,
    gender VARCHAR(5) CHECK (gender IN('Male', 'Female')),
    contact VARCHAR(20),
    address VARCHAR(200),
    victim_status VARCHAR(20),
    crime_id VARCHAR(20),
    FOREIGN KEY (crime_id) REFERENCES Crimes(crime_id)
);
CREATE TABLE Witness (
    witness_id VARCHAR(20) PRIMARY KEY,
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    contact VARCHAR(20),
    relationship VARCHAR(20),
    testimony VARCHAR(200),
    crime_id VARCHAR(20),
    FOREIGN KEY (crime_id) REFERENCES Crimes(crime_id)
);
CREATE TABLE Officer (
    officer_id VARCHAR(20) PRIMARY KEY,
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    officer_rank VARCHAR(30),
    contact VARCHAR(20)
);
CREATE TABLE CaseFile (
    case_id VARCHAR(20) PRIMARY KEY,
    case_title VARCHAR(50) NOT NULL,
    date_reported DATE,
    crime_id VARCHAR(20),
    investigating_officer INT,
    case_status VARCHAR(20),
    FOREIGN KEY (crime_id) REFERENCES Crimes(crime_id),
    FOREIGN KEY (investigating_officer) REFERENCES Officer(officer_id)
);
CREATE TABLE Evidence (
    evidence_id VARCHAR(20) PRIMARY KEY,
    evidence_type VARCHAR(100),
    location_found VARCHAR(50),
    collected_by VARCHAR(20),
    case_id VARCHAR(20),
    FOREIGN KEY (case_id) REFERENCES CaseFile(case_id),
    FOREIGN KEY (collected_by) REFERENCES Officer(officer_id)
);
CREATE TABLE Investigation (
    investigation_id VARCHAR(20) PRIMARY KEY,
    start_date DATE,
    end_date DATE,
    investigation_status VARCHAR(50),
    case_id VARCHAR(20),
    officer_in_charge VARCHAR(20),
    FOREIGN KEY (case_id) REFERENCES CaseFile(case_id),
    FOREIGN KEY (officer_in_charge) REFERENCES Officer(officer_id)
);
CREATE TABLE Arrest_Record (
    arrest_id VARCHAR(20) PRIMARY KEY,
    arrest_date DATE,
    arrest_time TIME,
    case_id VARCHAR(20),
    criminal_id VARCHAR(20),
    arrested_by_officer VARCHAR(20),
    FOREIGN KEY (case_id) REFERENCES CaseFile(case_id),
    FOREIGN KEY (arrested_by_officer) REFERENCES Officer(officer_id),
    FOREIGN KEY (criminal_id) REFERENCES Criminal(criminal_id)
);
CREATE TABLE LawSuit (
    proceeding_id VARCHAR(20) PRIMARY KEY,
    hearing_date DATE,
    hearing_time TIME,
    verdict VARCHAR(100),
    sentence VARCHAR(100),
    case_id VARCHAR(20),
    FOREIGN KEY (case_id) REFERENCES CaseFile(case_id)
);

1--list of criminals along with the crime types they are associated with
SELECT Criminal.criminal_name,Crimes.crime_type
FROM Criminal
INNER JOIN Crimes ON Criminal.criminal_id = Crimes.criminal_id;

2--information about witnesses and crimes
SELECT W.first_name, W.last_name, W.testimony, Cr.crime_type, Cr.date
FROM Witness W
NATURAL JOIN Crimes Cr;  

3--all criminals and any associated crimes they have committed.
SELECT Cr.criminal_id, Cr.criminal_name, C.crime_id, C.crime_type
FROM Criminal Cr
LEFT JOIN Crimes C
ON Cr.criminal_id = C.criminal_id;

4--all crimes and any associated victims.
SELECT Crimes.crime_id, Crimes.crime_type, Victim.victim_id, Victim.first_name AS victim_firstname, Victim.last_name AS victim_lastname
FROM Crimes
RIGHT JOIN Victim ON Crimes.crime_id = Victim.crime_id;

5-- all case files with evidence associated to them.
SELECT CaseFile.case_id, CaseFile.case_title, Evidence.evidence_id, Evidence.evidence_type
FROM CaseFile
NATURAL JOIN Evidence;

6--all cases and their corresponding investigating officers.
SELECT CaseFile.case_id, CaseFile.case_title, Officer.first_name AS officer_firstname, Officer.last_name AS officer_lastname
FROM CaseFile
INNER JOIN Officer ON CaseFile.investigating_officer = Officer.officer_id;

7--all possible combinations of victims and witnesses.
SELECT Victim.first_name AS Victim, Witness.first_name AS Witness
FROM Victim
CROSS JOIN Witness;

8--the details of criminals and the witnesses who testified in their cases.
SELECT Criminal.criminal_name, Witness.first_name AS Witness_firstname, Witness.last_name AS Witness_lastname, Witness.testimony
FROM Criminal
INNER JOIN Crimes ON Criminal.criminal_id = Crimes.criminal_id
INNER JOIN Witness ON Crimes.crime_id = Witness.crime_id;

--SUBQUERY--
1--
SELECT criminal_id,criminal_name,dob
FROM Criminal
WHERE age = 
(SELECT MAX(age) FROM Criminal);

2--
SELECT victim_id,first_name, last_name
FROM Victim
WHERE crime_id IN (
    SELECT crime_id 
    FROM Crimes 
    WHERE crime_type = 'Fraud'
    );

SELECT criminal_name
FROM Criminal c
WHERE EXISTS (
    SELECT 1
    FROM Crimes cr
    WHERE cr.criminal_id = c.criminal_id
    AND cr.location LIKE CONCAT('%', SUBSTRING(c.address, LOCATE(',', c.address) + 1), '%')
);

SELECT criminal_name
FROM Criminal
WHERE EXISTS (
    SELECT 5
    FROM Crimes c
    JOIN Witness w ON c.crime_id = w.crime_id
    WHERE c.criminal_id = Criminal.criminal_id
);

SELECT officer_id
FROM Officer
WHERE officer_id IN (
    SELECT investigating_officer
    FROM CaseFile
    GROUP BY investigating_officer
    HAVING COUNT(*) > 1
);
SELECT * FROM Evidence;

--victims who were involved in a crime that took place in a city where a criminal resides
SELECT victim_id,first_name, last_name, victim_status
FROM Victim
WHERE crime_id IN (
    SELECT crime_id
    FROM Crimes
    WHERE location LIKE '%Illinois%' AND criminal_id = 'CR0009'
);

--total number of cases for each officer
SELECT officer_id, COUNT(*) AS total_cases
FROM (
    SELECT investigating_officer AS officer_id
    FROM CaseFile
) AS cases
GROUP BY officer_id;

SELECT c.crime_type, c.date, c.location, cr.criminal_name
FROM Crimes c
JOIN Criminal cr ON c.criminal_id = cr.criminal_id
WHERE c.criminal_id IN (
    SELECT criminal_id
    FROM Arrest_Record
);

--number of victims for each crime type, but only for crime types with more than or equal to 2 victims
SELECT crime_type, COUNT(v.victim_id) AS victim_count
FROM Crimes c
JOIN Victim v ON c.crime_id = v.crime_id
GROUP BY crime_type
HAVING COUNT(v.victim_id) >= 2;


SELECT criminal_id, criminal_name
FROM Criminal
WHERE criminal_name LIKE 'A%';

SELECT crime_id, crime_type, location
FROM Crimes
WHERE location LIKE '%Street%';

--number of crimes committed in locations that contain the word "Street"
SELECT COUNT(*) AS crime_count,crime_id, location
FROM Crimes
WHERE location LIKE '%Street%'
GROUP BY location;

--how many victims were affected by crimes related to fraud
SELECT COUNT(v.victim_id) AS fraud_victims, victim_id
FROM Victim v
JOIN Crimes c ON v.crime_id = c.crime_id
WHERE c.crime_type LIKE '%Fraud%';

--number of pieces of evidence associated with each crime type
SELECT c.crime_type, COUNT(e.evidence_id) AS evidence_count
FROM Crimes c
JOIN CaseFile cf ON c.crime_id = cf.crime_id
JOIN Evidence e ON cf.case_id = e.case_id
GROUP BY c.crime_type
HAVING COUNT(e.evidence_id) > 1;

--the number of open cases assigned to each officer whose first name starts with "R", and only show officers with 1 or more than 1 open case.
SELECT o.officer_id, o.first_name, o.last_name, COUNT(c.case_id) AS open_cases
FROM Officer o
JOIN CaseFile c ON o.officer_id = c.investigating_officer
WHERE o.first_name LIKE 'R%' AND c.case_status = 'Open'
GROUP BY o.officer_id
HAVING COUNT(c.case_id) >= 1;

-------------------------------
SELECT first_name, last_name, crime_id
FROM Victim
WHERE crime_id IN (
    SELECT crime_id
    FROM Crimes
    WHERE criminal_id IN (
        SELECT criminal_id
        FROM Criminal
        WHERE gender = 'Male'
    )
    AND date > '2023-01-01'
);

SELECT case_id, case_title, case_status
FROM CaseFile
WHERE case_id IN (
    SELECT case_id
    FROM Arrest_Record
    WHERE arrested_by_officer IN (
        SELECT officer_id
        FROM Officer
        WHERE officer_rank = 'Detective'
    )
);

SELECT witness_id,first_name, last_name, testimony
FROM Witness
WHERE crime_id IN (
    SELECT crime_id
    FROM Crimes
    WHERE crime_type = 'Murder'
);


--SINGLE TABLE QUERY--

SELECT * FROM Crimes
WHERE crime_type = 'Burglary';

SELECT * FROM CaseFile
WHERE case_status = 'Open';

SELECT * FROM Evidence
WHERE case_id = 'CF-04';

--
SELECT * FROM Arrest_Record
WHERE arrest_date > '2023-10-01';

--
SELECT * FROM LawSuit
WHERE YEAR(hearing_date) < '2024';

--
SELECT * FROM CaseFile
WHERE case_status = 'Reopened' AND investigating_officer = 'PD-005';

--
SELECT criminal_name, age, address FROM Criminal
WHERE (address LIKE '%Illinois%' OR address LIKE '%Texas%') AND age BETWEEN 25 AND 40;

--
SELECT case_title,date_reported,case_status FROM CaseFile
WHERE (case_status = 'Open' OR case_status = 'Pending') ;

--
SELECT evidence_id, evidence_type, case_id FROM Evidence
WHERE case_id = 'CF-03' AND evidence_type LIKE '%Surveillance%';

--
SELECT officer_id, first_name, last_name, officer_rank FROM officer
WHERE officer_rank LIKE '%Detective%';

--
SELECT * FROM Criminal
WHERE age BETWEEN 30 AND 40;

--
SELECT * FROM Crimes
WHERE crime_type = 'Burglary' OR crime_type = 'Assault';

--
SELECT crime_id, crime_type, details, location FROM Crimes
WHERE crime_type NOT LIKE 'Murder';

--
SELECT * FROM Victim
WHERE TIMESTAMPDIFF(YEAR, dob, CURDATE()) BETWEEN 25 AND 40
  AND (victim_status = 'Injured' OR victim_status = 'Deceased');

--
SELECT proceeding_id, verdict, sentence, case_id FROM LawSuit
WHERE (verdict = 'Guilty' AND hearing_date BETWEEN '2023-01-01' AND '2023-12-31');





INSERT INTO Crimes (crime_id, crime_type, date, time, location, details, criminal_id)
VALUES 
('C-1001', 'Burglary', '2024-05-15', '02:30:00', '1000 Marine Drive, Miami Beach, Florida', 'Unlawfully entered a residence by shattering a window and rummaged through the rooms, taking valuable electronics, costly jewelry, a substantial sum of cash and injuring the residents.', 'CR0006'),
('C-1002', 'Fraud', '2023-08-22', '10:05:03', '1122 Camelback Road, Phoenix, Arizona', 'Manipulated elderly individuals by claiming they had won the lottery, tricking them into handing over large sums of money.', 'CR0007'),
('C-1003', 'Assault', '2022-11-30', '22:15:00', '2020 Queens Avenue, Seattle, Washington', 'Initiated a violent altercation in the bar, leading to serious harm and injury to the victims.', 'CR0003'),
('C-1004', 'Murder', '2024-01-10', '03:00:40', '525 Laketown, Springfield, Illinois', 'Victims shot during a failed home invasion. The intruder shot them in self-defense but was subsequently charged for unlawful entry and homicide.', 'CR0009'),
('C-1005', 'Theft', '2023-06-04', '02:45:10', '345 Broadway Street, Denver, Colorado', 'Stole invaluable relics from the museum while it was being renovated, skillfully evading the security measures and disappearing without a trace.', 'CR0005'),
('C-1006', 'Drug Possession', '2023-09-18', '19:20:06', '456 Pine Road, Springfield, Illinois', 'Found in possession of a stash of illegal drugs, with the intent to sell them across multiple locations', 'CR0001'),
('C-1007', 'Armed Robbery', '2024-12-03', '14:10:00', '789 Market Street, Dallas, Texas', 'Entered a convenience store with a weapon, held up the cashier at gunpoint, stole the money from the register, and then fled in a getaway vehicle.', 'CR0002'),
('C-1008', 'Hacking', '2024-07-21', '08:30:21', '215 Main Avenue, Boston, Massachusetts', 'Hacked into a government website, evading security measures, and stole sensitive data, potentially jeopardizing national security.', 'CR0008'),
('C-1009', 'Murder', '2023-02-19', '16:15:13', '300 William Boulevard, Los Angeles, California', 'Killed a former partner in a violent domestic dispute, stabbing them multiple times in the heat of the argument. Also attacked the the neighbour who came by to rescue.', 'CR0004'),
('C-1010', 'Driving Under Influence', '2024-04-15', '01:17:00', '1234 16th Street, Denver, Colorado', 'Caught driving erratically on the highway under the influence, hitting two cars, barely avoiding multiple accidents and refusing to assist authorities when in custody.', 'CR0010');

