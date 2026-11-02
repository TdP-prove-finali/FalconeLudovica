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
('1492 Pictures'),
('20th Century Fox'),
('21 Laps Entertainment'),
('A Band Apart'),
('A1 Films'),
('Aardman Animations'),
('Alcon Entertainment'),
('Amblin Entertainment'),
('Animal Logic'),
('Anonymous Content'),
('Apatow Productions'),
('Appian Way'),
('Atomic Monster'),
('Beacon Communications'),
('BenderSpink'),
('Black Bear Pictures'),
('Blinding Edge Pictures'),
('Blue Sky Studios'),
('Blumhouse Productions'),
('Bristol Bay Productions'),
('Bron Creative'),
('Capella Films'),
('Carnival Films'),
('Caro-Li'),
('Castle Rock Entertainment'),
('Chartoff-Winkler Productions'),
('Chernin Entertainment'),
('Clint Eastwood Productions'),
('Color Force'),
('Columbia Pictures'),
('Cruella Productions'),
('Cruise-Wagner'),
('DC Films'),
('Di Bonaventura Pictures'),
('Dickhouse Productions'),
('Dimension Films'),
('Disney-Pixar'),
('DreamWorks'),
('Escape Artists'),
('EuropaCorp'),
('Feigco Entertainment'),
('Focus Features'),
('Gary Sanchez Productions'),
('GK Films'),
('Global Entertainment Productions'),
('Gloria Sanchez Productions'),
('Gold Circle Films'),
('Gotham Group'),
('Green Hat Films'),
('Happy Madison Productions'),
('Hawn / Sylbert Productions'),
('HBO Films'),
('Heyday Films'),
('Hollywood Pictures'),
('Icon Productions'),
('Illumination Entertainment'),
('Image Entertainment'),
('Imagine Entertainment'),
('Interscope Communications'),
('Jerry Bruckheimer Films'),
('Jersey Films'),
('Jinks/Cohen Company'),
('Junction Entertainment'),
('Juno Pix'),
('Kennedy Miller Mitchell'),
('Kennedy Miller Productions'),
('Ladd Company'),
('Lakeshore Entertainment'),
('Legendary Pictures'),
('Lightstorm Entertainment'),
('Live Planet'),
('Lucasfilm'),
('MacGillivray Freeman Films'),
('Malpaso Productions'),
('Marv Films'),
('Marvel Studios'),
('Media Rights Capital'),
('MGM'),
('Millennium Films'),
('Miramax'),
('Morgan Creek Productions'),
('Motion Picture Corporation of America'),
('MTV Films'),
('National Geographic Society'),
('Nickelodeon Movies'),
('Original Film'),
('Overbrook Entertainment'),
('Paramount'),
('Parkes/MacDonald Image Nation'),
('Phoenix Pictures'),
('Pixar Animation Studios'),
('Plan B Entertainment'),
('Point Grey Pictures'),
('Red Wagon Entertainment'),
('Regency Enterprises'),
('Relativity Media'),
('Revolution Studios'),
('Roth Films'),
('Scott Free Productions'),
('Scott Rudin Productions'),
('Seven Arts Pictures'),
('Skydance Media'),
('Spring Creek Pictures'),
('StudioCanal'),
('Syncopy'),
('T-Street'),
('Tapestry Films'),
('Temple Hill Entertainment'),
('The Kennedy Company'),
('The Montecito Picture Company'),
('Threshold Entertainment'),
('Thunder Road Pictures'),
('Tim Burton Productions'),
('Touchstone Pictures'),
('Tribeca Productions'),
('Tyler Perry Studios'),
('Universal'),
('Village Roadshow Pictures'),
('Walden Media'),
('Walt Disney'),
('Walt Disney Animation Studios'),
('Walt Disney Pictures'),
('Warner Bros'),
('Waverly Films'),
('Wayans Brothers Entertainment'),
('Wayne Rice Films'),
('Wingnut Films'),
('Winkler Films'),
('Working Title Films');

INSERT INTO distributore (nome) VALUES
('20th Century Fox'),
('Dimension Pictures'),
('Dreamworks'),
('Filmways Pictures'),
('Focus Features'),
('IMAX Films'),
('Lionsgate'),
('MGM'),
('Miramax'),
('Miramax/Dimension'),
('Newline'),
('Paramount'),
('Sony Pictures'),
('STX Entertainment'),
('Summit Entertainment'),
('United Artists'),
('Universal'),
('Walt Disney'),
('Warner Bros'),
('Warner Independent'),
('Weinstein Co.');

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
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Legends of the Fall', 1995, (SELECT id FROM produttore WHERE nome = 'Columbia Pictures'), (SELECT id FROM distributore WHERE nome = 'Sony Pictures'), 30000000, 66020491, 180029, 150650, 17671192, 48018620);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Bad Boys', 1995, (SELECT id FROM produttore WHERE nome = 'Columbia Pictures'), (SELECT id FROM distributore WHERE nome = 'Sony Pictures'), 23000000, 65647413, 21487402, 15590585, 8824717, 19744709);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('The Living Sea', 1995, (SELECT id FROM produttore WHERE nome = 'MacGillivray Freeman Films'), (SELECT id FROM distributore WHERE nome = 'IMAX Films'), 4000000, 64800000, 120000, 250000, 380000, 64050000);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Dumb & Dumber', 1995, (SELECT id FROM produttore WHERE nome = 'Motion Picture Corporation of America'), (SELECT id FROM distributore WHERE nome = 'Newline'), 17000000, 60671411, 20170000, 18450000, 15200000, 6851411);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Species', 1995, (SELECT id FROM produttore WHERE nome = 'MGM'), (SELECT id FROM distributore WHERE nome = 'MGM'), 35000000, 60054449, 22680194, 13460810, 9412105, 14501340);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Jumanji', 1995, (SELECT id FROM produttore WHERE nome = 'Interscope Communications'), (SELECT id FROM distributore WHERE nome = 'Sony Pictures'), 65000000, 57848637, 15354988, 15478490, 11494559, 15520600);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Babe', 1995, (SELECT id FROM produttore WHERE nome = 'Kennedy Miller Productions'), (SELECT id FROM distributore WHERE nome = 'Universal'), 30000000, 56805285, 11462000, 11025000, 9850000, 24468285);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Clueless', 1995, (SELECT id FROM produttore WHERE nome = 'Paramount'), (SELECT id FROM distributore WHERE nome = 'Paramount'), 12000000, 56461210, 14561000, 13240000, 9870000, 18790210);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Father of the Bride Part II', 1995, (SELECT id FROM produttore WHERE nome = 'Touchstone Pictures'), (SELECT id FROM distributore WHERE nome = 'Walt Disney'), 30000000, 52265735, 12640248, 11890000, 10450000, 17285487);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('The American President', 1995, (SELECT id FROM produttore WHERE nome = 'Castle Rock Entertainment'), (SELECT id FROM distributore WHERE nome = 'Sony Pictures'), 62000000, 51068604, 13700000, 12400000, 8950000, 16018604);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Something to Talk About', 1995, (SELECT id FROM produttore WHERE nome = 'Hawn / Sylbert Productions'), (SELECT id FROM distributore WHERE nome = 'Warner Bros'), 25000000, 50865589, 10820000, 9450000, 7210000, 23385589);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('The Net', 1995, (SELECT id FROM produttore WHERE nome = 'Winkler Films'), (SELECT id FROM distributore WHERE nome = 'Sony Pictures'), 22000000, 50621733, 13100000, 10850000, 8420000, 18251733);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Under Siege 2: Dark Territory', 1995, (SELECT id FROM produttore WHERE nome = 'Regency Enterprises'), (SELECT id FROM distributore WHERE nome = 'Warner Bros'), 60000000, 50024083, 15750000, 11200000, 7890000, 15184083);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('A Walk in the Clouds', 1995, (SELECT id FROM produttore WHERE nome = '20th Century Fox'), (SELECT id FROM distributore WHERE nome = '20th Century Fox'), 20000000, 50008143, 12720000, 10150000, 7980000, 19158143);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('The Brady Bunch Movie', 1995, (SELECT id FROM produttore WHERE nome = 'Ladd Company'), (SELECT id FROM distributore WHERE nome = 'Paramount'), 12000000, 46546167, 14820000, 11240000, 7650000, 12836167);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Pulp Fiction', 1995, (SELECT id FROM produttore WHERE nome = 'A Band Apart'), (SELECT id FROM distributore WHERE nome = 'Miramax'), 8000000, 44268548, 9311372, 8420000, 7150000, 19387176);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Man of the House', 1995, (SELECT id FROM produttore WHERE nome = 'Walt Disney'), (SELECT id FROM distributore WHERE nome = 'Walt Disney'), 22000000, 40029009, 9850000, 8120000, 6410000, 15649009);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Nobody''s Fool', 1995, (SELECT id FROM produttore WHERE nome = 'Capella Films'), (SELECT id FROM distributore WHERE nome = 'Paramount'), 20000000, 39007303, 210000, 6800000, 9720000, 22277303);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('French Kiss', 1995, (SELECT id FROM produttore WHERE nome = 'Working Title Films'), (SELECT id FROM distributore WHERE nome = '20th Century Fox'), 40000000, 38863798, 9050000, 7820000, 6120000, 15873798);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Higher Learning', 1995, (SELECT id FROM produttore WHERE nome = 'Warner Bros'), (SELECT id FROM distributore WHERE nome = 'Newline'), 14000000, 38023585, 13400000, 9210000, 5890000, 9523585);

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
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Space Cowboys', 2000, (SELECT id FROM produttore WHERE nome = 'Malpaso Productions'), (SELECT id FROM distributore WHERE nome = 'Warner Bros'), 65000000, 90179885, 24037538, 17260541, 13328409, 35553397);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Unbreakable', 2000, (SELECT id FROM produttore WHERE nome = 'Touchstone Pictures'), (SELECT id FROM distributore WHERE nome = 'Walt Disney'), 75000000, 90033796, 42410313, 14620000, 9540000, 23463483);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Scream 3', 2000, (SELECT id FROM produttore WHERE nome = 'Dimension Films'), (SELECT id FROM distributore WHERE nome = 'Dimension Pictures'), 40000000, 89138076, 39722304, 18944521, 11068832, 19402419);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('U-571', 2000, (SELECT id FROM produttore WHERE nome = 'StudioCanal'), (SELECT id FROM distributore WHERE nome = 'Universal'), 62000000, 77086030, 24536655, 16805825, 11438725, 24304825);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Hollow Man', 2000, (SELECT id FROM produttore WHERE nome = 'Global Entertainment Productions'), (SELECT id FROM distributore WHERE nome = 'Sony Pictures'), 95000000, 73209340, 34088523, 17006844, 9143818, 12970155);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Rugrats in Paris', 2000, (SELECT id FROM produttore WHERE nome = 'Nickelodeon Movies'), (SELECT id FROM distributore WHERE nome = 'Paramount'), 30000000, 71205699, 30026210, 10600000, 9420000, 21159489);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Stuart Little', 2000, (SELECT id FROM produttore WHERE nome = 'Columbia Pictures'), (SELECT id FROM distributore WHERE nome = 'Sony Pictures'), 133000000, 140035367, 22116000, 21430000, 19580000, 76909367);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Shaft', 2000, (SELECT id FROM produttore WHERE nome = 'Scott Rudin Productions'), (SELECT id FROM distributore WHERE nome = 'Paramount'), 46000000, 70327868, 28328704, 17180470, 9851086, 14967608);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('The Kid', 2000, (SELECT id FROM produttore WHERE nome = 'Junction Entertainment'), (SELECT id FROM distributore WHERE nome = 'Walt Disney'), 65000000, 69688384, 17266100, 12410000, 8920000, 31092284);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('The Green Mile', 2000, (SELECT id FROM produttore WHERE nome = 'Castle Rock Entertainment'), (SELECT id FROM distributore WHERE nome = 'Warner Bros'), 60000000, 136801374, 23924707, 18105000, 14850000, 79921667);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Road Trip', 2000, (SELECT id FROM produttore WHERE nome = 'The Montecito Picture Company'), (SELECT id FROM distributore WHERE nome = 'Dreamworks'), 16000000, 68525609, 20958742, 16382101, 10312674, 20872092);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Bring it On', 2000, (SELECT id FROM produttore WHERE nome = 'Beacon Communications'), (SELECT id FROM distributore WHERE nome = 'Universal'), 11000000, 68353550, 21414345, 15132800, 9412150, 22394255);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Rules of Engagement', 2000, (SELECT id FROM produttore WHERE nome = 'Seven Arts Pictures'), (SELECT id FROM distributore WHERE nome = 'Paramount'), 60000000, 61322858, 20120000, 13420000, 9150000, 18632858);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('The Cell', 2000, (SELECT id FROM produttore WHERE nome = 'Caro-Li'), (SELECT id FROM distributore WHERE nome = 'Newline'), 33000000, 61280963, 24704052, 11986420, 6895101, 17695390);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Mission to Mars', 2000, (SELECT id FROM produttore WHERE nome = 'Touchstone Pictures'), (SELECT id FROM distributore WHERE nome = 'Walt Disney'), 100000000, 60874615, 30018780, 14120000, 7250000, 9485835);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Coyote Ugly', 2000, (SELECT id FROM produttore WHERE nome = 'Jerry Bruckheimer Films'), (SELECT id FROM distributore WHERE nome = 'Walt Disney'), 45000000, 60786269, 17296000, 13210000, 8850000, 21430269);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Snow Day', 2000, (SELECT id FROM produttore WHERE nome = 'Nickelodeon Movies'), (SELECT id FROM distributore WHERE nome = 'Paramount'), 13000000, 60008303, 17830000, 14250000, 9120000, 18808303);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('American Beauty', 2000, (SELECT id FROM produttore WHERE nome = 'Jinks/Cohen Company'), (SELECT id FROM distributore WHERE nome = 'Dreamworks'), 15000000, 130096601, 1403000, 2120000, 3250000, 123323601);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('102 Dalmatians', 2000, (SELECT id FROM produttore WHERE nome = 'Cruella Productions'), (SELECT id FROM distributore WHERE nome = 'Walt Disney'), 85000000, 58335959, 26620586, 8910000, 6420000, 16385373);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Fantasia 2000', 2000, (SELECT id FROM produttore WHERE nome = 'Walt Disney Animation Studios'), (SELECT id FROM distributore WHERE nome = 'Walt Disney'), 80000000, 60507281, 3880000, 2950000, 2150000, 51527281);

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
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Are We There Yet?', 2005, (SELECT id FROM produttore WHERE nome = 'Revolution Studios'), (SELECT id FROM distributore WHERE nome = 'Sony Pictures'), 32000000, 82301521, 26210000, 13420000, 8120000, 34551521);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('The Dukes of Hazzard', 2005, (SELECT id FROM produttore WHERE nome = 'Village Roadshow Pictures'), (SELECT id FROM distributore WHERE nome = 'Warner Bros'), 50000000, 80270227, 43085352, 15640000, 7210000, 14334875);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('The Aviator', 2005, (SELECT id FROM produttore WHERE nome = 'Appian Way'), (SELECT id FROM distributore WHERE nome = 'Miramax'), 110000000, 102610330, 11500000, 15400000, 13100000, 62610330);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('La Marche de L''empereur', 2005, (SELECT id FROM produttore WHERE nome = 'National Geographic Society'), (SELECT id FROM distributore WHERE nome = 'Warner Independent'), 8000000, 77437223, 1050000, 2450000, 3120000, 70817223);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('The Ring Two', 2005, (SELECT id FROM produttore WHERE nome = 'Parkes/MacDonald Image Nation'), (SELECT id FROM distributore WHERE nome = 'Dreamworks'), 50000000, 75941727, 49501362, 13520000, 6110000, 6810365);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Constantine', 2005, (SELECT id FROM produttore WHERE nome = 'Village Roadshow Pictures'), (SELECT id FROM distributore WHERE nome = 'Warner Bros'), 100000000, 75500759, 39785507, 14810000, 7520000, 13385252);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('The Exorcism of Emily Rose', 2005, (SELECT id FROM produttore WHERE nome = 'Lakeshore Entertainment'), (SELECT id FROM distributore WHERE nome = 'Sony Pictures'), 19000000, 75072454, 41031388, 16420000, 7810000, 9811066);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Four Brothers', 2005, (SELECT id FROM produttore WHERE nome = 'Di Bonaventura Pictures'), (SELECT id FROM distributore WHERE nome = 'Paramount'), 45000000, 74494381, 29215011, 15840000, 8910000, 20529370);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Sin City', 2005, (SELECT id FROM produttore WHERE nome = 'Dimension Films'), (SELECT id FROM distributore WHERE nome = 'Miramax/Dimension'), 40000000, 74103820, 38653241, 15420000, 8210000, 11820579);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('The Interpreter', 2005, (SELECT id FROM produttore WHERE nome = 'Working Title Films'), (SELECT id FROM distributore WHERE nome = 'Universal'), 80000000, 72515360, 29158300, 15410000, 8720000, 19227060);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Sahara', 2005, (SELECT id FROM produttore WHERE nome = 'Bristol Bay Productions'), (SELECT id FROM distributore WHERE nome = 'Paramount'), 160000000, 68671925, 24621033, 13100000, 7210000, 23740892);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Guess Who', 2005, (SELECT id FROM produttore WHERE nome = 'Regency Enterprises'), (SELECT id FROM distributore WHERE nome = 'Sony Pictures'), 34000000, 67962333, 28400000, 14820000, 8110000, 16632333);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Coach Carter', 2005, (SELECT id FROM produttore WHERE nome = 'MTV Films'), (SELECT id FROM distributore WHERE nome = 'Paramount'), 30000000, 67264877, 33481267, 14120000, 7810000, 11853610);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Herbie: Fully Loaded', 2005, (SELECT id FROM produttore WHERE nome = 'Walt Disney Pictures'), (SELECT id FROM distributore WHERE nome = 'Walt Disney'), 50000000, 66010682, 17650000, 11410000, 7510000, 29440682);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('The Amityville Horror', 2005, (SELECT id FROM produttore WHERE nome = 'Dimension Films'), (SELECT id FROM distributore WHERE nome = 'Filmways Pictures'), 19000000, 64858000, 34100000, 14820000, 7410000, 8528000);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Sky High', 2005, (SELECT id FROM produttore WHERE nome = 'Walt Disney'), (SELECT id FROM distributore WHERE nome = 'Walt Disney'), 35000000, 63939454, 14320000, 11840000, 8120000, 29659454);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Jarhead', 2005, (SELECT id FROM produttore WHERE nome = 'Red Wagon Entertainment'), (SELECT id FROM distributore WHERE nome = 'Universal'), 72000000, 62454785, 34100000, 14510000, 7620000, 6224785);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Bewitched', 2005, (SELECT id FROM produttore WHERE nome = 'Columbia Pictures'), (SELECT id FROM distributore WHERE nome = 'Sony Pictures'), 85000000, 62252415, 23450000, 11210000, 6810000, 20782415);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Cinderella Man', 2005, (SELECT id FROM produttore WHERE nome = 'Miramax'), (SELECT id FROM distributore WHERE nome = 'Universal'), 88000000, 61649911, 20120000, 10410000, 6520000, 24599911);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Red Eye', 2005, (SELECT id FROM produttore WHERE nome = 'BenderSpink'), (SELECT id FROM distributore WHERE nome = 'Dreamworks'), 26000000, 57891803, 21250000, 11410000, 6810000, 18421803);

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
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Jackass 3D', 2010, (SELECT id FROM produttore WHERE nome = 'Dickhouse Productions'), (SELECT id FROM distributore WHERE nome = 'Paramount'), 20000000, 117109417, 58223696, 25050000, 9420000, 24415721);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Valentine''s Day', 2010, (SELECT id FROM produttore WHERE nome = 'Wayne Rice Films'), (SELECT id FROM distributore WHERE nome = 'Warner Bros'), 52000000, 110485654, 63456314, 20410000, 8910000, 17709340);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Robin Hood', 2010, (SELECT id FROM produttore WHERE nome = 'Imagine Entertainment'), (SELECT id FROM distributore WHERE nome = 'Universal'), 200000000, 105487148, 44102175, 19810000, 9820000, 31754973);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('The Expendables', 2010, (SELECT id FROM produttore WHERE nome = 'Millennium Films'), (SELECT id FROM distributore WHERE nome = 'Lionsgate'), 80000000, 103068524, 48123562, 17610000, 8910000, 28424962);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Little Fockers', 2010, (SELECT id FROM produttore WHERE nome = 'Tribeca Productions'), (SELECT id FROM distributore WHERE nome = 'Universal'), 100000000, 102576190, 47102354, 21410000, 9810000, 24253836);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Due Date', 2010, (SELECT id FROM produttore WHERE nome = 'Green Hat Films'), (SELECT id FROM distributore WHERE nome = 'Warner Bros'), 65000000, 99231922, 42103652, 18410000, 9110000, 29608270);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Date Night', 2010, (SELECT id FROM produttore WHERE nome = '21 Laps Entertainment'), (SELECT id FROM distributore WHERE nome = '20th Century Fox'), 55000000, 98711404, 35102654, 15410000, 8110000, 40088750);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Sex and the City 2', 2010, (SELECT id FROM produttore WHERE nome = 'HBO Films'), (SELECT id FROM distributore WHERE nome = 'Warner Bros'), 95000000, 95347692, 48123654, 16410000, 7810000, 23004038);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('The Book of Eli', 2010, (SELECT id FROM produttore WHERE nome = 'Alcon Entertainment'), (SELECT id FROM distributore WHERE nome = 'Warner Bros'), 80000000, 94835059, 41230154, 16410000, 7810000, 29384905);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('The Social Network', 2010, (SELECT id FROM produttore WHERE nome = 'Relativity Media'), (SELECT id FROM distributore WHERE nome = 'Sony Pictures'), 40000000, 93222026, 31204154, 16410000, 8110000, 37497872);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('The Town', 2010, (SELECT id FROM produttore WHERE nome = 'GK Films'), (SELECT id FROM distributore WHERE nome = 'Warner Bros'), 37000000, 92173235, 32104523, 16410000, 8110000, 35548712);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Prince of Persia: Sands of Time', 2010, (SELECT id FROM produttore WHERE nome = 'Jerry Bruckheimer Films'), (SELECT id FROM distributore WHERE nome = 'Walt Disney'), 200000000, 90759676, 37102654, 17410000, 8110000, 28137022);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Red', 2010, (SELECT id FROM produttore WHERE nome = 'Di Bonaventura Pictures'), (SELECT id FROM distributore WHERE nome = 'Summit Entertainment'), 58000000, 89505187, 32104154, 15410000, 8110000, 33881033);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Percy Jackson & the Olympians: The Lightning Thief', 2010, (SELECT id FROM produttore WHERE nome = '1492 Pictures'), (SELECT id FROM distributore WHERE nome = '20th Century Fox'), 95000000, 88768303, 39102654, 15410000, 7810000, 26445649);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('The Chronicles of Narnia: The Voyage of the Dawn Treader', 2010, (SELECT id FROM produttore WHERE nome = 'Walden Media'), (SELECT id FROM distributore WHERE nome = '20th Century Fox'), 155000000, 86926397, 38102654, 15410000, 7810000, 25603743);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('True Grit', 2010, (SELECT id FROM produttore WHERE nome = 'Scott Rudin Productions'), (SELECT id FROM distributore WHERE nome = 'Paramount'), 38000000, 86670382, 36102654, 16410000, 8110000, 26047728);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Paranormal Activity 2', 2010, (SELECT id FROM produttore WHERE nome = 'Blumhouse Productions'), (SELECT id FROM distributore WHERE nome = 'Paramount'), 3000000, 84660648, 52103654, 18410000, 7810000, 6336994);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Eat Pray Love', 2010, (SELECT id FROM produttore WHERE nome = 'Plan B Entertainment'), (SELECT id FROM distributore WHERE nome = 'Sony Pictures'), 60000000, 80574010, 36102654, 15410000, 7810000, 21251356);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Dear John', 2010, (SELECT id FROM produttore WHERE nome = 'Relativity Media'), (SELECT id FROM distributore WHERE nome = 'Sony Pictures'), 25000000, 80014842, 41230154, 16410000, 7810000, 14564688);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Unstoppable', 2010, (SELECT id FROM produttore WHERE nome = 'Scott Free Productions'), (SELECT id FROM distributore WHERE nome = '20th Century Fox'), 100000000, 79468486, 31204154, 14410000, 7510000, 26344332);

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
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Mad Max: Fury Road', 2015, (SELECT id FROM produttore WHERE nome = 'Kennedy Miller Mitchell'), (SELECT id FROM distributore WHERE nome = 'Warner Bros'), 150000000, 153636354, 65227103, 24100000, 13100000, 51209251);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('The Divergent Series: Insurgent', 2015, (SELECT id FROM produttore WHERE nome = 'Red Wagon Entertainment'), (SELECT id FROM distributore WHERE nome = 'Lionsgate'), 110000000, 130179072, 68380435, 21100000, 10100000, 30598637);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Kingsman: The Secret Service', 2015, (SELECT id FROM produttore WHERE nome = 'Marv Films'), (SELECT id FROM distributore WHERE nome = '20th Century Fox'), 81000000, 128261724, 47213654, 18100000, 9100000, 53848070);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('The Peanuts Movie', 2015, (SELECT id FROM produttore WHERE nome = 'Blue Sky Studios'), (SELECT id FROM distributore WHERE nome = '20th Century Fox'), 99000000, 128235584, 55102654, 24100000, 13100000, 35932930);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Spy!', 2015, (SELECT id FROM produttore WHERE nome = 'Feigco Entertainment'), (SELECT id FROM distributore WHERE nome = '20th Century Fox'), 65000000, 110825712, 38102654, 16100000, 9100000, 47523058);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('The Good Dinosaur', 2015, (SELECT id FROM produttore WHERE nome = 'Pixar Animation Studios'), (SELECT id FROM distributore WHERE nome = 'Walt Disney'), 175000000, 110716470, 55102654, 28100000, 15100000, 12413816);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Trainwreck', 2015, (SELECT id FROM produttore WHERE nome = 'Apatow Productions'), (SELECT id FROM distributore WHERE nome = 'Universal'), 35000000, 110212700, 46102654, 17100000, 9100000, 37910046);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Creed', 2015, (SELECT id FROM produttore WHERE nome = 'Chartoff-Winkler Productions'), (SELECT id FROM distributore WHERE nome = 'Warner Bros'), 35000000, 99385165, 52103654, 21100000, 11100000, 15081511);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Tomorrowland', 2015, (SELECT id FROM produttore WHERE nome = 'A1 Films'), (SELECT id FROM distributore WHERE nome = 'Walt Disney'), 190000000, 93436322, 42103654, 16100000, 8100000, 27132668);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Get Hard', 2015, (SELECT id FROM produttore WHERE nome = 'Gary Sanchez Productions'), (SELECT id FROM distributore WHERE nome = 'Warner Bros'), 40000000, 90411453, 45102654, 17100000, 8100000, 20108799);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Terminator: Genisys', 2015, (SELECT id FROM produttore WHERE nome = 'Skydance Media'), (SELECT id FROM distributore WHERE nome = 'Paramount'), 155000000, 89760956, 35102654, 15100000, 7100000, 32458302);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Taken 3', 2015, (SELECT id FROM produttore WHERE nome = 'EuropaCorp'), (SELECT id FROM distributore WHERE nome = '20th Century Fox'), 48000000, 89256424, 51103654, 20100000, 9100000, 8952770);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Maze Runner: The Scorch Trials', 2015, (SELECT id FROM produttore WHERE nome = 'Gotham Group'), (SELECT id FROM distributore WHERE nome = '20th Century Fox'), 61000000, 81630702, 38102654, 15100000, 7100000, 21328048);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Ted 2', 2015, (SELECT id FROM produttore WHERE nome = 'Media Rights Capital'), (SELECT id FROM distributore WHERE nome = 'Universal'), 68000000, 81476385, 46102654, 18100000, 8100000, 9173731);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Goosebumps', 2015, (SELECT id FROM produttore WHERE nome = 'Original Film'), (SELECT id FROM distributore WHERE nome = 'Sony Pictures'), 58000000, 79132868, 32104154, 14100000, 7100000, 25828714);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Pixels', 2015, (SELECT id FROM produttore WHERE nome = '1492 Pictures'), (SELECT id FROM distributore WHERE nome = 'Sony Pictures'), 88000000, 78765986, 31102654, 13100000, 6100000, 28463332);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Paddington', 2015, (SELECT id FROM produttore WHERE nome = 'Heyday Films'), (SELECT id FROM distributore WHERE nome = 'Weinstein Co.'), 55000000, 76223578, 25102654, 11100000, 6100000, 33920924);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('The Intern', 2015, (SELECT id FROM produttore WHERE nome = 'Waverly Films'), (SELECT id FROM distributore WHERE nome = 'Warner Bros'), 35000000, 75574886, 26102654, 11100000, 6100000, 32272232);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('The Imitation Game', 2015, (SELECT id FROM produttore WHERE nome = 'Black Bear Pictures'), (SELECT id FROM distributore WHERE nome = 'Weinstein Co.'), 14000000, 91125583, 210000, 6500000, 10100000, 74315583);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Paul Blart: Mall Cop 2', 2015, (SELECT id FROM produttore WHERE nome = 'Happy Madison Productions'), (SELECT id FROM distributore WHERE nome = 'Sony Pictures'), 30000000, 71091594, 23631452, 13100000, 6100000, 28260142);

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
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Knives Out', 2019, (SELECT id FROM produttore WHERE nome = 'T-Street'), (SELECT id FROM distributore WHERE nome = 'Lionsgate'), 40000000, 115711579, 41703654, 18100000, 9100000, 46807925);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Dumbo', 2019, (SELECT id FROM produttore WHERE nome = 'Tim Burton Productions'), (SELECT id FROM distributore WHERE nome = 'Walt Disney'), 170000000, 114766307, 59102654, 19100000, 9100000, 27463653);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Maleficent: Mistress of Evil', 2019, (SELECT id FROM produttore WHERE nome = 'Roth Films'), (SELECT id FROM distributore WHERE nome = 'Walt Disney'), 185000000, 113294737, 46102654, 19100000, 9100000, 38992083);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Glass', 2019, (SELECT id FROM produttore WHERE nome = 'Blumhouse Productions'), (SELECT id FROM distributore WHERE nome = 'Universal'), 20000000, 111048468, 59102654, 21100000, 9100000, 21745814);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Godzilla: King of the Monsters', 2019, (SELECT id FROM produttore WHERE nome = 'Legendary Pictures'), (SELECT id FROM distributore WHERE nome = 'Warner Bros'), 170000000, 110500138, 66102654, 21100000, 9100000, 14197484);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('The Upside', 2019, (SELECT id FROM produttore WHERE nome = 'Escape Artists'), (SELECT id FROM distributore WHERE nome = 'STX Entertainment'), 37500000, 108235497, 28102654, 15100000, 8100000, 56932843);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Ford v. Ferrari', 2019, (SELECT id FROM produttore WHERE nome = 'Chernin Entertainment'), (SELECT id FROM distributore WHERE nome = '20th Century Fox'), 97600000, 107196444, 47102654, 19100000, 9100000, 31893790);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('The LEGO Movie 2: The Second Part', 2019, (SELECT id FROM produttore WHERE nome = 'Animal Logic'), (SELECT id FROM distributore WHERE nome = 'Warner Bros'), 99000000, 105806508, 48102654, 21100000, 9100000, 27503854);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Hustlers', 2019, (SELECT id FROM produttore WHERE nome = 'Gloria Sanchez Productions'), (SELECT id FROM distributore WHERE nome = 'STX Entertainment'), 20000000, 104960643, 44102654, 17100000, 8100000, 35657989);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('The Addams Family', 2019, (SELECT id FROM produttore WHERE nome = 'Bron Creative'), (SELECT id FROM distributore WHERE nome = 'United Artists'), 24000000, 97185807, 42103654, 17100000, 8100000, 29882153);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Downton Abbey', 2019, (SELECT id FROM produttore WHERE nome = 'Carnival Films'), (SELECT id FROM distributore WHERE nome = 'Focus Features'), 13000000, 96853865, 41103654, 17100000, 8100000, 30550211);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Rocketman', 2019, (SELECT id FROM produttore WHERE nome = 'Marv Films'), (SELECT id FROM distributore WHERE nome = 'Paramount'), 40000000, 96368160, 37102654, 16100000, 8100000, 35065506);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Alita: Battle Angel', 2019, (SELECT id FROM produttore WHERE nome = 'Lightstorm Entertainment'), (SELECT id FROM distributore WHERE nome = '20th Century Fox'), 170000000, 85710210, 37102654, 15100000, 7100000, 26407556);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Good Boys', 2019, (SELECT id FROM produttore WHERE nome = 'Point Grey Pictures'), (SELECT id FROM distributore WHERE nome = 'Universal'), 20000000, 83140306, 31102654, 14100000, 7100000, 30837652);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Spider-Man: Into The Spider-Verse', 2019, (SELECT id FROM produttore WHERE nome = 'Columbia Pictures'), (SELECT id FROM distributore WHERE nome = 'Sony Pictures'), 90000000, 190202675, 48102654, 21100000, 9100000, 111900021);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Men in Black: International', 2019, (SELECT id FROM produttore WHERE nome = 'Amblin Entertainment'), (SELECT id FROM distributore WHERE nome = 'Sony Pictures'), 110000000, 80001807, 37102654, 15100000, 7100000, 20699153);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Annabelle Comes Home', 2019, (SELECT id FROM produttore WHERE nome = 'Atomic Monster'), (SELECT id FROM distributore WHERE nome = 'Warner Bros'), 27000000, 74152591, 36102654, 15100000, 7100000, 15849937);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Yesterday', 2019, (SELECT id FROM produttore WHERE nome = 'Working Title Films'), (SELECT id FROM distributore WHERE nome = 'Universal'), 26000000, 73286650, 24102654, 10100000, 5100000, 33983996);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Tyler Perry''s A Madea Family Funeral', 2019, (SELECT id FROM produttore WHERE nome = 'Tyler Perry Studios'), (SELECT id FROM distributore WHERE nome = 'Lionsgate'), 20000000, 73257045, 34102654, 14100000, 7100000, 17954391);
INSERT INTO film (titolo, anno, id_produttore, id_distributore, budget, boxoffice_domestico, sett1, sett2, sett3, sett4) VALUES ('Zombieland: Double Tap', 2019, (SELECT id FROM produttore WHERE nome = 'Columbia Pictures'), (SELECT id FROM distributore WHERE nome = 'Sony Pictures'), 42000000, 72930156, 35102654, 14100000, 7100000, 16627502);

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

SELECT titolo FROM film WHERE id_produttore IS NULL OR id_distributore IS NULL;
