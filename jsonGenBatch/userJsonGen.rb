require 'pg'
require 'json'
require 'pry'


owner_name = "gtfs_t"
database_name = "user_db_t"

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

File.open(dirname+"/createTables_user.sql", "r") do |f|
  f.each_line do |line|

    create_tables += line
  end
end

puts create_tables
conn.exec(create_tables)
puts "\ntables created\n"

import_data = ""

File.open(dirname+"/importData_user.sql", "r") do |f|
  f.each_line do |line|

   	line["dir"] = dirname
    import_data += line
  end
end

puts import_data
conn.exec(import_data)
puts "\ndata imported\n"

sql = "select t, user_id from user_list where status = 1 order by user_id asc;" 

p = conn.exec(sql).values

user_reg = []

p.each do |i|
	user_reg << [i[1],i[0]]
end

sql = "select t, user_id from user_list where status = 0 order by user_id asc;"

p = conn.exec(sql).values

p.each do |i|
	user_reg.each_with_index do |j, index|
		if i[1] == j[0]
			user_reg[index][1] += "." + i[0]
		end
	end
end

time_min = conn.exec("select min(t) from user_list").values.join.to_i
time_max = conn.exec("select max(t) from user_list").values.join.to_i

user_list = []

time_offset = 330

for t0 in 0..1439

	user_infos = []
	if t0 - time_offset >= time_min && t0 - time_offset < time_max
		t = t0 - time_offset
		# user_infos << ["t=" + "#{t}"]
		user_index = 0
		user_reg.each_with_index do |user, index|
			user_info = []
			if user[1].split('.')[0].to_i > t || user[1].split('.')[1].to_i <= t #######unregistered
				
			else ######registered
				user_info[0] = user[0]
				sql_update = "select state from user_update where t = time;".gsub('time', "#{t}")
				user_state_update = conn.exec(sql_update).values
				# binding.pry
				if user_state_update[0][0].split(//)[user_index] == "1"
					sql_state = "select state from user_state where t = time;".gsub('time', "#{t}")
					user_state = conn.exec(sql_state).values
					if user_state[user_index][0] == "4"
						sql_vehicle_update = "select vehicle from user_update where t = time;".gsub('time',"#{t}")
						user_vehicle_update = conn.exec(sql_vehicle_update).values
						if user_vehicle_update[0][0].split(//)[user_index] == "1"
							sql_vehicle = "select vehicle_id from user_vehicle where t = time;".gsub('time',"#{t}")
							user_vehicle = conn.exec(sql_vehicle).values
							user_info << user_vehicle[user_index][0]
						else
							user_info << user_list[t0-1][user_index][1]
						end
					else
						if user_state[user_index][0] == "1"
							user_info << "wb"
						elsif user_state[user_index][0] == "2"
							user_info << "wa"
						elsif user_state[user_index][0] == "3"
							user_info << "wk"
							###### query the walking locations ######
						else
							user_info << "pc"
						end
					end
				else
					# binding.pry
					user_info << user_list[t0-1][user_index][1]
				end

				sql_utility_update = "select utility from user_update where t = time;".gsub('time', "#{t}")
				user_utility_update = conn.exec(sql_utility_update).values

				if user_utility_update[0][0].split(//)[user_index] == "1"
					sql_utility = "select utility from user_utility where t = time;".gsub('time',"#{t}")
					user_utility = conn.exec(sql_utility).values
					# binding.pry
					user_info << user_utility[user_index][0]
				else
					user_info << user_list[t0-1][user_index][2]
				end
				user_index += 1
				user_infos << user_info
			end

		end
	end
	puts t0
	user_list << user_infos
	# binding.pry
end
# binding.pry

user_list.map! do |p|
  	t = {}
	p.each do |trip|
		if trip[1] == "wk"
			t[ "u" + trip[0]] = [trip[1]+"."+trip[1], trip[2].to_i, trip[3].to_f, trip[4].to_f]
		elsif trip[1].split(//)[0] == "c"
			t[ "u" + trip[0]] = ["cab."+trip[1], trip[2].to_i]
		elsif trip[1].split(//)[0] == "b"
			t[ "u" + trip[0]] = ["bus."+trip[1], trip[2].to_i]
		else
	    	t[ "u" + trip[0]] = [trip[1]+"."+trip[1], trip[2].to_i]
		end
	end
  	t
end
# binding.pry

File.open('DyPosition_user.json','wb') do |f|
  f.write( { start_time: 180, positions: user_list } .to_json)
end

puts "DyPosition_user.json Generated"