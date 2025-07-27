drop database if exists PortaAperta;
create database if not exists PortaAperta;
use PortaAperta;

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
	ID int unsigned AUTO_INCREMENT,
	CreditiDisponibili tinyint unsigned,
	AccessiDisponibili tinyint unsigned,

	primary key (ID)
);

drop table if exists Prenotazioni;
create table if not exists Prenotazioni (
	Cliente int unsigned,
	DataPrenotata date not null,
	ID smallint auto_increment,

	Operatore smallint unsigned not null,
	-- DataInserimento datetime default current_timestamp(),
	-- DataAggiornamento datetime default current_timestamp() on update current_timestamp(),

	primary key (ID)
	-- foreign key (Cliente) references Clienti(ID) on DELETE set NULL,
	-- foreign key (Operatore) references Operatori(ID) on DELETE set NULL
);

drop table if exists Accessi;
create table if not exists Accessi (
	Cliente int unsigned,
	Operatore smallint unsigned,
	Data_Orario datetime not null,
	CreditiSpesi tinyint not null,
	ID smallint auto_increment,
	IDPrenotazione smallint,

	primary key (ID)
	-- foreign key (Cliente) references Clienti(ID) on DELETE set NULL,
	-- foreign key (Operatore) references Operatori(ID) on DELETE set NULL, 
	-- foreign key (IDPrenotazione) references Prenotazioni(ID) on DELETE set NULL
);
