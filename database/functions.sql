use OpenDoor;

-- SEZIONE STORED FUNCTIONS --

drop function if exists calcola_crediti_disponibili;
delimiter $$
create function calcola_crediti_disponibili (NumeroFamigliari tinyint unsigned) returns tinyint unsigned deterministic
	begin
		return (
			case NumeroFamigliari
				when 1 then 40
				when 2 then 60
				when 3 then 75
				when 4 then 90
				when 5 then 105
				else 120
			end
        );
	end
$$
delimiter ;

drop function if exists calcola_accessi_disponibili;
delimiter $$
create function calcola_accessi_disponibili (NumeroFamigliari tinyint unsigned) returns tinyint unsigned deterministic
	begin
		return (
			case
				when NumeroFamigliari <= 3 then 2
				else 3
			end
        );
	end
$$
delimiter ;
