<?php

class Cliente
{
    private int $ID;
    private string $cognome;
    private string $nome;
    private string $regione;
    private int $numerofamigliari;

    public function __construct(int $ID, string $cognome, string $nome, string $regione, int $numerofamigliari)
    {
        $this->ID = $ID;
        $this->cognome = $cognome;
        $this->nome = $nome;
        $this->regione = $regione;
        $this->numerofamigliari = $numerofamigliari;
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