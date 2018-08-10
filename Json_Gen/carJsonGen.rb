require 'pg'
require 'json'
require 'pry'

conn = PG.connect :dbname => 'car_db_t', :user => 'gtfs_t'

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