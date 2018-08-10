create table cab_busy (t integer, revenue integer, cost numeric);
create table cab_list (t integer, cab_id varchar(4), status integer);
create table cab_state (t integer, state integer, moved integer);
create table cab_loc(t integer, lat numeric, lon numeric, distance numeric);


copy cab_busy from '/Users/iniesdu/Desktop/data_0802/cabbusy.txt' with delimiter ',' null '' csv header;
copy cab_list from '/Users/iniesdu/Desktop/data_0802/cablist.txt' with delimiter ',' null '' csv header;
copy cab_state from '/Users/iniesdu/Desktop/data_0802/cabstate.txt' with delimiter ',' null '' csv header;
copy cab_loc from '/Users/iniesdu/Desktop/data_0802/cabloc.txt' with delimiter ',' null '' csv header;


create table user_list (t integer, user_id integer, status integer);
create table user_loc (t integer, lat numeric, lon numeric, distance numeric);
create table user_state (t integer, state integer);
create table user_update (t integer, state integer, vehicle integer, utility integer);
create table user_utility (t integer, utility integer);
create table user_vehicle (t integer, vehicle varchar(4));


copy user_list from '/Users/iniesdu/Desktop/data_0802/userlist.txt' with delimiter ',' null '' csv header;
copy user_loc from '/Users/iniesdu/Desktop/data_0802/userloc.txt' with delimiter ',' null '' csv header;
copy user_state from '/Users/iniesdu/Desktop/data_0802/userstate.txt' with delimiter ',' null '' csv header;
copy user_update from '/Users/iniesdu/Desktop/data_0802/userupdate.txt' with delimiter ',' null '' csv header;
copy user_utility from '/Users/iniesdu/Desktop/data_0802/userutility.txt' with delimiter ',' null '' csv header;
copy user_vehicle from '/Users/iniesdu/Desktop/data_0802/uservehicle.txt' with delimiter ',' null '' csv header;



create table car_loc (t integer, lat numeric, lon numeric, distance numeric);
create table car_state (t integer, moved integer);

copy car_loc from '/Users/iniesdu/Desktop/data_0802/carloc.txt' with delimiter ',' null '' csv header;
copy car_state from '/Users/iniesdu/Desktop/data_0802/carstate.txt' with delimiter ',' null '' csv header;