<?php
// Set $head_title for custom page title
require_once '../includes/init.php';

if (isset($_SESSION['operatore'])) {
    header("Location: /dashboard");
    exit();
}
?>

<!DOCTYPE html>
<html lang="it">
<head>
    <?php require_once '../includes/head.php'; ?>
</head>

<body>
    <!-- <header> -->
        <?php require_once '../includes/header.php'; ?>
    <!-- </header> -->

    <main>
        <h1>Pagina principale</h1>
        <p>
            Lorem ipsum dolor sit amet consectetur, adipisicing elit. Nam id, animi deserunt amet porro eos magnam explicabo soluta earum ab ullam omnis, laborum provident eaque officiis cupiditate eveniet, nesciunt neque.
            Lorem ipsum dolor sit amet consectetur, adipisicing elit. Vitae facere, quidem consectetur cupiditate, obcaecati cumque laborum quo a neque perspiciatis, iusto eius distinctio tempore suscipit velit pariatur aut necessitatibus ab?
            Lorem ipsum dolor sit amet consectetur, adipisicing elit. Veritatis mollitia at aut molestiae ex officia optio? Hic ex aperiam error iusto, incidunt harum molestias odio consectetur. Nobis ut blanditiis quia.
        </p>
    </main>

</body>
</html>
