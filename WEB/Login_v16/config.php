<?php
session_start();
$host = "localhost"; /* Host name */
$user = "clobber"; /* User */
$password = "ClobberPassword_9"; /* Password */
$dbname = "clobber"; /* Database name */

$con = mysqli_connect($host, $user, $password,$dbname);
// Check connection
if (!$con) {
  die("Connection failed: " . mysqli_connect_error());
}
?>
