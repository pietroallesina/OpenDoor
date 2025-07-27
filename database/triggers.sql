use PortaAperta;
SET GLOBAL event_scheduler = ON;

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

-- SEZIONE TRIGGER --

drop trigger if exists trigger_inserimento_cliente;
delimiter $$
create trigger trigger_inserimento_cliente AFTER INSERT on Clienti
	for each row
	begin
		update Clienti
			set
				CreditiDisponibili = calcola_crediti_disponibili (NumeroFamigliari),
				AccessiDisponibili = calcola_accessi_disponibili (NumeroFamigliari)
		;
	end
$$
delimiter ;

drop trigger if exists trigger_aggiornamento_cliente;
delimiter $$
create trigger trigger_aggiornamento_cliente AFTER UPDATE on Clienti
	for each row
	begin
		update Clienti
			set
				CreditiDisponibili = calcola_crediti_disponibili (NumeroFamigliari),
				AccessiDisponibili = calcola_accessi_disponibili (NumeroFamigliari)
		;
	end
$$
delimiter ;

drop trigger if exists trigger_inserimento_accesso;
delimiter $$
create trigger trigger_inserimento_accesso AFTER INSERT on Accessi
	for each row
	begin
		update Clienti
			set
				Clienti.CreditiDisponibili = Clienti.CreditiDisponibili - Accessi.CreditiSpesi,
				Clienti.AccessiDisponibili = Clienti.AccessiDisponibili - 1
			where Clienti.ID = Accessi.Cliente
		;
	end
$$
delimiter ;

drop event if exists aggiornamento_mensile_risorse;
delimiter $$
create event aggiornamento_mensile_risorse on schedule EVERY 1 MONTH
	do
	begin
		update Clienti
			set
				CreditiDisponibili = calcola_crediti_disponibili (NumeroFamigliari),
				AccessiDisponibili = calcola_accessi_disponibili (NumeroFamigliari)
		;
	end
$$
delimiter ;