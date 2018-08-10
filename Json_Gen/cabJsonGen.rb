require 'pg'
require 'json'
require 'pry'

conn = PG.connect :dbname => 'cab_db_t', :user => 'gtfs_t'

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
				else    #######registered, not busy and bot moved
					# binding.pry
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

# puts cab_info