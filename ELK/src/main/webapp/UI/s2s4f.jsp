<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
  <title>ELK graphs</title>
  <style>
    .graph-container {
      width: 100%;
      height: 0;
      padding-bottom: 33.33%;
      position: relative;
      display: inline-block;
      box-sizing: border-box;
    }

    .graph-container iframe {
      position: absolute;
      width: 100%;
      height: 620px;
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
	<iframe src="https://localhost/app/dashboards#/view/40fe28a0-3686-11ee-9357-3bb1035a196c?embed=true&_g=(refreshInterval:(pause:!t,value:60000),time:(from:now-1y%2Fd,to:now))&_a=()&show-time-filter=true&hide-filter-bar=true" height="600" width="800"></iframe>
  </div>
</body>
</html>