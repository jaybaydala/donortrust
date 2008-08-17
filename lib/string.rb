class String
	def strip_tags
		self.gsub( %r{</?[^>]+?>}, '' )
	end
end