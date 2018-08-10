// request frame polyfill;
window.requestAnimFrame = (function(){
  return  window.requestAnimationFrame       ||
          window.webkitRequestAnimationFrame ||
          window.mozRequestAnimationFrame    ||
          function( callback ){
            window.setTimeout(callback, 1000 / 60);
          };
})();

//initialize the map setting, modify the center coordinates when applying a new dataset
var map = new L.Map('map', {
        center: [42.45267, -76.49766], 
        zoom: 13
      });
window.map = map;

//initialize the tilelayer, a street map is shown by default
var tileLayer = new L.tileLayer('http://{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',{
    maxZoom: 20,
    subdomains:['mt0','mt1','mt2','mt3']
});

window.tileLayer = tileLayer;
tileLayer.setOpacity(0.6);
map.addLayer(tileLayer);

map._initPathRoot();

queue()
  // import the required json files
  .defer(d3.json, 'json/routes.json')
  .defer(d3.json,'json/DyPosition_bus.json')
  .defer(d3.json, 'json/DyPosition_cab.json')
  .defer(d3.json, "json/DyPosition_car.json")
  .defer(d3.json, "json/DyPosition_user.json")
  .await(function(error, routes, data_bus, data_cab, data_car, data_user) { 
    if (error) throw error;

    window.routes = routes;
    window.data_bus = data_bus;
    window.data_cab = data_cab;
    window.data_car = data_car;
    window.data_user = data_user;

    //all vehicles layer is shown by default
    window.layer_type_sel = "all";
    window.svg_bus_show = 1;
    window.svg_cab_show = 1;
    window.svg_car_show = 1;
    window.svg_user_show = 1;

    window.user_dots = [];

    window.cab_routes = {
      "type": "FeatureCollection",
      "crs": { "type": "name", "properties": { "name": "urn:ogc:def:crs:OGC:1.3:CRS84" } },
      "features": []
    };
    window.car_routes = {
      "type": "FeatureCollection",
      "crs": { "type": "name", "properties": { "name": "urn:ogc:def:crs:OGC:1.3:CRS84" } },
      "features": []
    };

    window.user_routes = {
      "type": "FeatureCollection",
      "crs": { "type": "name", "properties": { "name": "urn:ogc:def:crs:OGC:1.3:CRS84" } },
      "features": []
    };

    // show the initial svg layers
    window.svg_bus = svgBus(routes);
    window.svg_cab = svgCab(cab_routes);
    window.svg_car = svgCar(car_routes);
    window.svg_user = svgUser(user_routes);
    svg_bus.addTo(map);
    svg_cab.addTo(map);
    svg_user.addTo(map);
    svg_car.addTo(map);

    //obtain the total times, 1440 (=60*24) is assigned by default
    window.times = Object.keys(data_bus.positions);
    window.current_time_h = $('#hour');
    window.current_time_m = $('#minute');
    window.current_time_p = $('#period');

    window.current_index = 0;
    //obtain the starting time setting through the json file
    window.start_time = data_bus.start_time;

    // Most browsers will animate the canvas at 60 fps or an update every 16.67 ms.
    // We'll slow things down a little more by adding 10 frames between minutes.
    window.running = true;
    window.timeout = 10;
    window.frame = 0;
    window.dot_size = 2.5;
    window.Slidenav_show = 0;


    // Canvas Draying
    var drawingOnCanvas = function(canvasOverlay, params) {
      window.canvasOverlay = canvasOverlay;
      window.params = params;
      draw(); // call the draw function
    };

    L.canvasOverlay()
      .drawing(drawingOnCanvas)
      .addTo(map);

    params.canvas.addEventListener('click', (e) => {
      cabClick(e);
    });
  });


     