// UI Controls 

//monitor the running speed
$(document).on('input change', '#speed', function(e){
  var slider = $('#speed-slider'),
      max = +slider.prop('max'),
      val = +slider.val();

  window.timeout = max - val;
});

//monitor the click event of play button
$(document).on('click', '#run', function(){
  var icon = window.running ? 'play' : 'stop';
  window.running = !window.running;

  $('#run').html('<i class="fa fa-' + icon + '"></i>')
  if(window.running){
    draw();
  }
});

//monitor the change event of time selection
$(document).on('change', '.current-time', function(e){
  var restart = false;
  if(window.running){
    restart = true
    window.running = false;
  }

  var h = +$('#hour').val(),
      m = +$('#minute').val(),
      p = $('#period').val();

  if(p == 'AM' && h == 12){
    h = 0;
  } else if(p == 'PM'){
    h = (h + 12) % 24
  }

  window.current_index = (h * 60 + m - window.start_time) % 1440;
  draw();

  if(restart){
    window.running = true;
  }
}); 

//monitor the change event of map selection (satellite map vs street map)
$(document).on('change', '.current-map', function(e){

  var map_type_sel = $('#map_selected').val();

  // map.removeLayer(stopsLay);
  map.removeLayer(tileLayer);

  if (map_type_sel == "satellite"){
    window.tileLayer = L.tileLayer('http://{s}.google.com/vt/lyrs=s&x={x}&y={y}&z={z}',{
        maxZoom: 20,
        subdomains:['mt0','mt1','mt2','mt3']
    });
  }
  else{
    window.tileLayer = L.tileLayer('http://{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',{
        maxZoom: 20,
        subdomains:['mt0','mt1','mt2','mt3']
    });
  }

  window.tileLayer.setOpacity(0.6);
  map.addLayer(tileLayer);
  // if (route_id == "0")
  //   stopsLay.addTo(map);

});

//monitor the change event of layer selection (All vehicles, Bus, Cab, Private car, User)
$(document).on('change', '.current-layer', function(e){

  layer_type_sel = $('#layer_selected').val();

});

//monitor the click event on canvas, helps to find the cab click
function cabClick(e) {

  if (layer_type_sel != "bus") {
    const pos = {
      x: e.clientX,
      y: e.clientY
    };

    for (var i = 0; i < active_cabs.length; i++) {
      var active_cab = active_cabs[i];
      if ((active_cab[1]-pos.x)**2 + (active_cab[2]-pos.y)**2 <= 50 ){

        window.active_cab_id = active_cab[0];

        document.getElementById('cab_id').innerHTML = "Cab ID: " + active_cab[0];
        if (parseInt(active_cab[3]) <=2) {
          document.getElementById('status').innerHTML = "Status: busy";
        }
        else {
          document.getElementById('status').innerHTML = "Status: idle";
        }
        
        document.getElementById("dist").innerHTML = "Distance: " + active_cab[4];
        document.getElementById("revenue").innerHTML = "Revenue: $" + active_cab[6];
        document.getElementById("cost").innerHTML = "Cost: $" + active_cab[5];
        document.getElementById("mySidenav").style.width = "300px";
        Slidenav_show = 1;
        break;
      }
    }
  }
}

//close Side Nav button 
function closeNav() {
    Slidenav_show = 0;
    document.getElementById("mySidenav").style.width = "0";
}