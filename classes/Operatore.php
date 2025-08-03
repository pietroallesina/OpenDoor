<?php

class Operatore
{
    private string $cognome;
    private string $nome;
    private bool $isAdmin;

    public function __construct(string $cognome, string $nome, bool $isAdmin = false)
    {
        $this->cognome = $cognome;
        $this->nome = $nome;
        $this->isAdmin = $isAdmin;
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
