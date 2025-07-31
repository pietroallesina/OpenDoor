<?php

    function get_db_status() {
        $mysqli = new mysqli("mysql", "root", "", "OpenDoor");
        if ($mysqli->connect_error) {
            $status = false;
        } else {
            $status = true;
        }
        $mysqli->close();
        return $status;
    }

    function register_user($cognome, $nome, $password) {
        $mysqli = new mysqli("mysql", "root", "", "OpenDoor");
        if ($mysqli->connect_error) {
            die("Connection failed: " . $mysqli->connect_error);
        }

        // Prepare and bind

        $stmt = $mysqli->prepare("CALL procedura_inserimento_operatore(?, ?, ?)");
        if (!$stmt) {
            die("Prepare failed: " . $mysqli->error);
        }
        $hashed_password = password_hash($password, PASSWORD_DEFAULT);
        if (!$stmt->bind_param("sss", $cognome, $nome, $hashed_password)) {
            die("Bind failed: " . $stmt->error);
        }

        // Execute the statement
        if ($stmt->execute()) {
            echo "Registrazione effettuata con successo!";
        } else {
            echo "Errore: " . $stmt->error;
        }

        // Close the connections
        $stmt->close();
        $mysqli->close();
    }

    function login($cognome, $nome, $password) {
        $mysqli = new mysqli("mysql", "root", "", "OpenDoor");
        if ($mysqli->connect_error) {
            die("Connection failed: " . $mysqli->connect_error);
        }

        // Prepare and bind
        $stmt = $mysqli->prepare("SELECT password FROM Operatori WHERE Cognome = ? AND Nome = ?");
        if (!$stmt) {
            die("Prepare failed: " . $mysqli->error);
        }
        if (!$stmt->bind_param("ss", $cognome, $nome)) {
            die("Bind failed: " . $stmt->error);
        }

        // Execute the statement
        if ($stmt->execute()) {
            $stmt->store_result();
            if ($stmt->num_rows > 0) {
                // Bind the result
                $stmt->bind_result($hashed_password);
                // Fetch the result
                $stmt->fetch();
                // Verify the password
                if (password_verify($password, $hashed_password)) {
                    echo "Login effettuato con successo!";
                } else {
                    echo "Credenziali non valide.";
                }
            } else {
                echo "Credenziali non valide.";
            }
        } else {
            echo "Errore: " . $stmt->error;
        }

        // Close the connections
        $stmt->close();
        $mysqli->close();
    }

    if (session_status() === PHP_SESSION_NONE) {
            session_start();
    }
    // set session connection status
    $_SESSION['db_status'] = get_db_status();
?>