<header class="underline-animation">

<!-- <a href="home"> -->
<!-- <img src="/favicon.ico" alt="Logo Porta Aperta"> -->
<!-- </a> -->

<nav class="left-navbar">

<?php if(isset($_SESSION['operatore'])) : ?>
    <a href="/dashboard" class="header-link">Pannello di controllo</a></li>

    <?php if ($_SESSION['operatore']->isAdmin()) : ?>
    <a href="/admin" class="header-link">Area riservata</a>
    <?php endif; ?>

<?php else : ?>
    <a href="/home" class="header-link">Home</a>

<?php endif; ?>

    <a href="/guide" class="header-link">Guida</a>

</nav class="left-navbar"> 


<nav class="right-navbar">

<?php if(isset($_SESSION['operatore'])) : ?>
    <a onclick="logout()" class="header-link">Esci</a>

<?php else : ?>
    <a href="/login" class="header-link">Accedi</a>

<?php endif; ?>

</nav class="right-navbar">

</header>