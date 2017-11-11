
var lat = 0.0;
var lon = 0.0;

function getLocation() {
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(showPosition);
    }
}
function showPosition(position) {
   lat = position.coords.latitude;
   lon = position.coords.longitude; 
}

function getLat() {
  return lat;
}

function getLat() {
  return lon;
}

function getPosition() {
  Shiny.onInputChange("lat", lat);
  Shiny.onInputChange("lon", lon);
}