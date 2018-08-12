create table user_list (t integer, user_id integer, status integer);
create table user_loc (t integer, lat numeric, lon numeric, distance numeric);
create table user_state (t integer, state varchar(50));
create table user_update (t integer, state varchar(50), vehicle varchar(50), utility varchar(50));
create table user_utility (t integer, utility integer);
create table user_vehicle (t integer, vehicle_id varchar(4));