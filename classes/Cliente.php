<?php

class Cliente
{
    private int $ID;
    private string $cognome;
    private string $nome;
    private string $regione;
    private int $numerofamigliari;
    private int $creditiDisponibili;

    public function __construct(int $ID, string $cognome, string $nome, string $regione, int $numerofamigliari, int $creditiDisponibili)
    {
        $this->ID = $ID;
        $this->cognome = $cognome;
        $this->nome = $nome;
        $this->regione = $regione;
        $this->numerofamigliari = $numerofamigliari;
        $this->creditiDisponibili = $creditiDisponibili;
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
    public function numerofamigliari(): int
    {
        return $this->numerofamigliari;
    }
    public function creditiDisponibili(): int
    {
        return $this->creditiDisponibili;
    }
}