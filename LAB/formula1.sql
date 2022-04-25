CREATE TABLE AIRPORTS(
	Id INTEGER NOT NULL,
	Ident VARCHAR(4) NOT NULL,
	Type VARCHAR(20) NOT NULL,
	Name VARCHAR(50) NOT NULL,
	LatDeg FLOAT NOT NULL,
	LongDeg FLOAT NOT NULL,
	ElevFt INTEGER,
	Continent VARCHAR(2),
	ISOCountry VARCHAR(2),
	ISORegion VARCHAR(5),
	City VARCHAR(50),
	Scheduled_service VARCHAR(3),
	GPSCode VARCHAR(5),
	IATACode VARCHAR(10),
	LocalCode VARCHAR(5),
	HomeLink VARCHAR(200),
	WikipediaLink VARCHAR(2083),
	Keyword VARCHAR(100),
	
	CONSTRAINT pk_airport PRIMARY KEY(Id)
);

CREATE TABLE COUNTRIES(
	Id INTEGER NOT NULL,
	Code VARCHAR(2) NOT NULL,
	Name VARCHAR(50) NOT NULL,
	Continent VARCHAR(2) NOT NULL,
	WikipediaLink VARCHAR(2083),
	Keywords VARCHAR(200),
	
	CONSTRAINT pk_countries PRIMARY KEY(Id)
);

CREATE TABLE GEOCITIES15K(
	GeonameID INTEGER NOT NULL,
	Name VARCHAR(50) NOT NULL,
	AsciiName VARCHAR(50) NOT NULL,
	AlternateNames VARCHAR(1000),
	Lat FLOAT NOT NULL,
	Long FLOAT NOT NULL,
	FeatureClass VARCHAR(2) NOT NULL, --talvez varchar 1
	FeatureCode VARCHAR(5) NOT NULL,
	Country VARCHAR(2) NOT NULL,
	CC2 VARCHAR(2),
	Admin1Code INTEGER,
	Admin2Code INTEGER,
	Admin3Code INTEGER,
	Admin4Code INTEGER,
	Population INTEGER NOT NULL,
	Elevation INTEGER,
	Dem INTEGER,
	TimeZone VARCHAR(50) NOT NULL,
	Modification DATE,
	
	CONSTRAINT pk_geocities PRIMARY KEY(GeonameID)
);

CREATE TABLE Status(
	StatusId INTEGER,
	Status VARCHAR(50),

	CONSTRAINT pk_status PRIMARY KEY(StatusId)
);

CREATE TABLE Seasons(
	Year VARCHAR(4),
	URL VARCHAR(2048),

	CONSTRAINT pk_seasons PRIMARY KEY(Year)
);

CREATE TABLE Circuits(
	CircuitID INTEGER,
	CircuitRef VARCHAR(100),
	Name VARCHAR(100),
	Location VARCHAR(100),
	Country VARCHAR(100),
	Lat FLOAT,
	Lng FLOAT,
	Alt INTEGER,
	URL VARCHAR(2048),

	CONSTRAINT pk_circuits PRIMARY KEY(CircuitID)
);

CREATE TABLE Constructors(
	ConstructorID INTEGER,
	ConstructorRef VARCHAR(50),
	Name VARCHAR(50),
	Nationality VARCHAR(50),
	URL VARCHAR(2048),

	CONSTRAINT pk_constructors PRIMARY KEY(ConstructorID)
);

CREATE TABLE Driver(
	DriverId INTEGER,
	DriverRef VARCHAR(50),
	Number VARCHAR(5) DEFAULT "\N",
	Code VARCHAR(3) DEFAULT "\N",
	Forename VARCHAR(50),
	Surname VARCHAR(50),
	DateOfBirth DATE,
	Nationality VARCHAR(50),
	URL VARCHAR(2048)

	CONSTRAINT pk_driver PRIMARY KEY(DriverId)
);

CREATE TABLE Races(
	RaceId INTEGER,
	Year VARCHAR(4),
	Round INTEGER,
	CircuitId INTEGER,
	Name VARCHAR(100),
	Date DATE,
	Time TIME,
	URL VARCHAR(2048),

	CONSTRAINT pk_races PRIMARY KEY(RaceId),
	CONSTRAINT fk_race_year FOREIGN KEY(Year) REFERENCES Seasons(Year)
);

CREATE TABLE Laptimes(
	RaceId INTEGER,
	DriverId INTEGER,
	Lap INTEGER,
	Position INTEGER,
	Time TIME,
	Milliseconds INTEGER,

	CONSTRAINT pk_laptime PRIMARY KEY(RaceId, DriverId, Lap),
	CONSTRAINT fk_laptime_race FOREIGN KEY(RaceId) REFERENCES Races(RaceId)
);

CREATE TABLE Pitstops(
	RaceId INTEGER,
	DriverId INTEGER,
	Stop INTEGER,
	Lap INTEGER,
	Time TIME,
	Duration FLOAT,
	Milliseconds INTEGER,

	CONSTRAINT pk_pitstops PRIMARY KEY(RaceId, DriverId, Stop),
	CONSTRAINT fk_pitstops_race FOREIGN KEY(RaceId) REFERENCES Races(RaceId),
	CONSTRAINT fk_pitstops_driver FOREIGN KEY(DriverId) REFERENCES Driver(DriverId)
);

CREATE TABLE Qualifying(
	QualifyId INTEGER,
	RaceId INTEGER,
	DriverId INTEGER,
	ConstructorId INTEGER,
	Number INTEGER,
	Position INTEGER,
	Q1 VARCHAR(10) NOT NULL,
	Q2 VARCHAR(10) DEFAULT "\N",
	Q3 VARCHAR(10) DEFAULT "\N",

	CONSTRAINT pk_qualifying PRIMARY KEY(QualifyId),
	CONSTRAINT fk_qualifying_race FOREIGN KEY(RaceId) REFERENCES Races(RaceId),
	CONSTRAINT fk_qualifying_driver FOREIGN KEY(DriverId) REFERENCES Driver(DriverId),
	CONSTRAINT fk_qualifying_constructor FOREIGN KEY(ConstructorId) REFERENCES Constructors(ConstructorId)
);

CREATE TABLE DriverStandings(
	DriverStandingsId INTEGER,
	RaceID INTEGER,
	DriverId INTEGER,
	Points INTEGER,
	Position INTEGER,
	PositionText INTEGER,
	Win BOOLEAN DEFAULT FALSE,

	CONSTRAINT pk_driverstandings PRIMARY KEY(DriverStandingsId),
	CONSTRAINT fk_driverstandings_race FOREIGN KEY(RaceId) REFERENCES Races(RaceId),
	CONSTRAINT fk_driverstandings_driver FOREIGN KEY(DriverId) REFERENCES Driver(DriverId)
);

CREATE TABLE Results(
	ResultId INTEGER,
	RaceId INTEGER,
	DriverId INTEGER,
	ConstructorId INTEGER,
	Number INTEGER,
	Grid INTEGER,
	Position VARCHAR(3) DEFAULT "\N",
	PositionText VARCHAR(3) DEFAULT "R",
	PositionOrder INTEGER,
	Points INTEGER,
	Laps INTEGER,
 	Time VARCHAR(10) DEFAULT "\N",
 	Milliseconds VARCHAR(8) DEFAULT "\N",
 	FastestLap VARCHAR(3) DEFAULT "\N",
 	Rank VARCHAR(3) DEFAULT "\N",
 	FastestLapTime VARCHAR(10) DEFAULT "\N",
 	FastestLapSpeed VARCHAR(10) DEFAULT "\N",
 	StatusID INTEGER,

	CONSTRAINT pk_results PRIMARY KEY(ResultId),
	CONSTRAINT fk_results_race FOREIGN KEY(RaceId) REFERENCES Races(RaceId),
	CONSTRAINT fk_results_driver FOREIGN KEY(DriverId) REFERENCES Driver(DriverId),
	CONSTRAINT fk_results_constructor FOREIGN KEY(ConstructorId) REFERENCES Constructors(ConstructorId)
	CONSTRAINT fk_results_status FOREIGN KEY(StatusId) REFERENCES Status(StatusId)
);
