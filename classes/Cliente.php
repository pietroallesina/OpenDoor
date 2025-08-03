<?php

class Cliente
{
    private string $cognome;
    private string $nome;
    private string $regione;
    private int $numerofamigliari;
    private int $accessidisponibili;
    private int $creditidisponibili;

    public function __construct(string $cognome, string $nome, string $regione, int $numerofamigliari, int $accessidisponibili, int $creditidisponibili)
    {
        $this->cognome = $cognome;
        $this->nome = $nome;
        $this->regione = $regione;
        $this->numerofamigliari = $numerofamigliari;
        $this->accessidisponibili = $accessidisponibili;
        $this->creditidisponibili = $creditidisponibili;
    }
}