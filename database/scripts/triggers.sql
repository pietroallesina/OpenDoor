use OpenDoor;
SET GLOBAL event_scheduler = ON;

-- SEZIONE TRIGGER --

drop trigger if exists trigger_inserimento_cliente;
delimiter $$
create trigger trigger_inserimento_cliente BEFORE INSERT on Clienti
	for each row
	begin
		set
			new.AccessiDisponibili = calcola_accessi_disponibili (new.NumeroFamigliari)
			, new.CreditiDisponibili = calcola_crediti_disponibili (new.NumeroFamigliari)
		;
	end
$$
delimiter ;

-- trigger inserimento prenotazione, IDcliente e IDoperatore non possono essere null
drop trigger if exists trigger_inserimento_prenotazione;
delimiter $$
create trigger trigger_inserimento_prenotazione BEFORE INSERT on Prenotazioni
	for each row
    begin
		if new.Cliente is NULL or new.Operatore is NULL
		then SIGNAL sqlstate '45000' SET message_text = 'I campi Cliente e Operatore non possono essere NULL all\'inserimento';
        end if;
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
