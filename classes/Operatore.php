<?php

class Operatore {
    private $cognome;
    private $nome;
    private $isAdmin;

    public function __construct($cognome, $nome, $isAdmin = false) {
        $this->cognome = $cognome;
        $this->nome = $nome;
        $this->isAdmin = $isAdmin;
    }
}

?>
