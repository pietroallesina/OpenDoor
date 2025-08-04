function logout() {
    if (window.confirm("Sei sicuto di voler effettuare il logout?")) {
        window.location.href = "logout";
    }
    else {
        // Do nothing
    }
}
