ALTER TABLE gtfs_trips ADD start_time time;
ALTER TABLE gtfs_trips ADD end_time time;	
UPDATE gtfs_trips AS t1 SET start_time = t2.start_time FROM (SELECT trip_id, arrival_time as start_time FROM gtfs_stop_times WHERE stop_sequence = 1) AS t2 WHERE t1.trip_id = t2.trip_id;
UPDATE gtfs_trips AS t1 SET end_time = t2.end_time FROM (SELECT m.trip_id, m.arrival_time as end_time FROM (SELECT trip_id, MAX(stop_sequence) AS stop_sequence_max FROM gtfs_stop_times GROUP BY trip_id) t JOIN gtfs_stop_times m ON m.trip_id = t.trip_id AND t.stop_sequence_max = m.stop_sequence) AS t2 WHERE t1.trip_id = t2.trip_id;
CREATE EXTENSION postgis;
ALTER TABLE gtfs_shapes ADD COLUMN geom geometry(POINT,4326);
UPDATE gtfs_shapes SET geom = ST_SetSRID(ST_MakePoint(shape_pt_lon, shape_pt_lat), 4326);
ALTER TABLE gtfs_stops ADD COLUMN geom geometry(POINT,4326);
UPDATE gtfs_stops SET geom = ST_SetSRID(ST_MakePoint(stop_lon, stop_lat), 4326);
DROP TABLE IF EXISTS gtfs_shape_lines;
CREATE TABLE gtfs_shape_lines (route_id varchar(10), shape_id char(8), geom geometry(LINESTRING,4326));
UPDATE gtfs_stops SET geom = ST_SetSRID(ST_MakePoint(stop_lon, stop_lat), 4326);
INSERT INTO gtfs_shape_lines SELECT DISTINCT t.route_id, s.shape_id, s.geom FROM gtfs_trips AS t, (SELECT shape_id, ST_MakeLine(geom ORDER BY shape_pt_sequence) AS geom FROM gtfs_shapes GROUP BY shape_id) AS s WHERE s.shape_id = t.shape_id;