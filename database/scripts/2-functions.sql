use OpenDoor;

-- SEZIONE STORED FUNCTIONS --

drop function if exists calcola_accessi_disponibili;
DELIMITER $$
CREATE FUNCTION calcola_accessi_disponibili (NumeroFamigliari TINYINT UNSIGNED) RETURNS TINYINT UNSIGNED DETERMINISTIC
	BEGIN
	    DECLARE valore TINYINT UNSIGNED;

	    SELECT CAST(
	        JSON_UNQUOTE(
	            JSON_EXTRACT(Parametri, CONCAT('$.accessi_mensili.', k))
	        ) AS UNSIGNED
	    )
	    INTO valore
	    FROM (
	        SELECT JSON_UNQUOTE(jt.key) AS k
	        FROM Impostazioni,
	             JSON_TABLE(
	                 JSON_KEYS(Parametri, '$.accessi_mensili'),
	                 '$[*]' COLUMNS(key VARCHAR(10) PATH '$')
	             ) AS jt
	        WHERE id = 1
	          AND CAST(jt.key AS UNSIGNED) <= NumeroFamigliari
	        ORDER BY CAST(jt.key AS UNSIGNED) DESC
	        LIMIT 1
	    ) AS sub;

	    RETURN valore;
	END
$$
DELIMITER ;


drop function if exists calcola_crediti_disponibili;
delimiter $$
create function calcola_crediti_disponibili (NumeroFamigliari tinyint unsigned) returns tinyint unsigned deterministic
	begin
		declare crediti tinyint unsigned;

		select cast(json_unquote(
			json_extract(Parametri, CONCAT('$.crediti_accesso.', NumeroFamigliari)))
			as tinyint unsigned)
		into crediti
		from Impostazioni
		where id = 1;

		return crediti;
	end
$$
delimiter ;
