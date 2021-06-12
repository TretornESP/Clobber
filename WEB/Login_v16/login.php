<?php
include "config.php";
if(isset($_POST['login-btn'])){
    $uname = mysqli_real_escape_string($con,$_POST['username']);
    $password = mysqli_real_escape_string($con,$_POST['pass']);

    if ($uname != "" && $password != ""){

        $sql_query = "select count(*) as cntUser from users where username='".$uname."' and password='".$password."'";
        $result = mysqli_query($con,$sql_query);
        $row = mysqli_fetch_array($result);

        $count = $row['cntUser'];

        if($count > 0){
            $_SESSION['username'] = $uname;
            $port = '9420';
            echo "Redirecting...";
            header('Location: '
                . ($_SERVER['HTTPS'] ? 'https' : 'http')
                . '://' . $_SERVER['HTTP_HOST'] . ':' . $port
                . "/names/" . $uname);
            exit();
        }else{
            echo "Invalid username and password";
        }
    } else {
      echo "Username or password cannot be void";
    }
} else {
  echo "Unexpected error";
}
?>
