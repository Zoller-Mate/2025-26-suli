-- 1. feladat
SELECT nev AS `Lovag`, cimer AS `Címer`
FROM lovag
WHERE orszaga = 'Bergengócia' AND cimer LIKE '%Sárkány%'
ORDER BY 1;

-- 2. feladat
SELECT k.nev AS `KirálylányNév`
FROM kiralylany k
JOIN sarkany s ON k.fogvatarto = s.nev
JOIN sarkanyfajta sf ON s.faj = sf.sarkanyfaj
WHERE k.eletkor > 20 AND sf.emberevo = 1 AND sf.ropkepes = 1
ORDER BY 1;

-- 3. feladat
SELECT l.nev AS `Lovag`, l.holgye AS `Hölgy`, kr.nev AS `Király`
FROM lovag l
JOIN kiralylany ky ON l.holgye = ky.nev
JOIN orszag o ON l.orszaga = o.orszagnev
JOIN kiraly kr ON o.kiralya = kr.kiralykod
WHERE ky.apa = o.kiralya
ORDER BY 1;

-- 4. feladat
SELECT nev AS `Sárkánynév`
FROM sarkany
WHERE testhossz IS NOT NULL
  AND nosteny = 0
  AND eletkor BETWEEN 100 AND 500
  AND feszkelohely NOT IN ('Varacskosfölde','Bergengócia')
ORDER BY 1;

-- 5. feladat
SELECT l.nev AS `Lovag`, l.vagyon AS `Lovag Vagyona`, kr.nev AS `Király`, kr.vagyon AS `Király Vagyona`
FROM lovag l
JOIN orszag o ON l.orszaga = o.orszagnev
JOIN kiraly kr ON o.kiralya = kr.kiralykod
WHERE l.vagyon > kr.vagyon
ORDER BY 1;

-- 6. feladat
SELECT AVG(testhossz) AS `Átlaghossz`, faj AS `fajta`
FROM sarkany
GROUP BY faj
ORDER BY 1;

-- 7. feladat
SELECT feszkelohely AS `Országnév`, SUM(kincs) AS `Kincs`
FROM sarkany
GROUP BY feszkelohely
HAVING SUM(kincs) > 100000
ORDER BY 1;

-- 8. feladat
SELECT AVG(k.eletkor) AS `átlagéletkor`
FROM kiralylany k
JOIN sarkany s ON k.fogvatarto = s.nev
JOIN sarkanyfajta sf ON s.faj = sf.sarkanyfaj
WHERE sf.fejszam > 1 AND k.fogvatarto <> ''
;

-- 9. feladat
SELECT COUNT(*) AS `Sárkányszám`, s.feszkelohely AS `Ország`
FROM sarkany s
JOIN sarkanyfajta sf ON s.faj = sf.sarkanyfaj
WHERE sf.ropkepes = 1
GROUP BY s.feszkelohely
ORDER BY 1;

-- 10. feladat
SELECT AVG(l.had) AS `Átlag`, o.orszagnev AS `Ország`
FROM lovag l
JOIN orszag o ON l.orszaga = o.orszagnev
WHERE o.terulet > 200
GROUP BY o.orszagnev
ORDER BY 1;

-- 11. feladat
SELECT orszagnev AS `Országnév`
FROM orszag
WHERE orszagnev NOT IN (SELECT DISTINCT feszkelohely FROM sarkany)
ORDER BY 1;

-- 12. feladat
SELECT s.nev AS `Sárkánynév`
FROM sarkany s
JOIN sarkanyfajta sf ON s.faj = sf.sarkanyfaj
WHERE sf.ropkepes = 1 AND sf.fejszam > 1
  AND s.nev NOT IN (SELECT fogvatarto FROM kiralylany WHERE fogvatarto <> '')
ORDER BY 1;

-- 13. feladat
SELECT (CAST(lakossag AS DECIMAL(10,4)) / NULLIF(terulet,0)) AS `Népsűrüség`, orszagnev AS `Ország`
FROM orszag
ORDER BY 1;

-- 14. feladat
SELECT DISTINCT l.orszaga AS `Név`
FROM lovag l
WHERE l.holgye = 'Tündérszép Ilona'
  AND l.batorsag = (
    SELECT MAX(batorsag) FROM lovag WHERE holgye = 'Tündérszép Ilona'
  )
ORDER BY 1;

-- 15. feladat
SELECT DISTINCT kr.nev AS `Királynév`
FROM osellensegek o
JOIN lovag l ON o.lovag = l.nev
JOIN orszag orz ON l.orszaga = orz.orszagnev
JOIN kiraly kr ON orz.kiralya = kr.kiralykod
WHERE o.sarkany = 'Csorbafog'
  AND l.batorsag = (
    SELECT MIN(l2.batorsag)
    FROM osellensegek o2
    JOIN lovag l2 ON o2.lovag = l2.nev
    WHERE o2.sarkany = 'Csorbafog'
  )
ORDER BY 1;

-- 16. feladat
SELECT AVG(cnt) AS `Átlag`, t.orszaga AS `Ország`
FROM (
  SELECT l.orszaga, l.nev, COUNT(o.sarkany) AS cnt
  FROM lovag l
  LEFT JOIN osellensegek o ON l.nev = o.lovag
  GROUP BY l.nev
) t
GROUP BY t.orszaga
ORDER BY 1;
