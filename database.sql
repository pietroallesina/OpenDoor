create database if not exists PortaAperta;
use PortaAperta;
SET GLOBAL event_scheduler = ON;

-- SEZIONE TABELLE --

drop table if exists Operatori;
create table if not exists Operatori (
	Cognome varchar(64) not null,
	Nome varchar(64) not null,
	ID smallint unsigned auto_increment,

	primary key (ID)
);

drop table if exists Clienti;
create table if not exists Clienti (
	Cognome varchar(64) not null,
	Nome varchar(64) not null,
	Regione enum('ITA', 'PAK', 'AN') not null,
	NumeroFamigliari tinyint unsigned not null,
	NumeroFascicolo int unsigned auto_increment,
	CreditiDisponibili tinyint unsigned, -- trigger per inizializzazione e aggiornamento (decremento)
	AccessiDisponibili tinyint unsigned, -- trigger per inizializzazione e aggiornamento (decremento)

	primary key (NumeroFascicolo)
);

drop table if exists Prenotazioni;
create table if not exists Prenotazioni (
	Cliente int unsigned,
	DataPrenotata date not null,
	ID smallint auto_increment,

	Operatore smallint unsigned not null,
	DataInserimento datetime default current_timestamp(),
	DataAggiornamento datetime default current_timestamp() on update current_timestamp(),

	primary key (ID),
	foreign key (Cliente) references Clienti(NumeroFascicolo),
	foreign key (Operatore) references Operatori(ID)
);

drop table if exists Accessi;
create table if not exists Accessi (
	Cliente int unsigned,
	Operatore smallint unsigned,
	Data_Orario datetime not null, -- bravo, usa datetime + definisci modalità di inserimento(?)
	CreditiSpesi tinyint not null,
	ID smallint auto_increment,

	primary key (ID),
	foreign key (Cliente) references Prenotazioni(Cliente),
	foreign key (Operatore) references Operatori(ID)
);

-- SEZIONE STORED FUNCTIONS --

drop function if exists calcola_crediti_disponibili;
delimiter $$
create function calcola_crediti_disponibili (NumeroFamigliari tinyint unsigned) returns tinyint unsigned
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
create function calcola_accessi_disponibili (NumeroFamigliari tinyint unsigned) returns tinyint unsigned
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
		; -- end of update statement
	end
$$ -- end of create trigger statement
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
		; -- end of update statement
	end
$$ -- end of create trigger statement
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
			where Clienti.NumeroFascicolo = Accessi.Utente
		; -- end of update statement
	end
$$ -- end of create trigger statement
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
		; -- end of update statement
	end
$$ -- end of create event statement
delimiter ;
