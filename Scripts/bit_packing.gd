extends Node

var array_data: Array = []

# The final array will be made of DataChunk objects, which will contain a value and the number of bits of that value
class DataChunk:
	var value
	var bits
	
	func _init(value, bits):
		self.value = value
		self.bits = bits
	
	func convert_to_bits():
		# A string is used here to append bit values instead off adding them up
		# A later conversion to an integer removes any leading zeroes
		var bit_chunk: String = ""
		# For loop which loops starting at the highest bit index, iterates backwards and stops at 0
		for i in range(self.bits - 1, -1, -1):
			bit_chunk += str((self.value >> i) & 1)
			print("Bit chunk: ", bit_chunk)
		
		self.value = int(bit_chunk)
		self.bits = len(str(self.value))

func compress(data):
	print(data)
	
	for value in data:
		if typeof(value) == TYPE_STRING or typeof(value) == TYPE_STRING_NAME:
			value = value.to_int()
		var chunk = DataChunk.new(value, (var_to_bytes(data).size() * 8))
		chunk.convert_to_bits()
		print("Bit Representation: ", chunk.value, " bits: ", chunk.bits)
		array_data.append(chunk)
	
	for chunk in array_data:
		print(chunk.value, "   ", chunk.bits)
	
#func decompress():
	#decompress
