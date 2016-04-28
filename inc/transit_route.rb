class TransitRoute
	attr_reader :id, :color, :segments
	def initialize(id, color)
		@id = id
		@color = color
		@segments = []
	end

	def add_segment(segment)
		@segments.push(segment) unless @segments.include?(segment)
	end

	def to_lines
		lines = []
		previous_node = nil
		@segments.each do |segment|
			lines.push([segment.a]) if previous_node != segment.a
			lines.last.push(segment.b)
			previous_node = segment.b
		end
		lines
	end

	def to_lines_without_long_runs
		lines = to_lines
		lines_without_long_runs = []
		lines.each do |line|
			other_lines_merged = (lines - [line]).flatten
			is_long_run = (line - other_lines_merged).empty?
			lines_without_long_runs.push(line) unless is_long_run
		end
		lines_without_long_runs
	end

	def to_geojson_features
		to_lines_without_long_runs.map do |line|
			{
				'type' => 'Feature',
				'properties' => {
					'route_id' => id,
					'color' => color
				},
				'geometry' => {
					'type' => 'LineString',
					'coordinates' => line.map(&:to_geojson_coordinates)
				}
			}
		end
	end


end
