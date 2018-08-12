require 'pg'
require 'json'

owner_name = "gtfs_t"
database_name = "bus_db_t"

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

File.open(dirname+"/createTables_bus.sql", "r") do |f|
  f.each_line do |line|

    create_tables += line
  end
end

puts create_tables
conn.exec(create_tables)
puts "\ntables created\n"

import_data = ""

File.open(dirname+"/importData_bus.sql", "r") do |f|
  f.each_line do |line|

   	line["dir"] = dirname
    import_data += line
  end
end

puts import_data
conn.exec(import_data)
puts "\ndata imported\n"

process_data = ""

File.open(dirname+"/processData_bus.sql", "r") do |f|
  f.each_line do |line|

    process_data += line
  end
end

puts process_data
conn.exec(process_data)
puts "\ndata processed\n"


cmd = "ogr2ogr -f GeoJSON routes_bus.json \"PG:host=localhost dbname=databaseName user=ownerName\" -sql 'select route_id, shape_id, geom from gtfs_shape_lines;'"
cmd["databaseName"] = database_name
cmd["ownerName"] = owner_name
value = `#{cmd}`
puts "\nroutes.json generated\n"

exact_routes = ""

File.open(dirname+"/exact_routes.sql", "r") do |f|
  f.each_line do |line|

    exact_routes += line
  end
end

puts exact_routes

interpolated_routes = ""

File.open(dirname+"/interpolated_routes.sql", "r") do |f|
  f.each_line do |line|

    interpolated_routes += line
  end
end

puts interpolated_routes

positions = []

0.upto(23) do |i|
  h = (i + 3) % 24
  0.upto(59) do |m|
    t = "#{ h.to_s.rjust(2, '0') }:#{ m.to_s.rjust(2, '0') }"

    puts t

    p = conn.exec(exact_routes.gsub('09:00',t)).values
    p += conn.exec(interpolated_routes.gsub('09:00',t)).values

    positions << p
    
  end
end

positions.map! do |p|
  t = {}
  p.each do |trip|
    t[ "#{ trip[0] }.#{ trip[1] }" ] = [ trip[3].to_f, trip[2].to_f ]
  end
  t
end

File.open('DyPosition_bus.json','wb') do |f|
  f.write( { start_time: 180, positions: positions } .to_json)
end
puts "\nDyPosition_bus.json generated\n"