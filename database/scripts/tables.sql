use OpenDoor;

-- SEZIONE TABELLE --

drop table if exists Operatori;
create table if not exists Operatori (
	Cognome varchar(64) NOT NULL
	, Nome varchar(64) NOT NULL
	, Password char(24) NOT NULL
	, ID smallint unsigned NOT NULL AUTO_INCREMENT

	, primary key (ID)
);

drop table if exists Clienti;
create table if not exists Clienti (
	Cognome varchar(64) NOT NULL
	, Nome varchar(64) NOT NULL
	, Regione enum('ITA', 'PAK', 'AN') NOT NULL
	, NumeroFamigliari tinyint unsigned NOT NULL
	, ID smallint unsigned NOT NULL AUTO_INCREMENT
	, AccessiDisponibili tinyint unsigned NULL
    , CreditiDisponibili tinyint unsigned NULL

	, primary key (ID)
);

drop table if exists Prenotazioni;
create table if not exists Prenotazioni (
	Cliente smallint unsigned NULL
    , Operatore smallint unsigned NULL
	, DataPrenotata date NOT NULL
	, OrarioAccesso time NULL DEFAULT NULL
	, CreditiSpesi tinyint unsigned NULL DEFAULT NULL
	, ID int unsigned NOT NULL AUTO_INCREMENT
	, primary key (ID)
	, foreign key (Cliente) references Clienti(ID) on DELETE set NULL
	, foreign key (Operatore) references Operatori(ID) on DELETE set NULL
);
