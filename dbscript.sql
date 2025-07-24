create database if not exists PorteAperte;

create table if not exists Operatori (
	Cognome varchar(64) not null,
	Nome varchar(64) not null,
	ID smallint unsigned auto_increment,

	primary key (ID),
);

create table if not exists Persone (
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
	foreign key (Utente) references Persone(NumeroFascicolo),
	foreign key (Operatore) references Operatori(ID),
);

create table if not exists Accessi (
	Utente int unsigned,
	Operatore smallint unsigned,
	Data_Orario datetime not null, -- definisci modalità di inserimento
	CreditiSpesi tinyint not null,
	ID smallint auto_increment,

	primary key (ID),
	foreign key (Utente) references Prenotazioni(Utente),
	foreign key (Operatore) references Operatori(ID),
);
