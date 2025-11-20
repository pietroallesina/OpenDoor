use OpenDoor;

-- SEZIONE STORED PROCEDURES --

drop procedure if exists procedura_aggiornamento_impostazioni;
delimiter $$
create procedure procedura_aggiornamento_impostazioni(in parametro varchar(255), in valore json)
	begin
		update Impostazioni
			set Parametri = json_replace(
				Parametri,
				concat('$."', parametro, '"'), -- check string escaping
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
			Clienti(Cognome, Nome, Regione, NumeroFamigliari)
			values(Cognome, Nome, Regione, NumeroFamigliari)
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
				Clienti.Cognome = Cognome, Clienti.Nome = Nome, Clienti.Regione = Regione, Clienti.NumeroFamigliari = NumeroFamigliari
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
		select ID, Regione, NumeroFamigliari, calcola_crediti_disponibili(Clienti.NumeroFamigliari) as CreditiDisponibili from Clienti where Clienti.Cognome = Cognome and Clienti.Nome = Nome;
	end
$$
delimiter ;

-- aggiungi parametro opzionale ID per modifica (eliminazione e reinserimento)
drop procedure if exists procedura_inserimento_prenotazione;
delimiter $$
create procedure procedura_inserimento_prenotazione(in Cliente smallint unsigned, in Operatore smallint unsigned, in Data date, in Orario time, in Crediti tinyint unsigned, in Descrizione varchar(255), in ID int unsigned)
    begin
        declare nf tinyint unsigned;

        -- get cliente.NumeroFamigliari
        select NumeroFamigliari into nf from Clienti where Clienti.ID = Cliente;

        -- controllo se lo slot è disponibile
        if exists(
            select 1 from Prenotazioni
            where Prenotazioni.Data = Data and Prenotazioni.Orario = Orario and Prenotazioni.Stato = 'PRENOTATA'
        )
            then SIGNAL sqlstate '45000' SET message_text = 'Slot non disponibile';

        -- controllo disponibilità accessi (use date range for the month)
        elseif (select COUNT(*) from Prenotazioni
                where Prenotazioni.Cliente = Cliente
                  and Prenotazioni.Data >= DATE_SUB(Data, INTERVAL DAY(Data)-1 DAY)
                  and Prenotazioni.Data < DATE_ADD(DATE_SUB(Data, INTERVAL DAY(Data)-1 DAY), INTERVAL 1 MONTH)
                  and Prenotazioni.Stato = 'PRENOTATA'
            ) >= calcola_accessi_disponibili(nf)
            then SIGNAL sqlstate '45000' SET message_text = 'Limite prenotazioni mensile superato';

        -- controllo crediti disponibili
        elseif Crediti > (select calcola_crediti_disponibili(nf))
			then SIGNAL sqlstate '45000' SET message_text = 'Crediti insufficienti per la prenotazione';

		-- somma accessi delle prenotazioni nel dato giorno
		elseif (select COUNT(*) from Prenotazioni where Prenotazioni.Data = Data) >= limite_accessi()
			then SIGNAL sqlstate '45000' SET message_text = 'Limite accessi giornaliero superato';

		-- somma crediti delle prenotazioni nel dato giorno
		elseif (select COALESCE(SUM(Prenotazioni.Crediti), 0) from Prenotazioni where Prenotazioni.Data = Data) + Crediti > limite_crediti()
			then SIGNAL sqlstate '45000' SET message_text = 'Limite crediti giornaliero superato';

		-- controllo se l'ID è fornito (modifica)
		elseif ID is not NULL and not exists(select * from Prenotazioni where Prenotazioni.ID = ID)
			then SIGNAL sqlstate '45000' SET message_text = 'Prenotazione da modificare non trovata';

		elseif ID is not NULL
			then
				delete from Prenotazioni where Prenotazioni.ID = ID;

		end if;

		insert into Prenotazioni(Cliente, Operatore, Data, Orario, Crediti, Descrizione)
			values(Cliente, Operatore, Data, Orario, Crediti, Descrizione)
		;
    end
$$
delimiter ;


drop procedure if exists procedura_annullamento_prenotazione;
delimiter $$
create procedure procedura_annullamento_prenotazione(in targetID int unsigned)
	begin

		if not exists(select * from Prenotazioni where Prenotazioni.ID = targetID)
			then SIGNAL sqlstate '45000' SET message_text = 'Prenotazione da annullare non trovata';

		elseif (select Prenotazioni.Stato from Prenotazioni where Prenotazioni.ID = targetID) != 'PRENOTATA'
			then SIGNAL sqlstate '45000' SET message_text = 'La prenotazione non è in stato PRENOTATA';

		end if;

		update Prenotazioni
			set Prenotazioni.Stato = 'ANNULLATA'
			where Prenotazioni.ID = targetID
		;
    end
$$
delimiter ;

drop procedure if exists procedura_restituisci_eventi;
delimiter $$
create procedure procedura_restituisci_eventi(in DataInizio date, in DataFine date)
	begin
		select Prenotazioni.ID as id, Prenotazioni.Stato as stato, Prenotazioni.Data as data, Prenotazioni.Orario as orario, Clienti.Nome as nome, Clienti.Cognome as cognome
		from Prenotazioni
		join Clienti on Prenotazioni.Cliente = Clienti.ID
		where Prenotazioni.Data between DataInizio and DataFine;
	end
$$
delimiter ;

drop procedure if exists procedura_restituisci_dati_prenotazione;
delimiter $$
create procedure procedura_restituisci_dati_prenotazione(in targetID int unsigned)
	begin
		select *
		from Prenotazioni join Clienti on Prenotazioni.Cliente = Clienti.ID
		where Prenotazioni.ID = targetID;
	end
$$
delimiter ;

drop procedure if exists procedura_inserimento_accesso;
delimiter $$
create procedure procedura_inserimento_accesso(in targetID int unsigned, in OrarioAccesso time, in CreditiUtilizzati tinyint unsigned, in Note varchar(255))
	begin

		if not exists(select * from Prenotazioni where Prenotazioni.ID = targetID)
			then SIGNAL sqlstate '45000' SET message_text = 'Prenotazione da completare non trovata';

		elseif not exists(select * from Prenotazioni where Prenotazioni.ID = targetID and Prenotazioni.Stato = 'PRENOTATA')
			then SIGNAL sqlstate '45000' SET message_text = 'La prenotazione non è in stato PRENOTATA';

        end if;

		update Prenotazioni -- Prenotazione diventa Accesso (a livello logico)
			set Orario = if(OrarioAccesso is not null, OrarioAccesso, Orario)
			, Crediti = if(CreditiUtilizzati is not null, CreditiUtilizzati, Crediti)
			, Note = if(Note is not null, Note, '')
			, Stato = 'COMPLETATA'
			where ID = targetID
		;
    end
$$
delimiter ;
