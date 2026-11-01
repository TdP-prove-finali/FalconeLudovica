CREATE DATABASE IF NOT EXISTS cinema
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE cinema;

DROP VIEW  IF EXISTS v_guadagni_film;
DROP TABLE IF EXISTS film;
DROP TABLE IF EXISTS raccolta_film;
DROP TABLE IF EXISTS produttore;
DROP TABLE IF EXISTS distributore;
DROP TABLE IF EXISTS mercato_annuale;

CREATE TABLE mercato_annuale (
    anno                    INT           NOT NULL,
    prezzo_medio_biglietto  DECIMAL(5,2)  NOT NULL,
    PRIMARY KEY (anno),
    CONSTRAINT chk_mercato_anno   CHECK (anno BETWEEN 1995 AND 2019),
    CONSTRAINT chk_mercato_prezzo CHECK (prezzo_medio_biglietto > 0)
) ENGINE=InnoDB;

CREATE TABLE produttore (
    id    INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome  VARCHAR(150)  NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_produttore_nome (nome)
) ENGINE=InnoDB;

CREATE TABLE distributore (
    id    INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    nome  VARCHAR(150)  NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_distributore_nome (nome)
) ENGINE=InnoDB;

CREATE TABLE film (
    id                   INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    titolo               VARCHAR(200)  NOT NULL,
    anno                 INT           NOT NULL,
    id_produttore        INT UNSIGNED  NOT NULL,
    id_distributore      INT UNSIGNED  NOT NULL,
    budget               BIGINT        NOT NULL,
    boxoffice_domestico  BIGINT        NOT NULL,
    sett1                BIGINT        NOT NULL,
    sett2                BIGINT        NOT NULL,
    sett3                BIGINT        NOT NULL,
    sett4                BIGINT        NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_film_titolo_anno (titolo, anno),
    KEY idx_film_anno (anno),
    CONSTRAINT fk_film_anno
        FOREIGN KEY (anno) REFERENCES mercato_annuale (anno),
    CONSTRAINT fk_film_produttore
        FOREIGN KEY (id_produttore) REFERENCES produttore (id),
    CONSTRAINT fk_film_distributore
        FOREIGN KEY (id_distributore) REFERENCES distributore (id),
    CONSTRAINT chk_film_importi
        CHECK (budget > 0 AND boxoffice_domestico > 0
               AND sett1 >= 0 AND sett2 >= 0 AND sett3 >= 0 AND sett4 >= 0),
    CONSTRAINT chk_film_somma
        CHECK (sett1 + sett2 + sett3 + sett4 = boxoffice_domestico)
) ENGINE=InnoDB;

CREATE TABLE raccolta_film (
    titolo               VARCHAR(200)  NOT NULL,
    anno                 INT           NOT NULL,
    produttore           VARCHAR(150)  NOT NULL,
    distributore         VARCHAR(150)  NOT NULL,
    budget               BIGINT        NOT NULL,
    boxoffice_domestico  BIGINT        NOT NULL,
    sett1                BIGINT        NOT NULL,
    sett2                BIGINT        NOT NULL,
    sett3                BIGINT        NOT NULL,
    sett4                BIGINT        NOT NULL
) ENGINE=InnoDB;

INSERT INTO mercato_annuale (anno, prezzo_medio_biglietto) VALUES
(1995, 4.35), (1996, 4.42), (1997, 4.59), (1998, 4.69), (1999, 5.08),
(2000, 5.39), (2001, 5.66), (2002, 5.81), (2003, 6.03), (2004, 6.21),
(2005, 6.41), (2006, 6.55), (2007, 6.88), (2008, 7.18), (2009, 7.50),
(2010, 7.89), (2011, 7.93), (2012, 7.96), (2013, 8.13), (2014, 8.17),
(2015, 8.43), (2016, 8.65), (2017, 8.97), (2018, 9.11), (2019, 9.16);

CREATE VIEW v_guadagni_film AS
SELECT
    f.id,
    f.titolo,
    f.anno,
    p.nome AS produttore,
    d.nome AS distributore,
    f.budget,
    f.boxoffice_domestico,
    ROUND(f.boxoffice_domestico / m.prezzo_medio_biglietto) AS spettatori_stimati,

    (0.95*f.sett1 + 0.90*f.sett2 + 0.85*f.sett3 + 0.50*f.sett4) AS quota_dist_sliding,
    (0.95*f.boxoffice_domestico)                                AS quota_dist_bidding,

    (0.25*f.budget) AS utile_prod_leasing,
    (0.80*(0.95*f.sett1 + 0.90*f.sett2 + 0.85*f.sett3 + 0.50*f.sett4) - f.budget)
        AS utile_prod_profit_sliding,
    (0.80*0.95*f.boxoffice_domestico - f.budget)
        AS utile_prod_profit_bidding,

    ((0.95*f.sett1 + 0.90*f.sett2 + 0.85*f.sett3 + 0.50*f.sett4) - 1.25*f.budget)
        AS guad_dist_leasing_sliding,
    (0.95*f.boxoffice_domestico - 1.25*f.budget)
        AS guad_dist_leasing_bidding,
    (0.20*(0.95*f.sett1 + 0.90*f.sett2 + 0.85*f.sett3 + 0.50*f.sett4))
        AS guad_dist_profit_sliding,
    (0.20*0.95*f.boxoffice_domestico)
        AS guad_dist_profit_bidding
FROM film f
JOIN produttore      p ON p.id   = f.id_produttore
JOIN distributore    d ON d.id   = f.id_distributore
JOIN mercato_annuale m ON m.anno = f.anno;

SET NAMES utf8mb4;

INSERT INTO produttore (nome) VALUES
('20th Century Fox'),
('Aardman Animations'),
('Amblin Entertainment'),
('Anonymous Content'),
('Blinding Edge Pictures'),
('Bron Creative'),
('Clint Eastwood Productions'),
('Color Force'),
('Columbia Pictures'),
('Cruise-Wagner'),
('DC Films'),
('Disney-Pixar'),
('DreamWorks'),
('Focus Features'),
('Gary Sanchez Productions'),
('Gold Circle Films'),
('Happy Madison Productions'),
('Heyday Films'),
('Hollywood Pictures'),
('Icon Productions'),
('Illumination Entertainment'),
('Image Entertainment'),
('Jersey Films'),
('Juno Pix'),
('Legendary Pictures'),
('Lightstorm Entertainment'),
('Live Planet'),
('Lucasfilm'),
('Marvel Studios'),
('MGM'),
('Morgan Creek Productions'),
('Original Film'),
('Overbrook Entertainment'),
('Phoenix Pictures'),
('Pixar Animation Studios'),
('Regency Enterprises'),
('Relativity Media'),
('Scott Free Productions'),
('Skydance Media'),
('Spring Creek Pictures'),
('Syncopy'),
('Tapestry Films'),
('Temple Hill Entertainment'),
('The Kennedy Company'),
('Threshold Entertainment'),
('Thunder Road Pictures'),
('Touchstone Pictures'),
('Universal'),
('Walt Disney'),
('Warner Bros'),
('Wayans Brothers Entertainment'),
('Wingnut Films');

INSERT INTO distributore (nome) VALUES
('20th Century Fox'),
('Dreamworks'),
('Lionsgate'),
('MGM'),
('Miramax'),
('Newline'),
('Paramount'),
('Sony Pictures'),
('Summit Entertainment'),
('Universal'),
('Walt Disney'),
('Warner Bros');

INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Batman Forever', 1995, (SELECT id FROM produttore WHERE nome = 'Warner Bros'), (SELECT id FROM distributore WHERE nome = 'Warner Bros'), 100000000, 184190913, 77403197, 42665389, 25520687, 38601640);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Apollo 13', 1995, (SELECT id FROM produttore WHERE nome = 'Image Entertainment'), (SELECT id FROM distributore WHERE nome = 'Universal'), 65000000, 174626134, 46005195, 29291400, 23490465, 75839074);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Toy Story', 1995, (SELECT id FROM produttore WHERE nome = 'Disney-Pixar'), (SELECT id FROM distributore WHERE nome = 'Walt Disney'), 30000000, 199244616, 34579405, 24660317, 17313352, 122691542);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Pocahontas', 1995, (SELECT id FROM produttore WHERE nome = 'Disney-Pixar'), (SELECT id FROM distributore WHERE nome = 'Walt Disney'), 55000000, 141579773, 4953359, 46920295, 28624221, 61081898);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Ace Ventura', 1995, (SELECT id FROM produttore WHERE nome = 'Morgan Creek Productions'), (SELECT id FROM distributore WHERE nome = 'Warner Bros'), 30000000, 212000000, 45510178, 72784966, 88128568, 5576288);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Casper', 1995, (SELECT id FROM produttore WHERE nome = 'Amblin Entertainment'), (SELECT id FROM distributore WHERE nome = 'Universal'), 55000000, 102677077, 25511615, 18549390, 15640310, 42975762);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Die Hard', 1995, (SELECT id FROM produttore WHERE nome = '20th Century Fox'), (SELECT id FROM distributore WHERE nome = '20th Century Fox'), 90000000, 100000000, 29882809, 22492166, 13000000, 34625025);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Goldeneye', 1995, (SELECT id FROM produttore WHERE nome = 'MGM'), (SELECT id FROM distributore WHERE nome = 'MGM'), 60000000, 106429941, 39094491, 22073956, 11414525, 33846969);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Crimson Tide', 1995, (SELECT id FROM produttore WHERE nome = 'Hollywood Pictures'), (SELECT id FROM distributore WHERE nome = 'Walt Disney'), 55000000, 91387195, 25544515, 15601294, 15116928, 35124458);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Waterworld', 1995, (SELECT id FROM produttore WHERE nome = 'Universal'), (SELECT id FROM distributore WHERE nome = 'Universal'), 175000000, 88246220, 32118480, 19896685, 12753525, 23477530);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Seven', 1995, (SELECT id FROM produttore WHERE nome = 'Juno Pix'), (SELECT id FROM distributore WHERE nome = 'Newline'), 30000000, 101871174, 18427014, 16651975, 14029787, 52762398);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Dangerous Minds', 1995, (SELECT id FROM produttore WHERE nome = 'Hollywood Pictures'), (SELECT id FROM distributore WHERE nome = 'Walt Disney'), 23000000, 84919401, 23002151, 15604358, 10958477, 35354415);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('While you were sleeping', 1995, (SELECT id FROM produttore WHERE nome = 'Hollywood Pictures'), (SELECT id FROM distributore WHERE nome = 'Walt Disney'), 25000000, 81057016, 12306013, 13808834, 11028515, 43913654);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Congo', 1995, (SELECT id FROM produttore WHERE nome = 'The Kennedy Company'), (SELECT id FROM distributore WHERE nome = 'Paramount'), 50000000, 81022000, 33805311, 16063120, 12128418, 19025151);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Mortal Kombat', 1995, (SELECT id FROM produttore WHERE nome = 'Threshold Entertainment'), (SELECT id FROM distributore WHERE nome = 'Newline'), 20000000, 70433227, 32753183, 14054705, 9530620, 14094719);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('The Bridges of Madison County', 1995, (SELECT id FROM produttore WHERE nome = 'Amblin Entertainment'), (SELECT id FROM distributore WHERE nome = 'Warner Bros'), 22000000, 71516617, 15803651, 13769185, 10536835, 31406946);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Nine Months', 1995, (SELECT id FROM produttore WHERE nome = '20th Century Fox'), (SELECT id FROM distributore WHERE nome = '20th Century Fox'), 35000000, 69660733, 18904601, 15101081, 10242857, 25412194);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Get Shorty', 1995, (SELECT id FROM produttore WHERE nome = 'Jersey Films'), (SELECT id FROM distributore WHERE nome = 'MGM'), 30250000, 72021008, 16781624, 37076009, 17266007, 897368);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Outbreak', 1995, (SELECT id FROM produttore WHERE nome = 'Warner Bros'), (SELECT id FROM distributore WHERE nome = 'Warner Bros'), 50000000, 67823573, 18109662, 14629273, 10391362, 24693276);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Braveheart', 1995, (SELECT id FROM produttore WHERE nome = 'Icon Productions'), (SELECT id FROM distributore WHERE nome = 'Paramount'), 72000000, 75545647, 15571948, 10733143, 7895103, 41345453);

INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('How the Grinch stole Christmas', 2000, (SELECT id FROM produttore WHERE nome = 'Universal'), (SELECT id FROM distributore WHERE nome = 'Universal'), 123000000, 265489295, 84977355, 59922105, 32100195, 88489640);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Mission Impossible 2', 2000, (SELECT id FROM produttore WHERE nome = 'Cruise-Wagner'), (SELECT id FROM distributore WHERE nome = 'Paramount'), 120000000, 215409889, 83347490, 37133438, 24381910, 70547051);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Gladiator', 2000, (SELECT id FROM produttore WHERE nome = 'Universal'), (SELECT id FROM distributore WHERE nome = 'Dreamworks'), 103000000, 187683805, 49016336, 34374456, 26541094, 77751919);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('The Perfect Storm', 2000, (SELECT id FROM produttore WHERE nome = 'Spring Creek Pictures'), (SELECT id FROM distributore WHERE nome = 'Warner Bros'), 120000000, 182618434, 73076981, 38294594, 24301979, 46944880);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Meet the parents', 2000, (SELECT id FROM produttore WHERE nome = 'Universal'), (SELECT id FROM distributore WHERE nome = 'Universal'), 55000000, 166225040, 37656250, 27051590, 20257935, 81259265);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('X-Men', 2000, (SELECT id FROM produttore WHERE nome = '20th Century Fox'), (SELECT id FROM distributore WHERE nome = '20th Century Fox'), 75000000, 157299717, 75850059, 34405995, 19220059, 27823604);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Scary Movie', 2000, (SELECT id FROM produttore WHERE nome = 'Wayans Brothers Entertainment'), (SELECT id FROM distributore WHERE nome = 'Miramax'), 19000000, 157019771, 62900537, 38410001, 22522350, 33186883);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('What Lies Beneath', 2000, (SELECT id FROM produttore WHERE nome = '20th Century Fox'), (SELECT id FROM distributore WHERE nome = 'Dreamworks'), 90000000, 155464351, 46488736, 34833441, 20945935, 53196239);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Dinosaur', 2000, (SELECT id FROM produttore WHERE nome = 'Disney-Pixar'), (SELECT id FROM distributore WHERE nome = 'Walt Disney'), 127500000, 137748063, 48410715, 36399496, 16810958, 36126894);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Erin Brockovich', 2000, (SELECT id FROM produttore WHERE nome = 'Jersey Films'), (SELECT id FROM distributore WHERE nome = 'Universal'), 50000000, 125548685, 37308685, 24703915, 17811500, 45724585);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Nutty Professor II', 2000, (SELECT id FROM produttore WHERE nome = 'Image Entertainment'), (SELECT id FROM distributore WHERE nome = 'Universal'), 84000000, 123307945, 58533530, 25229190, 14222160, 25323065);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Charlie''s Angels', 2000, (SELECT id FROM produttore WHERE nome = 'Columbia Pictures'), (SELECT id FROM distributore WHERE nome = 'Sony Pictures'), 90000000, 125305545, 50404458, 29492715, 18552578, 26855794);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Big Momma''s House', 2000, (SELECT id FROM produttore WHERE nome = '20th Century Fox'), (SELECT id FROM distributore WHERE nome = '20th Century Fox'), 33000000, 117559438, 35201233, 24343223, 17132748, 40882234);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Remember The Titans', 2000, (SELECT id FROM produttore WHERE nome = 'Walt Disney'), (SELECT id FROM distributore WHERE nome = 'Walt Disney'), 30000000, 115719751, 26654715, 24494217, 16286187, 48284632);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('The Patriot', 2000, (SELECT id FROM produttore WHERE nome = 'Columbia Pictures'), (SELECT id FROM distributore WHERE nome = 'Sony Pictures'), 110000000, 113330342, 40714554, 22114168, 15009940, 35491680);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('What women want', 2000, (SELECT id FROM produttore WHERE nome = 'Icon Productions'), (SELECT id FROM distributore WHERE nome = 'Paramount'), 65000000, 182805123, 48567079, 46360599, 27414675, 60462770);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Chicken run', 2000, (SELECT id FROM produttore WHERE nome = 'Aardman Animations'), (SELECT id FROM distributore WHERE nome = 'Dreamworks'), 42000000, 107031060, 36478285, 17175889, 15369866, 38007020);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Gone in 60 seconds', 2000, (SELECT id FROM produttore WHERE nome = 'Touchstone Pictures'), (SELECT id FROM distributore WHERE nome = 'Walt Disney'), 103300000, 101643008, 37178056, 22228385, 16712393, 25524174);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Cast away', 2000, (SELECT id FROM produttore WHERE nome = '20th Century Fox'), (SELECT id FROM distributore WHERE nome = '20th Century Fox'), 85000000, 233632142, 78711571, 40769776, 28499878, 85650917);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Me, Myself and Irene', 2000, (SELECT id FROM produttore WHERE nome = '20th Century Fox'), (SELECT id FROM distributore WHERE nome = '20th Century Fox'), 51000000, 90570999, 41962720, 17049443, 12382418, 19176418);

INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Star Wars ep. III', 2005, (SELECT id FROM produttore WHERE nome = 'Lucasfilm'), (SELECT id FROM distributore WHERE nome = '20th Century Fox'), 115000000, 414378291, 50013589, 150428880, 82361886, 131573936);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Harry Potter and the goblet of fire', 2005, (SELECT id FROM produttore WHERE nome = 'Warner Bros'), (SELECT id FROM distributore WHERE nome = 'Warner Bros'), 150000000, 291337603, 146283069, 63105511, 24415282, 57533741);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('War of the worlds', 2005, (SELECT id FROM produttore WHERE nome = 'Amblin Entertainment'), (SELECT id FROM distributore WHERE nome = 'Paramount'), 132000000, 234280354, 98826764, 42682009, 22313865, 70457716);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('The chronicles of Narnia', 2005, (SELECT id FROM produttore WHERE nome = 'Walt Disney'), (SELECT id FROM distributore WHERE nome = 'Walt Disney'), 180000000, 291710957, 81331961, 52110879, 58548482, 99719635);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Wedding crashers', 2005, (SELECT id FROM produttore WHERE nome = 'Tapestry Films'), (SELECT id FROM distributore WHERE nome = 'Newline'), 40000000, 209218368, 54701439, 40897541, 32000197, 81619191);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Charlie and the chocolate factory', 2005, (SELECT id FROM produttore WHERE nome = 'Warner Bros'), (SELECT id FROM distributore WHERE nome = 'Warner Bros'), 150000000, 206459076, 85805554, 45905636, 26747197, 48000689);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Batman Begins', 2005, (SELECT id FROM produttore WHERE nome = 'Legendary Pictures'), (SELECT id FROM distributore WHERE nome = 'Warner Bros'), 150000000, 205343774, 24151546, 70770878, 40538513, 69882837);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Madagascar', 2005, (SELECT id FROM produttore WHERE nome = '20th Century Fox'), (SELECT id FROM distributore WHERE nome = 'Dreamworks'), 75000000, 194304665, 72267556, 38965977, 24860988, 58210144);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Mr. And Mrs. Smith', 2005, (SELECT id FROM produttore WHERE nome = 'Regency Enterprises'), (SELECT id FROM distributore WHERE nome = '20th Century Fox'), 110000000, 186336279, 70660963, 38027311, 24670617, 52977388);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Hitch', 2005, (SELECT id FROM produttore WHERE nome = 'Columbia Pictures'), (SELECT id FROM distributore WHERE nome = 'Sony Pictures'), 55000000, 177784257, 58315219, 42692999, 24877956, 51898083);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('King Kong', 2005, (SELECT id FROM produttore WHERE nome = 'Wingnut Films'), (SELECT id FROM distributore WHERE nome = 'Universal'), 207000000, 218080025, 16051500, 71271230, 56410170, 74347125);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('The Longest Yard', 2005, (SELECT id FROM produttore WHERE nome = 'Columbia Pictures'), (SELECT id FROM distributore WHERE nome = 'Paramount'), 82000000, 158119460, 69704254, 34901829, 19298535, 34214842);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Fantastic Four', 2005, (SELECT id FROM produttore WHERE nome = '20th Century Fox'), (SELECT id FROM distributore WHERE nome = '20th Century Fox'), 87500000, 154696080, 77412492, 32872417, 19059982, 25351189);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Meet the Fockers', 2005, (SELECT id FROM produttore WHERE nome = 'Universal'), (SELECT id FROM distributore WHERE nome = 'Universal'), 60000000, 279167575, 24396740, 96322845, 55080125, 103367865);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Chicken little', 2005, (SELECT id FROM produttore WHERE nome = 'Walt Disney'), (SELECT id FROM distributore WHERE nome = 'Walt Disney'), 150000000, 135386665, 48747895, 35633823, 21448610, 29556337);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('The Pacifier', 2005, (SELECT id FROM produttore WHERE nome = 'Walt Disney'), (SELECT id FROM distributore WHERE nome = 'Walt Disney'), 56000000, 113006880, 36325340, 23415114, 18005423, 35261003);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('The 40 year-old virgin', 2005, (SELECT id FROM produttore WHERE nome = 'Universal'), (SELECT id FROM distributore WHERE nome = 'Universal'), 26000000, 109607527, 32292080, 23058675, 19058275, 35198497);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Million dollar baby', 2005, (SELECT id FROM produttore WHERE nome = 'Warner Bros'), (SELECT id FROM distributore WHERE nome = 'Warner Bros'), 30000000, 100492203, 282087, 435136, 414609, 99360371);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Walk the line', 2005, (SELECT id FROM produttore WHERE nome = 'Columbia Pictures'), (SELECT id FROM distributore WHERE nome = '20th Century Fox'), 29000000, 119519402, 34795769, 23970711, 12486706, 48266216);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Monster-in-law', 2005, (SELECT id FROM produttore WHERE nome = 'Spring Creek Pictures'), (SELECT id FROM distributore WHERE nome = 'Newline'), 45000000, 82931301, 29823871, 19931373, 15430728, 17745329);

INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Toy Story 3', 2010, (SELECT id FROM produttore WHERE nome = 'Pixar Animation Studios'), (SELECT id FROM distributore WHERE nome = 'Walt Disney'), 200000000, 415004880, 167611847, 88880628, 43227924, 115284481);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Avatar', 2010, (SELECT id FROM produttore WHERE nome = 'Lightstorm Entertainment'), (SELECT id FROM distributore WHERE nome = '20th Century Fox'), 237000000, 408392727, 35222955, 32890691, 36402264, 303876817);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Alice in Wonderland', 2010, (SELECT id FROM produttore WHERE nome = 'Walt Disney'), (SELECT id FROM distributore WHERE nome = 'Walt Disney'), 200000000, 334191110, 166038102, 84491764, 44535384, 39125860);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Iron Man 2', 2010, (SELECT id FROM produttore WHERE nome = 'Marvel Studios'), (SELECT id FROM distributore WHERE nome = 'Paramount'), 170000000, 312433331, 174148419, 72958327, 37248061, 28078524);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('The Twilight Saga: Eclipse', 2010, (SELECT id FROM produttore WHERE nome = 'Temple Hill Entertainment'), (SELECT id FROM distributore WHERE nome = 'Summit Entertainment'), 68000000, 300531751, 175965416, 48443907, 23531398, 52591030);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Inception', 2010, (SELECT id FROM produttore WHERE nome = 'Syncopy'), (SELECT id FROM distributore WHERE nome = 'Warner Bros'), 160000000, 292568851, 94269152, 63765108, 40716186, 93818405);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Harry Potter and the Deathly Hallows: Part 1', 2010, (SELECT id FROM produttore WHERE nome = 'Heyday Films'), (SELECT id FROM distributore WHERE nome = 'Warner Bros'), 125000000, 283533215, 168700000, 74987000, 26543000, 13303215);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Despicable Me', 2010, (SELECT id FROM produttore WHERE nome = 'Illumination Entertainment'), (SELECT id FROM distributore WHERE nome = 'Universal'), 69000000, 251203225, 80077880, 47844050, 32278010, 91003285);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Shrek Forever After', 2010, (SELECT id FROM produttore WHERE nome = 'Columbia Pictures'), (SELECT id FROM distributore WHERE nome = 'Paramount'), 165000000, 238736787, 98205462, 57022064, 34720914, 48788347);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('How to Train Your Dragon', 2010, (SELECT id FROM produttore WHERE nome = 'Columbia Pictures'), (SELECT id FROM distributore WHERE nome = 'Paramount'), 165000000, 217581231, 61817551, 40191845, 34360695, 81211140);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('The Karate Kid', 2010, (SELECT id FROM produttore WHERE nome = 'Overbrook Entertainment'), (SELECT id FROM distributore WHERE nome = 'Sony Pictures'), 40000000, 176591618, 76150493, 38210344, 20894514, 41336267);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Clash of the Titans', 2010, (SELECT id FROM produttore WHERE nome = 'Thunder Road Pictures'), (SELECT id FROM distributore WHERE nome = 'Warner Bros'), 125000000, 163214888, 88705307, 37320078, 20172088, 17017415);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Grown Ups', 2010, (SELECT id FROM produttore WHERE nome = 'Happy Madison Productions'), (SELECT id FROM distributore WHERE nome = 'Sony Pictures'), 80000000, 162001186, 59032731, 29272365, 21200147, 52495943);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Tangled', 2010, (SELECT id FROM produttore WHERE nome = 'Walt Disney'), (SELECT id FROM distributore WHERE nome = 'Walt Disney'), 260000000, 161284390, 68706314, 30537446, 19451120, 42589510);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Megamind', 2010, (SELECT id FROM produttore WHERE nome = 'DreamWorks'), (SELECT id FROM distributore WHERE nome = 'Paramount'), 130000000, 144192018, 60049448, 39088610, 20695574, 24358386);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('The Last Airbender', 2010, (SELECT id FROM produttore WHERE nome = 'Blinding Edge Pictures'), (SELECT id FROM distributore WHERE nome = 'Paramount'), 150000000, 131772187, 70500000, 24800000, 11500000, 24972187);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Shutter Island', 2010, (SELECT id FROM produttore WHERE nome = 'Phoenix Pictures'), (SELECT id FROM distributore WHERE nome = 'Paramount'), 80000000, 128012934, 52784577, 28775440, 16886866, 29566051);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('The Other Guys', 2010, (SELECT id FROM produttore WHERE nome = 'Gary Sanchez Productions'), (SELECT id FROM distributore WHERE nome = 'Sony Pictures'), 100000000, 119219998, 46761759, 23977536, 14201389, 34279314);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Salt', 2010, (SELECT id FROM produttore WHERE nome = 'Relativity Media'), (SELECT id FROM distributore WHERE nome = 'Sony Pictures'), 110000000, 118311368, 47883908, 24872134, 14321098, 31234228);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Tron: Legacy', 2010, (SELECT id FROM produttore WHERE nome = 'Live Planet'), (SELECT id FROM distributore WHERE nome = 'Walt Disney'), 170000000, 117540071, 63270908, 26340000, 18200000, 9729163);

INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Star Wars: Episode VII - The Force Awakens', 2015, (SELECT id FROM produttore WHERE nome = 'Lucasfilm'), (SELECT id FROM distributore WHERE nome = 'Walt Disney'), 306000000, 936662225, 325439563, 281593452, 149232349, 180396861);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Jurassic World', 2015, (SELECT id FROM produttore WHERE nome = 'Legendary Pictures'), (SELECT id FROM distributore WHERE nome = 'Universal'), 150000000, 652270625, 296208388, 106655610, 54517335, 194889292);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Avengers: Age of Ultron', 2015, (SELECT id FROM produttore WHERE nome = 'Marvel Studios'), (SELECT id FROM distributore WHERE nome = 'Walt Disney'), 250000000, 459005868, 240081061, 77726929, 38829032, 102368846);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Inside Out', 2015, (SELECT id FROM produttore WHERE nome = 'Disney-Pixar'), (SELECT id FROM distributore WHERE nome = 'Walt Disney'), 175000000, 356461711, 110486246, 90440333, 52319223, 103215909);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Furious 7', 2015, (SELECT id FROM produttore WHERE nome = 'Original Film'), (SELECT id FROM distributore WHERE nome = 'Universal'), 190000000, 353007020, 170068415, 60655845, 29158580, 93124180);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Minions', 2015, (SELECT id FROM produttore WHERE nome = 'Illumination Entertainment'), (SELECT id FROM distributore WHERE nome = 'Universal'), 74000000, 336045770, 123165529, 50209425, 29410195, 133260621);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('American Sniper', 2015, (SELECT id FROM produttore WHERE nome = 'Clint Eastwood Productions'), (SELECT id FROM distributore WHERE nome = 'Warner Bros'), 58000000, 350126372, 107233212, 89531502, 64627196, 88734462);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('The Hunger Games: Mockingjay - Part 2', 2015, (SELECT id FROM produttore WHERE nome = 'Color Force'), (SELECT id FROM distributore WHERE nome = 'Lionsgate'), 160000000, 281723902, 125971775, 52033626, 21746654, 81971847);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('The Martian', 2015, (SELECT id FROM produttore WHERE nome = 'Scott Free Productions'), (SELECT id FROM distributore WHERE nome = '20th Century Fox'), 108000000, 228433663, 65330366, 37257321, 21508210, 104337766);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Cinderella', 2015, (SELECT id FROM produttore WHERE nome = 'Walt Disney'), (SELECT id FROM distributore WHERE nome = 'Walt Disney'), 95000000, 201151353, 70062947, 34484045, 17834520, 78769841);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Spectre', 2015, (SELECT id FROM produttore WHERE nome = 'MGM'), (SELECT id FROM distributore WHERE nome = 'Sony Pictures'), 245000000, 200074175, 88701928, 33900366, 12812267, 64659614);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Mission: Impossible - Rogue Nation', 2015, (SELECT id FROM produttore WHERE nome = 'Skydance Media'), (SELECT id FROM distributore WHERE nome = 'Paramount'), 150000000, 195042377, 61239983, 29367352, 17154247, 87280795);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Pitch Perfect 2', 2015, (SELECT id FROM produttore WHERE nome = 'Gold Circle Films'), (SELECT id FROM distributore WHERE nome = 'Universal'), 29000000, 184296230, 96936830, 30800000, 14389145, 42170255);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('San Andreas', 2015, (SELECT id FROM produttore WHERE nome = 'Warner Bros'), (SELECT id FROM distributore WHERE nome = 'Newline'), 110000000, 155901127, 54573027, 26390196, 13180421, 61757483);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Fifty Shades of Grey', 2015, (SELECT id FROM produttore WHERE nome = 'Focus Features'), (SELECT id FROM distributore WHERE nome = 'Universal'), 40000000, 166167230, 93017385, 22259115, 10931225, 39959505);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('The SpongeBob Movie: Sponge Out of Water', 2015, (SELECT id FROM produttore WHERE nome = 'Columbia Pictures'), (SELECT id FROM distributore WHERE nome = 'Paramount'), 74000000, 162994032, 61136423, 31215162, 16982463, 53659984);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Hotel Transylvania 2', 2015, (SELECT id FROM produttore WHERE nome = 'Columbia Pictures'), (SELECT id FROM distributore WHERE nome = 'Sony Pictures'), 80000000, 169700110, 48456438, 32700305, 20100210, 68443157);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('The Revenant', 2015, (SELECT id FROM produttore WHERE nome = 'Anonymous Content'), (SELECT id FROM distributore WHERE nome = '20th Century Fox'), 135000000, 183637894, 471415, 15904554, 38332115, 128929810);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Ant-Man', 2015, (SELECT id FROM produttore WHERE nome = 'Marvel Studios'), (SELECT id FROM distributore WHERE nome = 'Walt Disney'), 130000000, 180202163, 57225526, 24874013, 12781403, 85321221);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Home', 2015, (SELECT id FROM produttore WHERE nome = 'DreamWorks'), (SELECT id FROM distributore WHERE nome = '20th Century Fox'), 135000000, 177397510, 52107731, 27702812, 19010420, 78576547);

INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Avengers: Endgame', 2019, (SELECT id FROM produttore WHERE nome = 'Marvel Studios'), (SELECT id FROM distributore WHERE nome = 'Walt Disney'), 400000000, 898471864, 473894638, 186551101, 80949131, 157076994);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('The Lion King', 2019, (SELECT id FROM produttore WHERE nome = 'Walt Disney'), (SELECT id FROM distributore WHERE nome = 'Walt Disney'), 260000000, 543638043, 275251534, 117391544, 60460748, 90534217);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Toy Story 4', 2019, (SELECT id FROM produttore WHERE nome = 'Disney-Pixar'), (SELECT id FROM distributore WHERE nome = 'Walt Disney'), 200000000, 434038008, 178989809, 93267735, 53447030, 108333434);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Frozen II', 2019, (SELECT id FROM produttore WHERE nome = 'Disney-Pixar'), (SELECT id FROM distributore WHERE nome = 'Walt Disney'), 150000000, 477373578, 202867358, 100057543, 44435171, 130013506);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Captain Marvel', 2019, (SELECT id FROM produttore WHERE nome = 'Marvel Studios'), (SELECT id FROM distributore WHERE nome = 'Walt Disney'), 150000000, 426829839, 196895933, 89581902, 46827980, 93524024);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Star Wars: The Rise of Skywalker', 2019, (SELECT id FROM produttore WHERE nome = 'Lucasfilm'), (SELECT id FROM distributore WHERE nome = 'Walt Disney'), 275000000, 515202542, 289796816, 127260625, 64424417, 33720684);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Spider-Man: Far From Home', 2019, (SELECT id FROM produttore WHERE nome = 'Columbia Pictures'), (SELECT id FROM distributore WHERE nome = 'Sony Pictures'), 160000000, 391362492, 136745455, 92483850, 69430107, 92703080);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Aladdin', 2019, (SELECT id FROM produttore WHERE nome = 'Disney-Pixar'), (SELECT id FROM distributore WHERE nome = 'Walt Disney'), 183000000, 355559216, 142697174, 65188752, 37651080, 110022210);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Joker', 2019, (SELECT id FROM produttore WHERE nome = 'Bron Creative'), (SELECT id FROM distributore WHERE nome = 'Warner Bros'), 55000000, 335451311, 137728787, 80295217, 40659518, 76767789);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('It: Chapter Two', 2019, (SELECT id FROM produttore WHERE nome = 'Warner Bros'), (SELECT id FROM distributore WHERE nome = 'Newline'), 79000000, 211593228, 113068524, 48852039, 21000000, 28672665);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Jumanji: The Next Level', 2019, (SELECT id FROM produttore WHERE nome = 'Columbia Pictures'), (SELECT id FROM distributore WHERE nome = 'Sony Pictures'), 125000000, 320314960, 75811365, 69470623, 74424417, 100608555);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Us', 2019, (SELECT id FROM produttore WHERE nome = 'Focus Features'), (SELECT id FROM distributore WHERE nome = 'Universal'), 20000000, 175084580, 94614440, 43968555, 20120111, 16381474);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Fast & Furious Presents: Hobbs & Shaw', 2019, (SELECT id FROM produttore WHERE nome = 'Focus Features'), (SELECT id FROM distributore WHERE nome = 'Universal'), 200000000, 173956935, 83113780, 35123450, 18200100, 37519605);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('John Wick: Chapter 3 — Parabellum', 2019, (SELECT id FROM produttore WHERE nome = 'Universal'), (SELECT id FROM distributore WHERE nome = 'Lionsgate'), 75000000, 171015687, 76638941, 35210450, 16980120, 42186176);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('How to Train Your Dragon: The Hidden World', 2019, (SELECT id FROM produttore WHERE nome = 'DreamWorks'), (SELECT id FROM distributore WHERE nome = 'Universal'), 129000000, 160799505, 65150275, 30120400, 15430210, 50098620);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('The Secret Life of Pets 2', 2019, (SELECT id FROM produttore WHERE nome = 'Illumination Entertainment'), (SELECT id FROM distributore WHERE nome = 'Universal'), 80000000, 158874395, 67319390, 31200150, 16540200, 43814655);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Pokémon: Detective Pikachu', 2019, (SELECT id FROM produttore WHERE nome = 'Legendary Pictures'), (SELECT id FROM distributore WHERE nome = 'Warner Bros'), 150000000, 144105346, 69186846, 25410300, 13200110, 36308090);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Once Upon a Time…in Hollywood', 2019, (SELECT id FROM produttore WHERE nome = 'Heyday Films'), (SELECT id FROM distributore WHERE nome = 'Sony Pictures'), 90000000, 141076968, 58817475, 25110200, 13010400, 44138893);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Shazam!', 2019, (SELECT id FROM produttore WHERE nome = 'Warner Bros'), (SELECT id FROM distributore WHERE nome = 'Newline'), 100000000, 140371656, 66448013, 25100120, 12900110, 35923413);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Aquaman', 2019, (SELECT id FROM produttore WHERE nome = 'DC Films'), (SELECT id FROM distributore WHERE nome = 'Warner Bros'), 200000000, 335061807, 41575901, 31003280, 20355000, 242127626);

SELECT COUNT(*) AS film_inseriti FROM film;
SELECT anno, COUNT(*) AS film FROM film GROUP BY anno ORDER BY anno;
SELECT COUNT(*) AS produttori FROM produttore;
SELECT COUNT(*) AS distributori FROM distributore;

SELECT titolo, anno, produttore, distributore,
       ROUND(utile_prod_profit_sliding) AS utile_produttore,
       spettatori_stimati
FROM v_guadagni_film
ORDER BY utile_prod_profit_sliding DESC
LIMIT 10;
