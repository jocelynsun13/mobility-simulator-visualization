// update svg layer of bus routes
function svgBus(routes){

  var svg = L.d3SvgOverlay(function(selection, projection){

    var routes_g = selection.selectAll('.routes');
    if(routes_g.empty()){
      routes_g = selection.append('g')
        .attr('class','routes')

      var route_paths = routes_g.selectAll('path')
        .data(routes.features);

      route_paths.enter().append('path')
        .attr('class', 'route')
        .attr('d', d3.geo.path()
            .projection(function(l){
              var p = projection.latLngToLayerPoint({ lon: l[0], lat:  l[1] });
              return [p.x,p.y];
            })
          )
        .attr('stroke', function(d){
            var color = "#111" 
            return color;
        });
      route_paths.attr('stroke-width',4.5);
    }
  });

  return svg;
}

// update svg layer of cab routes
function svgCab(cab_routes) {

  var svg = L.d3SvgOverlay(function(selection, projection) {
    var routes_g = selection.selectAll('.routes');
    if(routes_g.empty()){
      routes_g = selection.append('g')
        .attr('class','routes')

      var route_paths = routes_g.selectAll('path')
        .data(cab_routes.features);

      route_paths.enter().append('path')
        .attr('class', 'route')
        .attr('d', d3.geo.path()
            .projection(function(l){
              var p = projection.latLngToLayerPoint({ lon: l[0], lat:  l[1] });
              return [p.x,p.y];
            })
          )
        .attr('stroke', function(d){
            var color = "#fa0000" 
            return color;
        });
      route_paths.attr('stroke-width', 4.5);
    }
  });

  return svg;
}

// update svg layer of car routes
function svgCar(car_routes) {

  var svg = L.d3SvgOverlay(function(selection, projection) {
    var routes_g = selection.selectAll('.routes');
    if(routes_g.empty()){
      routes_g = selection.append('g')
        .attr('class','routes')

      var route_paths = routes_g.selectAll('path')
        .data(car_routes.features);

      route_paths.enter().append('path')
        .attr('class', 'route')
        .attr('d', d3.geo.path()
            .projection(function(l){
              var p = projection.latLngToLayerPoint({ lon: l[0], lat:  l[1] });
              return [p.x,p.y];
            })
          )
        .attr('stroke', function(d){
            var color = "#15922a" 
            return color;
        });
      route_paths.attr('stroke-width', 4.5);
    }
  });

  return svg;
}

// update svg layer of user routes
function svgUser(user_routes) {

  var svg = L.d3SvgOverlay(function(selection, projection) {

    var routes_g = selection.selectAll('.routes');
    if(routes_g.empty()){
      routes_g = selection.append('g');

      var route_paths = routes_g.selectAll('path')
        .data(user_routes.features);

      route_paths.enter().append('path')
        .attr('class', 'route')
        .attr('d', d3.geo.path()
            .projection(function(l){
              var p = projection.latLngToLayerPoint({ lon: l[0], lat:  l[1] });
              return [p.x,p.y];
            })
          )
        .attr('stroke', function(d){
            var color = "#111" 
            return color;
        });
      route_paths.attr('stroke-width', 2);
      route_paths.attr('stroke-dasharray','5.5');
    }
  });

  return svg;
}

// interpolate coordinates between two locations
function interpolate(p1, p2, f) {

  var nx = p1[0] + ( p2[0] - p1[0] ) * f,
      ny = p1[1] + ( p2[1] - p1[1] ) * f;
  return [nx, ny];
}

// minutes to hours
function m_to_h(c) {
  var h = Math.floor(c / 60) % 24,
      m = c % 60,
      p = h < 12 ? 'AM' : 'PM',
      h = h % 12 == 0 ? 12 : h % 12;
  return { h: h, m: m, p: p };
}