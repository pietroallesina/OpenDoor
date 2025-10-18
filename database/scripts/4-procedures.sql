use OpenDoor;

-- SEZIONE STORED PROCEDURES --

drop procedure if exists procedura_aggiornamento_impostazioni;
delimiter $$
create procedure procedura_aggiornamento_impostazioni(in parametro varchar(255), in valore json)
	begin
		update Impostazioni
			set Parametri = json_replace(
				Parametri,
				concat('$.', parametro),
				valore
			)
			where id = 1
		;
	end
$$
delimiter ;

drop procedure if exists procedura_inserimento_operatore;
delimiter $$
create procedure procedura_inserimento_operatore(in Cognome varchar(64), in Nome varchar(64), in Password varchar(255), in Admin boolean)
	begin
		-- controllo se l'operatore esiste già
		if exists(select * from Operatori where Operatori.Cognome = Cognome and Operatori.Nome = Nome)
			then SIGNAL sqlstate '45000' SET message_text = 'Operatore già esistente';
		end if;

		insert into
			Operatori(Cognome, Nome, Password, Admin)
            values(Cognome, Nome, Password, Admin)
		;
		-- restituisco l'ID dell'operatore appena inserito
		select ID from Operatori where
			Operatori.Cognome = Cognome
			and Operatori.Nome = Nome
		;
    end
$$
delimiter ;

drop procedure if exists procedura_aggiornamento_operatore;
delimiter $$
create procedure procedura_aggiornamento_operatore(in ID smallint unsigned, in Cognome varchar(64), in Nome varchar(64), in Admin boolean)
	begin
		-- controllo se l'operatore esiste già
		if not exists(select * from Operatori where Operatori.ID = ID)
			then SIGNAL sqlstate '45000' SET message_text = 'Operatore non trovato';
		end if;

		update Operatori
			set Operatori.Cognome = Cognome, Operatori.Nome = Nome, Operatori.Admin = Admin
			where Operatori.ID = ID
		;
    end
$$
delimiter ;

drop procedure if exists procedura_login_operatore;
delimiter $$
create procedure procedura_login_operatore(in Cognome varchar(64), in Nome varchar(64))
	begin
		-- controllo se l'operatore esiste già e se la password è corretta
		if not exists(select * from Operatori where Operatori.Cognome = Cognome and Operatori.Nome = Nome)
			then SIGNAL sqlstate '45000' SET message_text = 'Operatore non trovato';
		end if;

		-- restituisco la password hashata dell'operatore
		select Password, ID, Admin from Operatori where Operatori.Cognome = Cognome and Operatori.Nome = Nome;
	end
$$
delimiter ;

drop procedure if exists procedura_eliminazione_operatore;
delimiter $$
create procedure procedura_eliminazione_operatore(in ID smallint unsigned)
	begin
		-- controllo se l'operatore esiste già
		if not exists(select * from Operatori where Operatori.ID = ID)
			then SIGNAL sqlstate '45000' SET message_text = 'Operatore non trovato';
		end if;

		delete from Operatori where Operatori.ID = ID;
    end
$$
delimiter ;

drop procedure if exists procedura_inserimento_cliente;
delimiter $$
create procedure procedura_inserimento_cliente(in Cognome varchar(64), in Nome varchar(64), in Regione enum('ITA', 'PAK', 'AN'), in NumeroFamigliari tinyint unsigned)
	begin
		insert into
			Clienti(Cognome, Nome, Regione, NumeroFamigliari, AccessiDisponibili, CreditiDisponibili)
			values(Cognome, Nome, Regione, NumeroFamigliari, calcola_accessi_disponibili(NumeroFamigliari), calcola_crediti_disponibili(NumeroFamigliari))
		;
	end
$$
delimiter ;

drop procedure if exists procedura_aggiornamento_cliente;
delimiter $$
create procedure procedura_aggiornamento_cliente(in ID smallint unsigned, in Cognome varchar(64), in Nome varchar(64), in Regione enum('ITA', 'PAK', 'AN'), in NumeroFamigliari tinyint unsigned, in refill boolean)
	begin
		update Clienti
			set
				Clienti.Cognome = Cognome, Clienti.Nome = Nome
                , Clienti.Regione = Regione, Clienti.NumeroFamigliari = NumeroFamigliari
                , Clienti.AccessiDisponibili = if(refill, calcola_accessi_disponibili(NumeroFamigliari), Clienti.AccessiDisponibili) -- condizionale
                , Clienti.CreditiDisponibili = if(refill, calcola_crediti_disponibili(NumeroFamigliari), Clienti.CreditiDisponibili) -- condizionale
			where Clienti.ID = ID
		;
	end
$$
delimiter ;

drop procedure if exists procedura_eliminazione_cliente;
delimiter $$
create procedure procedura_eliminazione_cliente(in ID smallint unsigned)
	begin
		delete from Clienti where Clienti.ID = ID;
    end
$$
delimiter ;

drop procedure if exists procedura_restituisci_dati_cliente;
delimiter $$
create procedure procedura_restituisci_dati_cliente(in Cognome varchar(64), in Nome varchar(64))
	begin
		select ID, Regione, NumeroFamigliari, AccessiDisponibili, CreditiDisponibili from Clienti where Clienti.Cognome = Cognome and Clienti.Nome = Nome;
	end
$$
delimiter ;

-- Controllo disponibilità accessi, crediti, fascia oraria, accessi e crediti giornalieri
drop procedure if exists procedura_inserimento_prenotazione;
delimiter $$
create procedure procedura_inserimento_prenotazione(in Cliente smallint unsigned, in Operatore smallint unsigned, in DataPrenotata date, in Crediti tinyint unsigned)
	begin
		if (select Clienti.AccessiDisponibili from Clienti where Clienti.ID = (select Prenotazioni.Cliente from Prenotazioni where Prenotazioni.ID = ID)) = 0
			then SIGNAL sqlstate '45000' SET message_text = 'Il cliente ha esaurito gli accessi';

		elseif (select Clienti.CreditiDisponibili from Clienti where Clienti.ID = (select Prenotazioni.Cliente from Prenotazioni where Prenotazioni.ID = ID)) < Crediti
			then SIGNAL sqlstate '45000' SET message_text = 'Crediti insufficienti per la prenotazione';

		elseif (select Prenotazioni.Stato from Prenotazioni where Prenotazioni.DataPrenotata = DataPrenotata) = 'PRENOTATA'
			then SIGNAL sqlstate '45000' SET message_text = 'Slot non disponibile';

		-- somma accessi delle prenotazioni nel dato giorno
		elseif (select COUNT(*) from Prenotazioni where Prenotazioni.DataPrenotata = DataPrenotata) >= limite_accessi()
			then SIGNAL sqlstate '45000' SET message_text = 'Limite accessi giornaliero superato';

		-- somma crediti delle prenotazioni nel dato giorno
		elseif (select SUM(Prenotazioni.Crediti) from Prenotazioni where Prenotazioni.DataPrenotata = DataPrenotata) + Crediti > limite_crediti()
			then SIGNAL sqlstate '45000' SET message_text = 'Limite crediti giornaliero superato';

		end if;

		update Clienti
			set
				Clienti.AccessiDisponibili = Clienti.AccessiDisponibili - 1
				, Clienti.CreditiDisponibili = Clienti.CreditiDisponibili - Crediti
			where Clienti.ID = Cliente
		;

		insert into
			Prenotazioni(Cliente, Operatore, DataPrenotata, Crediti)
            values(Cliente, Operatore, DataPrenotata, Crediti)
		;
    end
$$
delimiter ;

drop procedure if exists procedura_aggiornamento_prenotazione;
delimiter $$
create procedure procedura_aggiornamento_prenotazione(in ID int, in DataPrenotata date, in Crediti tinyint unsigned)
	begin
		declare Cliente smallint unsigned;
		declare old_Crediti tinyint unsigned;

		if (select Prenotazioni.Stato from Prenotazioni where Prenotazioni.ID = ID) != 'PRENOTATA'
			then SIGNAL sqlstate '45000' SET message_text = 'La prenotazione non è in stato PRENOTATA';
		end if;

		set Cliente = (select Prenotazioni.Cliente from Prenotazioni where Prenotazioni.ID = ID);
		if Cliente is NULL
			then SIGNAL sqlstate '45000' SET message_text = 'Prenotazione non trovata';
		end if;

		set old_Crediti = (select Prenotazioni.Crediti from Prenotazioni where Prenotazioni.ID = ID);

		if (select Clienti.CreditiDisponibili from Clienti where Clienti.ID = Cliente) + old_Crediti < Crediti
			then SIGNAL sqlstate '45000' SET message_text = 'Crediti insufficienti per la prenotazione';
		end if;

		update Prenotazioni
			set Prenotazioni.DataPrenotata = DataPrenotata, Prenotazioni.Crediti = Crediti
			where Prenotazioni.ID = ID
		;
		update Clienti
			set
				Clienti.CreditiDisponibili = Clienti.CreditiDisponibili + old_Crediti - Crediti
			where Clienti.ID = Cliente
		;
    end
$$
delimiter ;

drop procedure if exists procedura_annullamento_prenotazione;
delimiter $$
create procedure procedura_annullamento_prenotazione(in ID int unsigned)
	begin
		if (select Prenotazioni.Stato from Prenotazioni where Prenotazioni.ID = ID) != 'PRENOTATA'
			then SIGNAL sqlstate '45000' SET message_text = 'La prenotazione non è in stato PRENOTATA';
		end if;

		update Clienti
			set
				Clienti.AccessiDisponibili = Clienti.AccessiDisponibili + 1
				, Clienti.CreditiDisponibili = Clienti.CreditiDisponibili + (select Prenotazioni.Crediti from Prenotazioni where Prenotazioni.ID = ID)
			where Clienti.ID = (SELECT Cliente from Prenotazioni where Prenotazioni.ID = ID)
		;

		update Prenotazioni
			set Prenotazioni.Stato = 'ANNULLATA'
			where Prenotazioni.ID = ID
		;
    end
$$
delimiter ;

drop procedure if exists procedura_restituisci_eventi;
delimiter $$
create procedure procedura_restituisci_eventi(in DataInizio date, in DataFine date)
	begin
		select Prenotazioni.ID as id, Prenotazioni.DataPrenotata as data, Clienti.Nome as nome, Clienti.Cognome as cognome
		from Prenotazioni
		join Clienti on Prenotazioni.Cliente = Clienti.ID
		where Prenotazioni.DataPrenotata between DataInizio and DataFine;
	end
$$
delimiter ;

drop procedure if exists procedura_restituisci_dati_prenotazione;
delimiter $$
create procedure procedura_restituisci_dati_prenotazione(in ID int unsigned)
	begin
		select *
		from Prenotazioni join Clienti on Prenotazioni.Cliente = Clienti.ID
		where Prenotazioni.ID = ID;
	end
$$
delimiter ;

-- trasformo prenotazione in accesso -> aggiorno Cliente
drop procedure if exists procedura_inserimento_accesso;
delimiter $$
create procedure procedura_inserimento_accesso(in ID int unsigned, in OrarioAccesso time)
	begin
		if (select Prenotazioni.Stato from Prenotazioni where Prenotazioni.ID = ID) != 'PRENOTATA'
			then SIGNAL sqlstate '45000' SET message_text = 'La prenotazione non è in stato PRENOTATA';

        elseif OrarioAccesso is NULL
			then SIGNAL sqlstate '45000' SET message_text = 'Il campo OrarioAccesso non può essere NULL';

        end if;

		update Prenotazioni -- Prenotazione diventa Accesso (a livello logico)
			set Prenotazioni.OrarioAccesso = OrarioAccesso
			, Prenotazioni.Stato = 'COMPLETATA'
			where Prenotazioni.ID = ID
		;
    end
$$
delimiter ;
