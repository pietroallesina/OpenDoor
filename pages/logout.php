<?php
require_once '../includes/init.php';

// Invalidate the session
$_SESSION = array();
session_destroy();

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
    p {
        font-size: large;
    }
</style>
</head>

<body>
    <main>
        <h1>Logout</h1>
        
        <p>
            Sei stato disconnesso con successo!
        </p>
        <p>
            Torna alla
            <a href="/home">
                pagina principale
            </a>
        </p>
    </main>
</body>
</html>