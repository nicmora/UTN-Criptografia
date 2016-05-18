<?php
// Check for empty fields
if(empty($_POST['name'])  		||
   empty($_POST['nroafiliado']) 		||
   empty($_POST['nrodni']) 		||
   empty($_POST['message'])	||
   !filter_var($_POST['email'],FILTER_VALIDATE_EMAIL))
   {
	echo "No arguments Provided!";
	return false;
   }
	
$name = $_POST['name'];
$nroafiliado = $_POST['nroafiliado'];
$nroafiliado = $_POST['nrodni'];
$email_address = $_POST['email'];
$phone = $_POST['phone'];
$message = $_POST['message'];
	
// Create the email and send the message
$to = 'esteban.chacho@gmail.com'; // Add your email address inbetween the '' replacing yourname@yourdomain.com - This is where the form will send a message to.
$email_subject = "ATE Sur Turismo:  $name";
$email_body = "You have received a new message from your website contact form.\n\n"."Here are the details:\n\nName: $name\n\nNroAfiliad: $nroafiliado\n\nDNI: $nrodni\n\nEmail: $email_address\n\nPhone: $phone\n\nMessage:\n$message";
$headers = "From: esteban.chacho@gmail.com\n"; // This is the email address the generated message will be from. We recommend using something like noreply@yourdomain.com.
$headers .= "Reply-To: $email_address";	
mail($to,$email_subject,$email_body,$headers);
return true;			
?>