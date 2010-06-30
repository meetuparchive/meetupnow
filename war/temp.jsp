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
			min-height: 100%;
			margin-bottom: -150px;
			position: relative;
		}
		#footer {
			height: 150px;
			position: relative;
		}
		.clearfooter {
			height: 150px;
			clear: both;
		}
		#content {
			height:1000px;
			background-color: red;
		}
	</style>
</head>
<body>
	
	<div id="container">
	      <div id="header">Header</div>
	      <div id="nav">
	         <ul>
	            <li><a href="#">Home</a></li>
	            <li><a href="#">Page 1</a></li>
	            <li><a href="#">Page 2</a></li>
	         </ul>
	         </div>
		<div id="content">Content Here.</div>
		<div class="clearfooter"></div>
	</div>
	<div id="footer">Footer Here.</div>

</body>
</html>