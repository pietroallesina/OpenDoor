<?php

class Cliente {
    private $cognome;
    private $nome;
    private $regione;
    private $numerofamigliari;
    private $accessidisponibili;
    private $creditidisponibili;

    public function __construct($cognome, $nome, $regione, $numerofamigliari, $accessidisponibili, $creditidisponibili) {
        $this->cognome = $cognome;
        $this->nome = $nome;
        $this->regione = $regione;
        $this->numerofamigliari = $numerofamigliari;
        $this->accessidisponibili = $accessidisponibili;
        $this->creditidisponibili = $creditidisponibili;
    }
}