<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
	"http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
	<title>Temp</title>
	<style type="text/css" media="screen">
		html,
		body {
		   margin:0;
		   padding:0;
		   height:100%;
		}
		body {
			background: -webkit-gradient(
			    linear,
			    left bottom,
			    left top,
			    color-stop(0, rgb(0,0,0)),
			    color-stop(0.66, rgb(2,36,50))
			);
			background: -moz-linear-gradient(
			    center bottom,
			    rgb(0,0,0) 0%,
			    rgb(2,36,50) 66%
			);
		}
		#container {
		   min-height:100%;
		   position:relative;
		}
		#header {
		   background:#ff0;
		   padding:10px;
		}
		#body {
		   padding:10px;
		   padding-bottom:60px;   /* Height of the footer */
		}
		#footer {
		   position:absolute;
		   bottom:0;
		   width:100%;
		   height:60px;   /* Height of the footer */
		   background:#6cf;
		}
		#test {
			height: 1000px;
		}
	</style>
</head>
<body>
	
<div id="container">
	<div id="header">
		
	</div>
	<div id="body">
		<div id="test">
			
		</div>
	</div>
	<div id="footer">
		
	</div>
</div>

</body>
</html>