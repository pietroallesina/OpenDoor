use OpenDoor;

-- SEZIONE STORED PROCEDURES --

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
                , Clienti.CreditiDisponibili = calcola_crediti_disponibili(NumeroFamigliari) -- condizionale
                , Clienti.AccessiDisponibili = calcola_accessi_disponibili(NumeroFamigliari) -- condizionale
			where Clienti.ID = ID
		;
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

drop procedure if exists procedura_inserimento_accesso;
delimiter $$
create procedure procedura_inserimento_accesso(in Cliente smallint unsigned, in Operatore smallint unsigned, in Data_Orario datetime, in CreditiSpesi tinyint unsigned, in IDPrenotazione int unsigned)
	begin
		insert into
			Accessi(Cliente, Operatore, Data_Orario, CreditiSpesi, IDPrenotazione)
            values(Cliente, Operatore, Data_Orario, CreditiSpesi, IDPrenotazione)
		;
    end
$$
delimiter ;
