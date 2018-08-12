require 'pg'
require 'json'
require 'pry'


owner_name = "gtfs_t"
database_name = "cab_db_t"

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

File.open(dirname+"/createTables_cab.sql", "r") do |f|
  f.each_line do |line|

    create_tables += line
  end
end

puts create_tables
conn.exec(create_tables)
puts "\ntables created\n"

import_data = ""

File.open(dirname+"/importData_cab.sql", "r") do |f|
  f.each_line do |line|

   	line["dir"] = dirname
    import_data += line
  end
end

puts import_data
conn.exec(import_data)
puts "\ndata imported\n"

sql = "select t, cab_id from cab_list where status = 1 order by cab_id asc;" 

p = conn.exec(sql).values

cab_reg = []

p.each do |i|
	cab_reg << [i[1],i[0]]
end

sql = "select t, cab_id from cab_list where status = 0 order by cab_id asc;"

p = conn.exec(sql).values

p.each do |i|
	cab_reg.each_with_index do |j, index|
		if i[1] == j[0]
			cab_reg[index][1] += "." + i[0]
		end
	end
end


time_min = conn.exec("select min(t) from cab_list").values.join.to_i
time_max = conn.exec("select max(t) from cab_list").values.join.to_i

cab_list = []

time_offset = 330

for t0 in 0..1439

	cab_infos = []

	if t0 - time_offset >= time_min && t0 - time_offset < time_max

		t = t0 - time_offset
		cab_index = 0

		cab_reg.each_with_index do |cab, index|

			cab_info = []

			if cab[1].split('.')[0].to_i > t || cab[1].split('.')[1].to_i <= t #######unregistered

			else  ####registered
				cab_info[0] = cab[0]

				sql = "select state, moved from cab_state where t = time".gsub('time', "#{t}")
				p = conn.exec(sql).values

				sql = "select lat, lon, distance from cab_loc where t = time".gsub('time', "#{t}")
				loc = conn.exec(sql).values

				sql = "select revenue, cost from cab_busy where t = time".gsub('time', "#{t}")
				busy = conn.exec(sql).values

				if p[0][0].split(//)[cab_index] == '1' && p[0][1].split(//)[cab_index] == '0' ######registered, busy and not moved
					cab_info[1] = "1"
					cab_info += loc[cab_index]
					cab_info << busy[cab_index][1]
					cab_info << busy[cab_index][0]
				elsif p[0][0].split(//)[cab_index] == '1' && p[0][1].split(//)[cab_index] == '1' ######registered, busy and moved
					cab_info[1] = "2"
					cab_info += loc[cab_index]
					cab_info << busy[cab_index][1]
					cab_info << cab_list[t0-1][cab_index][6]
				elsif p[0][0].split(//)[cab_index] == '0' && p[0][1].split(//)[cab_index] == '1' ######registered, not busy and moved
					cab_info[1] = "3"
					cab_info += loc[cab_index]
					cab_info << busy[cab_index][1]
					cab_info << cab_list[t0-1][cab_index][6]
				else    #######registered, not busy and not moved
					cab_info[1] = "4"
					cab_info += cab_list[t0-1][cab_index][2..4]
					cab_info << busy[cab_index][1]
					cab_info << cab_list[t0-1][cab_index][6]
				end

				cab_index += 1		
				cab_infos << cab_info
			end
		end
	end

	cab_list << cab_infos
	puts t0
end

# binding.pry

cab_list.map! do |p|
  t = {}
  p.each do |trip|
    t[ trip[0] ] = [ trip[2].to_f, trip[3].to_f, trip[4].to_f, trip[1].to_i, trip[5].to_f, trip[6].to_i ]
  end
  t
end
# binding.pry

File.open('DyPosition_cab.json','wb') do |f|
  f.write( { start_time: 180, positions: cab_list } .to_json)
end

puts "DyPosition_cab.json Generated"

# puts cab_info