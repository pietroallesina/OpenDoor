use OpenDoor;
SET GLOBAL event_scheduler = ON;

-- SEZIONE TRIGGER --

drop trigger if exists trigger_inserimento_cliente;
delimiter $$
create trigger trigger_inserimento_cliente BEFORE INSERT on Clienti
	for each row
	begin
		set
			NEW.AccessiDisponibili = calcola_accessi_disponibili (NEW.NumeroFamigliari)
			, NEW.CreditiDisponibili = calcola_crediti_disponibili (NEW.NumeroFamigliari)
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
				Clienti.AccessiDisponibili = Clienti.AccessiDisponibili - 1
				, Clienti.CreditiDisponibili = Clienti.CreditiDisponibili - NEW.CreditiSpesi
			where Clienti.ID = NEW.Cliente
		;
	end
$$
delimiter ;

-- SEZIONE EVENTS --

drop event if exists aggiornamento_mensile_risorse;
delimiter $$
create event aggiornamento_mensile_risorse on schedule EVERY 1 MONTH STARTS DATE_FORMAT(CURDATE(), '%Y-%m-01')
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
