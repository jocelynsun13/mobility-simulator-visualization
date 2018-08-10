window.draw = function(){

  var context = params.canvas.getContext('2d'),
      frame_count = window.frame_count ? window.frame_count : (window.params.zoom - 6) * 2;

  context.clearRect(0, 0, params.canvas.width, params.canvas.height);

  var f = frame / frame_count;

  //obtain the active bus trips
  var bus_trips_t1 = data_bus.positions[ times[current_index] ],
      bus_trips_t2 = data_bus.positions[ times[current_index + 1] ];

  var bus_trip_keys = Object.keys(bus_trips_t1);
  var bus_dot = [];

  // show active bus trips
  bus_trip_keys.forEach(function(t){
    if(bus_trips_t2[t]){
      var d = interpolate( bus_trips_t1[t], bus_trips_t2[t], f);
      bus_dot = canvasOverlay._map.latLngToContainerPoint(d);

        if (layer_type_sel == "all" || layer_type_sel == "bus"){

          context.fillStyle = "#0057fa";
          context.beginPath();
          context.arc(bus_dot.x, bus_dot.y, window.params.zoom - 9 + 3, 0, Math.PI * 2);
          context.lineWidth = 4;
          context.fill();
          context.strokeStyle = '#FFFFFF';
          context.stroke();
          var filled_cap = Math.random(); 
          if (filled_cap <= 0.5) {
            context.strokeStyle = '#b3cf3c'; 
          }
          else if (filled_cap <= 0.8) {
            context.strokeStyle = '#f1960b'; 
          }
          else
            context.strokeStyle = '#f1270b';
          context.lineWidth = 4;
          context.beginPath();
          context.arc(bus_dot.x,bus_dot.y,window.params.zoom - 9 + 3, -0.5*Math.PI, (2*filled_cap-0.5)*Math.PI, false);
          context.stroke();
          context.fillStyle = "#111";
          context.fillText(t.split('.')[0],bus_dot.x+6,bus_dot.y-6);
          context.closePath();
        }
    }   
  });

  //obtain the actuve cab trips
  var cab_trips_t1 = data_cab.positions[ times[current_index] ],
      cab_trips_t2 = data_cab.positions[ times[current_index + 1]];

  active_cabs = [];
  active_cabs_index = 0;

  var cab_ds = [], 
      cab_dots = [];

  if (cab_trips_t1 && cab_trips_t2){

    var cab_trip_keys = Object.keys(cab_trips_t1);

    cab_trip_keys.forEach(function(t){

      if(cab_trips_t2[t]){
        var cab_d = interpolate( cab_trips_t1[t], cab_trips_t2[t], f),
            cab_dot = canvasOverlay._map.latLngToContainerPoint(cab_d);

        cab_ds[t] = cab_d;
        cab_dots[t] = cab_dot;

        //record the active cabs, for the cab click event
        active_cabs[active_cabs_index] = [t, cab_dot.x, cab_dot.y, cab_trips_t1[t][3], cab_trips_t1[t][2],cab_trips_t1[t][4],cab_trips_t1[t][5]];
        active_cabs_index += 1;

        //update the cab routes, for dynamically showing the cab routes
        var fea_index = parseInt(t.split("")[1]);
        if (!cab_routes.features[fea_index]) {
          var cab_feature = {
            "type": "Feature",
            "geometry": {"type": "LineString", "coordinates": []}
          };
          cab_routes.features[fea_index] = cab_feature;
        }
        cab_routes.features[fea_index].geometry.coordinates.push([cab_d[1],cab_d[0]]);

        if (layer_type_sel == "all" || layer_type_sel == "cab") {
          context.fillStyle = "#faeb00";
          context.beginPath();
          context.arc(cab_dot.x, cab_dot.y, window.params.zoom - 9 + 3, 0, Math.PI * 2);
          context.lineWidth = 4;
          context.fill();
          context.strokeStyle = '#FFFFFF';
          context.stroke(); 
          if (parseInt(cab_trips_t2[t][3]) <= 2) {
            context.strokeStyle = '#f1270b'; 
          }
          else
            context.strokeStyle = '#b3cf3c';
          context.lineWidth = 4;
          context.beginPath();
          context.arc(cab_dot.x,cab_dot.y,window.params.zoom - 9 + 3, -0.5*Math.PI, 1.5*Math.PI, false);
          context.stroke();
          context.fillStyle = "#111";
          context.fillText(t.split('.')[0],cab_dot.x+6,cab_dot.y-6);
          context.closePath();
        }
        if (Slidenav_show == 1 && active_cab_id == t) {
          if (parseInt(cab_trips_t2[t][3]) <=2) {
            document.getElementById('status').innerHTML = "Status: busy";
          }
          else {
            document.getElementById('status').innerHTML = "Status: idle";
          }
          
          document.getElementById("dist").innerHTML = "Distance: " + cab_trips_t2[t][2];
          document.getElementById("revenue").innerHTML = "Revenue: $" + cab_trips_t2[t][5];
          document.getElementById("cost").innerHTML = "Cost: $" + cab_trips_t2[t][4];
        }
      }           
    });
  }

  //obtain active private car trips
  var car_trips_t1 = data_car.positions[ times[current_index] ],
      car_trips_t2 = data_car.positions[ times[current_index + 1]];

  var car_ds = [], 
      car_dots = [];

  if (car_trips_t1 && car_trips_t2){

    var car_trip_keys = Object.keys(car_trips_t1);

    car_trip_keys.forEach(function(t){

      if(car_trips_t2[t]){
        var car_d = interpolate( car_trips_t1[t], car_trips_t2[t], f),
            car_dot = canvasOverlay._map.latLngToContainerPoint(car_d);

        car_ds[t] = car_d;
        car_dots[t] = car_dot;

        //update the car routes, for dynamically showing the car routes
        var fea_index = 0;
        if (!car_routes.features[fea_index]) {
          var car_feature = {
            "type": "Feature",
            "geometry": {"type": "LineString", "coordinates": []}
          };
          car_routes.features[fea_index] = car_feature;
        }
        car_routes.features[fea_index].geometry.coordinates.push([car_d[1],car_d[0]]);

        if (layer_type_sel == "all" || layer_type_sel == "car") {
          context.fillStyle = "#feab00";
          context.beginPath();
          context.arc(car_dot.x, car_dot.y, window.params.zoom - 9 + 3, 0, Math.PI * 2);
          context.lineWidth = 4;
          context.fill();
          context.strokeStyle = '#FFFFFF';
          context.stroke(); 
          context.lineWidth = 4;
          context.beginPath();
          context.arc(car_dot.x,car_dot.y,window.params.zoom - 9 + 3, -0.5*Math.PI, 1.5*Math.PI, false);
          context.stroke();
          context.fillStyle = "#111";
          context.fillText(t.split('.')[0],car_dot.x+6,car_dot.y-6);
          context.closePath();
        }
      }           
    });
  }

  //obtain the active user trips
  var user_trips_t1 = data_user.positions[ times[current_index] ],
      user_trips_t2 = data_user.positions[ times[current_index + 1] ],
      f = frame / frame_count;

  var user_trip_keys = Object.keys(user_trips_t1);

  var active_user_num = 1;

  user_trip_keys.forEach(function(t){
    
    if(user_trips_t2[t]){

      var user_dot = [];
      var user_status = user_trips_t2[t][0].split(".")[0];

      var fea_index = parseInt(t.split("")[1]);
      if (!user_routes.features[fea_index]) {
        var user_feature = {
          "type": "Feature",
          "geometry": {"type": "LineString", "coordinates": []}
        };
        user_routes.features[fea_index] = user_feature;
      }

      // assign the location information according to user's status
      var vehicle_id = [];
      var status_color = [];
      if (user_status == "cab") {
        vehicle_id = user_trips_t1[t][0].split(".")[1];
        user_dot = cab_dots[vehicle_id];
        user_routes.features[fea_index].geometry.coordinates.push([cab_ds[vehicle_id][1],cab_ds[vehicle_id][0]]);
        status_color = "#faeb00";
      }
      else if (user_status == "bus") {
        status_color = "#0057fa";
      }
      else if (user_status == "wa") {
        user_dot = user_dots[t];
        vehicle_id = "waiting after confirmation"
        status_color = "#ffffff";
      }
      else if (user_status == "wb") {
        status_color = "#ffffff";
      }
      else if (user_status == "wk") {
        status_color = "#111";
      }
      else if (user_status == "pc") {
        vehicle_id = user_trips_t1[t][0].split(".")[1];
        user_dot = car_dots[vehicle_id];
        user_routes.features[fea_index].geometry.coordinates.push([car_ds[vehicle_id][1],car_ds[vehicle_id][0]]);
        vehicle_id = "private car";
        status_color = "#feab00";
      }

      // show atcive user trips
      if (layer_type_sel == "all" || layer_type_sel == "user"){

        context.fillStyle = "#111";
        context.beginPath();
        context.arc(user_dot.x, user_dot.y, window.params.zoom - 9 + 3, 0, Math.PI * 2);
        context.lineWidth = 4;
        context.fill();
        context.strokeStyle = status_color;
        context.stroke();
        context.lineWidth = 4;
        context.beginPath();
        context.arc(user_dot.x,user_dot.y,window.params.zoom - 9 + 3, -0.5*Math.PI, 1.5*Math.PI, false);
        context.stroke();
        context.fillStyle = "#111";
        context.fillText(t.split('.')[0],user_dot.x+6,user_dot.y-6);
        context.closePath();

        if (active_user_num > 1) {
          document.getElementById('user_id').innerHTML += "," + t;
          document.getElementById('user_status').innerHTML += "," + user_status+ "-"+vehicle_id;
          document.getElementById('user_utility').innerHTML += "," + user_trips_t1[t][1];
        }else{
          document.getElementById('user_id').innerHTML = "User ID: " + t;
          document.getElementById('user_status').innerHTML = "User Status: " + user_status + "-"+vehicle_id;
          document.getElementById('user_utility').innerHTML = "User Utility: " + user_trips_t1[t][1];
          active_user_num += 1;
        }

      }

      user_dots[t] = user_dot;
    }   
  });

  // update svg layer, according to the selected layer
  if (layer_type_sel == "all") {
    map.removeLayer(svg_bus);
    svg_bus = svgBus(routes);
    svg_bus.addTo(map);
    svg_bus_show = 1;

    map.removeLayer(svg_cab);
    svg_cab = svgCab(cab_routes);
    svg_cab.addTo(map);
    svg_cab_show = 1;

    map.removeLayer(svg_car);

    svg_car = svgCar(car_routes);
    svg_car.addTo(map);
    svg_car_show = 1;

    map.removeLayer(svg_user);

    svg_user = svgUser(user_routes);
    svg_user.addTo(map);
    svg_user_show = 1;
  }
  else if(layer_type_sel == "cab") {
    if (svg_bus_show == 1) {
      map.removeLayer(svg_bus);
      svg_bus_show = 0;
    }
    if (svg_car_show == 1) {
      map.removeLayer(svg_car);
      svg_car_show = 0;
    }
    if (svg_user_show == 1) {
      map.removeLayer(svg_user)
      svg_user_show = 0;
    }
    map.removeLayer(svg_cab);

    svg_cab = svgCab(cab_routes);
    svg_cab.addTo(map);
    svg_cab_show = 1;

  }
  else if (layer_type_sel == "car") {
    if (svg_bus_show == 1) {
      map.removeLayer(svg_bus);
      svg_bus_show = 0;
    }
    if (svg_cab_show == 1) {
      map.removeLayer(svg_cab);
      svg_cab_show = 0;
    }
    if (svg_user_show == 1) {
      map.removeLayer(svg_user);
      svg_user_show = 0;
    }
    map.removeLayer(svg_car);

    svg_car = svgCar(car_routes);
    svg_car.addTo(map);
    svg_car_show = 1;
    if (Slidenav_show == 1)
      closeNav();
  }
  else if (layer_type_sel == "user") {
    if (svg_bus_show == 1) {
      map.removeLayer(svg_bus);
      svg_bus_show = 0;
    }
    if (svg_cab_show == 1) {
      map.removeLayer(svg_cab);
      svg_cab_show = 0;
    }
    if (svg_car_show == 1) {
      map.removeLayer(svg_car);
      svg_car_show = 0;
    }
    map.removeLayer(svg_user);

    svg_user = svgUser(user_routes);
    svg_user.addTo(map);
    svg_user_show = 1;
  }
  else{
    if (svg_user_show == 1) {
      map.removeLayer(svg_user);
      svg_user_show = 0;
    }
    if (svg_cab_show == 1) {
      map.removeLayer(svg_cab);
      svg_cab_show = 0;
    }
    if (svg_car_show == 1) {
      map.removeLayer(svg_car);
      svg_car_show = 0;
    }

    map.removeLayer(svg_bus);
    svg_bus = svgBus(routes);
    svg_bus.addTo(map);
    svg_bus_show = 1;
    
    
    if (Slidenav_show == 1)
      closeNav();
  }

  //keep time moving
  frame = (frame + 1) % frame_count;

  if(frame == 0){
    current_index += 1;
    var t = m_to_h( data_bus.start_time + current_index );

    current_time_h.val(t.h);
    current_time_m.val(t.m);
    current_time_p.val(t.p);
  }
  if(running && current_index < (times.length - 1)){
    setTimeout(function(){
      requestAnimationFrame(draw);
    }, timeout);
  }

};