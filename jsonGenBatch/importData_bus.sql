COPY gtfs_agency FROM 'dir/agency.txt' WITH DELIMITER ',' NULL '' CSV HEADER;
COPY gtfs_calendar_dates FROM 'dir/calendar_dates.txt' WITH DELIMITER ',' NULL '' CSV HEADER;
COPY gtfs_routes FROM 'dir/routes.txt' WITH DELIMITER ',' NULL '' CSV HEADER;
COPY gtfs_shapes FROM 'dir/shapes.txt' WITH DELIMITER ',' NULL '' CSV HEADER;
COPY gtfs_stop_times FROM 'dir/stop_times.txt' WITH DELIMITER ',' NULL '' CSV HEADER;
COPY gtfs_stops FROM 'dir/stops.txt' WITH DELIMITER ',' NULL '' CSV HEADER;
COPY gtfs_trips FROM 'dir/trips.txt' WITH DELIMITER ',' NULL '' CSV HEADER;