-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Gép: 127.0.0.1
-- Létrehozás ideje: 2025. Nov 26. 12:11
-- Kiszolgáló verziója: 10.4.28-MariaDB
-- PHP verzió: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Adatbázis: `feladatbank`
--
DROP DATABASE IF EXISTS `feladatbank`;
CREATE DATABASE `feladatbank` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_hungarian_ci;
USE `feladatbank`;

DELIMITER $$
--
-- Eljárások
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `teszt_generalasa` (IN `p_bemeneti_json` TEXT, OUT `p_kimeneti_json` JSON)   BEGIN
	-- változók deklarálása
	DECLARE v_kategoria_azon INT;
	DECLARE v_keresek_szama INT;
	DECLARE v_kategoria_index INT DEFAULT 0;
	DECLARE v_osszes_kategoria INT;

	DECLARE v_teszt_kerdesei_json JSON DEFAULT '[]';
	DECLARE v_kerdes_json JSON;
	DECLARE v_valaszok_json JSON;
	
	-- CURSOR -hoz változók
	DECLARE v_feladat_azon INT;
	DECLARE v_feladat_leiras TEXT;
	DECLARE v_feladat_pontszam INT;
	DECLARE v_feladat_tipus_azon INT;
	DECLARE v_feladat_kategoria_azon INT;
	DECLARE v_feladat_kategoria_megnevezes VARCHAR(50);
	DECLARE v_nincs_tobb_feladat BOOLEAN DEFAULT FALSE;
	
	
	SET v_osszes_kategoria = JSON_LENGTH(p_bemeneti_json);
	
	CREATE TEMPORARY TABLE kivalasztott_feladatok (
		id INT,
		leiras TEXT,
		pontszam INT,
		feladat_tipus_id INT,
		kategoria_id INT,
		megnevezes VARCHAR(50)
	);
	
	WHILE v_kategoria_index < v_osszes_kategoria DO
		SET v_kategoria_azon = JSON_UNQUOTE(JSON_EXTRACT(p_bemeneti_json, CONCAT('$[', v_kategoria_index, '].id')));
		SET v_keresek_szama = JSON_UNQUOTE(JSON_EXTRACT(p_bemeneti_json, CONCAT('$[', v_kategoria_index, '].db')));
		
		TRUNCATE TABLE kivalasztott_feladatok;
		
		INSERT INTO kivalasztott_feladatok
		SELECT f.id, f.leiras, f.pontszam, f.feladat_tipus_id, f.kategoria_id, k.megnevezes
		FROM feladatok AS f
		INNER JOIN kategoriak AS k ON k.id = f.kategoria_id
		WHERE k.engedelyezett = 1 AND f.allapot='elfogadott' AND (f.kategoria_id = v_kategoria_azon OR v_kategoria_azon = -1)
		ORDER BY RAND()
		LIMIT v_keresek_szama;

		-- cursor
		BEGIN
			DECLARE feladat_kurzor CURSOR FOR
				SELECT id, leiras, pontszam, feladat_tipus_id, kategoria_id, megnevezes
				FROM kivalasztott_feladatok;
			DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_nincs_tobb_feladat = TRUE;
			
			OPEN feladat_kurzor;
			feladat_ciklus: LOOP
				FETCH feladat_kurzor INTO 
				  v_feladat_azon,
				  v_feladat_leiras,
				  v_feladat_pontszam,
				  v_feladat_tipus_azon,
				  v_feladat_kategoria_azon,
				  v_feladat_kategoria_megnevezes;
				  
				IF v_nincs_tobb_feladat THEN
					LEAVE feladat_ciklus;
				END IF;
				
				SET v_valaszok_json = (
					SELECT JSON_ARRAYAGG(
						JSON_OBJECT(
							'id', id,
							'leiras', leiras,
							'helyes_e', helyes_e
						)
					)
					FROM valaszok
					WHERE feladat_id = v_feladat_azon
					ORDER BY RAND()
				);
				
				IF v_valaszok_json IS NULL THEN
					SET v_valaszok_json = '[]';
				END IF;
				
				SET v_kerdes_json = JSON_OBJECT(
					'id', v_feladat_azon,
					'leiras', v_feladat_leiras,
					'pontszam', v_feladat_pontszam,
					'feladat_tipus_id', v_feladat_tipus_azon,
					'kategoria_id', v_feladat_kategoria_azon,
					'kategoria', v_feladat_kategoria_megnevezes,
					'valaszok', v_valaszok_json
				);
	 
			END LOOP feladat_ciklus;
			CLOSE feladat_kurzor;
		END;
		
		SET v_teszt_kerdesei_json = JSON_ARRAY_APPEND(v_teszt_kerdesei_json, '$', v_kerdes_json);
		
		SET v_nincs_tobb_feladat = FALSE;
		
		SET v_kategoria_index = v_kategoria_index+1;
	END WHILE;
	
	DROP TEMPORARY TABLE kivalasztott_feladatok;
	
	SET p_kimeneti_json = v_teszt_kerdesei_json;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `teszt_generalasa_jo` (IN `p_bemeneti_json` TEXT, OUT `p_kimeneti_json` JSON)   BEGIN
	-- változók deklarálása
	DECLARE v_kategoria_azon INT;
	DECLARE v_keresek_szama INT;
	DECLARE v_kategoria_index INT DEFAULT 0;
	DECLARE v_osszes_kategoria INT;

	DECLARE v_teszt_kerdesei_json JSON DEFAULT '[]';
	DECLARE v_kerdes_json JSON;
	DECLARE v_valaszok_json JSON;
	DECLARE v_valaszok_string TEXT;
	DECLARE v_json_elemek_string TEXT DEFAULT '';
		
	-- CURSOR -hoz változók
	DECLARE v_feladat_azon INT;
	DECLARE v_feladat_leiras TEXT;
	DECLARE v_feladat_pontszam INT;
	DECLARE v_feladat_tipus_azon INT;
	DECLARE v_feladat_kategoria_azon INT;
	DECLARE v_feladat_kategoria_megnevezes VARCHAR(50);
	DECLARE v_nincs_tobb_feladat BOOLEAN DEFAULT FALSE;
	
	
	SET v_osszes_kategoria = JSON_LENGTH(p_bemeneti_json);
	
	CREATE TEMPORARY TABLE kivalasztott_feladatok (
		id INT,
		leiras TEXT,
		pontszam INT,
		feladat_tipus_id INT,
		kategoria_id INT,
		megnevezes VARCHAR(50)
	);
	-- $[0].id vagy $[1].db
	WHILE v_kategoria_index < v_osszes_kategoria DO
		SET v_kategoria_azon = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_bemeneti_json, CONCAT('$[', v_kategoria_index, '].id'))) AS INTEGER);
		
		SET v_keresek_szama = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_bemeneti_json, CONCAT('$[', v_kategoria_index, '].db'))) AS INTEGER);
		
		TRUNCATE TABLE kivalasztott_feladatok;
		
		INSERT INTO kivalasztott_feladatok
		SELECT f.id, f.leiras, f.pontszam, f.feladat_tipus_id, f.kategoria_id, k.megnevezes
		FROM feladatok AS f
		INNER JOIN kategoriak AS k ON k.id = f.kategoria_id
		WHERE k.engedelyezett = 1 AND f.allapot='elfogadott' AND (f.kategoria_id = v_kategoria_azon OR v_kategoria_azon = -1)
		ORDER BY RAND()
		LIMIT v_keresek_szama;

		-- cursor
		BEGIN
			DECLARE feladat_kurzor CURSOR FOR
				SELECT id, leiras, pontszam, feladat_tipus_id, kategoria_id, megnevezes
				FROM kivalasztott_feladatok;
			DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_nincs_tobb_feladat = TRUE;
			
			OPEN feladat_kurzor;
			feladat_ciklus: LOOP
				FETCH feladat_kurzor INTO 
				  v_feladat_azon,
				  v_feladat_leiras,
				  v_feladat_pontszam,
				  v_feladat_tipus_azon,
				  v_feladat_kategoria_azon,
				  v_feladat_kategoria_megnevezes;
				  
				IF v_nincs_tobb_feladat THEN
					LEAVE feladat_ciklus;
				END IF;
				
				SET v_valaszok_string = (
					SELECT GROUP_CONCAT(
						JSON_OBJECT(
							'id', id,
							'leiras', leiras,
							'helyes_e', helyes_e
						)
						ORDER BY RAND()
						SEPARATOR ','
					)
					FROM valaszok
					WHERE feladat_id = v_feladat_azon
				);
				
				IF v_valaszok_string IS NULL THEN
					SET v_valaszok_json = '[]';
				ELSE
					SET v_valaszok_json = CONCAT('[',v_valaszok_string , ']');
				END IF;
				
				SET v_kerdes_json = JSON_OBJECT(
					'id', v_feladat_azon,
					'leiras', v_feladat_leiras,
					'pontszam', v_feladat_pontszam,
					'feladat_tipus_id', v_feladat_tipus_azon,
					'kategoria_id', v_feladat_kategoria_azon,
					'kategoria', v_feladat_kategoria_megnevezes,
					'valaszok', v_valaszok_json
				);
				
				IF v_json_elemek_string = '' THEN
					SET v_json_elemek_string = v_kerdes_json;
				ELSE
					SET v_json_elemek_string = CONCAT(v_json_elemek_string, ',',  v_kerdes_json);
				END IF;
	 
			END LOOP feladat_ciklus;
			CLOSE feladat_kurzor;
		END;
		
		SET v_kategoria_index = v_kategoria_index+1;
	END WHILE;
	
	DROP TEMPORARY TABLE kivalasztott_feladatok;
	
	SET p_kimeneti_json = CONCAT('[', v_json_elemek_string, ']');

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `teszt_minden` (IN `darab` INT)   BEGIN
	SELECT f.id, f.leiras, f.pontszam, t.megnevezes AS tipus, k.megnevezes AS kategoria
	FROM feladatok AS f
	INNER JOIN kategoriak AS k ON k.id = f.kategoria_id
	INNER JOIN feladat_tipusok AS t ON t.id = f.feladat_tipus_id
	WHERE f.allapot = 'elfogadott' AND k.engedelyezett = '1'
	ORDER BY RAND()
	LIMIT darab;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `valami2` (IN `hatar` INT, IN `uj_ar` INT)   BEGIN
  -- változók
  DECLARE v_id INT;
  DECLARE v_ar INT;
  DECLARE vege INT DEFAULT FALSE;
  -- kurzor
  DECLARE ar_cursor CURSOR FOR
	SELECT id, ar FROM nem_semmi WHERE ar < hatar;
  -- folyamat kezelő handler
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET vege = TRUE;
  
  OPEN ar_cursor;
  read_loop: LOOP
	FETCH ar_cursor INTO v_id,  v_ar;
	IF vege THEN
		LEAVE read_loop;
	END IF;
	UPDATE nem_semmi SET ar = uj_ar WHERE id = v_id;
  END LOOP;
  CLOSE ar_cursor;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `ertekelesek`
--

CREATE TABLE `ertekelesek` (
  `id` tinyint(3) UNSIGNED NOT NULL,
  `megnevezes` varchar(50) NOT NULL,
  `jegy2` tinyint(3) UNSIGNED NOT NULL,
  `jegy3` tinyint(3) UNSIGNED NOT NULL,
  `jegy4` tinyint(3) UNSIGNED NOT NULL,
  `jegy5` tinyint(3) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

--
-- A tábla adatainak kiíratása `ertekelesek`
--

INSERT INTO `ertekelesek` (`id`, `megnevezes`, `jegy2`, `jegy3`, `jegy4`, `jegy5`) VALUES
(1, 'Jóindulatú', 20, 40, 60, 80),
(2, 'Szigorú', 50, 65, 80, 90);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `feladatok`
--

CREATE TABLE `feladatok` (
  `id` int(10) UNSIGNED NOT NULL,
  `leiras` tinytext NOT NULL,
  `kategoria_id` tinyint(3) UNSIGNED NOT NULL,
  `feladat_tipus_id` tinyint(3) UNSIGNED NOT NULL,
  `pontszam` tinyint(3) UNSIGNED NOT NULL,
  `bonthato_e` tinyint(1) NOT NULL,
  `allapot` enum('elfogadott','folyamatban','tiltott') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

--
-- A tábla adatainak kiíratása `feladatok`
--

INSERT INTO `feladatok` (`id`, `leiras`, `kategoria_id`, `feladat_tipus_id`, `pontszam`, `bonthato_e`, `allapot`) VALUES
(1, 'Mi az osztály szerepe az objektumorientált programozásban?', 1, 2, 2, 0, 'elfogadott'),
(2, 'Mit jelent az öröklés?', 1, 2, 3, 0, 'elfogadott'),
(3, 'Mi a polimorfizmus lényege?', 1, 2, 2, 0, 'elfogadott'),
(4, 'Mi az enkapszuláció elsődleges célja?', 1, 2, 3, 0, 'elfogadott'),
(5, 'Melyik kifejezés jelenti azt, hogy egy metódus többféle paraméterlistával is létezhet?', 1, 2, 2, 0, 'elfogadott'),
(6, 'Mit jelent a metódus felüldefiniálása?', 1, 2, 2, 0, 'elfogadott'),
(7, 'Mi jellemző az absztrakt osztályra?', 1, 2, 3, 0, 'elfogadott'),
(8, 'Mi az interfész fő jellemzője?', 1, 2, 2, 0, 'elfogadott'),
(9, 'Mit jelent a konstruktor?', 1, 2, 2, 0, 'elfogadott'),
(10, 'Mi a destruktor szerepe?', 1, 2, 2, 0, 'elfogadott'),
(11, 'Mit jelent az „is-a” kapcsolat?', 1, 2, 3, 0, 'elfogadott'),
(12, 'Mit jelent a kompozíció?', 1, 2, 3, 0, 'elfogadott'),
(13, 'Mi jellemzi a privát adattagot?', 1, 2, 2, 0, 'elfogadott'),
(14, 'Mi a protected láthatóság jelentése?', 1, 2, 3, 0, 'elfogadott'),
(15, 'Melyik jellemző NEM része az objektumorientált programozás három alapelvének?', 1, 2, 2, 0, 'elfogadott'),
(16, 'Mi a statikus adattag sajátossága?', 1, 2, 3, 0, 'elfogadott'),
(17, 'Mi jellemzi az absztrakció fogalmát?', 1, 2, 2, 0, 'elfogadott'),
(18, 'Mi történik, ha egy interfészt implementáló osztály nem valósítja meg az összes előírt metódust?', 1, 2, 3, 0, 'elfogadott'),
(19, 'Melyik állítás igaz a final kulcsszóra?', 1, 2, 2, 0, 'elfogadott'),
(20, 'Mit jelent a getter metódus?', 1, 2, 2, 0, 'elfogadott'),
(21, 'Mi a célja a konstruktor túlterhelésének?', 1, 2, 2, 0, 'elfogadott'),
(22, 'Mit jelent az osztály példánya?', 1, 2, 2, 0, 'elfogadott'),
(23, 'Mi a célja a setter metódusnak?', 1, 2, 2, 0, 'elfogadott'),
(24, 'Mikor beszélünk névütközésről?', 1, 2, 2, 0, 'elfogadott'),
(25, 'Mit biztosít a névtér használata?', 1, 2, 2, 0, 'elfogadott'),
(26, 'Mi az előnye a metódus-túlterhelésnek?', 1, 2, 2, 0, 'elfogadott'),
(27, 'Mit jelent a dinamikus kötés?', 1, 2, 3, 0, 'elfogadott'),
(28, 'Mi jellemző az ősosztályra?', 1, 2, 2, 0, 'elfogadott'),
(29, 'Mi a célja a kód újrafelhasználásának?', 1, 2, 3, 0, 'elfogadott'),
(30, 'Mit jelent a példányváltozó?', 1, 2, 2, 0, 'elfogadott'),
(31, 'Mi történik, ha egy osztály túlterheli a konstruktort?', 1, 2, 2, 0, 'elfogadott'),
(32, 'Mi a célja a final osztálynak?', 1, 2, 3, 0, 'elfogadott'),
(33, 'Mit jelent az osztály hierarchia?', 1, 2, 2, 0, 'elfogadott'),
(34, 'Mi a célja a virtuális metódusnak?', 1, 2, 3, 0, 'elfogadott'),
(35, 'Mit jelent az absztrakt metódus?', 1, 2, 2, 0, 'elfogadott'),
(36, 'Mit jelent a példányosítás?', 1, 2, 2, 0, 'elfogadott'),
(37, 'Mi a fő különbség az interfész és az absztrakt osztály között?', 1, 2, 3, 0, 'elfogadott'),
(38, 'Miért hasznos az enkapszuláció?', 1, 2, 2, 0, 'elfogadott'),
(39, 'Mit jelent a \"has-a\" kapcsolat?', 1, 2, 3, 0, 'elfogadott'),
(40, 'Mi jellemzi az aggregációt?', 1, 2, 3, 0, 'elfogadott'),
(41, 'Mit jelent a metódus szignatúrája?', 1, 2, 2, 0, 'elfogadott'),
(42, 'Melyik NEM a polimorfizmus típusa?', 1, 2, 2, 0, 'elfogadott'),
(43, 'Mi jellemző a statikus metódusra?', 1, 2, 2, 0, 'elfogadott'),
(44, 'Mit jelent a felüldefiniálás?', 1, 2, 2, 0, 'elfogadott'),
(45, 'Mi történik, ha egy privát adattaghoz közvetlenül kívülről próbálunk hozzáférni?', 1, 2, 3, 0, 'elfogadott'),
(46, 'Mire utal a \"super\" kulcsszó?', 1, 2, 2, 0, 'elfogadott'),
(47, 'Mire használható az osztálydiagram?', 1, 2, 3, 0, 'elfogadott'),
(48, 'Mi jellemző az immutable objektumra?', 1, 2, 3, 0, 'elfogadott'),
(49, 'Mit jelent a downcasting?', 1, 2, 3, 0, 'elfogadott'),
(50, 'Mi a célja a toString metódusnak?', 1, 2, 2, 0, 'elfogadott'),
(51, 'Miért használunk interfészeket?', 1, 2, 2, 0, 'elfogadott'),
(52, 'Mi az adatbázis célja?', 3, 2, 2, 0, 'elfogadott'),
(53, 'Mit jelent a relációs adatmodell?', 3, 2, 3, 0, 'elfogadott'),
(54, 'Mi a kulcs szerepe egy táblában?', 3, 2, 2, 0, 'elfogadott'),
(55, 'Mi a mező?', 3, 2, 2, 0, 'elfogadott'),
(56, 'Mit jelent a rekord?', 3, 2, 2, 0, 'elfogadott'),
(57, 'Mi a külső kulcs szerepe?', 3, 2, 3, 0, 'elfogadott'),
(58, 'Mit jelent az SQL?', 3, 2, 2, 0, 'elfogadott'),
(59, 'Mit csinál a SELECT utasítás?', 3, 2, 2, 0, 'elfogadott'),
(60, 'Mit csinál a DELETE utasítás?', 3, 2, 3, 0, 'elfogadott'),
(61, 'Mit csinál az INSERT?', 3, 2, 2, 0, 'elfogadott'),
(62, 'Mit csinál az UPDATE?', 3, 2, 2, 0, 'elfogadott'),
(63, 'Mi a lekérdezés?', 3, 2, 2, 0, 'elfogadott'),
(64, 'Mit jelent a normalizálás?', 3, 2, 3, 0, 'elfogadott'),
(65, 'Mi az 1NF egyik feltétele?', 3, 2, 2, 0, 'elfogadott'),
(66, 'Mit jelent a JOIN?', 3, 2, 2, 0, 'elfogadott'),
(67, 'Mit jelent az INNER JOIN?', 3, 2, 3, 0, 'elfogadott'),
(68, 'Mi az adatbázis séma?', 3, 2, 3, 0, 'elfogadott'),
(69, 'Mi az index?', 3, 2, 3, 0, 'elfogadott'),
(70, 'Mi a tábla elsődleges kulcsa?', 3, 2, 2, 0, 'elfogadott'),
(71, 'Mi az adatbázis tranzakció?', 3, 2, 3, 0, 'elfogadott'),
(72, 'Mit jelent az ACID elv A betűje?', 3, 2, 2, 0, 'elfogadott'),
(73, 'Mit jelent a NULL érték?', 3, 2, 2, 0, 'elfogadott'),
(74, 'Mit jelent a GROUP BY?', 3, 2, 3, 0, 'elfogadott'),
(75, 'Mi a HAVING célja?', 3, 2, 3, 0, 'elfogadott'),
(76, 'Melyik SQL függvény aggregáló függvény?', 3, 2, 2, 0, 'elfogadott'),
(77, 'Mit csinál a COUNT(*)?', 3, 2, 2, 0, 'elfogadott'),
(78, 'Mi a tábla karbantartásának célja?', 3, 2, 3, 0, 'elfogadott'),
(79, 'Mit jelent a referenciális integritás?', 3, 2, 3, 0, 'elfogadott'),
(80, 'Mi az ON DELETE CASCADE hatása?', 3, 2, 3, 0, 'elfogadott'),
(81, 'Mit jelent a NOT NULL kikötés?', 3, 2, 2, 0, 'elfogadott'),
(82, 'Mit csinál a DISTINCT?', 3, 2, 2, 0, 'elfogadott'),
(83, 'Mi a nézet (VIEW)?', 3, 2, 3, 0, 'elfogadott'),
(84, 'Mi a szekvencia (SEQUENCE)?', 3, 2, 3, 0, 'elfogadott'),
(85, 'Mire való a CHECK constraint?', 3, 2, 3, 0, 'elfogadott'),
(86, 'Mit jelent a tranzakciók visszagörgetése?', 3, 2, 3, 0, 'elfogadott'),
(87, 'Mit csinál a COMMIT?', 3, 2, 2, 0, 'elfogadott'),
(88, 'Mit csinál a ROLLBACK?', 3, 2, 2, 0, 'elfogadott'),
(89, 'Mi az index hátránya?', 3, 2, 3, 0, 'elfogadott'),
(90, 'Mi a stored procedure?', 3, 2, 3, 0, 'elfogadott'),
(91, 'Mi a trigger?', 3, 2, 3, 0, 'elfogadott'),
(92, 'Mire jó a FOREIGN KEY?', 3, 2, 2, 0, 'elfogadott'),
(93, 'Mi a DDL kategória?', 3, 2, 3, 0, 'elfogadott'),
(94, 'Melyik DDL parancs?', 3, 2, 2, 0, 'elfogadott'),
(95, 'Mit jelent a DML?', 3, 2, 2, 0, 'elfogadott'),
(96, 'Mi tartozik a DCL-be?', 3, 2, 2, 0, 'elfogadott'),
(97, 'Melyik parancs ad hozzá jogosultságot?', 3, 2, 2, 0, 'elfogadott'),
(98, 'Mit jelent a schema?', 3, 2, 3, 0, 'elfogadott'),
(99, 'Mi jellemző a denormalizálásra?', 3, 2, 3, 0, 'elfogadott'),
(100, 'Mi a tábla alias?', 3, 2, 2, 0, 'elfogadott'),
(101, 'Mit jelent az ORDER BY?', 3, 2, 2, 0, 'elfogadott'),
(102, 'Mi a HTML fő célja?', 5, 2, 2, 0, 'elfogadott'),
(103, 'Mit jelent a HTML rövidítés?', 5, 2, 2, 0, 'elfogadott'),
(104, 'Mit jelenít meg a <title> elem?', 5, 2, 2, 0, 'elfogadott'),
(105, 'Mi a <p> elem szerepe?', 5, 2, 2, 0, 'elfogadott'),
(106, 'Mit tesz a <br> elem?', 5, 2, 2, 0, 'elfogadott'),
(107, 'Melyik elem jelenít meg képet?', 5, 2, 2, 0, 'elfogadott'),
(108, 'Mit készít a <ul> elem?', 5, 2, 2, 0, 'elfogadott'),
(109, 'Mit jelöl a <li> elem?', 5, 2, 2, 0, 'elfogadott'),
(110, 'Mi a <div> elem alapvető szerepe?', 5, 2, 2, 0, 'elfogadott'),
(111, 'Mit jelent a <span> elem?', 5, 2, 2, 0, 'elfogadott'),
(112, 'Mit jelöl a <header> elem?', 5, 2, 2, 0, 'elfogadott'),
(113, 'Mit jelöl a <footer> elem?', 5, 2, 2, 0, 'elfogadott'),
(114, 'Mit jelöl a <nav> elem?', 5, 2, 2, 0, 'elfogadott'),
(115, 'Mit jelent az <a> elem?', 5, 2, 2, 0, 'elfogadott'),
(116, 'Melyik attribútum adja meg a link célját?', 5, 2, 2, 0, 'elfogadott'),
(117, 'Mit jelent a <table> elem?', 5, 2, 2, 0, 'elfogadott'),
(118, 'Mit jelent a <tr> elem?', 5, 2, 2, 0, 'elfogadott'),
(119, 'Mit jelent a <td> elem?', 5, 2, 2, 0, 'elfogadott'),
(120, 'Mit jelent a <th> elem?', 5, 2, 2, 0, 'elfogadott'),
(121, 'Mit jelent a colspan attribútum?', 5, 2, 2, 0, 'elfogadott'),
(122, 'Mit jelent a rowspan attribútum?', 5, 2, 2, 0, 'elfogadott'),
(123, 'Mit jelent a <form> elem?', 5, 2, 2, 0, 'elfogadott'),
(124, 'Mit jelent az input type=\"submit\"?', 5, 2, 2, 0, 'elfogadott'),
(125, 'Mit jelent a placeholder attribútum egy mezőben?', 5, 2, 2, 0, 'elfogadott'),
(126, 'Mit jelent a required attribútum?', 5, 2, 2, 0, 'elfogadott'),
(127, 'Mit jelent a <style> elem?', 5, 2, 2, 0, 'elfogadott'),
(128, 'Mit jelent a CSS?', 5, 2, 2, 0, 'elfogadott'),
(129, 'Mire való a class a HTML-ben?', 5, 2, 2, 0, 'elfogadott'),
(130, 'Mire való az id a HTML-ben?', 5, 2, 2, 0, 'elfogadott'),
(131, 'Hogyan jelölünk class-t CSS-ben?', 5, 2, 2, 0, 'elfogadott'),
(132, 'Mit jelent a display block tulajdonság?', 5, 2, 2, 0, 'elfogadott'),
(133, 'Mit jelent a display inline tulajdonság?', 5, 2, 2, 0, 'elfogadott'),
(134, 'Mit jelent a display flex tulajdonság?', 5, 2, 2, 0, 'elfogadott'),
(135, 'Mit jelent a justify content tulajdonság flexboxban?', 5, 2, 2, 0, 'elfogadott'),
(136, 'Mit jelent az align items tulajdonság?', 5, 2, 2, 0, 'elfogadott'),
(137, 'Mit határoz meg a position absolute?', 5, 2, 2, 0, 'elfogadott'),
(138, 'Mit jelent a position fixed?', 5, 2, 2, 0, 'elfogadott'),
(139, 'Mit szab meg a z index?', 5, 2, 2, 0, 'elfogadott'),
(140, 'Mire használjuk a float tulajdonságot?', 5, 2, 2, 0, 'elfogadott'),
(141, 'Mi tartozik a box model részei közé?', 5, 2, 2, 0, 'elfogadott'),
(142, 'Mit jelent a margin?', 5, 2, 2, 0, 'elfogadott'),
(143, 'Mit jelent a padding?', 5, 2, 2, 0, 'elfogadott'),
(144, 'Mit jelent a color tulajdonság?', 5, 2, 2, 0, 'elfogadott'),
(145, 'Mit állít be a background color?', 5, 2, 2, 0, 'elfogadott'),
(146, 'Mit jelent a font weight bold?', 5, 2, 2, 0, 'elfogadott'),
(147, 'Mit jelent a text decoration underline?', 5, 2, 2, 0, 'elfogadott'),
(148, 'Mit jelent a text align center?', 5, 2, 2, 0, 'elfogadott'),
(149, 'Mit jelent az iframe elem?', 5, 2, 2, 0, 'elfogadott'),
(150, 'Mit jelent a script elem?', 5, 2, 2, 0, 'elfogadott'),
(151, 'Mit jelent a responsive webdesign?', 5, 2, 2, 0, 'elfogadott'),
(152, 'Mit jelent a media lekérdezés használata CSS-ben?', 5, 2, 2, 0, 'elfogadott'),
(153, 'Mit jelent a vw mértékegység CSS-ben?', 5, 2, 2, 0, 'elfogadott'),
(154, 'Mit jelent a vh mértékegység CSS-ben?', 5, 2, 2, 0, 'elfogadott'),
(155, 'Mit jelent a rem egység?', 5, 2, 2, 0, 'elfogadott'),
(156, 'Mit jelent a background size cover?', 5, 2, 2, 0, 'elfogadott'),
(157, 'Mit jelent a background size contain?', 5, 2, 2, 0, 'elfogadott'),
(158, 'Mit jelent az opacity tulajdonság?', 5, 2, 2, 0, 'elfogadott'),
(159, 'Mit jelent az overflow hidden?', 5, 2, 2, 0, 'elfogadott'),
(160, 'Mit jelent a cursor pointer?', 5, 2, 2, 0, 'elfogadott'),
(161, 'Mit jelent a transition tulajdonság?', 5, 2, 2, 0, 'elfogadott'),
(162, 'Mit jelent a pseudo element before?', 5, 2, 2, 0, 'elfogadott'),
(163, 'Mit jelent a pseudo class hover?', 5, 2, 2, 0, 'elfogadott'),
(164, 'Mit jelent az alt attribútum képnél?', 5, 2, 2, 0, 'elfogadott'),
(165, 'Mit jelent a semantic HTML fogalma?', 5, 2, 2, 0, 'elfogadott'),
(166, 'Mit jelent a label elem egy űrlapban?', 5, 2, 2, 0, 'elfogadott'),
(167, 'Mit jelent az autocomplete attribútum űrlapban?', 5, 2, 2, 0, 'elfogadott'),
(168, 'Mit jelent a crossorigin attribútum?', 5, 2, 2, 0, 'elfogadott'),
(169, 'Mit jelent a HTML entity kifejezés?', 5, 2, 2, 0, 'elfogadott'),
(170, 'Melyik a helyes HTML komment?', 5, 2, 2, 0, 'elfogadott'),
(171, 'Mit jelent a CSS változó jelölése?', 5, 2, 2, 0, 'elfogadott'),
(172, 'Hogyan használjuk a CSS változót?', 5, 2, 2, 0, 'elfogadott'),
(173, 'Mit jelent a calc függvény CSS-ben?', 5, 2, 2, 0, 'elfogadott'),
(174, 'Mit jelent az object fit cover egy képen?', 5, 2, 2, 0, 'elfogadott'),
(175, 'Mit jelent a video elem?', 5, 2, 2, 0, 'elfogadott'),
(176, 'Mit jelent a video autoplay attribútum?', 5, 2, 2, 0, 'elfogadott'),
(177, 'Mit jelent az audio elem?', 5, 2, 2, 0, 'elfogadott'),
(178, 'Mit jelent az audio autoplay attribútum?', 5, 2, 2, 0, 'elfogadott'),
(179, 'Mit állít be a border radius tulajdonság?', 5, 2, 2, 0, 'elfogadott'),
(180, 'Mit jelent a box shadow tulajdonság?', 5, 2, 2, 0, 'elfogadott'),
(181, 'Mit jelent a font family tulajdonság?', 5, 2, 2, 0, 'elfogadott'),
(182, 'Mit jelent a list style type none érték?', 5, 2, 2, 0, 'elfogadott'),
(183, 'Mit jelent az outline tulajdonság?', 5, 2, 2, 0, 'elfogadott'),
(184, 'Mit jelent a min width tulajdonság?', 5, 2, 2, 0, 'elfogadott'),
(185, 'Mit jelent a max width tulajdonság?', 5, 2, 2, 0, 'elfogadott'),
(186, 'Mit jelent a min height tulajdonság?', 5, 2, 2, 0, 'elfogadott'),
(187, 'Mit jelent a max height tulajdonság?', 5, 2, 2, 0, 'elfogadott'),
(188, 'Mit jelent a white space nowrap?', 5, 2, 2, 0, 'elfogadott'),
(189, 'Mit jelent a text transform uppercase?', 5, 2, 2, 0, 'elfogadott'),
(190, 'Mit jelent a text transform lowercase?', 5, 2, 2, 0, 'elfogadott'),
(191, 'Mit jelent a letter spacing tulajdonság?', 5, 2, 2, 0, 'elfogadott'),
(192, 'Mit jelent a line height tulajdonság?', 5, 2, 2, 0, 'elfogadott'),
(193, 'Mit jelent a visibility hidden tulajdonság?', 5, 2, 2, 0, 'elfogadott'),
(194, 'Mit jelent a display none?', 5, 2, 2, 0, 'elfogadott'),
(195, 'Mit jelent a pointer events none?', 5, 2, 2, 0, 'elfogadott'),
(196, 'Mit jelent a filter blur érték?', 5, 2, 2, 0, 'elfogadott'),
(197, 'Mit jelent a filter grayscale érték?', 5, 2, 2, 0, 'elfogadott'),
(198, 'Mit jelent a transform rotate érték?', 5, 2, 2, 0, 'elfogadott'),
(199, 'Mit jelent a transform scale érték?', 5, 2, 2, 0, 'elfogadott'),
(200, 'Mit jelent a transform translate érték?', 5, 2, 2, 0, 'elfogadott'),
(201, 'Mit jelent a grid display használata?', 5, 2, 2, 0, 'elfogadott'),
(202, 'Mit jelent a grid template columns tulajdonság?', 5, 2, 2, 0, 'elfogadott'),
(203, 'Mit jelent a justify items tulajdonság grid esetén?', 5, 2, 2, 0, 'elfogadott'),
(204, 'Mit jelent a aspect ratio tulajdonság?', 5, 2, 2, 0, 'elfogadott'),
(205, 'Mire való a Bootstrap rendszer?', 5, 2, 2, 0, 'elfogadott'),
(206, 'Melyik CDN szolgál Bootstrap stíluslap betöltésére?', 5, 2, 2, 0, 'elfogadott'),
(207, 'Mit jelent a container osztály?', 5, 2, 2, 0, 'elfogadott'),
(208, 'Mit jelent a container fluid osztály?', 5, 2, 2, 0, 'elfogadott'),
(209, 'Mit jelent a row osztály?', 5, 2, 2, 0, 'elfogadott'),
(210, 'Mit jelent a col osztály?', 5, 2, 2, 0, 'elfogadott'),
(211, 'Mit ad meg a g osztály?', 5, 2, 2, 0, 'elfogadott'),
(212, 'Melyik jelöli a kis képernyőkre vonatkozó oszloptörést?', 5, 2, 2, 0, 'elfogadott'),
(213, 'Mit jelent a d none osztály?', 5, 2, 2, 0, 'elfogadott'),
(214, 'Mit jelent a d block osztály?', 5, 2, 2, 0, 'elfogadott'),
(215, 'Mit jelent a d flex osztály?', 5, 2, 2, 0, 'elfogadott'),
(216, 'Mit jelent az align items center osztály?', 5, 2, 2, 0, 'elfogadott'),
(217, 'Mit jelent a justify content center osztály?', 5, 2, 2, 0, 'elfogadott'),
(218, 'Mit jelent a m 3 osztály?', 5, 2, 2, 0, 'elfogadott'),
(219, 'Mit jelent a p 2 osztály?', 5, 2, 2, 0, 'elfogadott'),
(220, 'Mit jelent a text center osztály?', 5, 2, 2, 0, 'elfogadott'),
(221, 'Mit jelent a text end osztály?', 5, 2, 2, 0, 'elfogadott'),
(222, 'Mit jelent a bg primary osztály?', 5, 2, 2, 0, 'elfogadott'),
(223, 'Mit jelent az alert osztály?', 5, 2, 2, 0, 'elfogadott'),
(224, 'Mit jelent az alert danger osztály?', 5, 2, 2, 0, 'elfogadott'),
(225, 'Mit jelent a btn osztály?', 5, 2, 2, 0, 'elfogadott'),
(226, 'Mit jelent a btn primary osztály?', 5, 2, 2, 0, 'elfogadott'),
(227, 'Mit jelent a btn outline primary osztály?', 5, 2, 2, 0, 'elfogadott'),
(228, 'Mit jelent a navbar osztály?', 5, 2, 2, 0, 'elfogadott'),
(229, 'Mit jelent a navbar brand osztály?', 5, 2, 2, 0, 'elfogadott'),
(230, 'Mit jelent a card osztály?', 5, 2, 2, 0, 'elfogadott'),
(231, 'Mit jelent a card body osztály?', 5, 2, 2, 0, 'elfogadott'),
(232, 'Mit jelent az accordion osztály?', 5, 2, 2, 0, 'elfogadott'),
(233, 'Mit jelent a modal komponens?', 5, 2, 2, 0, 'elfogadott'),
(234, 'Mit jelent a progress osztály?', 5, 2, 2, 0, 'elfogadott'),
(235, 'Mit jelent a spinner border osztály?', 5, 2, 2, 0, 'elfogadott'),
(236, 'Mit jelent a main elem HTML5-ben?', 5, 2, 2, 0, 'elfogadott'),
(237, 'Mit jelent az article elem HTML5-ben?', 5, 2, 2, 0, 'elfogadott'),
(238, 'Mit jelent a section elem HTML5-ben?', 5, 2, 2, 0, 'elfogadott'),
(239, 'Mit jelent az aside elem?', 5, 2, 2, 0, 'elfogadott'),
(240, 'Mit jelent a figure elem?', 5, 2, 2, 0, 'elfogadott'),
(241, 'Mit jelent a figcaption elem?', 5, 2, 2, 0, 'elfogadott'),
(242, 'Mit jelent a video controls attribútum?', 5, 2, 2, 0, 'elfogadott'),
(243, 'Mit jelent a track elem?', 5, 2, 2, 0, 'elfogadott'),
(244, 'Mit jelent az audio loop attribútum?', 5, 2, 2, 0, 'elfogadott'),
(245, 'Mit jelent az input type email?', 5, 2, 2, 0, 'elfogadott'),
(246, 'Mit jelent az input type date?', 5, 2, 2, 0, 'elfogadott'),
(247, 'Mit jelent az input type range?', 5, 2, 2, 0, 'elfogadott'),
(248, 'Mit jelent a required attribútum HTML5-ben?', 5, 2, 2, 0, 'elfogadott'),
(249, 'Mit jelent a pattern attribútum?', 5, 2, 2, 0, 'elfogadott'),
(250, 'Mit jelent a placeholder attribútum?', 5, 2, 2, 0, 'elfogadott'),
(251, 'Mit jelent a CSS3 border radius tulajdonság?', 5, 2, 2, 0, 'elfogadott'),
(252, 'Mit jelent a linear gradient háttér?', 5, 2, 2, 0, 'elfogadott'),
(253, 'Mit jelent a radial gradient?', 5, 2, 2, 0, 'elfogadott'),
(254, 'Mit jelent az animation name tulajdonság?', 5, 2, 2, 0, 'elfogadott'),
(255, 'Mit jelent az animation duration?', 5, 2, 2, 0, 'elfogadott'),
(256, 'Mit jelent az animation iteration count?', 5, 2, 2, 0, 'elfogadott'),
(257, 'Mit jelent a transform translate?', 5, 2, 2, 0, 'elfogadott'),
(258, 'Mit jelent a transform rotate?', 5, 2, 2, 0, 'elfogadott'),
(259, 'Mit jelent a transform scale?', 5, 2, 2, 0, 'elfogadott'),
(260, 'Mit jelent a flex direction row?', 5, 2, 2, 0, 'elfogadott'),
(261, 'Mit jelent a flex direction column?', 5, 2, 2, 0, 'elfogadott'),
(262, 'Mit jelent a justify content space between?', 5, 2, 2, 0, 'elfogadott'),
(263, 'Mit jelent a align items stretch?', 5, 2, 2, 0, 'elfogadott'),
(264, 'Mit jelent a grid template rows tulajdonság?', 5, 2, 2, 0, 'elfogadott'),
(265, 'Mit jelent a JavaScript futtatási környezete a böngészőben?', 4, 2, 2, 0, 'elfogadott'),
(266, 'Melyik helyes változódeklaráció?', 4, 2, 2, 0, 'elfogadott'),
(267, 'Mit jelent a let kulcsszó?', 4, 2, 2, 0, 'elfogadott'),
(268, 'Mit jelent a const kulcsszó?', 4, 2, 2, 0, 'elfogadott'),
(269, 'Melyik a helyes mód függvény létrehozására?', 4, 2, 2, 0, 'elfogadott'),
(270, 'Mit jelent a return utasítás?', 4, 2, 2, 0, 'elfogadott'),
(271, 'Mit jelent az if feltétel?', 4, 2, 2, 0, 'elfogadott'),
(272, 'Mit jelent az else ág?', 4, 2, 2, 0, 'elfogadott'),
(273, 'Mit jelent a switch szerkezet?', 4, 2, 2, 0, 'elfogadott'),
(274, 'Mit jelent a for ciklus?', 4, 2, 2, 0, 'elfogadott'),
(275, 'Mit jelent a while ciklus?', 4, 2, 2, 0, 'elfogadott'),
(276, 'Mit jelent a do while ciklus?', 4, 2, 2, 0, 'elfogadott'),
(277, 'Mit jelent a strict mode?', 4, 2, 2, 0, 'elfogadott'),
(278, 'Mit jelent a JSON formátum?', 4, 2, 2, 0, 'elfogadott'),
(279, 'Mire való a JSON parse?', 4, 2, 2, 0, 'elfogadott'),
(280, 'Mire való a JSON stringify?', 4, 2, 2, 0, 'elfogadott'),
(281, 'Mit jelent a tömb JavaScriptben?', 4, 2, 2, 0, 'elfogadott'),
(282, 'Melyik tömb létrehozása helyes?', 4, 2, 2, 0, 'elfogadott'),
(283, 'Mit csinál a push metódus?', 4, 2, 2, 0, 'elfogadott'),
(284, 'Mit csinál a pop metódus?', 4, 2, 2, 0, 'elfogadott'),
(285, 'Mit csinál a shift metódus?', 4, 2, 2, 0, 'elfogadott'),
(286, 'Mit csinál az unshift metódus?', 4, 2, 2, 0, 'elfogadott'),
(287, 'Mit csinál a map metódus?', 4, 2, 2, 0, 'elfogadott'),
(288, 'Mit csinál a filter metódus?', 4, 2, 2, 0, 'elfogadott'),
(289, 'Mit csinál a reduce metódus?', 4, 2, 2, 0, 'elfogadott'),
(290, 'Mit jelent a callback függvény?', 4, 2, 2, 0, 'elfogadott'),
(291, 'Mit jelent az arrow function?', 4, 2, 2, 0, 'elfogadott'),
(292, 'Mit jelent a this kulcsszó?', 4, 2, 2, 0, 'elfogadott'),
(293, 'Mit jelent az objektum JavaScriptben?', 4, 2, 2, 0, 'elfogadott'),
(294, 'Melyik az objektum létrehozása helyesen?', 4, 2, 2, 0, 'elfogadott'),
(295, 'Mit jelent a DOM?', 4, 2, 2, 0, 'elfogadott'),
(296, 'Mit jelent a document getElementById?', 4, 2, 2, 0, 'elfogadott'),
(297, 'Mit jelent a querySelector?', 4, 2, 2, 0, 'elfogadott'),
(298, 'Mit jelent az event handler?', 4, 2, 2, 0, 'elfogadott'),
(299, 'Mit jelent a click esemény?', 4, 2, 2, 0, 'elfogadott'),
(300, 'Mit jelent a preventDefault?', 4, 2, 2, 0, 'elfogadott'),
(301, 'Mit jelent a stopPropagation?', 4, 2, 2, 0, 'elfogadott'),
(302, 'Mit jelent a promise?', 4, 2, 2, 0, 'elfogadott'),
(303, 'Mit jelent az async kulcsszó?', 4, 2, 2, 0, 'elfogadott'),
(304, 'Mit jelent az await kulcsszó?', 4, 2, 2, 0, 'elfogadott'),
(305, 'Mit jelent a fetch?', 4, 2, 2, 0, 'elfogadott'),
(306, 'Mit ad vissza a typeof operátor?', 4, 2, 2, 0, 'elfogadott'),
(307, 'Mit jelent a NaN érték?', 4, 2, 2, 0, 'elfogadott'),
(308, 'Mit jelent az undefined?', 4, 2, 2, 0, 'elfogadott'),
(309, 'Mit jelent az == operátor?', 4, 2, 2, 0, 'elfogadott'),
(310, 'Mit jelent a === operátor?', 4, 2, 2, 0, 'elfogadott'),
(311, 'Mit jelent a spread operátor?', 4, 2, 2, 0, 'elfogadott'),
(312, 'Mit jelent a destructuring?', 4, 2, 2, 0, 'elfogadott'),
(313, 'Mit jelent a setTimeout?', 4, 2, 2, 0, 'elfogadott'),
(314, 'Mit jelent a JSON parse metódus?', 4, 2, 2, 0, 'elfogadott'),
(315, 'Mit jelent a JSON stringify metódus?', 4, 2, 2, 0, 'elfogadott'),
(316, 'Hogyan hozható létre üres tömb?', 4, 2, 2, 0, 'elfogadott'),
(317, 'Mit csinál a splice metódus?', 4, 2, 2, 0, 'elfogadott'),
(318, 'Mit csinál a slice metódus?', 4, 2, 2, 0, 'elfogadott'),
(319, 'Hogyan hozható létre üres objektum?', 4, 2, 2, 0, 'elfogadott'),
(320, 'Mit jelent az objektum property fogalma?', 4, 2, 2, 0, 'elfogadott'),
(321, 'Hogyan érjük el az objektum property értékét pont jelöléssel?', 4, 2, 2, 0, 'elfogadott'),
(322, 'Hogyan érjük el az objektum propertyt szögletes zárójelekkel?', 4, 2, 2, 0, 'elfogadott'),
(323, 'Mit jelent a nested object?', 4, 2, 2, 0, 'elfogadott'),
(324, 'Mit jelent a for in ciklus objektumnál?', 4, 2, 2, 0, 'elfogadott'),
(325, 'Mit jelent a hasOwnProperty metódus?', 4, 2, 2, 0, 'elfogadott'),
(326, 'Mit jelent az Object keys metódus?', 4, 2, 2, 0, 'elfogadott'),
(327, 'Mit jelent az Object values metódus?', 4, 2, 2, 0, 'elfogadott'),
(328, 'Mit jelent az Object entries metódus?', 4, 2, 2, 0, 'elfogadott'),
(329, 'Mit jelent a deep copy objektumokra?', 4, 2, 2, 0, 'elfogadott'),
(330, 'Mit jelent a shallow copy objektumoknál?', 4, 2, 2, 0, 'elfogadott'),
(331, 'Mit jelent a structuredClone?', 4, 2, 2, 0, 'elfogadott'),
(332, 'Mit jelent a JSON alapú másolás objektumokra?', 4, 2, 2, 0, 'elfogadott'),
(333, 'Mit jelent a tömb spread szintaxisa?', 4, 2, 2, 0, 'elfogadott'),
(334, 'Mit jelent az objektum spread szintaxisa?', 4, 2, 2, 0, 'elfogadott'),
(335, 'Mit jelent a length tulajdonság egy tömbnél?', 4, 2, 2, 0, 'elfogadott'),
(336, 'Mit csinál a includes metódus?', 4, 2, 2, 0, 'elfogadott'),
(337, 'Mit csinál az indexOf metódus?', 4, 2, 2, 0, 'elfogadott'),
(338, 'Mit csinál a lastIndexOf metódus?', 4, 2, 2, 0, 'elfogadott'),
(339, 'Mit csinál a sort metódus?', 4, 2, 2, 0, 'elfogadott'),
(340, 'Mit csinál a reverse metódus?', 4, 2, 2, 0, 'elfogadott'),
(341, 'Mit csinál a concat metódus?', 4, 2, 2, 0, 'elfogadott'),
(342, 'Mit csinál a join metódus?', 4, 2, 2, 0, 'elfogadott'),
(343, 'Mit csinál az every metódus?', 4, 2, 2, 0, 'elfogadott'),
(344, 'Mit csinál a some metódus?', 4, 2, 2, 0, 'elfogadott'),
(345, 'Mit csinál a forEach metódus?', 4, 2, 2, 0, 'elfogadott'),
(346, 'Mit csinál a find metódus?', 4, 2, 2, 0, 'elfogadott'),
(347, 'Mit csinál a findIndex metódus?', 4, 2, 2, 0, 'elfogadott'),
(348, 'Mit csinál a fill metódus?', 4, 2, 2, 0, 'elfogadott'),
(349, 'Mit csinál a flat metódus?', 4, 2, 2, 0, 'elfogadott'),
(350, 'Mit csinál a flatMap metódus?', 4, 2, 2, 0, 'elfogadott'),
(351, 'Mit jelent a spread operator tömbök esetén?', 4, 2, 2, 0, 'elfogadott'),
(352, 'Mit jelent a destructuring tömböknél?', 4, 2, 2, 0, 'elfogadott'),
(353, 'Mit csinál a copyWithin metódus?', 4, 2, 2, 0, 'elfogadott'),
(354, 'Mit jelent a toSorted metódus?', 4, 2, 2, 0, 'elfogadott'),
(355, 'Mit jelent az ECMAScript szabvány?', 4, 2, 2, 0, 'elfogadott'),
(356, 'Melyik évben jelent meg az ES6?', 4, 2, 2, 0, 'elfogadott'),
(357, 'Mit hozott be az ES6 az alábbiak közül?', 4, 2, 2, 0, 'elfogadott'),
(358, 'Melyik az arrow function helyes alakja?', 4, 2, 2, 0, 'elfogadott');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `feladat_tipusok`
--

CREATE TABLE `feladat_tipusok` (
  `id` tinyint(3) UNSIGNED NOT NULL,
  `megnevezes` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

--
-- A tábla adatainak kiíratása `feladat_tipusok`
--

INSERT INTO `feladat_tipusok` (`id`, `megnevezes`) VALUES
(1, 'Eldöntendő'),
(2, 'Egy jó válasz'),
(3, 'Több jó válasz'),
(4, 'Konkrét válasz');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `kategoriak`
--

CREATE TABLE `kategoriak` (
  `id` tinyint(3) UNSIGNED NOT NULL,
  `megnevezes` varchar(50) NOT NULL,
  `engedelyezett` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

--
-- A tábla adatainak kiíratása `kategoriak`
--

INSERT INTO `kategoriak` (`id`, `megnevezes`, `engedelyezett`) VALUES
(1, 'OOP', 1),
(2, 'Tiszta kód', 1),
(3, 'Adatbázis', 1),
(4, 'JavaScript', 1),
(5, 'HTML, HTML5, CSS, CSS3', 1);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `kepek`
--

CREATE TABLE `kepek` (
  `id` int(10) UNSIGNED NOT NULL,
  `kep` longtext NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `nem_semmi`
--

CREATE TABLE `nem_semmi` (
  `id` int(11) NOT NULL,
  `megn` varchar(30) NOT NULL,
  `ar` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

--
-- A tábla adatainak kiíratása `nem_semmi`
--

INSERT INTO `nem_semmi` (`id`, `megn`, `ar`) VALUES
(1, 'alma', 700),
(2, 'eper', 4000),
(3, 'csoki', 700),
(4, 'citrom', 1000),
(5, 'zsemle', 700);

-- --------------------------------------------------------

--
-- A nézet helyettes szerkezete `random_kerdesek`
-- (Lásd alább az aktuális nézetet)
--
CREATE TABLE `random_kerdesek` (
`id` int(10) unsigned
,`leiras` tinytext
,`pontszam` tinyint(3) unsigned
,`tipus` varchar(30)
,`kategoria` varchar(50)
);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `tesztek`
--

CREATE TABLE `tesztek` (
  `id` int(10) UNSIGNED NOT NULL,
  `megnevezes` varchar(50) NOT NULL,
  `ertekeles_id` tinyint(3) UNSIGNED NOT NULL,
  `veletlen_sorrendu_feladatok` tinyint(1) NOT NULL,
  `veletlen_sorrendu_valaszok` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `tesztek_feladatai`
--

CREATE TABLE `tesztek_feladatai` (
  `id` int(10) UNSIGNED NOT NULL,
  `teszt_id` int(10) UNSIGNED NOT NULL,
  `feladat_id` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

-- --------------------------------------------------------

--
-- A nézet helyettes szerkezete `valami`
-- (Lásd alább az aktuális nézetet)
--
CREATE TABLE `valami` (
`id` int(10) unsigned
,`leiras` tinytext
,`pontszam` tinyint(3) unsigned
,`tipus` varchar(30)
,`kategoria` varchar(50)
);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `valaszok`
--

CREATE TABLE `valaszok` (
  `id` int(10) UNSIGNED NOT NULL,
  `feladat_id` int(10) UNSIGNED NOT NULL,
  `leiras` tinytext NOT NULL,
  `helyes_e` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

--
-- A tábla adatainak kiíratása `valaszok`
--

INSERT INTO `valaszok` (`id`, `feladat_id`, `leiras`, `helyes_e`) VALUES
(1, 1, 'Egy algoritmus lépéseinek felsorolása', 0),
(2, 1, 'A program teljes futásának vezérlése', 0),
(3, 1, 'Objektumok tervrajzának, adattagjainak és metódusainak definiálása', 1),
(4, 1, 'Csak adattípusok tárolása', 0),
(5, 2, 'Új objektum létrehozása paraméter nélkül', 0),
(6, 2, 'Egy osztály képessége, hogy átvegye egy másik osztály tulajdonságait és metódusait', 1),
(7, 2, 'Egy metódus túlterhelése többféle paraméterrel', 0),
(8, 2, 'Objektumok futásidejű létrehozása', 0),
(9, 2, 'Osztályok közti teljes izoláció', 0),
(10, 3, 'Azonos nevű függvények különböző módon viselkedhetnek', 1),
(11, 3, 'Egy osztály több ősosztályból származik', 0),
(12, 3, 'Csak egyetlen metódus lehet egy osztályban', 0),
(13, 3, 'Objektumok nem példányosíthatók', 0),
(14, 4, 'A kód teljes elrejtése a fordító elől', 0),
(15, 4, 'Az adatok és a hozzájuk tartozó műveletek egységbe zárása', 1),
(16, 4, 'Programok futási sebességének növelése', 0),
(17, 4, 'Öröklési hierarchia létrehozása', 0),
(18, 5, 'Metódus-átadás', 0),
(19, 5, 'Metódus-túlterhelés', 1),
(20, 5, 'Metódus-túlírás', 0),
(21, 5, 'Metódus-beágyazás', 0),
(22, 6, 'Új metódus létrehozása azonos névvel, más osztályban, eltérő működéssel', 1),
(23, 6, 'Adattag elrejtése a névtérből', 0),
(24, 6, 'Két metódus összevonása', 0),
(25, 6, 'Egy metódus törlése az ősosztályból', 0),
(26, 7, 'Nem lehet példányosítani', 1),
(27, 7, 'Nem tartalmazhat metódust', 0),
(28, 7, 'Csak privát adattagjai lehetnek', 0),
(29, 7, 'Minden metódusa kötelezően absztrakt', 0),
(30, 7, 'Csak interfészből származhat', 0),
(31, 8, 'Csak adattagokat tartalmaz', 0),
(32, 8, 'Csak metódusok nevét és aláírását írja elő, implementáció nélkül', 1),
(33, 8, 'Bármelyik metódusa lehet privát', 0),
(34, 8, 'Teljesen végrehajtott logikát tartalmaz', 0),
(35, 9, 'Egy osztály példányának előkészítésére szolgáló speciális metódus', 1),
(36, 9, 'Objektum törlését végző metódus', 0),
(37, 9, 'Öröklést tiltó kulcsszó', 0),
(38, 9, 'Adatmezők elrejtése', 0),
(39, 10, 'Objektum létrehozása', 0),
(40, 10, 'Objektum erőforrásainak felszabadítása a megsemmisítés során', 1),
(41, 10, 'Metódusok összevonása', 0),
(42, 10, 'Osztályok közti kapcsolat létrehozása', 0),
(43, 11, 'Kompozíciót két objektum között', 0),
(44, 11, 'Öröklési viszonyt, ahol egy osztály egy másik speciális esete', 1),
(45, 11, 'Két objektum egyenlőségét', 0),
(46, 11, 'Független modulok kapcsolatát', 0),
(47, 12, 'Egy objektum az élettartama során nem függ más objektumoktól', 0),
(48, 12, 'Egy objektum tartalmaz egy másik objektumot, amely nélkül nem létezhet', 1),
(49, 12, 'Két osztály közös ősosztályt kap', 0),
(50, 12, 'Azonos nevű változók összevonása', 0),
(51, 12, 'Csak statikus tagok használata', 0),
(52, 13, 'Minden osztályból látható', 0),
(53, 13, 'Csak az adott osztály metódusai érhetik el', 1),
(54, 13, 'A csomag összes eleme elérheti', 0),
(55, 13, 'Minden leszármazott automatikusan használhatja', 0),
(56, 14, 'Csak példányon keresztül érhető el', 0),
(57, 14, 'A saját osztály és a leszármazottak is elérhetik', 1),
(58, 14, 'Bárhonnan olvasható', 0),
(59, 14, 'Semmilyen körülmények között nem érhető el', 0),
(60, 15, 'Absztrakció', 0),
(61, 15, 'Polimorfizmus', 0),
(62, 15, 'Enkapszuláció', 0),
(63, 15, 'Rekurzió', 1),
(64, 16, 'Minden példánynak saját külön másolata van', 0),
(65, 16, 'Az egész osztályhoz tartozik, nem az egyes példányokhoz', 1),
(66, 16, 'Nem inicializálható', 0),
(67, 16, 'Mindig privát láthatóságú', 0),
(68, 16, 'Csak örökölt formában érhető el', 0),
(69, 17, 'Teljes kód elrejtése', 0),
(70, 17, 'A lényegtelen részletek elhagyása és a fontos tulajdonságok kiemelése', 1),
(71, 17, 'Kódoptimalizálás', 0),
(72, 17, 'Adatbázis-kezelés', 0),
(73, 18, 'Semmi, az osztály így is példányosítható', 0),
(74, 18, 'Az osztály automatikusan kap alapértelmezett metódusokat', 0),
(75, 18, 'Az osztálynak is absztrakttá kell válnia', 1),
(76, 18, 'Az interfész módosul', 0),
(77, 19, 'Final metódus nem definiálható', 0),
(78, 19, 'Final osztály örökölhető', 0),
(79, 19, 'Final metódus nem írható felül', 1),
(80, 19, 'Final adattag mindig változtatható', 0),
(81, 20, 'Értéket módosító metódus', 0),
(82, 20, 'Egy objektum törléséért felelős metódus', 0),
(83, 20, 'Egy privát adattag értékét lekérdező metódus', 1),
(84, 20, 'Futási hibákat kezelő metódus', 0),
(85, 21, 'Hogy egy osztályból többféle módon lehessen példányt létrehozni', 1),
(86, 21, 'Hogy megakadályozza az öröklést', 0),
(87, 21, 'Hogy véglegesítse az osztály metódusait', 0),
(88, 21, 'Hogy automatikusan törölje az objektumokat', 0),
(89, 22, 'Egy futó programfolyamat', 0),
(90, 22, 'Az osztály alapján létrehozott konkrét objektum', 1),
(91, 22, 'Egy névtér leírása', 0),
(92, 22, 'Egy interfész definíciója', 0),
(93, 23, 'Egy privát adattag értékének megváltoztatása', 1),
(94, 23, 'Konstruktorok meghívása', 0),
(95, 23, 'Öröklés tiltása', 0),
(96, 23, 'Metódusok túlterhelése', 0),
(97, 24, 'Ha két különböző programfájl tartalmaz adattagot', 0),
(98, 24, 'Ha ugyanabban a névtérben két elem azonos néven szerepel', 1),
(99, 24, 'Ha két objektum egyszerre fut', 0),
(100, 24, 'Ha két metódus különböző osztályokban van', 0),
(101, 25, 'Automatikus öröklést', 0),
(102, 25, 'A névütközések elkerülését', 1),
(103, 25, 'Kód automatikus optimalizálását', 0),
(104, 25, 'Objektumok automatikus megsemmisítését', 0),
(105, 26, 'Kevesebb memóriát használ', 0),
(106, 26, 'Különböző paraméterezésű metódusok hozhatók létre ugyanazzal a névvel', 1),
(107, 26, 'Megakadályozza a polimorfizmust', 0),
(108, 26, 'Csak privát metódusok esetén alkalmazható', 0),
(109, 27, 'A metódus hívása fordítási időben dől el', 0),
(110, 27, 'A metódus hívása futási időben dől el', 1),
(111, 27, 'Az osztályok közti kapcsolat kódszinten megsemmisül', 0),
(112, 27, 'A változók típusa futás közben módosítható', 0),
(113, 27, 'A program memóriakezelése automatikussá válik', 0),
(114, 28, 'Nem örökölhet más osztályból', 0),
(115, 28, 'Más osztályok származhatnak belőle', 1),
(116, 28, 'Mindig absztrakt', 0),
(117, 28, 'Nem tartalmazhat publikus metódust', 0),
(118, 29, 'A program lassítása', 0),
(119, 29, 'A fejlesztés egyszerűsítése és gyorsítása', 1),
(120, 29, 'A fölösleges osztályok létrehozása', 0),
(121, 29, 'Az öröklés tiltása', 0),
(122, 30, 'Olyan változó, amely az osztály összes példánya között közös', 0),
(123, 30, 'Olyan változó, amely minden példány esetén külön értékkel rendelkezik', 1),
(124, 30, 'Csak statikus metódusból érhető el', 0),
(125, 30, 'Nem inicializálható', 0),
(126, 31, 'Az osztály több ősosztályt kap', 0),
(127, 31, 'Az osztály többféle paraméterrel példányosítható', 1),
(128, 31, 'Az öröklési hierarchia megszűnik', 0),
(129, 31, 'A metódusok automatikusan felüldefiniálódnak', 0),
(130, 32, 'A példányosítás tiltása', 0),
(131, 32, 'Az öröklés megakadályozása', 1),
(132, 32, 'A polimorfizmus erősítése', 0),
(133, 32, 'A memóriakezelés gyorsítása', 0),
(134, 33, 'Az osztályok közti öröklődési és kapcsolati struktúra', 1),
(135, 33, 'A program futási idejének listája', 0),
(136, 33, 'Csak a privát metódusok felsorolása', 0),
(137, 33, 'A változók memóriafoglalása', 0),
(138, 34, 'A statikus kötés megakadályozása', 0),
(139, 34, 'A leszármazottak számára felüldefiniálható metódus biztosítása', 1),
(140, 34, 'Objektumok törlése', 0),
(141, 34, 'Az interfészek összefésülése', 0),
(142, 34, 'A névterek automatikus létrehozása', 0),
(143, 35, 'Olyan metódus, amely nem tartalmaz implementációt', 1),
(144, 35, 'Olyan metódus, amelyet nem lehet felüldefiniálni', 0),
(145, 35, 'Olyan metódus, amely automatikusan statikus', 0),
(146, 35, 'Olyan metódus, amely csak privát lehet', 0),
(147, 36, 'Öröklési kapcsolat létrehozását', 0),
(148, 36, 'Objektum létrehozását egy osztály alapján', 1),
(149, 36, 'Változók elrejtését', 0),
(150, 36, 'Adattípusok konvertálását', 0),
(151, 37, 'Az interfész teljes implementációt tartalmaz', 0),
(152, 37, 'Az absztrakt osztály tartalmazhat implementációt, az interfész nem', 1),
(153, 37, 'Az interfész példányosítható', 0),
(154, 37, 'Az absztrakt osztály nem örökölhet', 0),
(155, 37, 'Az interfész csak privát metódusokat tartalmazhat', 0),
(156, 38, 'Csökkenti a kód olvashatóságát', 0),
(157, 38, 'Biztonságossá teszi az adattagokat és elrejti a belső működést', 1),
(158, 38, 'Megszünteti a konstruktorokat', 0),
(159, 38, 'Megakadályozza a metódusok hívását', 0),
(160, 39, 'Öröklési viszony', 0),
(161, 39, 'Aggregáció vagy kompozíció egy objektum és egy másik között', 1),
(162, 39, 'Teljes izoláció két osztály között', 0),
(163, 39, 'Statikus metódus hívása', 0),
(164, 40, 'A részek az egész nélkül nem létezhetnek', 0),
(165, 40, 'Laza kapcsolat, ahol az egész és a rész külön is létezhet', 1),
(166, 40, 'Nem hozható létre objektum', 0),
(167, 40, 'Csak privát adattagok esetén alkalmazható', 0),
(168, 40, 'A kód futási sebessége nő', 0),
(169, 41, 'A metódus neve és paraméterlistája', 1),
(170, 41, 'A metódus neve és törzse', 0),
(171, 41, 'Csak a paraméterek típusa', 0),
(172, 41, 'Csak a visszatérési típus', 0),
(173, 42, 'Futásidejű', 0),
(174, 42, 'Fordításidejű', 0),
(175, 42, 'Statikus adattag', 1),
(176, 42, 'Metódus-túlterhelés', 0),
(177, 43, 'Csak példányon keresztül érhető el', 0),
(178, 43, 'Az osztályhoz tartozik és nem igényel példányosítást a hívásához', 1),
(179, 43, 'Nem használhat változókat', 0),
(180, 43, 'Mindig privát', 0),
(181, 44, 'Statikus adattag inicializálását', 0),
(182, 44, 'Az ősosztályban lévő metódus újraimplementálását a leszármazottban', 1),
(183, 44, 'Azonos nevű metódusok létrehozását külön paraméterekkel', 0),
(184, 44, 'Objektumok törlését', 0),
(185, 45, 'A program sikeresen fut tovább', 0),
(186, 45, 'Fordítási vagy futási hiba keletkezik', 1),
(187, 45, 'Automatikusan nyilvánossá válik', 0),
(188, 45, 'Az osztály átíródik', 0),
(189, 46, 'A példányváltozó deklarációjára', 0),
(190, 46, 'Az ősosztály tagjainak elérésére', 1),
(191, 46, 'Az interfészek összefűzésére', 0),
(192, 46, 'Statikus metódusok jelölésére', 0),
(193, 47, 'A program futási idejének mérésére', 0),
(194, 47, 'Objektumok és osztályok kapcsolatainak ábrázolására', 1),
(195, 47, 'A kód optimalizálására', 0),
(196, 47, 'A memóriakezelés nyomon követésére', 0),
(197, 47, 'Hálózati kapcsolatok leírására', 0),
(198, 48, 'Módosítható az állapota', 0),
(199, 48, 'Létrehozás után nem változik az állapota', 1),
(200, 48, 'Nem példányosítható', 0),
(201, 48, 'Mindig absztrakt', 0),
(202, 49, 'Egy objektum ősosztályba való konvertálása', 0),
(203, 49, 'Egy objektum leszármazott típusra alakítása', 1),
(204, 49, 'Objektum adattagjainak törlése', 0),
(205, 49, 'Statikus típus ellenőrzés megszüntetése', 0),
(206, 49, 'A névterek összevonása', 0),
(207, 50, 'Objektum törlése', 0),
(208, 50, 'Objektum szöveges reprezentációjának előállítása', 1),
(209, 50, 'Statikus adattagok listázása', 0),
(210, 50, 'Öröklés megakadályozása', 0),
(211, 51, 'Hogy elrejtsük az adattagokat', 0),
(212, 51, 'Hogy közös viselkedést írjunk elő különböző osztályok számára', 1),
(213, 51, 'Hogy példányosíthatóvá tegyünk osztályokat', 0),
(214, 51, 'Hogy automatikusan létrehozzuk a konstruktorokat', 0),
(215, 52, 'Az adatok átmeneti tárolása futás közben', 0),
(216, 52, 'Nagy mennyiségű adat tartós és rendezett tárolása', 1),
(217, 52, 'Programok futási idejének csökkentése', 0),
(218, 52, 'Grafikus felület létrehozása', 0),
(219, 53, 'Adatok hálós elrendezésben tárolása', 0),
(220, 53, 'Adatok táblázatos formában, kapcsolatokkal való tárolása', 1),
(221, 53, 'Csak hierarchikus adatszerkezetek használata', 0),
(222, 53, 'Kizárólag fájl alapú adatok kezelése', 0),
(223, 54, 'Több érték egyesítése', 0),
(224, 54, 'Rekordok egyedi azonosítása', 1),
(225, 54, 'Tábla törlése', 0),
(226, 54, 'Indexek automatikus létrehozása', 0),
(227, 55, 'Egy rekord neve', 0),
(228, 55, 'A tábla függvénye', 0),
(229, 55, 'A tábla egy oszlopa', 1),
(230, 55, 'Az adatbázis fájlja', 0),
(231, 56, 'Egy tábla egy sora', 1),
(232, 56, 'Az adatbázis neve', 0),
(233, 56, 'A kulcs típusa', 0),
(234, 56, 'Egy SQL-fájl', 0),
(235, 57, 'Tábla elsődleges azonosítója', 0),
(236, 57, 'Kapcsolat létrehozása két tábla között', 1),
(237, 57, 'Tábla törlésének engedélyezése', 0),
(238, 57, 'Index létrehozása', 0),
(239, 58, 'Structured Query Language', 1),
(240, 58, 'System Quality Logic', 0),
(241, 58, 'Sub Query List', 0),
(242, 58, 'Simple Query Link', 0),
(243, 59, 'Új táblát hoz létre', 0),
(244, 59, 'Adatokat kérdez le', 1),
(245, 59, 'Törli az adatbázist', 0),
(246, 59, 'Indexet generál', 0),
(247, 60, 'Törli az adatbázist', 0),
(248, 60, 'Törli a táblából a kiválasztott rekordokat', 1),
(249, 60, 'Új oszlopot hoz létre', 0),
(250, 60, 'Módosítja a kulcsot', 0),
(251, 61, 'Módosít meglévő rekordokat', 0),
(252, 61, 'Új rekordot szúr be', 1),
(253, 61, 'Fájlt hoz létre', 0),
(254, 61, 'Törli az oszlopot', 0),
(255, 62, 'Törli a táblát', 0),
(256, 62, 'Módosít meglévő rekordokat', 1),
(257, 62, 'Új táblát hoz létre', 0),
(258, 62, 'Indexet töröl', 0),
(259, 63, 'Program telepítése', 0),
(260, 63, 'Adatbázison végrehajtott művelet, utasítás', 1),
(261, 63, 'Feldolgozó program futtatása', 0),
(262, 63, 'Adatok törlése', 0),
(263, 64, 'Adatok törlése a táblákból', 0),
(264, 64, 'Adatbázis szerkezetének optimalizálása redundancia csökkentésével', 1),
(265, 64, 'Adatok kódolása titkosítással', 0),
(266, 64, 'A kulcsok automatikus generálása', 0),
(267, 65, 'Többértékű attribútumok megengedettek', 0),
(268, 65, 'Minden mező atomiságot követ', 1),
(269, 65, 'Rekordok sorrendje fix', 0),
(270, 65, 'Kulcsok nem használhatók', 0),
(271, 66, 'Táblák másolása', 0),
(272, 66, 'Táblák összekapcsolása közös mező alapján', 1),
(273, 66, 'Oszlopok törlése', 0),
(274, 66, 'Rekordok titkosítása', 0),
(275, 67, 'A kapcsolódó táblák minden rekordját visszaadja', 0),
(276, 67, 'Csak a mindkét táblában illeszkedő rekordokat adja vissza', 1),
(277, 67, 'Csak a bal oldali tábla rekordjait adja vissza', 0),
(278, 67, 'Csak a jobb oldali tábla rekordjait adja vissza', 0),
(279, 68, 'A rekordok száma', 0),
(280, 68, 'Az adatbázis szerkezeti leírása', 1),
(281, 68, 'A táblák tartalma', 0),
(282, 68, 'Az adatbázis jelszava', 0),
(283, 69, 'Fájl neve', 0),
(284, 69, 'Adatokat rendező algoritmus', 0),
(285, 69, 'Keresést gyorsító speciális adatstruktúra', 1),
(286, 69, 'A tábla első sora', 0),
(287, 69, 'Egy kapcsolati kulcs', 0),
(288, 70, 'Minden érték ismétlődhet benne', 0),
(289, 70, 'Minden rekordot egyedileg azonosít', 1),
(290, 70, 'Csak külső kulcs lehet', 0),
(291, 70, 'Csak szöveg lehet', 0),
(292, 71, 'Program telepítése', 0),
(293, 71, 'Logikai műveletek csoportja, amely vagy teljes egészében lefut, vagy sem', 1),
(294, 71, 'Rekordok törlése', 0),
(295, 71, 'Kulcsok módosítása', 0),
(296, 72, 'Active', 0),
(297, 72, 'Atomicity', 1),
(298, 72, 'Access', 0),
(299, 72, 'Auto', 0),
(300, 73, '0 számot', 0),
(301, 73, 'Ismeretlen vagy nem létező értéket', 1),
(302, 73, 'A sor végét', 0),
(303, 73, 'Egy kulcs hibát', 0),
(304, 74, 'Rekordok törlése', 0),
(305, 74, 'Rekordok csoportosítása egy adott oszlop szerint', 1),
(306, 74, 'Tábla másolása', 0),
(307, 74, 'Index létrehozása', 0),
(308, 75, 'Rekordok törlése', 0),
(309, 75, 'Csoportosított adatok szűrése', 1),
(310, 75, 'Új rekord beszúrása', 0),
(311, 75, 'Osztások kiszámítása', 0),
(312, 76, 'UPPER()', 0),
(313, 76, 'SUM()', 1),
(314, 76, 'REPLACE()', 0),
(315, 76, 'SUBSTRING()', 0),
(316, 77, 'Összeadja az értékeket', 0),
(317, 77, 'Megszámolja a rekordokat', 1),
(318, 77, 'Frissíti az indexeket', 0),
(319, 77, 'Rendez adatokat', 0),
(320, 78, 'Adatok törlése ok nélkül', 0),
(321, 78, 'Teljesítmény fenntartása és hibák megelőzése', 1),
(322, 78, 'Felesleges rekordok szaporítása', 0),
(323, 78, 'Az indexek megszüntetése', 0),
(324, 79, 'Tábla neveinek szabványosítása', 0),
(325, 79, 'Kapcsolatok helyességének biztosítása a kulcsok között', 1),
(326, 79, 'Rekordok automatikus rendezése', 0),
(327, 79, 'Az indexek újraszámolása', 0),
(328, 80, 'Megakadályozza a törlést', 0),
(329, 80, 'A kapcsolódó rekordokat is törli a másik táblában', 1),
(330, 80, 'Csak az első rekord törlődik', 0),
(331, 80, 'A tábla duplikálódik', 0),
(332, 80, 'Az index frissül', 0),
(333, 81, 'A mező értéke lehet ismeretlen', 0),
(334, 81, 'A mező nem vehet fel NULL értéket', 1),
(335, 81, 'A mező mindig kulcs', 0),
(336, 81, 'A mező mindig szám', 0),
(337, 82, 'Minden rekordot töröl', 0),
(338, 82, 'Eltávolítja a duplikált sorokat a lekérdezés eredményéből', 1),
(339, 82, 'Új indexet hoz létre', 0),
(340, 82, 'Megfordítja a rekordok sorrendjét', 0),
(341, 83, 'A tábla fizikai másolata', 0),
(342, 83, 'Egy lekérdezés eredményére épülő virtuális tábla', 1),
(343, 83, 'Az adatbázis jelszava', 0),
(344, 83, 'A rekordok időbélyege', 0),
(345, 83, 'Egy index', 0),
(346, 84, 'Oszlop neve', 0),
(347, 84, 'Automatikusan növekvő értékek generátora', 1),
(348, 84, 'Rekord törlő algoritmus', 0),
(349, 84, 'Tábla összefűzése', 0),
(350, 85, 'Új index létrehozása', 0),
(351, 85, 'Mezők értékeinek korlátozása feltétellel', 1),
(352, 85, 'Rekordok törlésének megakadályozása', 0),
(353, 85, 'Tranzakciók visszavonása', 0),
(354, 86, 'Új rekord beszúrása', 0),
(355, 86, 'A tranzakcióban végzett módosítások visszavonása', 1),
(356, 86, 'Index létrehozása', 0),
(357, 86, 'Tábla szűrése', 0),
(358, 87, 'Törli a tábla tartalmát', 0),
(359, 87, 'Véglegesíti a tranzakció módosításait', 1),
(360, 87, 'Rekordokat rejt el', 0),
(361, 87, 'Lekérdezést töröl', 0),
(362, 88, 'Új rekordokat hoz létre', 0),
(363, 88, 'Visszavonja a még el nem kötelezett tranzakciókat', 1),
(364, 88, 'Törli az adatbázist', 0),
(365, 88, 'Rendez egy oszlopot', 0),
(366, 89, 'Lassabb lekérdezést okoz', 0),
(367, 89, 'Több tárhelyet fogyaszt és lassíthatja az INSERT/UPDATE műveleteket', 1),
(368, 89, 'Csak egy táblán használható', 0),
(369, 89, 'Nem működik kulcsokkal', 0),
(370, 89, 'Megszünteti a normalizációt', 0),
(371, 90, 'Külső fájl', 0),
(372, 90, 'Az adatbázisban tárolt előre definiált parancssorozat', 1),
(373, 90, 'Egy index típus', 0),
(374, 90, 'Rekord törlésére szolgáló kulcs', 0),
(375, 90, 'A normalizáció szabálya', 0),
(376, 91, 'Rekordok számlálója', 0),
(377, 91, 'Automatikusan lefutó eseménykezelő az adatbázisban', 1),
(378, 91, 'Egy tábla rejtett mezője', 0),
(379, 91, 'A PRIMARY KEY másik neve', 0),
(380, 91, 'SQL függvény', 0),
(381, 92, 'Adatok titkosítására', 0),
(382, 92, 'Kapcsolatok létrehozására táblák között', 1),
(383, 92, 'Tábla törlésére', 0),
(384, 92, 'Függvények létrehozására', 0),
(385, 93, 'Adatok lekérdezése', 0),
(386, 93, 'Adatdefiníciós utasítások csoportja', 1),
(387, 93, 'Adatmanipuláló utasítások csoportja', 0),
(388, 93, 'Felhasználói jogosultságok', 0),
(389, 94, 'SELECT', 0),
(390, 94, 'CREATE', 1),
(391, 94, 'UPDATE', 0),
(392, 94, 'INSERT', 0),
(393, 95, 'Data Manipulation Language', 1),
(394, 95, 'Data Minimal Level', 0),
(395, 95, 'Delete Modify Load', 0),
(396, 95, 'Double Memory Logic', 0),
(397, 96, 'Jogosultságkezelés és hozzáférés-szabályozás', 1),
(398, 96, 'Tábla létrehozása', 0),
(399, 96, 'Rekordok törlése', 0),
(400, 96, 'Indexek kezelése', 0),
(401, 97, 'REVOKE', 0),
(402, 97, 'GRANT', 1),
(403, 97, 'GIVE', 0),
(404, 97, 'ALLOW', 0),
(405, 98, 'Feldolgozó motor', 0),
(406, 98, 'Az adatbázis logikai felépítésének egysége', 1),
(407, 98, 'Az index kívülről', 0),
(408, 98, 'A tranzakció neve', 0),
(409, 99, 'Csökkenti a lekérdezések sebességét', 0),
(410, 99, 'Redundanciát növel teljesítmény javítása érdekében', 1),
(411, 99, 'Értékeket töröl', 0),
(412, 99, 'Kulcsokat módosít', 0),
(413, 99, 'Megszünteti a kapcsolatokat', 0),
(414, 100, 'Index típusa', 0),
(415, 100, 'Táblanév rövidítése a lekérdezésben', 1),
(416, 100, 'Kulcs elnevezése', 0),
(417, 100, 'Tranzakció neve', 0),
(418, 101, 'Rekordok rendezése megadott oszlop alapján', 1),
(419, 101, 'Rekordok törlése', 0),
(420, 101, 'Tábla létrehozása', 0),
(421, 101, 'Jogosultságok kezelése', 0),
(422, 102, 'A weboldalak logikai működésének vezérlése', 0),
(423, 102, 'A weboldalak szerkezeti felépítésének leírása', 1),
(424, 102, 'Az adatbázisok kezelésének biztosítása', 0),
(425, 102, 'A szerveroldali programok futtatása', 0),
(426, 103, 'HyperText Markup Language', 1),
(427, 103, 'HighTransfer Machine Logic', 0),
(428, 103, 'HybridText Multi Language', 0),
(429, 103, 'HyperTransfer Markup Level', 0),
(430, 104, 'A weboldal törzsében látható főcímet', 0),
(431, 104, 'A böngésző fülén megjelenő címet', 1),
(432, 104, 'A lábléc címét', 0),
(433, 104, 'Egy gomb feliratát', 0),
(434, 105, 'Bekezdés definiálása', 1),
(435, 105, 'Kép beszúrása', 0),
(436, 105, 'Navigációs sáv létrehozása', 0),
(437, 105, 'Táblázat sorának definiálása', 0),
(438, 106, 'Új bekezdést hoz létre nagy térközzel', 0),
(439, 106, 'Sortörést hoz létre a szövegben', 1),
(440, 106, 'Félkövérre állítja a szöveget', 0),
(441, 106, 'Dőltre állítja a szöveget', 0),
(442, 107, '<link>', 0),
(443, 107, '<img>', 1),
(444, 107, '<image>', 0),
(445, 107, '<src>', 0),
(446, 108, 'Rendezett (sorszámozott) listát', 0),
(447, 108, 'Rendezetlen (felsorolásos) listát', 1),
(448, 108, 'Táblázatot', 0),
(449, 108, 'Űrlapot', 0),
(450, 109, 'Táblázat egy celláját', 0),
(451, 109, 'Lista egy elemét', 1),
(452, 109, 'Képkeretet', 0),
(453, 109, 'Stílusblokkot', 0),
(454, 110, 'Inline elemek csoportosítása', 0),
(455, 110, 'Blokkszintű tartalom csoportosítása', 1),
(456, 110, 'Hangfájl beágyazása', 0),
(457, 110, 'Közvetlen navigáció készítése', 0),
(458, 111, 'Blokkszintű konténer elemet', 0),
(459, 111, 'Inline, szövegen belüli csoportosító elemet', 1),
(460, 111, 'Táblázat sorát', 0),
(461, 111, 'Űrlap gombját', 0),
(462, 112, 'Oldal vagy szakasz fejléce', 1),
(463, 112, 'Oldal lábléce', 0),
(464, 112, 'Képek tárolására szolgáló konténer', 0),
(465, 112, 'Navigációs gombok kizárólagos helye', 0),
(466, 113, 'Oldal vagy szakasz lábléce', 1),
(467, 113, 'Oldal teteje', 0),
(468, 113, 'Navigációs sáv', 0),
(469, 113, 'Kép felirata', 0),
(470, 114, 'Képgalériát', 0),
(471, 114, 'Navigációs menüt', 1),
(472, 114, 'Videólejátszó keretet', 0),
(473, 114, 'Metaadat blokkot', 0),
(474, 115, 'Űrlapmezőt', 0),
(475, 115, 'Hiperhivatkozást', 1),
(476, 115, 'Hangfájlt', 0),
(477, 115, 'Táblázat sort', 0),
(478, 116, 'src', 0),
(479, 116, 'href', 1),
(480, 116, 'target', 0),
(481, 116, 'alt', 0),
(482, 117, 'Űrlap mezőt hoz létre', 0),
(483, 117, 'Táblázatot hoz létre', 1),
(484, 117, 'Navigációt hoz létre', 0),
(485, 117, 'Kép keretét adja', 0),
(486, 118, 'Táblázat cellája', 0),
(487, 118, 'Táblázat sora', 1),
(488, 118, 'Táblázat fejlécének címe', 0),
(489, 118, 'Táblázat lábléce', 0),
(490, 119, 'Táblázat fejléc cellája', 0),
(491, 119, 'Táblázat adatcellája', 1),
(492, 119, 'Kép felirata', 0),
(493, 119, 'Űrlap gombja', 0),
(494, 120, 'Táblázat adatcellája', 0),
(495, 120, 'Táblázat fejléc cellája', 1),
(496, 120, 'Listaelem fejléc', 0),
(497, 120, 'Navigációs címke', 0),
(498, 121, 'Cella több soron nyúlik át', 0),
(499, 121, 'Cella több oszlopon nyúlik át', 1),
(500, 121, 'A cella dőlt betűssé válik', 0),
(501, 121, 'A cella szegélyét eltávolítja', 0),
(502, 122, 'Cella több oszlopon nyúlik át', 0),
(503, 122, 'Cella több soron nyúlik át', 1),
(504, 122, 'Cella háttérszínét módosítja', 0),
(505, 122, 'Cella méretét duplázza', 0),
(506, 123, 'Képek csoportosítása', 0),
(507, 123, 'Űrlap létrehozása', 1),
(508, 123, 'Videó beágyazása', 0),
(509, 123, 'Metaadat írása', 0),
(510, 124, 'Töröl egy rekordot', 0),
(511, 124, 'Beküldi az űrlapot', 1),
(512, 124, 'Jelszót rejt el', 0),
(513, 124, 'Képet jelenít meg', 0),
(514, 125, 'Mező hátterének színét adja', 0),
(515, 125, 'Segítő szöveget jelenít meg üres mezőben', 1),
(516, 125, 'A mezőt jelszó mezővé alakítja', 0),
(517, 125, 'A mezőt readonly módba teszi', 0),
(518, 126, 'A mező tartalma readonly', 0),
(519, 126, 'A mező kitöltése kötelező', 1),
(520, 126, 'A mező automatikusan feltöltődik', 0),
(521, 126, 'A mező rejtetté válik', 0),
(522, 127, 'Külső CSS törlése', 0),
(523, 127, 'Belső CSS stílusok megadása', 1),
(524, 127, 'JavaScript kód futtatása', 0),
(525, 127, 'Metaadat létrehozása', 0),
(526, 128, 'Creative Style Structure', 0),
(527, 128, 'Cascading Style Sheets', 1),
(528, 128, 'Central Style Script', 0),
(529, 128, 'Coded Script Sheets', 0),
(530, 129, 'Elemek egyedi azonosítása', 0),
(531, 129, 'Elemek stíluscsoportba rendezése', 1),
(532, 129, 'Csak JavaScript eseményekhez kell', 0),
(533, 129, 'Táblázatok formázásához kizárólag', 0),
(534, 130, 'Elemek stíluscsoportba rendezése', 0),
(535, 130, 'Elem egyedi azonosítása', 1),
(536, 130, 'Elem másolása', 0),
(537, 130, 'Videó lejátszása', 0),
(538, 131, 'class szóval', 0),
(539, 131, '.ponttal', 1),
(540, 131, '%jel', 0),
(541, 131, '@jel', 0),
(542, 132, 'Az elem új sort kezd és kitölti a rendelkezésre álló szélességet', 1),
(543, 132, 'Az elem inline elem lesz', 0),
(544, 132, 'Az elem eltűnik', 0),
(545, 132, 'Az elem háttérszínt kap', 0),
(546, 133, 'Az elem új sort kezd', 0),
(547, 133, 'Az elem nem kezd új sort és csak szükséges szélességű', 1),
(548, 133, 'Az elem képpé alakul', 0),
(549, 133, 'Az elem táblázat lesz', 0),
(550, 134, 'Az elem képszerkesztő módba lép', 0),
(551, 134, 'Az elem rugalmas elrendezést biztosít a gyermekeknek', 1),
(552, 134, 'Az elem fix pozíciót kap', 0),
(553, 134, 'Az elem táblázatként viselkedik', 0),
(554, 135, 'A gyermek elemek függőleges igazítása', 0),
(555, 135, 'A gyermek elemek vízszintes igazítása', 1),
(556, 135, 'A border vastagságának beállítása', 0),
(557, 135, 'A háttérkép ismétlődése', 0),
(558, 136, 'A hátteret igazítja', 0),
(559, 136, 'A flex elemeket igazítja függőlegesen a tengely mentén', 1),
(560, 136, 'A szöveg színét állítja', 0),
(561, 136, 'A betűközt szabályozza', 0),
(562, 137, 'Az elem a dokumentumfolyam része marad', 0),
(563, 137, 'Az elem a legközelebbi pozicionált felmenőhöz igazodik', 1),
(564, 137, 'Az elem rögzítve marad az ablakhoz', 0),
(565, 137, 'Az elem mindig a bal felső sarokba kerül', 0),
(566, 138, 'Az elem a szülő elemhez igazodik', 0),
(567, 138, 'Az elem a böngészőablakhoz rögzül', 1),
(568, 138, 'Az elem automatikusan eltűnik', 0),
(569, 138, 'Az elem nem pozicionálható', 0),
(570, 139, 'Az elem betűméretét', 0),
(571, 139, 'Az egymást fedő elemek sorrendjét', 1),
(572, 139, 'A háttérkép méretét', 0),
(573, 139, 'A táblázat cellák igazítását', 0),
(574, 140, 'Hangfájl lejátszására', 0),
(575, 140, 'Elemek jobbra vagy balra igazítására folyó szöveg mellett', 1),
(576, 140, 'Táblázat sorok összefűzésére', 0),
(577, 140, 'Kép animálására', 0),
(578, 141, 'Csak a tartalom', 0),
(579, 141, 'Margin, border, padding és content', 1),
(580, 141, 'Csak a border', 0),
(581, 141, 'Padding és margin együtt', 0),
(582, 142, 'A belső tér a tartalom körül', 0),
(583, 142, 'A külső tér az elem körül', 1),
(584, 142, 'A tartalom mérete', 0),
(585, 142, 'A háttérszín jelölése', 0),
(586, 143, 'A külső tér távolsága más elemektől', 0),
(587, 143, 'A belső tér a tartalom és a border között', 1),
(588, 143, 'A teljes elem szélessége', 0),
(589, 143, 'A border stílusa', 0),
(590, 144, 'A háttérszínt állítja', 0),
(591, 144, 'A szöveg színét adja meg', 1),
(592, 144, 'A border vastagságát adja', 0),
(593, 144, 'Az elem magasságát adja meg', 0),
(594, 145, 'A szöveg színét', 0),
(595, 145, 'Az elem háttérszínét', 1),
(596, 145, 'A border színét', 0),
(597, 145, 'A táblázat vonalait', 0),
(598, 146, 'A szöveg dőlt lesz', 0),
(599, 146, 'A szöveg félkövér lesz', 1),
(600, 146, 'A szöveg áthúzott lesz', 0),
(601, 146, 'A szöveg kisebb lesz', 0),
(602, 147, 'A szöveg dőlt lesz', 0),
(603, 147, 'A szöveg aláhúzott lesz', 1),
(604, 147, 'A szöveg vastagabb lesz', 0),
(605, 147, 'A szöveg középre igazítást kap', 0),
(606, 148, 'A szöveg balra igazítása', 0),
(607, 148, 'A szöveg középre igazítása', 1),
(608, 148, 'A szöveg jobbra igazítása', 0),
(609, 148, 'A szöveg sorkizárása', 0),
(610, 149, 'Hangfájl lejátszását', 0),
(611, 149, 'Másik weboldal beágyazását', 1),
(612, 149, 'Táblázat létrehozását', 0),
(613, 149, 'Navigáció készítését', 0),
(614, 150, 'CSS stílus beillesztését', 0),
(615, 150, 'JavaScript futtatását', 1),
(616, 150, 'Kép átméretezését', 0),
(617, 150, 'Táblázat színezését', 0),
(618, 151, 'A weboldal csak nagy kijelzőn működik', 0),
(619, 151, 'A weboldal igazodik a különböző kijelzőméretekhez', 1),
(620, 151, 'A weboldal csak széles monitoron nézhető', 0),
(621, 151, 'A weboldal mindig fix szélességű', 0),
(622, 152, 'Betűkészlet választást', 0),
(623, 152, 'Külön stílusok alkalmazását eltérő kijelzőméretekhez', 1),
(624, 152, 'Animációk létrehozását', 0),
(625, 152, 'HTML elemek kijelölését', 0),
(626, 153, 'A viewport teljes magasságát jelenti', 0),
(627, 153, 'A viewport szélességének egy százalékát jelenti', 1),
(628, 153, 'A dokumentum teljes szélességét jelenti', 0),
(629, 153, 'A szülő elem szélességét jelenti', 0),
(630, 154, 'A viewport szélességének egy százalékát jelenti', 0),
(631, 154, 'A viewport magasságának egy százalékát jelenti', 1),
(632, 154, 'A tartalom magasságát jelenti', 0),
(633, 154, 'A margin méretét jelenti', 0),
(634, 155, 'A kijelző fizikai méretét', 0),
(635, 155, 'A gyökérelem betűméretéhez viszonyított egységet', 1),
(636, 155, 'A szülő elem százalékos méretét', 0),
(637, 155, 'A margin egységét', 0),
(638, 156, 'A háttérkép ismétlődik', 0),
(639, 156, 'A háttérkép kitölti a területet, szükség esetén vágással', 1),
(640, 156, 'A háttérkép eredeti méretű marad', 0),
(641, 156, 'A háttérkép mindig a bal sarokba igazodik', 0),
(642, 157, 'A háttérkép vágásra kerül', 0),
(643, 157, 'A háttérkép úgy fér be, hogy nem vágódik le', 1),
(644, 157, 'A háttérkép ismétlődik', 0),
(645, 157, 'A háttérkép nagyított lesz', 0),
(646, 158, 'A betűk vastagságát', 0),
(647, 158, 'Az elem átlátszóságát', 1),
(648, 158, 'Az elem méretét', 0),
(649, 158, 'A border lekerekítését', 0),
(650, 159, 'A kilógó tartalom görgethető lesz', 0),
(651, 159, 'A kilógó tartalom el lesz rejtve', 1),
(652, 159, 'A kilógó tartalom felnagyítódik', 0),
(653, 159, 'Az elem átlátszó lesz', 0),
(654, 160, 'A szöveg aláhúzott lesz', 0),
(655, 160, 'Az egér kurzor kéz ikonra vált', 1),
(656, 160, 'Az elem eltűnik', 0),
(657, 160, 'A border vastagságát módosítja', 0),
(658, 161, 'Az elem ugrásszerűen változik', 0),
(659, 161, 'Az elem stílusváltozásai finoman animálva történnek', 1),
(660, 161, 'Az elem fix pozíciót kap', 0),
(661, 161, 'A flex irányát módosítja', 0),
(662, 162, 'Az elem mögé kerülő tartalom', 0),
(663, 162, 'Az elem elé virtuálisan beszúrt tartalom', 1),
(664, 162, 'A háttér növelése', 0),
(665, 162, 'A border elrejtése', 0),
(666, 163, 'Elem megjelenítése oldal betöltésekor', 0),
(667, 163, 'Elem állapota egér ráhúzásakor', 1),
(668, 163, 'Elem rejtett állapota', 0),
(669, 163, 'Elem aktív kijelölése', 0),
(670, 164, 'A kép URL címét', 0),
(671, 164, 'Helyettesítő szöveget, ha a kép nem töltődik be', 1),
(672, 164, 'A kép méretét', 0),
(673, 164, 'A kép betöltési idejét', 0),
(674, 165, 'HTML kizárólag képekhez', 0),
(675, 165, 'Jelentést hordozó, logikus szerkezetű HTML elemek használata', 1),
(676, 165, 'HTML csak táblázatokhoz', 0),
(677, 165, 'CSS nélküli HTML', 0),
(678, 166, 'A kép feliratát', 0),
(679, 166, 'Egy űrlapmező feliratát', 1),
(680, 166, 'Egy táblázat fejlécét', 0),
(681, 166, 'Egy beépített stílusblokkot', 0),
(682, 167, 'A mező automatikusan törlődik', 0),
(683, 167, 'A böngésző automatikus kitöltést alkalmazhat', 1),
(684, 167, 'A mező csak számot fogad', 0),
(685, 167, 'A mező rejtetté válik', 0),
(686, 168, 'A képek színkezelését', 0),
(687, 168, 'Külső erőforrások betöltési jogosultságának kezelését', 1),
(688, 168, 'A szöveg betűméretének szabályozását', 0),
(689, 168, 'A HTML dokumentum címének kezelését', 0),
(690, 169, 'Kép formátum', 0),
(691, 169, 'Speciális karakter kódolt formája', 1),
(692, 169, 'Hangfájl típusa', 0),
(693, 169, 'CSS hivatkozás', 0),
(694, 170, '(comment)', 0),
(695, 170, '<!-- comment -->', 1),
(696, 170, '// comment', 0),
(697, 170, '## comment ##', 0),
(698, 171, 'variable name', 0),
(699, 171, '--variable name', 1),
(700, 171, '@@variable', 0),
(701, 171, '%%variable', 0),
(702, 172, 'value(variable)', 0),
(703, 172, 'var(--variable)', 1),
(704, 172, 'use[var]', 0),
(705, 172, 'call variable', 0),
(706, 173, 'Hangmagasság számítást', 0),
(707, 173, 'Matematikai számítást stílusértékekhez', 1),
(708, 173, 'Elemek összemozaikolását', 0),
(709, 173, 'Kép átméretezését', 0),
(710, 174, 'A kép kilóg a keretből és eltorzul', 0),
(711, 174, 'A kép kitölti a keretet, szükség esetén vágással', 1),
(712, 174, 'A kép csak balra igazodik', 0),
(713, 174, 'A kép ismétlődik', 0),
(714, 175, 'Hangfájl lejátszása', 0),
(715, 175, 'Videó beágyazása', 1),
(716, 175, 'Csak képek tárolása', 0),
(717, 175, 'Háttérszín váltása', 0),
(718, 176, 'A videó csak gombnyomásra indul', 0),
(719, 176, 'A videó automatikusan elindul', 1),
(720, 176, 'A videó ismétlődik', 0),
(721, 176, 'A videó hangja letiltódik', 0),
(722, 177, 'Táblázat megjelenítése', 0),
(723, 177, 'Hang lejátszása', 1),
(724, 177, 'Videó vetítése', 0),
(725, 177, 'Képek animálása', 0),
(726, 178, 'A hang nem játszható le', 0),
(727, 178, 'A hang automatikusan elindul', 1),
(728, 178, 'A hang visszatekeri magát', 0),
(729, 178, 'A hang némított lesz mindig', 0),
(730, 179, 'A border vastagságát', 0),
(731, 179, 'A sarkok lekerekítését', 1),
(732, 179, 'A szöveg dőlését', 0),
(733, 179, 'A háttér átlátszóságát', 0),
(734, 180, 'Az elem körvonalának eltüntetése', 0),
(735, 180, 'Az elem árnyékának megjelenítése', 1),
(736, 180, 'Az elem forgatása', 0),
(737, 180, 'A margin eltávolítása', 0),
(738, 181, 'A szöveg színét', 0),
(739, 181, 'A betűtípus családját', 1),
(740, 181, 'A háttérszínt', 0),
(741, 181, 'A border stílusát', 0),
(742, 182, 'A lista számai megnagyobbodnak', 0),
(743, 182, 'A lista eleje nem kap jelölőt', 1),
(744, 182, 'A lista elemei pirosak lesznek', 0),
(745, 182, 'A lista sortörése eltűnik', 0),
(746, 183, 'A háttérminta beállítása', 0),
(747, 183, 'A borderhez hasonló külső keret beállítása', 1),
(748, 183, 'A szöveg betűközének módosítása', 0),
(749, 183, 'A padding eltávolítása', 0),
(750, 184, 'Az elem maximális szélességét', 0),
(751, 184, 'Az elem minimális szélességét', 1),
(752, 184, 'Az elem teljes szélességét', 0),
(753, 184, 'Az elem automatikus kitöltését', 0),
(754, 185, 'Az elem fix szélességét', 0),
(755, 185, 'Az elem maximális szélességét', 1),
(756, 185, 'Az elem minimális szélességét', 0),
(757, 185, 'A margin méretét', 0),
(758, 186, 'Az elem minimális magasságát', 1),
(759, 186, 'Az elem maximális magasságát', 0),
(760, 186, 'Az elem színeinek számát', 0),
(761, 186, 'A padding méretét', 0),
(762, 187, 'Az elem minimális magasságát', 0),
(763, 187, 'Az elem maximális magasságát', 1),
(764, 187, 'Az elem teljes magasságát', 0),
(765, 187, 'Az elem border vastagságát', 0),
(766, 188, 'A szöveg automatikusan több sorba törik', 0),
(767, 188, 'A szöveg nem törik új sorba', 1),
(768, 188, 'A szöveg háttérszíne váltakozik', 0),
(769, 188, 'A szöveg félkövér lesz', 0),
(770, 189, 'A szöveget kisbetűssé alakítja', 0),
(771, 189, 'A szöveget nagybetűssé alakítja', 1),
(772, 189, 'A szöveget dőltté alakítja', 0),
(773, 189, 'A szöveget áthúzottá teszi', 0),
(774, 190, 'A szöveg minden betűje nagybetű lesz', 0),
(775, 190, 'A szöveg minden betűje kisbetű lesz', 1),
(776, 190, 'A szöveg középre igazított lesz', 0),
(777, 190, 'A szöveg sorkizárt lesz', 0),
(778, 191, 'A sorok közötti távolságot állítja', 0),
(779, 191, 'A betűk közötti távolságot állítja', 1),
(780, 191, 'A bekezdések közötti távolságot állítja', 0),
(781, 191, 'A betűk dőlésszögét állítja', 0),
(782, 192, 'A betűk vastagságát adja meg', 0),
(783, 192, 'A sorok közötti távolságot adja meg', 1),
(784, 192, 'A képek magasságát állítja', 0),
(785, 192, 'A háttér átlátszóságát állítja', 0),
(786, 193, 'Az elem teljesen törlődik', 0),
(787, 193, 'Az elem láthatatlan, de a helyét megtartja', 1),
(788, 193, 'Az elem átlátszó lesz', 0),
(789, 193, 'Az elem kattintható marad', 0),
(790, 194, 'Az elem láthatatlan, de helyet foglal', 0),
(791, 194, 'Az elem eltűnik és helyet sem foglal', 1),
(792, 194, 'Az elem nagyobb lesz', 0),
(793, 194, 'Az elem marginja megnő', 0),
(794, 195, 'Az elem kattinthatóbb lesz', 0),
(795, 195, 'Az elem nem reagál kattintásokra', 1),
(796, 195, 'Az elem gyorsabban renderelődik', 0),
(797, 195, 'Az elem nagyobb margint kap', 0),
(798, 196, 'A kép kontrasztja nő', 0),
(799, 196, 'A kép elmosódik', 1),
(800, 196, 'A kép invertálódik', 0),
(801, 196, 'A kép élesebbé válik', 0),
(802, 197, 'A kép elmosódik', 0),
(803, 197, 'A kép fekete-fehérré válik', 1),
(804, 197, 'A kép piros árnyalatú lesz', 0),
(805, 197, 'A kép megfordul', 0),
(806, 198, 'Az elem átlátszó lesz', 0),
(807, 198, 'Az elem elfordul', 1),
(808, 198, 'Az elem kiemelődik', 0),
(809, 198, 'Az elem lekerekített lesz', 0),
(810, 199, 'Az elem elforgatása', 0),
(811, 199, 'Az elem nagyítása vagy kicsinyítése', 1),
(812, 199, 'Az elem színeinek invertálása', 0),
(813, 199, 'Az elem háttérszínének váltása', 0),
(814, 200, 'Az elem elforgatása', 0),
(815, 200, 'Az elem mozgatása vízszintesen és függőlegesen', 1),
(816, 200, 'Az elem méretének növelése', 0),
(817, 200, 'Az elem borderének törlése', 0),
(818, 201, 'Az elem inline-ként viselkedik', 0),
(819, 201, 'Két dimenziós rács alapú elrendezést biztosít', 1),
(820, 201, 'Az elem minden gyermekét elrejti', 0),
(821, 201, 'Az elem táblázattá válik', 0),
(822, 202, 'A sorok közti távolságot állítja', 0),
(823, 202, 'A rács oszlopainak méreteit adja meg', 1),
(824, 202, 'A rács szegélyét állítja', 0),
(825, 202, 'A háttér pozícióját adja meg', 0),
(826, 203, 'A gyermek elemek vízszintes igazítása rácsban', 1),
(827, 203, 'A gyermek elemek függőleges igazítása flexboxban', 0),
(828, 203, 'A border eltávolítása', 0),
(829, 203, 'A háttérkép középre igazítása', 0),
(830, 204, 'A háttérkép pozícióját adja meg', 0),
(831, 204, 'Az elem szélességének és magasságának arányát határozza meg', 1),
(832, 204, 'A tartalom betűméretét növeli', 0),
(833, 204, 'Az elem láthatóságát kapcsolja ki', 0),
(834, 205, 'Adatbázisok kezelésére', 0),
(835, 205, 'Reszponzív weboldalak gyors fejlesztésére', 1),
(836, 205, 'Szerver oldali kód futtatására', 0),
(837, 205, 'Képek szerkesztésére', 0),
(838, 206, 'A JavaScript vagy CSS fájl Bootstrap kiszolgálón keresztül', 1),
(839, 206, 'Csak lokális fájlok', 0),
(840, 206, 'Csak adatbázis kapcsolaton keresztül', 0),
(841, 206, 'Csak videó fájlok segítségével', 0),
(842, 207, 'Lapozási funkciók megadása', 0),
(843, 207, 'Fix szélességű központi tartalom konténer', 1),
(844, 207, 'Képkeret létrehozása', 0),
(845, 207, 'Táblázat cellák összefűzése', 0),
(846, 208, 'Fix szélességű konténer', 0),
(847, 208, 'Teljes szélességű, rugalmas konténer', 1),
(848, 208, 'Navigációs elemek szűrése', 0),
(849, 208, 'Űrlapmezők validálása', 0),
(850, 209, 'Háttérszín beállítása', 0),
(851, 209, 'Rácsszerkezet sorainak definiálása', 1),
(852, 209, 'Táblázat generálása', 0),
(853, 209, 'Kép igazítása', 0),
(854, 210, 'Reszponzív rács oszlopának definiálása', 1),
(855, 210, 'Csak navigációhoz használható', 0),
(856, 210, 'Hangfájl lejátszása', 0),
(857, 210, 'Border megjelenítése', 0),
(858, 211, 'Szöveg stílusát', 0),
(859, 211, 'Rácselemek közötti térköz értékét', 1),
(860, 211, 'Kép árnyékát', 0),
(861, 211, 'Táblázatot', 0),
(862, 212, 'col lg', 0),
(863, 212, 'col sm', 1),
(864, 212, 'col xxl', 0),
(865, 212, 'col auto', 0),
(866, 213, 'Az elem nagyobb lesz', 0),
(867, 213, 'Az elem elrejtésre kerül', 1),
(868, 213, 'Az elem animálódik', 0),
(869, 213, 'Az elem margót kap', 0),
(870, 214, 'Az elem eltűnik', 0),
(871, 214, 'Az elem blokkszintű elemmé válik', 1),
(872, 214, 'Az elem képpé alakul', 0),
(873, 214, 'Az elem helyet nem foglal', 0),
(874, 215, 'Elem láthatatlanná válik', 0),
(875, 215, 'Flexbox elrendezést biztosít', 1),
(876, 215, 'Táblázatként viselkedik', 0),
(877, 215, 'Képkeretet hoz létre', 0),
(878, 216, 'Flex elemek aljára igazítása', 0),
(879, 216, 'Flex elemek középre igazítása függőlegesen', 1),
(880, 216, 'Flex elemek szétosztása vízszintesen', 0),
(881, 216, 'Border középre igazítása', 0),
(882, 217, 'Flex elemek függőleges középre igazítása', 0),
(883, 217, 'Flex elemek vízszintes középre igazítása', 1),
(884, 217, 'Flex elemek középre igazítása átlósan', 0),
(885, 217, 'Csak táblázatoknál érvényes', 0),
(886, 218, 'Margin értéke 3 egység', 1),
(887, 218, 'Margin nulla', 0),
(888, 218, 'Padding 3 egység', 0),
(889, 218, 'Border 3 vastagság', 0),
(890, 219, 'Padding értéke 2 egység', 1),
(891, 219, 'Padding nulla', 0),
(892, 219, 'Padding eltávolítása', 0),
(893, 219, 'Border igazítása', 0),
(894, 220, 'Szöveg balra igazítása', 0),
(895, 220, 'Szöveg középre igazítása', 1),
(896, 220, 'Szöveg jobbra igazítása', 0),
(897, 220, 'Szöveg aláhúzása', 0),
(898, 221, 'Szöveg balra igazítása', 0),
(899, 221, 'Szöveg jobbra igazítása', 1),
(900, 221, 'Szöveg középre igazítása', 0),
(901, 221, 'Szöveg dőlt lesz', 0),
(902, 222, 'Kép beillesztése', 0),
(903, 222, 'Elem elsődleges témaszínt kap', 1),
(904, 222, 'Elem elrejtése', 0),
(905, 222, 'Elem margójának beállítása', 0),
(906, 223, 'Navigáció készítése', 0),
(907, 223, 'Figyelmeztető üzenet komponens', 1),
(908, 223, 'Képkeret létrehozása', 0),
(909, 223, 'Táblázat formázása', 0),
(910, 224, 'Success stílus', 0),
(911, 224, 'Vörös figyelmeztető doboz', 1),
(912, 224, 'Kép eseménykezelése', 0),
(913, 224, 'Border generálása', 0),
(914, 225, 'Táblázat alakítása', 0),
(915, 225, 'Gombok stílusozása', 1),
(916, 225, 'Képek szűrése', 0),
(917, 225, 'Listák rendezése', 0),
(918, 226, 'Képfeltöltés', 0),
(919, 226, 'Elsődleges stílusú gomb', 1),
(920, 226, 'Rejtett gomb', 0),
(921, 226, 'Táblázat generálása', 0),
(922, 227, 'Vonal nélküli gomb', 0),
(923, 227, 'Körvonalas elsődleges stílusú gomb', 1),
(924, 227, 'Háttér nélküli link', 0),
(925, 227, 'Video gomb', 0),
(926, 228, 'Táblázat fejléc', 0),
(927, 228, 'Navigációs sáv létrehozása', 1),
(928, 228, 'Form mező', 0),
(929, 228, 'Kép konténere', 0),
(930, 229, 'A márkanév vagy logó megjelenítése a navigációban', 1),
(931, 229, 'Kép betöltése', 0),
(932, 229, 'Táblázat oszlopcímke', 0),
(933, 229, 'Hang lejátszása', 0),
(934, 230, 'Eseménykezelő létrehozása', 0),
(935, 230, 'Kártya dizájnú tartalmi blokk', 1),
(936, 230, 'Kép átméretezése', 0),
(937, 230, 'Táblázat generálása', 0),
(938, 231, 'Card belső tartalmi területe', 1),
(939, 231, 'Card háttérének eltávolítása', 0),
(940, 231, 'Card címsorának megjelenítése', 0),
(941, 231, 'Card animálása', 0),
(942, 232, 'Form ellenőrzés', 0),
(943, 232, 'Összecsukható tartalmi panel', 1),
(944, 232, 'Képváltó animáció', 0),
(945, 232, 'Függőleges navigáció', 0),
(946, 233, 'Képkeret létrehozása', 0),
(947, 233, 'Felugró ablak megjelenítése', 1),
(948, 233, 'Táblázat rendezése', 0),
(949, 233, 'Hangfájl bekapcsolása', 0),
(950, 234, 'Form ellenőrző', 0),
(951, 234, 'Folyamatjelző sáv', 1),
(952, 234, 'Kép háttéreffektus', 0),
(953, 234, 'Táblázat összegzés', 0),
(954, 235, 'Kép betöltése', 0),
(955, 235, 'Kör alakú töltés animáció', 1),
(956, 235, 'Listák törlése', 0),
(957, 235, 'Form mező igazítása', 0),
(958, 236, 'Az oldal láblécét', 0),
(959, 236, 'A dokumentum fő tartalmi részét', 1),
(960, 236, 'Csak navigációs elemeket', 0),
(961, 236, 'Csak képgalériát', 0),
(962, 237, 'Kizárólag képek tárolására szolgáló konténer', 0),
(963, 237, 'Önálló, értelmezhető tartalmi egység', 1),
(964, 237, 'Navigációs menü', 0),
(965, 237, 'Táblázatfejléc', 0),
(966, 238, 'Háttérképet tartalmaz', 0),
(967, 238, 'Tematikus tartalmi szakaszt jelöl', 1),
(968, 238, 'Csak form mezőket tartalmazhat', 0),
(969, 238, 'Videók gyűjtésére szolgál', 0),
(970, 239, 'A fő tartalmon kívüli kiegészítő tartalom', 1),
(971, 239, 'A fő tartalom kötelező része', 0),
(972, 239, 'Videólejátszó helye', 0),
(973, 239, 'Kép háttéreffektus', 0),
(974, 240, 'Navigációs lista', 0),
(975, 240, 'Önálló médiatartalom és felirata számára kijelölt csoport', 1),
(976, 240, 'Táblázat összegző része', 0),
(977, 240, 'Rejtett tartalmi blokk', 0),
(978, 241, 'Kép átméretezése', 0),
(979, 241, 'A figure elem felirata', 1),
(980, 241, 'Navigáció címe', 0),
(981, 241, 'Audio felirata', 0),
(982, 242, 'Eltávolítja a vezérlőket', 0),
(983, 242, 'Megjeleníti a videó vezérlőgombjait', 1),
(984, 242, 'Hangot némít', 0),
(985, 242, 'Automatikusan teljes képernyőre vált', 0),
(986, 243, 'Videó tömörítése', 0),
(987, 243, 'Feliratok vagy meta adatok csatolása videóhoz', 1),
(988, 243, 'Videó hangvezérlése', 0),
(989, 243, 'Kép mozgatása', 0),
(990, 244, 'A hang nem indul el többször', 0),
(991, 244, 'A hang ismétlődően újraindul', 1),
(992, 244, 'A hang csak egyszer játszható le', 0),
(993, 244, 'A hang némított állapotban indul', 0),
(994, 245, 'Csak számokat fogad', 0),
(995, 245, 'E mail cím beviteli mezőt', 1),
(996, 245, 'Csak nagybetűket fogad', 0),
(997, 245, 'Kép URL beviteli mezőt', 0),
(998, 246, 'Szöveges dátum mezőt ad', 0),
(999, 246, 'Dátumválasztó felületet biztosít', 1),
(1000, 246, 'Csak hónapot lehet megadni', 0),
(1001, 246, 'Csak évet lehet megadni', 0),
(1002, 247, 'Többsoros szövegmező', 0),
(1003, 247, 'Csúszkával állítható numerikus érték', 1),
(1004, 247, 'Hangszín szabályzó', 0),
(1005, 247, 'Videó hangerő beállító', 0),
(1006, 248, 'A mező el van tiltva', 0),
(1007, 248, 'A mező kitöltése kötelező', 1),
(1008, 248, 'A mező automatikusan kitöltődik', 0),
(1009, 248, 'A mező csak olvasható', 0),
(1010, 249, 'Kép kitöltési módot ad meg', 0),
(1011, 249, 'Reguláris kifejezés alapján érvényesít mezőt', 1),
(1012, 249, 'Színpalettát ad', 0),
(1013, 249, 'Betűtípust jelöl', 0),
(1014, 250, 'A mező kötelező', 0),
(1015, 250, 'Segítő szöveg jelenik meg üres mezőben', 1),
(1016, 250, 'A mező automatikusan törlődik', 0),
(1017, 250, 'A mező ellenőrzött', 0),
(1018, 251, 'A border színét állítja', 0),
(1019, 251, 'A sarkok lekerekítését végzi', 1),
(1020, 251, 'A betűk vastagságát adja', 0),
(1021, 251, 'A háttérkép méretét szabályozza', 0),
(1022, 252, 'Háttér hang', 0),
(1023, 252, 'Lineáris átmenetes háttérszín', 1),
(1024, 252, 'Háttér ismétlődése', 0),
(1025, 252, 'Háttér átlátszatlansága', 0),
(1026, 253, 'Vízszintes színátmenet', 0),
(1027, 253, 'Körkörös középpontból induló színátmenet', 1),
(1028, 253, 'Csak képekhez használható', 0),
(1029, 253, 'Csak háttér árnyék', 0),
(1030, 254, 'A HTML oldal nevét', 0),
(1031, 254, 'A futtatni kívánt animáció azonosítóját', 1),
(1032, 254, 'A kép nevét', 0),
(1033, 254, 'A média fájl azonosítóját', 0),
(1034, 255, 'Az animáció kezdőpontját', 0),
(1035, 255, 'Az animáció időtartamát', 1),
(1036, 255, 'Az animáció színét', 0),
(1037, 255, 'Az animáció betűméretét', 0),
(1038, 256, 'Hányszor ismétlődik az animáció', 1),
(1039, 256, 'Az animáció betűszínét állítja', 0),
(1040, 256, 'Az animáció eltolását adja', 0),
(1041, 256, 'A háttér tömörítését jelöli', 0),
(1042, 257, 'Elem átlátszóvá tétele', 0),
(1043, 257, 'Elem eltolása vízszintes és függőleges irányban', 1),
(1044, 257, 'Elem forgatása', 0),
(1045, 257, 'Elem eltüntetése', 0),
(1046, 258, 'Elem lekerekítése', 0),
(1047, 258, 'Elem elforgatása', 1),
(1048, 258, 'Elem többszörözése', 0),
(1049, 258, 'Elem görbévé alakítása', 0),
(1050, 259, 'Elem háttérszínének váltása', 0),
(1051, 259, 'Elem nagyítása vagy kicsinyítése', 1),
(1052, 259, 'Elem átlátszósága', 0),
(1053, 259, 'Elem margójának növelése', 0),
(1054, 260, 'A flex elemek egymás alatt jelennek meg', 0),
(1055, 260, 'A flex elemek egymás mellett jelennek meg vízszintesen', 1),
(1056, 260, 'A flex elemek visszafelé rendelődnek', 0),
(1057, 260, 'A flex eltolódik', 0),
(1058, 261, 'A flex elemek vízszintesen sorakoznak', 0),
(1059, 261, 'A flex elemek függőlegesen egymás alatt jelennek meg', 1),
(1060, 261, 'A flex elemek eltűnnek', 0),
(1061, 261, 'A flex elemek összeolvadnak', 0),
(1062, 262, 'A flex elemek sűrűn összetapadnak', 0),
(1063, 262, 'A flex elemek között egyenletes rés van, széleken nincs térköz', 1),
(1064, 262, 'A flex elemek véletlenszerű helyen állnak', 0),
(1065, 262, 'A flex elemek középre kerülnek', 0),
(1066, 263, 'Flex elemek összenyomódnak', 0),
(1067, 263, 'Flex elemek kitöltik a teljes elérhető magasságot', 1),
(1068, 263, 'Flex elemek középen vannak', 0),
(1069, 263, 'Flex elemek elrejtődnek', 0),
(1070, 264, 'A rács oszlopait szabja meg', 0),
(1071, 264, 'A rács sorainak méretét adja meg', 1),
(1072, 264, 'A rács hátterét adja meg', 0),
(1073, 264, 'A rács betűméretét adja meg', 0),
(1074, 265, 'A JavaScript szerveren fut', 0),
(1075, 265, 'A JavaScript a böngésző motorjában fut', 1),
(1076, 265, 'A JavaScript csak mobilon fut', 0),
(1077, 265, 'A JavaScript csak adatbázisban fut', 0),
(1078, 266, 'var name', 1),
(1079, 266, 'variable name', 0),
(1080, 266, 'make name', 0),
(1081, 266, 'set name', 0),
(1082, 267, 'Globális változó', 0),
(1083, 267, 'Blokkszintű változó', 1),
(1084, 267, 'Kizárólag konstans érték', 0),
(1085, 267, 'Típus nélküli objektum', 0),
(1086, 268, 'Nem változtatható referencia', 1),
(1087, 268, 'Mindig számot tárol', 0),
(1088, 268, 'Böngészőt vezérlő változó', 0),
(1089, 268, 'Csak szerveroldalon működik', 0),
(1090, 269, 'function test() {}', 1),
(1091, 269, 'create test {}', 0),
(1092, 269, 'method test {}', 0),
(1093, 269, 'func test[]', 0),
(1094, 270, 'Függvény törlése', 0),
(1095, 270, 'Érték visszaadása egy függvényből', 1),
(1096, 270, 'Fájl letöltése', 0),
(1097, 270, 'Kép megjelenítése', 0),
(1098, 271, 'Ciklus', 0),
(1099, 271, 'Elágazás', 1),
(1100, 271, 'Fájlolvasás', 0),
(1101, 271, 'Hang lejátszás', 0),
(1102, 272, 'Új függvény létrehozása', 0),
(1103, 272, 'Az if hamis esetének kezelése', 1),
(1104, 272, 'Képbeállítás', 0),
(1105, 272, 'Számítások törlése', 0),
(1106, 273, 'Képek közti váltás', 0),
(1107, 273, 'Többirányú elágazás', 1),
(1108, 273, 'Böngésző bezárása', 0),
(1109, 273, 'Hangváltás', 0),
(1110, 274, 'Adatbázis lekérdezés', 0),
(1111, 274, 'Ismétlődő utasítások sorozata', 1),
(1112, 274, 'CSS aktiválása', 0),
(1113, 274, 'HTML töltése', 0),
(1114, 275, 'Egyszeri feltételvizsgálat', 0),
(1115, 275, 'Ismétlés amíg a feltétel igaz', 1),
(1116, 275, 'A böngésző újraindítása', 0),
(1117, 275, 'Képek váltása', 0),
(1118, 276, 'Mindig egyszer lefut, majd feltétel alapján ismétel', 1),
(1119, 276, 'Soha nem fut le', 0),
(1120, 276, 'Csak hibakezeléshez kell', 0),
(1121, 276, 'Elemek törlésére szolgál', 0),
(1122, 277, 'Gyorsabb grafika', 0),
(1123, 277, 'Szigorúbb hibakezelés és változóellenőrzés', 1),
(1124, 277, 'Webszerver indítása', 0),
(1125, 277, 'Videó gyorsítás', 0),
(1126, 278, 'Képek tömörítésére szolgál', 0),
(1127, 278, 'Szöveges adatformátum kulcs érték párokkal', 1),
(1128, 278, 'Hangfájl formátum', 0),
(1129, 278, 'Grafikus animáció', 0),
(1130, 279, 'Kép átalakításra', 0),
(1131, 279, 'JSON szöveg objektummá alakítására', 1),
(1132, 279, 'Hang konvertálására', 0),
(1133, 279, 'HTML elem törlésére', 0),
(1134, 280, 'Objektum számmá alakítása', 0),
(1135, 280, 'Objektum JSON szöveggé alakítása', 1),
(1136, 280, 'Hang indítása', 0),
(1137, 280, 'Kép forgatása', 0),
(1138, 281, 'Egyetlen szám tárolása', 0),
(1139, 281, 'Több értéket tartalmazó lista', 1),
(1140, 281, 'Kép tárolása', 0),
(1141, 281, 'Fájl neve', 0),
(1142, 282, 'let t = []', 1),
(1143, 282, 'let t = newlist', 0),
(1144, 282, 'let t = array()', 0),
(1145, 282, 'let t = values', 0),
(1146, 283, 'Összeolvaszt két tömböt', 0),
(1147, 283, 'Elemet ad a tömb végére', 1),
(1148, 283, 'Kitörli a tömböt', 0),
(1149, 283, 'Elemet ad a tömb elejére', 0),
(1150, 284, 'Elemet ad hozzá', 0),
(1151, 284, 'Eltávolítja az utolsó elemet', 1),
(1152, 284, 'Rendezi a tömböt', 0),
(1153, 284, 'Törli a tömböt', 0),
(1154, 285, 'Átrendezi a tömböt', 0),
(1155, 285, 'Eltávolítja az első elemet', 1),
(1156, 285, 'Képet olvas', 0),
(1157, 285, 'Új tömböt hoz létre', 0),
(1158, 286, 'Elem törlése', 0),
(1159, 286, 'Elem hozzáadása a tömb elejére', 1),
(1160, 286, 'Tömb fordítása', 0),
(1161, 286, 'Tömb törlése', 0),
(1162, 287, 'Minden elemet töröl', 0),
(1163, 287, 'Új tömböt hoz létre az eredeti elemeiből átalakítással', 1),
(1164, 287, 'Tömbből stringet készít', 0),
(1165, 287, 'Elemeket fordít', 0),
(1166, 288, 'Minden elem megfordul', 0);
INSERT INTO `valaszok` (`id`, `feladat_id`, `leiras`, `helyes_e`) VALUES
(1167, 288, 'Kiszűri a feltételnek megfelelő elemeket', 1),
(1168, 288, 'Összeadja az elemeket', 0),
(1169, 288, 'Törli a tömböt', 0),
(1170, 289, 'Elemeket kombinál egyetlen értékké', 1),
(1171, 289, 'Elemeket töröl', 0),
(1172, 289, 'Elemeket növel', 0),
(1173, 289, 'Tömböt szétvág', 0),
(1174, 290, 'Véletlenszerű függvény', 0),
(1175, 290, 'Más függvénynek átadott függvény', 1),
(1176, 290, 'Fájl letöltő függvény', 0),
(1177, 290, 'Kép beállító függvény', 0),
(1178, 291, 'Képet rajzol', 0),
(1179, 291, 'Rövidített függvényszintaxis', 1),
(1180, 291, 'Hangot indít', 0),
(1181, 291, 'HTML-t generál', 0),
(1182, 292, 'Globális változó', 0),
(1183, 292, 'Az aktuális objektumra hivatkozik', 1),
(1184, 292, 'Képnév', 0),
(1185, 292, 'Függvény visszatérési értéke', 0),
(1186, 293, 'Csak számokat tartalmaz', 0),
(1187, 293, 'Kulcs érték párok gyűjteménye', 1),
(1188, 293, 'Képcsomag', 0),
(1189, 293, 'Hangfájl', 0),
(1190, 294, 'let o = {}', 1),
(1191, 294, 'let o = newlist', 0),
(1192, 294, 'let o = value()', 0),
(1193, 294, 'let o = array', 0),
(1194, 295, 'Zenei formátum', 0),
(1195, 295, 'A HTML dokumentum objektum modellje', 1),
(1196, 295, 'Fájlgyűjtő', 0),
(1197, 295, 'Képszerkesztő', 0),
(1198, 296, 'Képet tölt be', 0),
(1199, 296, 'Visszaad egy elemet azonosító alapján', 1),
(1200, 296, 'Hangot indít', 0),
(1201, 296, 'Fájlt nyit meg', 0),
(1202, 297, 'Fájlokat rendez', 0),
(1203, 297, 'Visszaadja az első találatot CSS szelektor alapján', 1),
(1204, 297, 'HTML törlése', 0),
(1205, 297, 'Kép kiválasztása', 0),
(1206, 298, 'Animáció rajzoló', 0),
(1207, 298, 'Eseményeket kezelő függvény', 1),
(1208, 298, 'Képmegjelenítő', 0),
(1209, 298, 'Szövegszerkesztő', 0),
(1210, 299, 'Felhasználó beviteli mezőt ír', 0),
(1211, 299, 'Felhasználó rákattint valamire', 1),
(1212, 299, 'Program lezárul', 0),
(1213, 299, 'Kép eltűnik', 0),
(1214, 300, 'Leállít minden JavaScriptet', 0),
(1215, 300, 'Megakadályozza az esemény alapértelmezett működését', 1),
(1216, 300, 'Kép törlése', 0),
(1217, 300, 'Hang indítása', 0),
(1218, 301, 'HTML törlése', 0),
(1219, 301, 'Megállítja az esemény továbbterjedését', 1),
(1220, 301, 'Kép másolása', 0),
(1221, 301, 'Hang rögzítése', 0),
(1222, 302, 'Képfájl', 0),
(1223, 302, 'Aszinkron művelet eredményét jelképező objektum', 1),
(1224, 302, 'Hangminta', 0),
(1225, 302, 'Statikus HTML elem', 0),
(1226, 303, 'A függvény blokkolja a programot', 0),
(1227, 303, 'A függvény ígéreteket használ aszinkron működéshez', 1),
(1228, 303, 'A függvény képet tölt', 0),
(1229, 303, 'A függvény CSS-t ír', 0),
(1230, 304, 'Megállítja a böngészőt', 0),
(1231, 304, 'Megvárja egy promise teljesülését', 1),
(1232, 304, 'Képet zoomol', 0),
(1233, 304, 'Listát töröl', 0),
(1234, 305, 'Képek tömörítése', 0),
(1235, 305, 'Adat letöltése hálózaton keresztül', 1),
(1236, 305, 'Hang feltöltése', 0),
(1237, 305, 'HTML törlése', 0),
(1238, 306, 'A változó értékét', 0),
(1239, 306, 'A változó típusát', 1),
(1240, 306, 'A változó hosszát', 0),
(1241, 306, 'A változó címét', 0),
(1242, 307, 'Nagy szám', 0),
(1243, 307, 'Nem szám', 1),
(1244, 307, 'Kép index', 0),
(1245, 307, 'Hangfrekvencia', 0),
(1246, 308, 'Érvényes szám', 0),
(1247, 308, 'Olyan változó, aminek nincs értéke', 1),
(1248, 308, 'Képtípus', 0),
(1249, 308, 'Hangindex', 0),
(1250, 309, 'Típus és érték összehasonlítása', 0),
(1251, 309, 'Érték összehasonlítása típuskonverzióval', 1),
(1252, 309, 'Logikai NOT', 0),
(1253, 309, 'Függvény meghívása', 0),
(1254, 310, 'Érték összehasonlítás konverzióval', 0),
(1255, 310, 'Érték és típus szigorú összehasonlítása', 1),
(1256, 310, 'Fájl másolása', 0),
(1257, 310, 'Hang törlése', 0),
(1258, 311, 'HTML generátort ad', 0),
(1259, 311, 'Tömbök vagy objektumok szétbontását', 1),
(1260, 311, 'Hang effektet ad', 0),
(1261, 311, 'CSS változót hoz létre', 0),
(1262, 312, 'Hangtorzítás', 0),
(1263, 312, 'Tömbök vagy objektumok elemeinek szétszedése változókra', 1),
(1264, 312, 'Képek összefűzése', 0),
(1265, 312, 'HTML törlése', 0),
(1266, 313, 'Kép renderelés', 0),
(1267, 313, 'Függvény meghívása késleltetéssel', 1),
(1268, 313, 'Hangfelvétel', 0),
(1269, 313, 'Tömb törlése', 0),
(1270, 314, 'Objektum törlése', 0),
(1271, 314, 'JSON szöveg JavaScript objektummá alakítása', 1),
(1272, 314, 'Tömb növelése', 0),
(1273, 314, 'Függvény indítása', 0),
(1274, 315, 'Objektum JSON szöveggé alakítása', 1),
(1275, 315, 'Objektum összevonása', 0),
(1276, 315, 'Objektum törlése', 0),
(1277, 315, 'Hang átalakítása', 0),
(1278, 316, 'let t = array', 0),
(1279, 316, 'let t = []', 1),
(1280, 316, 'let t = object()', 0),
(1281, 316, 'let t = void', 0),
(1282, 317, 'Csak hozzáad elemeket', 0),
(1283, 317, 'Elemeket töröl és beszúr egy tömbben', 1),
(1284, 317, 'Csak rendezi a tömböt', 0),
(1285, 317, 'Elemeket klónoz', 0),
(1286, 318, 'Törli a tömböt', 0),
(1287, 318, 'A tömb egy részének másolatát adja vissza', 1),
(1288, 318, 'Megfordítja a tömböt', 0),
(1289, 318, 'Bezárja a programot', 0),
(1290, 319, 'let o = array', 0),
(1291, 319, 'let o = {}', 1),
(1292, 319, 'let o = []', 0),
(1293, 319, 'let o = number', 0),
(1294, 320, 'Függvény törlése', 0),
(1295, 320, 'Objektum kulcsa és értéke', 1),
(1296, 320, 'Elem helyzete tömbben', 0),
(1297, 320, 'Hang neve', 0),
(1298, 321, 'obj(property)', 0),
(1299, 321, 'obj.property', 1),
(1300, 321, 'obj property', 0),
(1301, 321, 'obj->property', 0),
(1302, 322, 'obj(property)', 0),
(1303, 322, 'obj[\"property\"]', 1),
(1304, 322, 'obj<property>', 0),
(1305, 322, 'obj{property}', 0),
(1306, 323, 'Objektum képpel', 0),
(1307, 323, 'Másik objektumot tartalmazó objektum', 1),
(1308, 323, 'Hangot tartalmazó objektum', 0),
(1309, 323, 'Függvény nélküli objektum', 0),
(1310, 324, 'Tömb rendezése', 0),
(1311, 324, 'Objektum kulcsainak bejárása', 1),
(1312, 324, 'Hangok listázása', 0),
(1313, 324, 'Kép megjelenítése', 0),
(1314, 325, 'Megnézi hogy az objektum rendelkezik e adott kulccsal', 1),
(1315, 325, 'Egy kulcsot töröl', 0),
(1316, 325, 'Egy kulcsot módosít', 0),
(1317, 325, 'Egy kulcsot klónoz', 0),
(1318, 326, 'Objektum értékeinek listázása', 0),
(1319, 326, 'Objektum kulcsainak listája', 1),
(1320, 326, 'Hangok listája', 0),
(1321, 326, 'Képek listája', 0),
(1322, 327, 'Objektum kulcsai', 0),
(1323, 327, 'Objektum értékei', 1),
(1324, 327, 'Objektum neve', 0),
(1325, 327, 'Típusazonosító', 0),
(1326, 328, 'Csak kulcsok listája', 0),
(1327, 328, 'Kulcs érték párok listája', 1),
(1328, 328, 'Csak értékek listája', 0),
(1329, 328, 'Objektum törlése', 0),
(1330, 329, 'Csak a felszíni referencia másolódik', 0),
(1331, 329, 'Az objektum teljes tartalma lemásolódik függetlenül', 1),
(1332, 329, 'Objektum törlődik', 0),
(1333, 329, 'Objektum neve módosul', 0),
(1334, 330, 'Nem másolódik semmi', 0),
(1335, 330, 'Csak a felső szintű propertyk másolódnak, a belső objektumok referencia marad', 1),
(1336, 330, 'Teljes mélységi másolat', 0),
(1337, 330, 'Elem törlés', 0),
(1338, 331, 'Objektum törlése', 0),
(1339, 331, 'Objektum mélységi másolása', 1),
(1340, 331, 'Objektum konvertálása számra', 0),
(1341, 331, 'Objektum felosztása', 0),
(1342, 332, 'Hangmásolat', 0),
(1343, 332, 'Objektum deep copy JSON stringify és parse segítségével', 1),
(1344, 332, 'Objektum törlése', 0),
(1345, 332, 'Objektum átrendezése', 0),
(1346, 333, 'let a = spread t', 0),
(1347, 333, 'let a = [...t]', 1),
(1348, 333, 'let a = copy t', 0),
(1349, 333, 'let a = =t', 0),
(1350, 334, 'let o = expand(obj)', 0),
(1351, 334, 'let o = {...obj}', 1),
(1352, 334, 'let o = clone obj', 0),
(1353, 334, 'let o = obj->copy', 0),
(1354, 335, 'Első elem értéke', 0),
(1355, 335, 'A tömb elemeinek száma', 1),
(1356, 335, 'A tömb memóriamérete', 0),
(1357, 335, 'Csak a változók neve', 0),
(1358, 336, 'Elemek sorrendjét megfordítja', 0),
(1359, 336, 'Megmondja hogy tartalmaz e egy elemet', 1),
(1360, 336, 'Elemeket töröl', 0),
(1361, 336, 'Elemeket összefűz', 0),
(1362, 337, 'Elemeket töröl', 0),
(1363, 337, 'Megadja az első előfordulás indexét', 1),
(1364, 337, 'Megadja az utolsó elem értékét', 0),
(1365, 337, 'Tömböt szétvág', 0),
(1366, 338, 'Első elem indexét adja', 0),
(1367, 338, 'Utolsó előfordulás indexét adja', 1),
(1368, 338, 'Elemeket töröl', 0),
(1369, 338, 'Elemeket hozzáad', 0),
(1370, 339, 'Megsemmisíti a tömböt', 0),
(1371, 339, 'Rendezi a tömböt', 1),
(1372, 339, 'Elemeket számokká alakít', 0),
(1373, 339, 'Elemeket töröl', 0),
(1374, 340, 'Tömböt kiüríti', 0),
(1375, 340, 'Elemek sorrendjét megfordítja', 1),
(1376, 340, 'Elemek értékét lenullázza', 0),
(1377, 340, 'Elemeket szétoszt', 0),
(1378, 341, 'Elmossa a képet', 0),
(1379, 341, 'Összefűz több tömböt', 1),
(1380, 341, 'Elemeket töröl', 0),
(1381, 341, 'Hangot indít', 0),
(1382, 342, 'Elemeket rendez', 0),
(1383, 342, 'Tömb elemeit összefűzi sztringgé', 1),
(1384, 342, 'Elemeket másol', 0),
(1385, 342, 'Tömb méretét csökkenti', 0),
(1386, 343, 'Mindegyik elem törlődik', 0),
(1387, 343, 'Igaz ha minden elem teljesíti a feltételt', 1),
(1388, 343, 'Elemeket számmá alakít', 0),
(1389, 343, 'Elemeket rendezi', 0),
(1390, 344, 'Minden elem igaz', 0),
(1391, 344, 'Igaz ha legalább egy elem teljesíti a feltételt', 1),
(1392, 344, 'Tömböt törli', 0),
(1393, 344, 'Hangot indít', 0),
(1394, 345, 'Elemeket töröl', 0),
(1395, 345, 'Minden elemre meghív egy függvényt', 1),
(1396, 345, 'Elemeket összekever', 0),
(1397, 345, 'Elemeket összead', 0),
(1398, 346, 'Eltávolít egy elemet', 0),
(1399, 346, 'Visszaadja az első elemet ami megfelel a feltételnek', 1),
(1400, 346, 'Minden elemet összegez', 0),
(1401, 346, 'Elemeket fordít', 0),
(1402, 347, 'Tömb utolsó elemét adja', 0),
(1403, 347, 'A feltételnek megfelelő első elem indexét adja', 1),
(1404, 347, 'Elemeket töröl', 0),
(1405, 347, 'Képet átalakít', 0),
(1406, 348, 'Elemeket töröl', 0),
(1407, 348, 'Kitölt egy tartományt adott értékkel', 1),
(1408, 348, 'Elemeket összefűz', 0),
(1409, 348, 'Elemeket véletlenszerűvé tesz', 0),
(1410, 349, 'Tömböt töröl', 0),
(1411, 349, 'Egy szint mélységig kisimítja a tömböt', 1),
(1412, 349, 'Elemeket növeli', 0),
(1413, 349, 'Elemeket tömbbé alakít', 0),
(1414, 350, 'Mindent töröl', 0),
(1415, 350, 'Map után egy szintű flatten műveletet végez', 1),
(1416, 350, 'Több szintű flatten műveletet végez minden szinten', 0),
(1417, 350, 'Elemeket összerak', 0),
(1418, 351, 'Elem törlése', 0),
(1419, 351, 'Tömb elemeinek szétszedése új tömbbe', 1),
(1420, 351, 'Hang indítása', 0),
(1421, 351, 'Elemek összevonása', 0),
(1422, 352, 'Tömb átalakítása objektummá', 0),
(1423, 352, 'Tömb elemeinek változókba történő szétszedése', 1),
(1424, 352, 'Tömb törlése', 0),
(1425, 352, 'Elemek összevonása', 0),
(1426, 353, 'Törli a tömböt', 0),
(1427, 353, 'Tömb elemeit átmásolja a tömbön belül másik helyre', 1),
(1428, 353, 'Elemeket rendez', 0),
(1429, 353, 'Elemeket képpé alakít', 0),
(1430, 354, 'A tömböt helyben rendezi', 0),
(1431, 354, 'Új rendezett tömböt ad vissza az eredeti módosítása nélkül', 1),
(1432, 354, 'Törli a tömböt', 0),
(1433, 354, 'Elemeket másol', 0),
(1434, 355, 'A CSS hivatalos szabványa', 0),
(1435, 355, 'A JavaScript nyelvet meghatározó szabvány', 1),
(1436, 355, 'A HTML kiterjesztése', 0),
(1437, 355, 'A JavaScript grafikus motorja', 0),
(1438, 356, '2010', 0),
(1439, 356, '2015', 1),
(1440, 356, '2018', 0),
(1441, 356, '2020', 0),
(1442, 357, 'document write', 0),
(1443, 357, 'let és const kulcsszavakat', 1),
(1444, 357, 'alert funkciót', 0),
(1445, 357, 'innerHTML tulajdonságot', 0),
(1446, 358, 'func => {}', 0),
(1447, 358, '() => {}', 1),
(1448, 358, '{} => ()', 0);

-- --------------------------------------------------------

--
-- Nézet szerkezete `random_kerdesek`
--
DROP TABLE IF EXISTS `random_kerdesek`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `random_kerdesek`  AS SELECT `f`.`id` AS `id`, `f`.`leiras` AS `leiras`, `f`.`pontszam` AS `pontszam`, `t`.`megnevezes` AS `tipus`, `k`.`megnevezes` AS `kategoria` FROM ((`feladatok` `f` join `kategoriak` `k` on(`k`.`id` = `f`.`kategoria_id`)) join `feladat_tipusok` `t` on(`t`.`id` = `f`.`feladat_tipus_id`)) WHERE `f`.`allapot` = 'elfogadott' AND `k`.`engedelyezett` = '1' ORDER BY rand() ASC ;

-- --------------------------------------------------------

--
-- Nézet szerkezete `valami`
--
DROP TABLE IF EXISTS `valami`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `valami`  AS SELECT `f`.`id` AS `id`, `f`.`leiras` AS `leiras`, `f`.`pontszam` AS `pontszam`, `t`.`megnevezes` AS `tipus`, `k`.`megnevezes` AS `kategoria` FROM ((`feladatok` `f` join `kategoriak` `k` on(`k`.`id` = `f`.`kategoria_id`)) join `feladat_tipusok` `t` on(`t`.`id` = `f`.`feladat_tipus_id`)) WHERE `f`.`allapot` = 'elfogadott' AND `k`.`engedelyezett` = '1' ORDER BY rand() ASC LIMIT 0, 3 ;

--
-- Indexek a kiírt táblákhoz
--

--
-- A tábla indexei `ertekelesek`
--
ALTER TABLE `ertekelesek`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `feladatok`
--
ALTER TABLE `feladatok`
  ADD PRIMARY KEY (`id`),
  ADD KEY `kategoria_id` (`kategoria_id`),
  ADD KEY `feladat_tipus_id` (`feladat_tipus_id`);

--
-- A tábla indexei `feladat_tipusok`
--
ALTER TABLE `feladat_tipusok`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `kategoriak`
--
ALTER TABLE `kategoriak`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `kepek`
--
ALTER TABLE `kepek`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `nem_semmi`
--
ALTER TABLE `nem_semmi`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `tesztek`
--
ALTER TABLE `tesztek`
  ADD PRIMARY KEY (`id`),
  ADD KEY `ertekeles_id` (`ertekeles_id`);

--
-- A tábla indexei `tesztek_feladatai`
--
ALTER TABLE `tesztek_feladatai`
  ADD PRIMARY KEY (`id`),
  ADD KEY `teszt_id` (`teszt_id`),
  ADD KEY `feladat_id` (`feladat_id`);

--
-- A tábla indexei `valaszok`
--
ALTER TABLE `valaszok`
  ADD PRIMARY KEY (`id`),
  ADD KEY `feladat_id` (`feladat_id`);

--
-- A kiírt táblák AUTO_INCREMENT értéke
--

--
-- AUTO_INCREMENT a táblához `ertekelesek`
--
ALTER TABLE `ertekelesek`
  MODIFY `id` tinyint(3) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT a táblához `feladatok`
--
ALTER TABLE `feladatok`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=359;

--
-- AUTO_INCREMENT a táblához `feladat_tipusok`
--
ALTER TABLE `feladat_tipusok`
  MODIFY `id` tinyint(3) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT a táblához `kategoriak`
--
ALTER TABLE `kategoriak`
  MODIFY `id` tinyint(3) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT a táblához `nem_semmi`
--
ALTER TABLE `nem_semmi`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT a táblához `tesztek`
--
ALTER TABLE `tesztek`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `tesztek_feladatai`
--
ALTER TABLE `tesztek_feladatai`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `valaszok`
--
ALTER TABLE `valaszok`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1449;

--
-- Megkötések a kiírt táblákhoz
--

--
-- Megkötések a táblához `feladatok`
--
ALTER TABLE `feladatok`
  ADD CONSTRAINT `feladatok_ibfk_1` FOREIGN KEY (`kategoria_id`) REFERENCES `kategoriak` (`id`),
  ADD CONSTRAINT `feladatok_ibfk_2` FOREIGN KEY (`feladat_tipus_id`) REFERENCES `feladat_tipusok` (`id`);

--
-- Megkötések a táblához `kepek`
--
ALTER TABLE `kepek`
  ADD CONSTRAINT `kepek_ibfk_1` FOREIGN KEY (`id`) REFERENCES `feladatok` (`id`);

--
-- Megkötések a táblához `tesztek`
--
ALTER TABLE `tesztek`
  ADD CONSTRAINT `tesztek_ibfk_1` FOREIGN KEY (`ertekeles_id`) REFERENCES `ertekelesek` (`id`);

--
-- Megkötések a táblához `tesztek_feladatai`
--
ALTER TABLE `tesztek_feladatai`
  ADD CONSTRAINT `tesztek_feladatai_ibfk_1` FOREIGN KEY (`teszt_id`) REFERENCES `tesztek` (`id`),
  ADD CONSTRAINT `tesztek_feladatai_ibfk_2` FOREIGN KEY (`feladat_id`) REFERENCES `feladatok` (`id`);

--
-- Megkötések a táblához `valaszok`
--
ALTER TABLE `valaszok`
  ADD CONSTRAINT `valaszok_ibfk_1` FOREIGN KEY (`feladat_id`) REFERENCES `feladatok` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
