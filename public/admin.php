<?php
    require_once 'functions.php';

    function logout() {
        // Unset all of the session variables
        $_SESSION = array();

        // If it's desired to kill the session, also delete the session cookie.
        if (ini_get("session.use_cookies")) {
            $params = session_get_cookie_params();
            setcookie(session_name(), '', time() - 42000,
                $params["path"], $params["domain"],
                $params["secure"], $params["httponly"]
            );
        }

        // Finally, destroy the session.
        session_destroy();
    }

    if ($_SESSION['stato_operatore'] !== LOGGED) {
        header("Location: index.php");
        exit();
    }
?>

<!DOCTYPE html>
<html>
    <head>
        <title>Admin</title>
        <link rel="stylesheet" href="index.css">
    </head>

    <body>
        <h1>Area Riservata</h1>
        <!-- <p>Benvenuto, <?php echo $_SESSION['nome_operatore'];?>!</p> -->
        <p><a href="index.php">Logout</a></p>
    </body>
</html>