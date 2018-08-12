create table cab_busy (t integer, revenue integer, cost numeric);
create table cab_list (t integer, cab_id varchar(4), status integer);
create table cab_state (t integer, state varchar(50), moved varchar(50));
create table cab_loc(t integer, lat numeric, lon numeric, distance numeric);