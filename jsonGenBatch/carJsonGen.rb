require 'pg'
require 'json'
require 'pry'

owner_name = "gtfs_t"
database_name = "car_db_t"

cmd_drop_db_if = "psql -c \"DROP DATABASE IF EXISTS \"databaseName\";\""
cmd_drop_db_if["databaseName"] = database_name

puts cmd_drop_db_if
value = `#{cmd_drop_db_if}`

cmd_drop_role_if = "psql -c \"DROP ROLE IF EXISTS \"ownerName\";\""
cmd_drop_role_if["ownerName"] = owner_name

puts cmd_drop_role_if
value = `#{cmd_drop_role_if}`

cmd_create_role = "psql -c \"CREATE ROLE \"ownerName\" WITH LOGIN;\""
cmd_create_role["ownerName"] = owner_name

puts cmd_create_role
value = `#{cmd_create_role}`
puts "\nrole created\n"

cmd_create_db = "psql -c \"CREATE DATABASE \"databaseName\" OWNER \"ownerName\";\"";
cmd_create_db["ownerName"] = owner_name
cmd_create_db["databaseName"] = database_name

puts cmd_create_db
value = `#{cmd_create_db}`
puts "\ndatabase created\n"

cmd_alter_superuser = "psql -c \"ALTER USER \"ownerName\" WITH SUPERUSER;\""
cmd_alter_superuser["ownerName"] = owner_name

puts cmd_alter_superuser
value = `#{cmd_alter_superuser}`
puts "\nsuperuser altered\n"

conn = PG.connect :dbname => database_name, :user => owner_name

dirname = Dir.pwd

create_tables = ""

File.open(dirname+"/createTables_car.sql", "r") do |f|
  f.each_line do |line|

    create_tables += line
  end
end

puts create_tables
conn.exec(create_tables)
puts "\ntables created\n"

import_data = ""

File.open(dirname+"/importData_car.sql", "r") do |f|
  f.each_line do |line|

   	line["dir"] = dirname
    import_data += line
  end
end

puts import_data
conn.exec(import_data)
puts "\ndata imported\n"

time_min = conn.exec("select min(t) from car_state").values.join.to_i
time_max = conn.exec("select max(t) from car_state").values.join.to_i

car_list = []

time_offset = 330

for t0 in 0..1439

	car_infos = []

	if t0 - time_offset >= time_min && t0 - time_offset <= time_max

		t = t0 - time_offset

		sql = "select lat, lon, distance from car_loc where t = time;".gsub('time', "#{t}");

		car_loc = conn.exec(sql).values
		car_infos = car_loc 
	end

	car_list << car_infos
	puts t0
end

car_list.map! do |p|
  t = {}
  p.each do |trip|
    t["pc"] = [ trip[0].to_f, trip[1].to_f, trip[2].to_f]
  end
  t
end

File.open('DyPosition_car.json','wb') do |f|
  f.write( { start_time: 180, positions: car_list } .to_json)
end

puts "DyPosition_car.json Generated"