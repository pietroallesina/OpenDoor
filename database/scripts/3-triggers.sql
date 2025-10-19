use OpenDoor;
SET GLOBAL event_scheduler = ON;

-- SEZIONE TRIGGER --

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

drop event if exists controllo_scadenza_prenotazioni;
delimiter $$
create event controllo_scadenza_prenotazioni on schedule EVERY 1 HOUR STARTS CURDATE()
	do
	begin
		-- Finisci
		update Prenotazioni
			set Stato = 'INATTESA'
			where Stato = 'PRENOTATA' and DataPrenotata < CURDATE()
		;
	end
$$
delimiter ;
