class TransitSegment
	attr_reader :a, :b
	def initialize(a, b)
		@a = a
		@b = b
	end

	def ==(other)
		# undirected comparison
		(a == other.a && b == other.b) || (a == other.b && b == other.a)
	end

	def eql?(other)
		self == other
	end

    def hash
        [a.hash, b.hash].sort.hash
    end
end
