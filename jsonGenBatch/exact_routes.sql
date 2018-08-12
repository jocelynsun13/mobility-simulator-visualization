SELECT trip_id, gtfs_shape_lines.route_id, lon, lat FROM gtfs_shape_lines, (SELECT trip_id, route_id, ST_X(geom) as lon, ST_Y(geom) as lat FROM ( SELECT gtfs_trips.route_id, current_stops.trip_id, ST_ClosestPoint(gtfs_shape_lines.geom, current_stops.geom) as geom FROM gtfs_shape_lines, gtfs_trips, ( SELECT DISTINCT ON (trip_id) gtfs_stop_times.trip_id, gtfs_stops.geom FROM gtfs_stop_times, gtfs_stops, (SELECT trip_id FROM gtfs_trips t WHERE t.start_time <= time '09:00' AND t.end_time >= time '09:00' ) AS active_trips WHERE gtfs_stop_times.trip_id = active_trips.trip_id AND gtfs_stop_times.stop_id = gtfs_stops.stop_id AND gtfs_stop_times.departure_time = time '09:00' ORDER BY trip_id, stop_sequence DESC ) AS current_stops WHERE gtfs_shape_lines.shape_id = gtfs_trips.shape_id AND gtfs_trips.trip_id = current_stops.trip_id) AS t2) AS t3 WHERE t3.route_id = gtfs_shape_lines.route_id;