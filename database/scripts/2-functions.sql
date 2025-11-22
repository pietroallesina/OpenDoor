use OpenDoor;

-- SEZIONE STORED FUNCTIONS --

drop function if exists calcola_accessi_disponibili;
DELIMITER $$
CREATE FUNCTION calcola_accessi_disponibili (NumeroFamigliari TINYINT UNSIGNED) RETURNS TINYINT UNSIGNED DETERMINISTIC
	BEGIN
	    DECLARE valore TINYINT UNSIGNED;

	    SELECT JSON_EXTRACT(Impostazioni.Parametri, CONCAT('$.accessi_mensili."', (
			SELECT jt.jkey
			FROM Impostazioni,
				JSON_TABLE(
					JSON_KEYS(Parametri, '$.accessi_mensili'),
					'$[*]' COLUMNS(jkey VARCHAR(10) PATH '$')
				) AS jt
			WHERE id = 1 AND jt.jkey <= NumeroFamigliari
			ORDER BY jt.jkey DESC
			LIMIT 1
        ), '"'))
		INTO valore
		FROM Impostazioni
		WHERE id = 1;

	    RETURN valore;
	END
$$
DELIMITER ;


drop function if exists calcola_crediti_disponibili;
delimiter $$
create function calcola_crediti_disponibili (NumeroFamigliari tinyint unsigned) returns tinyint unsigned deterministic
	BEGIN
	    DECLARE valore TINYINT UNSIGNED;

	    SELECT JSON_EXTRACT(Impostazioni.Parametri, CONCAT('$.crediti_accesso."', (
			SELECT jt.jkey
			FROM Impostazioni,
				JSON_TABLE(
					JSON_KEYS(Parametri, '$.crediti_accesso'),
					'$[*]' COLUMNS(jkey VARCHAR(10) PATH '$')
				) AS jt
			WHERE id = 1 AND jt.jkey <= NumeroFamigliari
			ORDER BY jt.jkey DESC
			LIMIT 1
        ), '"'))
		INTO valore
		FROM Impostazioni
		WHERE id = 1;

	    RETURN valore;
	END
$$
delimiter ;


drop function if exists limite_accessi;
delimiter $$
create function limite_accessi() returns tinyint unsigned deterministic
	begin
		declare limite tinyint unsigned;

		select CAST(
	        JSON_UNQUOTE(
	            JSON_EXTRACT(Parametri, '$.limite_accessi')
	        ) AS UNSIGNED
	    )
	    into limite
		from Impostazioni
	    where id = 1;

	    return limite;
	end
$$
delimiter ;

drop function if exists limite_crediti;
delimiter $$
create function limite_crediti() returns smallint unsigned deterministic
	begin
		declare limite smallint unsigned;

		select CAST(
	        JSON_UNQUOTE(
	            JSON_EXTRACT(Parametri, '$.limite_crediti')
	        ) AS UNSIGNED
	    )
	    into limite
		from Impostazioni
	    where id = 1;

	    return limite;
	end
$$
delimiter ;

drop function if exists ampiezza_fascia_oraria;
delimiter $$
create function ampiezza_fascia_oraria() returns tinyint unsigned deterministic
	begin
		declare amp tinyint unsigned;

		select CAST(
	        JSON_UNQUOTE(
	            JSON_EXTRACT(Parametri, '$.ampiezza_fascia_oraria')
	        ) AS UNSIGNED
	    )
	    into amp
		from Impostazioni
	    where id = 1;

	    return amp;
	end
$$
delimiter ;

drop function if exists orario_inizio;
delimiter $$
create function orario_inizio() returns time deterministic
	begin
		declare orario time;

		select CAST(
	        JSON_UNQUOTE(
	            JSON_EXTRACT(Parametri, '$.orario_inizio')
	        ) AS UNSIGNED
	    )
	    into orario
		from Impostazioni
	    where id = 1;

	    return orario;
	end
$$
delimiter ;

drop function if exists orario_fine;
delimiter $$
create function orario_fine() returns time deterministic
	begin
		declare orario time;

		select CAST(
	        JSON_UNQUOTE(
	            JSON_EXTRACT(Parametri, '$.orario_fine')
	        ) AS UNSIGNED
	    )
	    into orario
		from Impostazioni
	    where id = 1;

	    return orario;
	end
$$
delimiter ;
