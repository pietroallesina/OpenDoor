<?php
require_once '../includes/init.php';
?>

<!DOCTYPE html>
<html>

<head>
<?php require_once '../includes/head.php'; ?>
<style>
    main {
        display: flex;
        flex-direction: column;
        align-items: center;

        margin-top: 5rem;
    }

    img {
        max-width: 10rem;
        height: auto;
    }

    p {
        font-size: large;
    }
</style>
</head>

<body>
    <main>
        <img src="/favicon.ico" alt="Logo Porta Aperta">

        <h1>404 Not Found</h1>

        <p>
            La pagina richiesta non esiste.
            <br>
            <br>
            Torna alla
            <a href="/" style="color: var(--accent-color); text-decoration: underline">
                pagina principale
            </a>
        </p>
    </main>
</body>

</html>