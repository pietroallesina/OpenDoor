<nav>
    <ul>
        <li><a href="home">Home</a></li>
        <?php if (isset($_SESSION['operatore'])) : ?>
            <li><a href="dashboard">Dashboard</a></li>
            <?php if ($_SESSION['operatore']->isAdmin()) : ?>
                <li><a href="admin">Admin</a></li>
            <?php endif; ?>
        <?php else: ?>
            <li><a href="login">Accedi</a></li>
            <li><a href="register">Registrati</a></li>
        <?php endif; ?>
    </ul>
</nav>
