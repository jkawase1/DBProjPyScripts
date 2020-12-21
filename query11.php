<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
        <meta name="description" content="" />
        <meta name="author" content="" />
        <title>Murder Search</title>
        <link rel="icon" type="image/x-icon" href="favicon.ico" />
        <!-- Font Awesome icons (free version)-->
        <script src="https://use.fontawesome.com/releases/v5.15.1/js/all.js" crossorigin="anonymous"></script>
        <!-- Google fonts-->
        <link href="https://fonts.googleapis.com/css?family=Varela+Round" rel="stylesheet" />
        <link href="https://fonts.googleapis.com/css?family=Nunito:200,200i,300,300i,400,400i,600,600i,700,700i,800,800i,900,900i" rel="stylesheet" />
        <!-- Core theme CSS (includes Bootstrap)-->
        <link href="styles.css" rel="stylesheet" />
    </head>
    <body id="page-top">

        <!-- Navigation-->
        <nav class="navbar navbar-expand-lg navbar-light fixed-top" id="mainNav">
            <div class="container">
                <a class="navbar-brand js-scroll-trigger" href="#page-top" style="color: #A81E1C">Murder Search</a>
                <button class="navbar-toggler navbar-toggler-right" type="button" data-toggle="collapse" data-target="#navbarResponsive" aria-controls="navbarResponsive" aria-expanded="false" aria-label="Toggle navigation">
                    Menu
                    <i class="fas fa-bars"></i>
                </button>
                <div class="collapse navbar-collapse" id="navbarResponsive">
                    <ul class="navbar-nav ml-auto">
                        <li class="nav-item"><a class="nav-link js-scroll-trigger" href="/~mboloix1/DBProjPyScripts/index.html" style="color: #A81E1C">Back to Main Site</a></li>
                    </ul>
                </div>
            </div>
        </nav>

        <!-- Masthead-->
        <header class="masthead">
            <div class="container d-flex h-100 align-items-center">
                <div class="mx-auto text-center">
		    <div class="row">
			<div class="mb-3 mb-md-0 w-100">
                        <div class="card py-4 h-100">
                            <div class="card-body text-center">
                                <div class="small text-black-50">


<?php
 include 'open.php';
 
 ini_set('error_reporting', E_ALL);
 ini_set('display_errors', true);
 
 $Num = $_POST['11_num'];
 
 echo "<h4 class=\"text-uppercase m-0\">Query 11 </h4>";
 echo "<hr class=\"my-4\" />";
 
 if ($mysqli->multi_query("CALL LessThanMurdersByState(".$Num.");")) {
     if ($result = $mysqli->store_result()) {
	if (mysqli_num_rows($result) != 0) {
	echo "<div style=\"height: 400px; overflow:auto;\">\n";
        echo "<table border=1>\n";
        echo "<tr><td>States</td></tr>\n";
         while ($myrow = $result->fetch_row()) {
                 printf("<tr><td>%s</td></tr>\n", $myrow[0]);
         }
	echo "</table>\n";
	echo "</div>";
	} else {
		echo "<h5>There are no entries in the database that match this query.</h5>";
	}
         $result->close();
     }
}
 ?>
				
				</div>
                            </div>
                        </div>
                    	</div>
		    </div>
                </div>
            </div>
        </header>

        <footer class="footer bg-black small text-center text-white-50"><div class="container">All images come from <a href="https://unsplash.com/images/stock">unsplash.com</a></div></footer>
        <!-- Bootstrap core JS-->
        <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.3/dist/js/bootstrap.bundle.min.js"></script>
        <!-- Third party plugin JS-->
        <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery-easing/1.4.1/jquery.easing.min.js"></script>
        <!-- Core theme JS-->
        <script src="scripts.js"></script>
    </body>
</html>
