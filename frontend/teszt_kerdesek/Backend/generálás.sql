-- a) 20 kérdésből álló teszt
--   1-es kategóriából 8 db kérdésből
--   5-es kategóriából 7 db kérdésből
--   3-as kategóriából 5 db kérdésből 
--   JSON
'[{"id":1,"db":8},{"id":5,"db":7},{"id":3,"db":5}]'
-- b) 30 kérdésből álló teszt
--   bármelyik kategóriából
--   JSON '[{"id":-1,"db":30}]'
-- egy teszt feladatsor generálása
-- feladatok
SELECT f.id, f.leiras, f.pontszam, f.feladat_tipus_id, f.kategoria_id, k.megnevezes
FROM feladatok AS f
INNER JOIN kategoriak AS k ON k.id = f.kategoria_id
WHERE k.engedelyezett = 1 AND f.allapot='elfogadott' AND f.kategoria_id = 1
ORDER BY RAND()
LIMIT 8;
-- egy feladathoz tartozó válaszok
SELECT id, leiras, helyes_e
FROM valaszok
WHERE feladat_id = 23
ORDER BY RAND()

kerdes = {
  id:...,
  leiras:'...',
  pontszam:...,
  feladat_tipus_id:...,
  kategoria_id:...,
  kategoria:'...',
  valaszok : [
	{id:..., leiras:'...', helyes_e:...},
	{id:..., leiras:'...', helyes_e:...},
	{id:..., leiras:'...', helyes_e:...},
	...
  ]
};

tesztkerdesek = [
  kerdes : {.....},
  kerdes : {.....},
  kerdes : {.....},
  kerdes : {.....},
  ...
]

-- helyi/lokális változó: deklarálni, nincs @, csak az eljáráson belül lesz látható
-- globális/munkamenet/session változó: nem kell deklarálni, van @, eljáráson kívül is elérhető


DROP PROCEDURE IF EXISTS teszt_generalasa_jo;
DELIMITER $$
CREATE PROCEDURE teszt_generalasa_jo(
	IN p_bemeneti_json TEXT,
	OUT p_kimeneti_json JSON
	)
BEGIN
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
		SET v_nincs_tobb_feladat = FALSE;
		
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
DELIMITER ;

-- meghívás
-- SET @be = '[{"id":-1,"db":30}]';
SET @be = '[{"id":1,"db":8},{"id":5,"db":7},{"id":3,"db":5}]';
SET @ki = NULL;
CALL teszt_generalasa_jo(@be, @ki);
SELECT @ki;

