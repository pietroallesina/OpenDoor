use OpenDoor;

-- SEZIONE TABELLE --

drop table if exists Operatori;
create table if not exists Operatori (
	Cognome varchar(64) NOT NULL,
	, Nome varchar(64) NOT NULL
	, ID smallint unsigned AUTO_INCREMENT NOT NULL

	, primary key (ID)
);

drop table if exists Clienti;
create table if not exists Clienti (
	Cognome varchar(64) NOT NULL
	, Nome varchar(64) NOT NULL
	, Regione enum('ITA', 'PAK', 'AN') NOT NULL
	, NumeroFamigliari tinyint unsigned NOT NULL
	, ID smallint unsigned AUTO_INCREMENT NOT NULL
	, AccessiDisponibili tinyint unsigned NULL
    , CreditiDisponibili tinyint unsigned NULL

	, primary key (ID)
);

drop table if exists Prenotazioni;
create table if not exists Prenotazioni (
	Cliente smallint unsigned NULL
    , Operatore smallint unsigned NULL
	, DataPrenotata date NOT NULL
	, ID int unsigned AUTO_INCREMENT NOT NULL

	-- , DataInserimento datetime default current_timestamp()
	-- , DataAggiornamento datetime default current_timestamp() on update current_timestamp()

	, primary key (ID)
	-- , foreign key (Cliente) references Clienti(ID) on DELETE set NULL
	-- , foreign key (Operatore) references Operatori(ID) on DELETE set NULL
);

drop table if exists Accessi;
create table if not exists Accessi (
	Cliente smallint unsigned NULL
	, Operatore smallint unsigned NULL
	, Data_Orario datetime NULL -- NOT NULL in production
	, CreditiSpesi tinyint unsigned NULL
	, ID int unsigned AUTO_INCREMENT NOT NULL
	, IDPrenotazione int unsigned NULL

	, primary key (ID)
	-- , foreign key (Cliente) references Clienti(ID) on DELETE set NULL
	-- , foreign key (Operatore) references Operatori(ID) on DELETE set NULL
	-- , foreign key (IDPrenotazione) references Prenotazioni(ID) on DELETE set NULL
);
