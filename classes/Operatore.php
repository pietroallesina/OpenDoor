<?php

class Operatore
{
    private int $ID;
    private string $cognome;
    private string $nome;
    private bool $isAdmin;

    public function __construct(int $ID, string $cognome, string $nome, bool $isAdmin = false)
    {
        $this->ID = $ID;
        $this->cognome = $cognome;
        $this->nome = $nome;
        $this->isAdmin = $isAdmin;
    }
    public function ID(): int
    {
        return $this->ID;
    }
    public function cognome(): string
    {
        return $this->cognome;
    }
    public function nome(): string
    {
        return $this->nome;
    }
    public function isAdmin(): bool
    {
        return $this->isAdmin;
    }
}
