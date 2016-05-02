class TransitNode
	attr_reader :lon, :lat
	def initialize(lon, lat)
		@lon = lon.to_f
		@lat = lat.to_f
	end

	def ==(other)
		lon == other.lon && lat == other.lat
	end

	def eql?(other)
		self == other
	end

	def hash
		[lon, lat].hash
	end

	def to_geojson_coordinates
		[lon, lat]
	end
end
