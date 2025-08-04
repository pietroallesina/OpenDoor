<!-- <header> -->

<!-- <a href="home"> -->
<img src="/favicon.ico" alt="Logo Porta Aperta">
<!-- </a> -->

<nav>
    <ul class="left-navbar">
        |
        <li><a href="home">Home</a></li>
        |
        <li><a href="guide">Guida</a></li>
        |
        <li><a href="https://portaapertacarpi.com/" target="_blank">Porta Aperta↗️</a></li>
    </ul class="left-navbar">

    <ul class="right-navbar">
        
        <?php if(isset($_SESSION['operatore'])) : ?>
        <li>
            <input id="dropdown-toggle-1" type="checkbox" class="dropdown-toggle">
            <label for="dropdown-toggle-1" class="dropdown-text">
                <!-- <a href="#" onclick="return false;"> -->
                    <?php echo $_SESSION['operatore']->nome(); ?>
                <!-- </a> -->
            </label>

            <ul class="dropdown-menu">
                <li><a href="dashboard">Dashboard</a></li>
                
                <?php if ($_SESSION['operatore']->isAdmin()) : ?>
                <li><a href="admin">Configurazione</a></li>
                <?php endif; ?>
                
                <li><a href="profile">Profilo</a></li>
                <li><a onclick="logout()">Logout</a></li>
            </ul>
        </li>

        <?php else : ?>
        <li><a href="login">Accedi</a></li>

        <?php endif; ?>

    </ul class="right-navbar">
</nav>

<!-- </header> -->
 