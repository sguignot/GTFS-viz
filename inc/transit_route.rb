class TransitRoute
	attr_reader :id, :color
	def initialize(id, color)
		@id = id
		@color = color
		@edge_properties_map = {}
		@segments = []
	end

	def add_edge(u, v)
		key = [u, v]
		unless @edge_properties_map.include?(key)
			@edge_properties_map[key] = compute_distance(u.lon, u.lat, v.lon, v.lat)
		end
	end

	def add_segment(segment)
		@segments.push(segment) unless @segments.include?(segment)
	end

	def compute_unique_segments
		sorted_edges = @edge_properties_map.map do |(u, v), property|
			[u, v, property]
		end.sort do |a, b|
			a.last <=> b.last
		end
		graph = RGL::DirectedAdjacencyGraph.new
		segments = []
		sorted_edges.each do |(u, v, property)|
			if !graph.has_vertex?(u) || !graph.has_vertex?(v) || graph.dijkstra_shortest_path(Hash.new(1), u, v).nil?
				graph.add_edge(u, v)
				segments.push(TransitSegment.new(u, v))
			end
		end

		visitor = RGL::DFSVisitor.new(graph)
		visitor.set_examine_edge_event_handler do |u, v|
			add_segment(TransitSegment.new(u, v))
		end
		@segments = []
		graph.depth_first_search(visitor) {}
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

	def to_geojson_features
		compute_unique_segments
		to_lines.map do |line|
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

	def compute_distance(lon1, lat1, lon2, lat2)
		def deg2rad(deg)
			return deg * Math::PI / 180
		end

		dLat = deg2rad(lat2-lat1)
		dLon = deg2rad(lon2-lon1)
		a = Math.sin(dLat/2) * Math.sin(dLat/2) +
				Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) *
				Math.sin(dLon/2) * Math.sin(dLon/2)
		c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
		d = (6371 * c * 1000).to_i
	end

end
