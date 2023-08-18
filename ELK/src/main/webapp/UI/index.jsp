<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
  <title>ELK graphs</title>
  <style>
    .graph-container {
      width: 33%;
      height: 0;
      padding-bottom: 33.33%;
      position: relative;
      display: inline-block;
      box-sizing: border-box;
    }

    .graph-container iframe {
      position: absolute;
      width: 100%;
      height: 550px;
    }

    body {
      margin: 0;
      padding: 0;
    }
  </style>
</head>
<body>
  <h1>ELK</h1>
  <div class="graph-container">
		<h2>aiv_access.log</h2>
		<iframe src="https://192.168.83.99:5601/app/dashboards#/view/9bf7a0d0-31b6-11ee-8144-5dd83ef54758?embed=true&_g=(refreshInterval:(pause:!t,value:60000),time:(from:now-1y%2Fd,to:now))&_a=()&show-time-filter=true&hide-filter-bar=true" height="600" width="800"></iframe>
  </div>
  
<!--   <div class="graph-container"><iframe src="https://192.168.83.99:5601/app/dashboards#/view/d752cb30-29de-11ee-888d-bf00bb587e4f?embed=true&_g=(refreshInterval:(pause:!t,value:60000),time:(from:now-1y%2Fd,to:now))&_a=()&show-time-filter=true&hide-filter-bar=true" height="600" width="800"></iframe>
		<h2>aiv_error.log</h2>
		<iframe src="http://192.168.83.99:5601/app/dashboards#/view/6241d770-2234-11ee-a888-8b6adef987a7?embed=true&_g=(refreshInterval:(pause:!t,value:60000),time:(from:now-1y%2Fd,to:now))&_a=()&show-time-filter=true&hide-filter-bar=true" height="500" width="800" frameborder="0"></iframe>
  </div>
  <div class="graph-container">
		<h2>Stomp.log</h2>
		<iframe src="http://192.168.83.99:5601/app/dashboards#/view/4c11e8f0-2234-11ee-a888-8b6adef987a7?embed=true&_g=(refreshInterval:(pause:!t,value:60000),time:(from:now-1y%2Fd,to:now))&_a=()&show-time-filter=true&hide-filter-bar=true" height="500" width="800" frameborder="0"></iframe>
  </div> -->
</body>
</html>