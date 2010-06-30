<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
	"http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
	<title>Temp</title>
	<style type="text/css" media="screen">
		html, body {
			margin: 0;
			padding: 0;
			height: 100%;
		}
		body {
			background-color: #022432;
		}
		#wrap {
			min-height: 100%;
		}

		#main {
			overflow:auto;
			padding-bottom: 150px; /* must be same height as the footer */
		}

		#footer {
			position: relative;
			margin-top: -150px; /* negative value of footer height */
			height: 150px;
			clear:both;
		} 

		/*Opera Fix*/
		body:before {
			content:"";
			height:100%;
			float:left;
			width:0;
			margin-top:-32767px;/
		}
		
		#header {
			height: 36px;
			background-color: red;
		}
		#main {
			//background-color: blue;
			height: 1500px;
		}
		#footer {
			background-color: red;
		}
	</style>
</head>
<body>
	
	<div id="wrap">
		<div id="header">

		</div> <!-- end #header -->
		<div id="main">
			
		</div> <!-- end #main -->
	</div> <!-- end #wrap -->
	<div id="footer">
		
	</div> <!-- end #footer -->

</body>
</html>