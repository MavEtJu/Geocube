<?php

if (!isset($_REQUEST["date"]))
        $_REQUEST["date"] = 0;
setcookie("dateSelected", $_REQUEST["date"], time() + (86400 * 30), "/");

?>

<!DOCTYPE html>
<html>
  <head>
    <style>
      /* Always set the map height explicitly to define the size of the div
       * element that contains the map. */
      #mapcontainer {
	position: fixed;
	top: 0px;
	float: left;
        height: 100%;
	width: 80%;
      }
      #map {
	top: 0px;
        height: 100%;
	width: 100%;
	margin: 0px;
      }
      #sidecontainer {
        height: 100%;
	width: 20%;
	float: right;
	margin: 0px;
      }
      #sidetable {
	width: 100%;
	margin: 0px;
      }
      #sidedates {
	width: 100%;
	margin: 0px;
      }

      /* Optional: Makes the sample page fill the window. */
      html, body {
        height: 100%;
        width: 100%;
        margin: 0;
        padding: 0;
      }
      table {
	border-collapse: collapse;
	border-spacing: 0;
	font-family: Sans-Serif;
	font-size: 10pt;
	color: #444;
      }
      tr {
      }
      th {
	text-align: left;
	color: #444444;
	font-weight: bold;
	padding: 5px;
	border-color: #ccc;
      }
      td {
	padding: 5px;
	border-color: #ccc;
      }
    </style>
  </head>
  <body>
    <div id="mapcontainer">
      <div id="map"></div>
    </div>
    <div id="sidecontainer">
      <div id="sidedates"></div>
      <div id="sidetable"></div>
    </div>
      <script>
var tableData = new Array();
var dates = new Array();
var dateSelected = getCookie("dateSelected");
var map;

function initMap()
{
    map = new google.maps.Map(document.getElementById('map'), {
        zoom: 12,
        mapTypeId: 'roadmap'
    });

    // Create a <script> tag and set the USGS URL as the source.
    var script = document.createElement('script');
    script.src = "json.php?dateSelected=" + dateSelected;
    document.getElementsByTagName('head')[0].appendChild(script);
}

function GenerateSide()
{
    GenerateDates();
    GenerateTable();
}

function GenerateDates()
{
    var offset = new Date().getTimezoneOffset();

    var form = document.createElement("FORM");
    form.method = "POST";

    var select = document.createElement("SELECT");
    select.name = "date";
    for (var i = 1; i < dates.length; i++) {
	var option = document.createElement("OPTION");
	option.value = dates[i].epoch + 60 * offset;;
	var t = document.createTextNode(dates[i].text);
	option.appendChild(t);
	select.appendChild(option);
	if (dates[i].epoch + 60 * offset == dateSelected) {
	    option.setAttribute("selected", "selected");
	}
    }
    form.appendChild(select);

    var button = document.createElement("BUTTON");
    var t = document.createTextNode("Change date");
    button.appendChild(t);
    form.appendChild(button);

    var sidedates = document.getElementById("sidedates");
    sidedates.innerHTML = "";
    sidedates.appendChild(form);
}

function GenerateTable()
{
    //Create a HTML Table element.
    var table = document.createElement("TABLE");
    table.border = "1";
 
    //Get the count of columns.
    var columnCount = tableData[0].length;

    //Add the header row.
//    var row = table.insertRow(-1);
//    for (var i = 0; i < columnCount; i++) {
//        var headerCell = document.createElement("TH");
//        headerCell.innerHTML = tableData[0][i];
//        row.appendChild(headerCell);
//    }
 
    //Add the data rows.
    for (var i = 1; i < tableData.length; i++) {
        row = table.insertRow(-1);
	t = "";
        for (var j = 0; j < columnCount; j++) {
	    if (j != 0)
		t += "<br />";
	    t += tableData[i][j];
	}
        var cell = row.insertCell(-1);
        cell.innerHTML = t;
    }
 
    var sidetable = document.getElementById("sidetable");
    sidetable.innerHTML = "";
    sidetable.appendChild(table);
}

function getCookie(cname) {
    var name = cname + "=";
    var decodedCookie = decodeURIComponent(document.cookie);
    var ca = decodedCookie.split(';');
    for(var i = 0; i <ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0) == ' ') {
            c = c.substring(1);
        }
        if (c.indexOf(name) == 0) {
            return c.substring(name.length, c.length);
        }
    }
    return "";
}

// Loop through the results array and place a marker for each
// set of coordinates.
window.eqfeed_callback = function(results) {
    var poly = new google.maps.Polyline({
        strokeColor: '#000000',
        strokeOpacity: 1.0,
        strokeWeight: 3
    });

    for (var i = 0; i < results.dates.length; i++) {
	dates.push(results.dates[i]);
    }

    var bounds = new google.maps.LatLngBounds();
    for (var i = 0; i < results.features.length; i++) {
	var _id = results.features[i].id;
	var lat = results.features[i].lat;
        var lon = results.features[i].lon;
        var latlon = results.features[i].latlon;
        var latLng = new google.maps.LatLng(lat, lon);
        var text = results.features[i].text;
	var timeSubmitted = results.features[i].timeSubmitted;

        var marker = new google.maps.Marker({
	    position: latLng,
	    title: timeSubmitted + "\n" + text,
	    draggable: true,
	    label: "#" + _id,
            map: map
        });

	poly.getPath().push(marker.position);
	bounds.extend(marker.position);
	tableData.push(["#" + _id + " " + timeSubmitted, text, latlon]);
    }
    map.fitBounds(bounds);
    poly.setMap(map);
    GenerateSide();
}

    </script>

    <script async defer
    src="https://maps.googleapis.com/maps/api/js?key=AIzaSyA5Q4fNl0ScdW-dJW4QEf4t-u42nhtZpP8&v=3.exp&callback=initMap">
    </script>
  </body>
</html>
