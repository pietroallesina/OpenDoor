<?php

class Cliente
{
    private int $ID;
    private string $cognome;
    private string $nome;
    private string $regione;
    private int $numerofamigliari;
    private int $accessidisponibili;
    private int $creditidisponibili;

    public function __construct(int $ID, string $cognome, string $nome, string $regione, int $numerofamigliari, int $accessidisponibili, int $creditidisponibili)
    {
        $this->ID = $ID;
        $this->cognome = $cognome;
        $this->nome = $nome;
        $this->regione = $regione;
        $this->numerofamigliari = $numerofamigliari;
        $this->accessidisponibili = $accessidisponibili;
        $this->creditidisponibili = $creditidisponibili;
    }

    public function ID(): string
    {
        return $this->ID;
    }
    public function nome(): string
    {
        return $this->nome;
    }
    public function regione(): string
    {
        return $this->regione;
    }
}