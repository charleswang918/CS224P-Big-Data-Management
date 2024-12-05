DROP TABLE IF EXISTS Boats;

CREATE TABLE Boats (
  bid int NOT NULL,
  bname varchar(45),
  color varchar(15),
  PRIMARY KEY (bid)
);

INSERT INTO Boats
VALUES (101,'Interlake','blue'),
       (102,'Interlake','red'),
       (103,'Clipper','green'),
       (104,'Marine','red');


DROP TABLE IF EXISTS Reserves;

CREATE TABLE Reserves (
  sid int,
  bid int,
  date date
);

INSERT INTO Reserves VALUES (22,101,'1998-10-10'),
                              (22,102,'1998-10-10'),
                              (22,103,'1998-10-08'),
                              (22,104,'1998-10-07'),
                              (31,102,'1998-11-10'),
                              (31,103,'1998-11-06'),
                              (31,104,'1998-11-12'),
                              (64,101,'1998-09-05'),
                              (64,102,'1998-09-08'),
                              (74,103,'1998-09-08'),
                              (NULL,103,'1998-09-09'),
                              (1,NULL,'2001-01-11'),
                              (1,NULL,'2002-02-02');


DROP TABLE IF EXISTS Sailors;

CREATE TABLE Sailors (
  sid int,
  sname varchar(45),
  rating int,
  age decimal(5,1),
  PRIMARY KEY (sid)
);

INSERT INTO Sailors VALUES (22,'Dustin',7,45.0),
                             (29,'Brutus',1,33.0),
                             (31,'Lubber',8,55.5),
                             (32,'Andy',8,25.5),
                             (58,'Rusty',10,35.0),
                             (64,'Horatio',7,35.0),
                             (71,'Zorba',10,16.0),
                             (74,'Horatio',9,35.0),
                             (85,'Art',4,25.5),
                             (95,'Bob',3,63.5),
                             (101,'Joan',3,NULL),
                             (107,'Johannes',NULL,35.0);