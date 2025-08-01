use OpenDoor;

-- SEZIONE STORED PROCEDURES --

drop procedure if exists procedura_inserimento_operatore;
delimiter $$
create procedure procedura_inserimento_operatore(in Cognome varchar(64), in Nome varchar(64), in Password varchar(255), in Admin boolean)
	begin
		insert into
			Operatori(Cognome, Nome, Password, Admin)
            values(Cognome, Nome, Password, Admin)
		;
    end
$$
delimiter ;

drop procedure if exists procedura_aggiornamento_operatore;
delimiter $$
create procedure procedura_aggiornamento_operatore(in ID smallint unsigned, in Cognome varchar(64), in Nome varchar(64), in Admin boolean)
	begin
		update Operatori
			set Operatori.Cognome = Cognome, Operatori.Nome = Nome, Operatori.Admin = Admin
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

drop procedure if exists procedura_inserimento_prenotazione;
delimiter $$
create procedure procedura_inserimento_prenotazione(in Cliente smallint unsigned, in Operatore smallint unsigned, in DataPrenotata date, in CreditiSpesi tinyint unsigned)
	begin
		if (select Clienti.AccessiDisponibili from Clienti where Clienti.ID = (select Prenotazioni.Cliente from Prenotazioni where Prenotazioni.ID = ID)) = 0
			then SIGNAL sqlstate '45000' SET message_text = 'Il cliente ha esaurito gli accessi';

		else if (select Clienti.CreditiDisponibili from Clienti where Clienti.ID = (select Prenotazioni.Cliente from Prenotazioni where Prenotazioni.ID = ID)) < CreditiSpesi
			then SIGNAL sqlstate '45000' SET message_text = 'Crediti insufficienti per la prenotazione';

		end if;

		update Clienti
			set
				Clienti.AccessiDisponibili = Clienti.AccessiDisponibili - 1
				, Clienti.CreditiDisponibili = Clienti.CreditiDisponibili - CreditiSpesi
			where Clienti.ID = Cliente
		;

		insert into
			Prenotazioni(Cliente, Operatore, DataPrenotata, CreditiSpesi)
            values(Cliente, Operatore, DataPrenotata, CreditiSpesi)
		;
    end
$$
delimiter ;

drop procedure if exists procedura_aggiornamento_prenotazione;
delimiter $$
create procedure procedura_aggiornamento_prenotazione(in ID int, in DataPrenotata date, in CreditiSpesi tinyint unsigned)
	begin
		if (select Prenotazioni.Stato from Prenotazioni where Prenotazioni.ID = ID) != 'PRENOTATA'
			then SIGNAL sqlstate '45000' SET message_text = 'La prenotazione non è in stato PRENOTATA';

		-- variabili locali
		set @Cliente = (select Prenotazioni.Cliente from Prenotazioni where Prenotazioni.ID = ID);
		if @Cliente is NULL
			then SIGNAL sqlstate '45000' SET message_text = 'Prenotazione non trovata';
		end if;

		set @old_CreditiSpesi = (select Prenotazioni.CreditiSpesi from Prenotazioni where Prenotazioni.ID = ID);

		if (select Clienti.CreditiDisponibili from Clienti where Clienti.ID = @Cliente) + @old_CreditiSpesi < CreditiSpesi
			then SIGNAL sqlstate '45000' SET message_text = 'Crediti insufficienti per la prenotazione';
		end if;

		update Prenotazioni
			set Prenotazioni.DataPrenotata = DataPrenotata, Prenotazioni.CreditiSpesi = CreditiSpesi
			where Prenotazioni.ID = ID
		;
		update Clienti
			set
				Clienti.CreditiDisponibili = Clienti.CreditiDisponibili + @old_CreditiSpesi - CreditiSpesi
			where Clienti.ID = @Cliente
		;
    end
$$
delimiter ;

drop procedure if exists procedura_annullamento_prenotazione;
delimiter $$
create procedure procedura_annullamento_prenotazione(in ID int unsigned)
	begin
		IF (select Prenotazioni.Stato from Prenotazioni where Prenotazioni.ID = ID) != 'PRENOTATA'
			then SIGNAL sqlstate '45000' SET message_text = 'La prenotazione non è in stato PRENOTATA';

		update Clienti
			set
				Clienti.AccessiDisponibili = Clienti.AccessiDisponibili + 1
				, Clienti.CreditiDisponibili = Clienti.CreditiDisponibili + (select Prenotazioni.CreditiSpesi from Prenotazioni where Prenotazioni.ID = ID)
			where Clienti.ID = (SELECT Cliente from Prenotazioni where Prenotazioni.ID = ID)
		;

		update Prenotazioni
			set Prenotazioni.Stato = 'ANNULLATA'
			where Prenotazioni.ID = ID
		;
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

        else if OrarioAccesso is NULL
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
