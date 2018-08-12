DROP TABLE IF EXISTS gtfs_agency;
CREATE TABLE gtfs_agency (agency_id varchar(4), agency_name varchar(50), agency_url text, agency_timezone varchar(50));
DROP TABLE IF EXISTS gtfs_calendar_dates;
CREATE TABLE gtfs_calendar_dates (service_id varchar(50), date date, exception_type integer);
DROP TABLE IF EXISTS gtfs_routes;
CREATE TABLE gtfs_routes (route_id varchar(10), route_short_name varchar(5), route_long_name varchar(50), route_type integer);
DROP TABLE IF EXISTS gtfs_shapes;
CREATE TABLE gtfs_shapes (shape_id char(8), shape_pt_lat numeric, shape_pt_lon numeric, shape_pt_sequence integer);
DROP TABLE IF EXISTS gtfs_stop_times;
CREATE TABLE gtfs_stop_times (trip_id varchar(20), arrival_time time, departure_time time, stop_id char(6), stop_sequence integer);
DROP TABLE IF EXISTS gtfs_stops;
CREATE TABLE gtfs_stops (stop_id char(6), stop_name text, stop_lat numeric, stop_lon numeric);
DROP TABLE IF EXISTS gtfs_trips;
CREATE TABLE gtfs_trips (route_id varchar(10), service_id varchar(50), trip_id varchar(20), shape_id char(8));
