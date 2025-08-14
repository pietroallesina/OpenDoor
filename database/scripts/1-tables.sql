use OpenDoor;
set foreign_key_checks = 0;

-- SEZIONE TABELLE --

drop table if exists Operatori;
create table if not exists Operatori (
	Cognome varchar(64) NOT NULL
	, Nome varchar(64) NOT NULL
	, Password varchar(255) NOT NULL
	, Admin boolean NOT NULL DEFAULT false
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
	, Crediti tinyint unsigned NOT NULL
	, Stato enum('PRENOTATA', 'COMPLETATA', 'ANNULLATA', 'INATTESA') NOT NULL DEFAULT 'PRENOTATA'
	, ID int unsigned NOT NULL AUTO_INCREMENT
	, primary key (ID)
	, foreign key (Cliente) references Clienti(ID) on DELETE set NULL
	, foreign key (Operatore) references Operatori(ID) on DELETE set NULL
);
set foreign_key_checks = 1;
