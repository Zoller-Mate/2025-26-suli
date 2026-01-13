-- 1. feladat
SELECT sarkanyfaj AS faj
FROM sarkanyfajta
WHERE emberevo = 1 AND fejszam > 1
ORDER BY faj;

-- 2. feladat
SELECT DISTINCT l.nev AS lovag, l.holgye AS holgy
FROM lovag l
INNER JOIN kiralylany k ON l.holgye = k.nev
INNER JOIN sarkany s ON k.fogvatarto = s.nev
INNER JOIN sarkanyfajta sf ON s.faj = sf.sarkanyfaj
WHERE s.nosteny = 1 AND sf.fejszam > 1
ORDER BY lovag;

-- 3. feladat
SELECT l.nev AS lovag, s.nev AS sarkany, l.holgye AS holgy
FROM lovag l
INNER JOIN osellensegek o ON l.nev = o.lovag
INNER JOIN sarkany s ON o.sarkany = s.nev
INNER JOIN kiralylany k ON l.holgye = k.nev
WHERE k.fogvatarto = s.nev AND s.nosteny = 1
ORDER BY lovag;

-- 4. feladat
SELECT DISTINCT o.orszagnev AS orszagnev
FROM orszag o
INNER JOIN sarkany s ON o.orszagnev = s.feszkelohely
INNER JOIN sarkanyfajta sf ON s.faj = sf.sarkanyfaj
WHERE s.testhossz < 30 
  AND (sf.tuzokado = 1 OR sf.emberevo = 1)
  AND sf.sarkanyfaj != 'Mocsárisárkány'
ORDER BY orszagnev;

-- 5. feladat
SELECT l.nev AS lovag, b.minosites AS batorsag, l.holgye AS holgy, sz.minosites AS szepseg
FROM lovag l
INNER JOIN kiralylany k ON l.holgye = k.nev
INNER JOIN batorsag b ON l.batorsag = b.fokozat
INNER JOIN szepseg sz ON k.szepseg = sz.fokozat
WHERE l.had >= 1000 AND l.batorsag > k.szepseg
ORDER BY lovag;

-- 6. feladat
SELECT SUM(l.had) AS katonaszam, k.nev AS kiraly
FROM kiraly k
INNER JOIN orszag o ON k.kiralykod = o.kiralya
INNER JOIN lovag l ON o.orszagnev = l.orszaga
GROUP BY k.kiralykod, k.nev
ORDER BY katonaszam;

-- 7. feladat
SELECT DISTINCT l.holgye AS holgy
FROM lovag l
WHERE l.vagyon > 10000
ORDER BY holgy;

-- 8. feladat
SELECT COUNT(*) AS darabszam
FROM kiralylany k
INNER JOIN sarkany s ON k.fogvatarto = s.nev
INNER JOIN orszag o ON s.feszkelohely = o.orszagnev
WHERE o.kiralya = 'REX VALDEMAR';

-- 9. feladat
SELECT IFNULL(SUM(s.kincs), 0) AS arany, l.nev AS lovagnev
FROM lovag l
LEFT JOIN osellensegek o ON l.nev = o.lovag
LEFT JOIN sarkany s ON o.sarkany = s.nev AND s.eletkor < 100
LEFT JOIN sarkanyfajta sf ON s.faj = sf.sarkanyfaj AND sf.tuzokado = 0
GROUP BY l.nev
ORDER BY arany;

-- 10. feladat
SELECT COUNT(l.nev) AS hadurszam, k.nev AS kiralynev
FROM kiraly k
INNER JOIN orszag o ON k.kiralykod = o.kiralya
INNER JOIN lovag l ON o.orszagnev = l.orszaga
WHERE l.had >= 1000
GROUP BY k.kiralykod, k.nev
ORDER BY hadurszam;

-- 11. feladat
SELECT k.nev AS kiralynev
FROM kiraly k
LEFT JOIN kiralylany kl ON k.kiralykod = kl.apa
WHERE kl.nev IS NULL
ORDER BY kiralynev;

-- 12. feladat
SELECT o.orszagnev AS orszagnev
FROM orszag o
LEFT JOIN lovag l ON o.orszagnev = l.orszaga
WHERE o.lakossag > 100 AND l.nev IS NULL
ORDER BY orszagnev;

-- 13. feladat
SELECT l.nev AS lovag, k.vagyon / 10 AS hozomany
FROM lovag l
INNER JOIN kiralylany kl ON l.holgye = kl.nev
INNER JOIN kiraly k ON kl.apa = k.kiralykod
ORDER BY lovag;

-- 14. feladat
SELECT l.nev AS lovagnev, b.minosites AS batorsag
FROM lovag l
INNER JOIN batorsag b ON l.batorsag = b.fokozat
WHERE l.batorsag > (
    SELECT MAX(l2.batorsag)
    FROM lovag l2
    WHERE l2.orszaga = 'Sirályváros'
)
ORDER BY lovagnev;

-- 15. feladat
SELECT l.holgye AS kiralylany, l.nev AS lovag
FROM lovag l
INNER JOIN (
    SELECT holgye, MAX(batorsag) AS max_batorsag
    FROM lovag
    GROUP BY holgye
) AS max_lovag ON l.holgye = max_lovag.holgye AND l.batorsag = max_lovag.max_batorsag
ORDER BY kiralylany;

-- 16. feladat
SELECT s.nev AS sarkanynev
FROM sarkany s
WHERE s.nev NOT IN (
    SELECT DISTINCT fogvatarto
    FROM kiralylany
    WHERE fogvatarto != ''
)
AND s.faj IN (
    SELECT DISTINCT s2.faj
    FROM sarkany s2
    INNER JOIN kiralylany k ON s2.nev = k.fogvatarto
)
ORDER BY sarkanynev;
