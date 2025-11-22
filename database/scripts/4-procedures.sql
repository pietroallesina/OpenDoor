use OpenDoor;

-- SEZIONE STORED PROCEDURES --

drop procedure if exists procedura_aggiornamento_credenziali;
delimiter $$
create procedure procedura_aggiornamento_credenziali(in new_password varchar(255))
	begin
		-- use dynamic SQL because ALTER USER requires a string literal for the password
		set @sql = concat('ALTER USER \'access\'@\'%\' IDENTIFIED BY ', quote(new_password));
		prepare stmt from @sql;
		execute stmt;
		deallocate prepare stmt;
	end
$$
delimiter ;

drop procedure if exists procedura_aggiornamento_impostazioni;
delimiter $$
create procedure procedura_aggiornamento_impostazioni(in _New_params json)
	begin
		update Impostazioni
			set Parametri = _New_params
			where id = 1
		;
	end
$$
delimiter ;

drop procedure if exists procedura_restituisci_impostazioni;
delimiter $$
create procedure procedura_restituisci_impostazioni()
	begin
		select Parametri from Impostazioni where id = 1;
	end
$$
delimiter ;

drop procedure if exists procedura_inserimento_operatore;
delimiter $$
create procedure procedura_inserimento_operatore(in _Cognome varchar(64), in _Nome varchar(64), in _Password varchar(255), in _Admin boolean)
	begin
		-- controllo se l'operatore esiste già
		if exists(select * from Operatori where Operatori.Cognome = _Cognome and Operatori.Nome = _Nome)
			then SIGNAL sqlstate '45000' SET message_text = 'Operatore già esistente';
		end if;

		insert into
			Operatori(Cognome, Nome, Password, Admin)
            values(_Cognome, _Nome, _Password, _Admin)
		;
		-- restituisco l'ID dell'operatore appena inserito
		select ID from Operatori where
			Operatori.Cognome = _Cognome
			and Operatori.Nome = _Nome
		;
    end
$$
delimiter ;

drop procedure if exists procedura_aggiornamento_operatore;
delimiter $$
create procedure procedura_aggiornamento_operatore(in _ID smallint unsigned, in _Cognome varchar(64), in _Nome varchar(64), in _Admin boolean)
	begin
		-- controllo se l'operatore esiste già
		if not exists(select * from Operatori where Operatori.ID = _ID)
			then SIGNAL sqlstate '45000' SET message_text = 'Operatore non trovato';
		end if;

		update Operatori
			set Operatori.Cognome = _Cognome, Operatori.Nome = _Nome, Operatori.Admin = _Admin
			where Operatori.ID = _ID
		;
    end
$$
delimiter ;

drop procedure if exists procedura_login_operatore;
delimiter $$
create procedure procedura_login_operatore(in _Cognome varchar(64), in _Nome varchar(64))
	begin
		-- controllo se l'operatore esiste già e se la password è corretta
		if not exists(select * from Operatori where Operatori.Cognome = _Cognome and Operatori.Nome = _Nome)
			then SIGNAL sqlstate '45000' SET message_text = 'Operatore non trovato';
		end if;

		-- restituisco la password hashata dell'operatore
		select Password, ID, Admin from Operatori where Operatori.Cognome = _Cognome and Operatori.Nome = _Nome;
	end
$$
delimiter ;

drop procedure if exists procedura_eliminazione_operatore;
delimiter $$
create procedure procedura_eliminazione_operatore(in _ID smallint unsigned)
	begin
		-- controllo se l'operatore esiste già
		if not exists(select * from Operatori where Operatori.ID = _ID)
			then SIGNAL sqlstate '45000' SET message_text = 'Operatore non trovato';
		end if;

		delete from Operatori where Operatori.ID = _ID;
    end
$$
delimiter ;

drop procedure if exists procedura_inserimento_cliente;
delimiter $$
create procedure procedura_inserimento_cliente(in _Cognome varchar(64), in _Nome varchar(64), in _Regione enum('ITA', 'PAK', 'AN'), in _NumeroFamigliari tinyint unsigned)
	begin
		insert into
			Clienti(Cognome, Nome, Regione, NumeroFamigliari)
			values(_Cognome, _Nome, _Regione, _NumeroFamigliari)
		;
	end
$$
delimiter ;

drop procedure if exists procedura_aggiornamento_cliente;
delimiter $$
create procedure procedura_aggiornamento_cliente(in _ID smallint unsigned, in _Cognome varchar(64), in _Nome varchar(64), in _Regione enum('ITA', 'PAK', 'AN'), in _NumeroFamigliari tinyint unsigned, in _refill boolean)
	begin
		update Clienti
			set
				Clienti.Cognome = _Cognome, Clienti.Nome = _Nome, Clienti.Regione = _Regione, Clienti.NumeroFamigliari = _NumeroFamigliari
			where Clienti.ID = _ID
		;
	end
$$
delimiter ;

drop procedure if exists procedura_eliminazione_cliente;
delimiter $$
create procedure procedura_eliminazione_cliente(in _ID smallint unsigned)
	begin
		delete from Clienti where Clienti.ID = _ID;
    end
$$
delimiter ;

drop procedure if exists procedura_restituisci_dati_cliente;
delimiter $$
create procedure procedura_restituisci_dati_cliente(in _Cognome varchar(64), in _Nome varchar(64))
	begin
		select ID, Regione, NumeroFamigliari, calcola_crediti_disponibili(Clienti.NumeroFamigliari) as CreditiDisponibili from Clienti where Clienti.Cognome = _Cognome and Clienti.Nome = _Nome;
	end
$$
delimiter ;

-- aggiungi parametro opzionale ID per modifica (eliminazione e reinserimento)
drop procedure if exists procedura_inserimento_prenotazione;
delimiter $$
create procedure procedura_inserimento_prenotazione(in _Cliente smallint unsigned, in _Operatore smallint unsigned, in _Data date, in _Orario time, in _Crediti tinyint unsigned, in _Descrizione varchar(255), in _ID int unsigned)
    begin
        declare nf tinyint unsigned;
        select NumeroFamigliari into nf from Clienti where Clienti.ID = _Cliente;

        -- controllo se lo slot è disponibile
        -- if exists(
        --     select 1 from Prenotazioni
        --     where Prenotazioni.Data = _Data and Prenotazioni.Orario = _Orario and Prenotazioni.Stato = 'PRENOTATA'
        -- )
        --     then SIGNAL sqlstate '45000' SET message_text = 'Slot non disponibile';

        -- controllo disponibilità accessi (use date range for the month)
        if (select COUNT(*) from Prenotazioni
                where Prenotazioni.Cliente = _Cliente
                  and Prenotazioni.Data >= DATE_SUB(_Data, INTERVAL DAY(_Data)-1 DAY)
                  and Prenotazioni.Data < DATE_ADD(DATE_SUB(_Data, INTERVAL DAY(_Data)-1 DAY), INTERVAL 1 MONTH)
                  and Prenotazioni.Stato = 'PRENOTATA'
            ) >= calcola_accessi_disponibili(nf)
            then SIGNAL sqlstate '45000' SET message_text = 'Limite prenotazioni mensile superato';

        -- controllo crediti disponibili
        elseif _Crediti > (select calcola_crediti_disponibili(nf))
			then SIGNAL sqlstate '45000' SET message_text = 'Crediti insufficienti per la prenotazione';

		-- somma accessi delle prenotazioni nel dato giorno
		elseif (select COUNT(*) from Prenotazioni where Prenotazioni.Data = _Data) >= limite_accessi()
			then SIGNAL sqlstate '45000' SET message_text = 'Limite accessi giornaliero superato';

		-- somma crediti delle prenotazioni nel dato giorno
		elseif (select COALESCE(SUM(Prenotazioni.Crediti), 0) from Prenotazioni where Prenotazioni.Data = _Data) + _Crediti > limite_crediti()
			then SIGNAL sqlstate '45000' SET message_text = 'Limite crediti giornaliero superato';

		-- controllo se l'ID è fornito (modifica)
		elseif _ID is not NULL and not exists(select * from Prenotazioni where Prenotazioni.ID = _ID)
			then SIGNAL sqlstate '45000' SET message_text = 'Prenotazione da modificare non trovata';

		elseif _ID is not NULL
			then
				delete from Prenotazioni where Prenotazioni.ID = _ID;

		end if;

		insert into Prenotazioni(Cliente, Operatore, Data, Orario, Crediti, Descrizione)
			values(_Cliente, _Operatore, _Data, _Orario, _Crediti, _Descrizione)
		;
    end
$$
delimiter ;


drop procedure if exists procedura_annullamento_prenotazione;
delimiter $$
create procedure procedura_annullamento_prenotazione(in _ID int unsigned)
	begin

		if not exists(select * from Prenotazioni where Prenotazioni.ID = _ID)
			then SIGNAL sqlstate '45000' SET message_text = 'Prenotazione da annullare non trovata';

		elseif (select Prenotazioni.Stato from Prenotazioni where Prenotazioni.ID = _ID) != 'PRENOTATA'
			then SIGNAL sqlstate '45000' SET message_text = 'La prenotazione non è in stato PRENOTATA';

		end if;

		update Prenotazioni
			set Prenotazioni.Stato = 'ANNULLATA'
			where Prenotazioni.ID = _ID
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
create procedure procedura_restituisci_dati_prenotazione(in _ID int unsigned)
	begin
		select *
		from Prenotazioni join Clienti on Prenotazioni.Cliente = Clienti.ID
		where Prenotazioni.ID = _ID;
	end
$$
delimiter ;

drop procedure if exists procedura_inserimento_accesso;
delimiter $$
create procedure procedura_inserimento_accesso(in _ID int unsigned, in _OrarioAccesso time, in _CreditiUtilizzati tinyint unsigned, in _Note varchar(255))
	begin

		if not exists(select * from Prenotazioni where Prenotazioni.ID = _ID)
			then SIGNAL sqlstate '45000' SET message_text = 'Prenotazione da completare non trovata';

		elseif not exists(select * from Prenotazioni where Prenotazioni.ID = _ID and Prenotazioni.Stato = 'PRENOTATA')
			then SIGNAL sqlstate '45000' SET message_text = 'La prenotazione non è in stato PRENOTATA';

        end if;

		update Prenotazioni -- Prenotazione diventa Accesso (a livello logico)
			set Orario = if(_OrarioAccesso is not null, _OrarioAccesso, Orario)
			, Crediti = if(_CreditiUtilizzati is not null, _CreditiUtilizzati, Crediti)
			, Note = if(_Note is not null, _Note, '')
			, Stato = 'COMPLETATA'
			where ID = _ID
		;
    end
$$
delimiter ;
