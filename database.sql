create database if not exists PorteAperte;

create table if not exists Operatori (
	Cognome varchar(64) not null,
	Nome varchar(64) not null,
	ID smallint unsigned auto_increment,

	primary key (ID),
);

create table if not exists Clienti (
	Cognome varchar(64) not null,
	Nome varchar(64) not null,
	Regione enum('ITA', 'PAK', 'AN') not null,
	NumeroFascicolo int unsigned auto_increment,
	NumeroFamigliari tinyint unsigned not null,
	CreditiDisponibili tinyint, -- trigger per inizializzazione e aggiornamento (decremento)
	AccessiDisponibili tinyint, -- trigger per inizializzazione e aggiornamento (decremento)
	TotaleCreditiSpesi smallint default null, -- trigger per aggiornamento (incremento)
	TotaleAccessiEffettuati smallint default null, -- trigger per aggiornamento (incremento)

	primary key (NumeroFascicolo),
);

create table if not exists Prenotazioni (
	Utente int unsigned,
	DataPrenotata date not null,
	ID smallint auto_increment,

	Operatore smallint unsigned,
	DataInserimento datetime default current_timestamp(),
	DataAggiornamento datetime default current_timestamp() on update current_timestamp(),

	primary key (ID),
	foreign key (Utente) references Clienti(NumeroFascicolo),
	foreign key (Operatore) references Operatori(ID),
);

create table if not exists Accessi (
	Utente int unsigned,
	Operatore smallint unsigned,
	Data_Orario datetime not null, -- bravo, usa datetime + definisci modalità di inserimento
	CreditiSpesi tinyint not null,
	ID smallint auto_increment,

	primary key (ID),
	foreign key (Utente) references Prenotazioni(Utente),
	foreign key (Operatore) references Operatori(ID),
);

create trigger if not exists trigger_inserimento_persona AFTER INSERT on Clienti
	for each row
	begin
		update Clienti
			set CreditiDisponibili = (
				case NumeroFamigliari
				when 1 then 40
				when 2 then 60
				when 3 then 75
				when 4 then 90
				when 5 then 105
				else 120
				end
			),
			set AccessiDisponibili = (
				case
				when NumeroFamigliari <= 3 then 2
				else 3
			);
	end;

-- create trigger if not exists trigger_inserimento_accesso AFTER INSERT on Accessi
-- 	for each row
-- 	begin
-- 		update Clienti
-- 			set
