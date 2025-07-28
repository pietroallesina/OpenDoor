use OpenDoor;

-- SEZIONE STORED PROCEDURES --

drop procedure if exists procedura_inserimento_operatore;
delimiter $$
create procedure procedura_inserimento_operatore(in Cognome varchar(64), in Nome varchar(64))
	begin
		insert into
			Operatori(Cognome, Nome)
            values(Cognome, Nome)
		;
    end
$$
delimiter ;

drop procedure if exists procedura_aggiornamento_operatore;
delimiter $$
create procedure procedura_aggiornamento_operatore(in ID smallint unsigned, in Cognome varchar(64), in Nome varchar(64))
	begin
		update Operatori
			set Operatori.Cognome = Cognome, Operatori.Nome = Nome
			where Operatori.ID = ID
		;
    end
$$
delimiter ;

drop procedure if exists procedura_eliminazione_operatore;
delimiter $$
create procedure procedura_eliminazione_operatore(in ID smallint unsigned)
	begin
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
create procedure procedura_aggiornamento_cliente(in ID smallint unsigned, in Cognome varchar(64), in Nome varchar(64), in Regione enum('ITA', 'PAK', 'AN'), in NumeroFamigliari tinyint unsigned, in refill bool)
	begin
		update Clienti
			set
				Clienti.Cognome = Cognome, Clienti.Nome = Nome
                , Clienti.Regione = Regione, Clienti.NumeroFamigliari = NumeroFamigliari
                , Clienti.CreditiDisponibili = if(refill, calcola_crediti_disponibili(NumeroFamigliari), Clienti.CreditiDisponibili) -- condizionale
                , Clienti.AccessiDisponibili = if(refill, calcola_accessi_disponibili(NumeroFamigliari), Clienti.AccessiDisponibili) -- condizionale
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

drop procedure if exists procedura_inserimento_prenotazione;
delimiter $$
create procedure procedura_inserimento_prenotazione(in Cliente smallint unsigned, in Operatore smallint unsigned, in DataPrenotata date)
	begin
		insert into
			Prenotazioni(Cliente, Operatore, DataPrenotata)
            values(Cliente, Operatore, DataPrenotata)
		;
    end
$$
delimiter ;

drop procedure if exists procedura_aggiornamento_prenotazione;
delimiter $$
create procedure procedura_aggiornamento_prenotazione(in ID int, in DataPrenotata date)
	begin
		update Prenotazioni
			set Prenotazione.DataPrenotata = DataPrenotata
			where Prenotazione.ID = ID
		;
    end
$$
delimiter ;

drop procedure if exists procedura_cancellazione_prenotazione;
delimiter $$
create procedure procedura_eliminazione_prenotazione(in ID int unsigned)
	begin
		delete from Prenotazioni where Prenotazioni.ID = ID;
    end
$$
delimiter ;

-- trasformo prenotazione in accesso -> aggiorno Cliente
drop procedure if exists procedura_inserimento_accesso;
delimiter $$
create procedure procedura_inserimento_accesso(in ID int unsigned, in OrarioAccesso time, in CreditiSpesi tinyint unsigned)
	begin

    -- controlli pre-inserimento
		if (select Prenotazioni.OrarioAccesso from Prenotazioni where Prenotazioni.ID = ID) is NOT NULL
			then SIGNAL sqlstate '45000' SET message_text = 'L\'accesso è già stato effettuato: la prenotazione non è più valida';
		
        elseif OrarioAccesso is NULL or CreditiSpesi is NULL or CreditiSpesi = 0
			then SIGNAL sqlstate '45000' SET message_text = 'I campi OrarioAccesso e CreditiSpesi non possono essere NULL';
		
        elseif (select Clienti.AccessiDisponibili from Clienti where Clienti.ID = (select Prenotazioni.Cliente from Prenotazioni where Prenotazioni.ID = ID)) = 0
			then SIGNAL sqlstate '45000' SET message_text = 'Il cliente ha esaurito gli accessi';
		
        elseif (select Clienti.CreditiDisponibili from Clienti where Clienti.ID = (select Prenotazioni.Cliente from Prenotazioni where Prenotazioni.ID = ID)) < CreditiSpesi
			then SIGNAL sqlstate '45000' SET message_text = 'Il cliente ha esaurito i crediti';
		
        end if;

		update Prenotazioni -- Prenotazione diventa Accesso (a livello logico)
			set Prenotazioni.OrarioAccesso = OrarioAccesso, Prenotazioni.CreditiSpesi = CreditiSpesi
			where Prenotazioni.ID = ID
		;
        update Clienti
			set
				Clienti.AccessiDisponibili = Clienti.AccessiDisponibili - 1
				, Clienti.CreditiDisponibili = Clienti.CreditiDisponibili - CreditiSpesi
			where Clienti.ID = (SELECT Cliente from Prenotazioni where Prenotazioni.ID = ID)
		;
    end
$$
delimiter ;
