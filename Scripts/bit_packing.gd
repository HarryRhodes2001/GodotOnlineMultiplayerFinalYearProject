extends Node

var array_data: Array = []

# The final array will be made of DataChunk objects, which will contain a value and the number of bits of that value
class DataChunk:
	var value
	var bits
	
	func _init(value, bits):
		self.value = value
		self.bits = bits

# Compresses the data into eight bit chunks
# Each individual variable in the data packet is converted to bits and then separated into data chunks
# This is then appended to an array, which is sent to the recipient and later decompressed
# Work in progress, but nearly finished
func compress(data):
	print(data)
	
	for value in data:
		if typeof(value) == TYPE_STRING or typeof(value) == TYPE_STRING_NAME:
			value = value.to_int()
		var result = convert_to_bits(value, (var_to_bytes(data).size() * 8))
		var bitValue = result[0]
		var bits = result[1]
		var inc = 0
		for i in range(0, bits, 8):
			var dataChunk = bitValue.substr(i+inc, 8)
			if i == 0 or dataChunk == "00000000":
				dataChunk = int(dataChunk)
				dataChunk = str(dataChunk)
			while len(dataChunk) < 8 and dataChunk != "0" and i+len(dataChunk)+inc != bits:
				dataChunk += bitValue.substr(i+8+inc, 1)
				inc += 1
			var chunk = DataChunk.new(dataChunk, bits)
			print("Bit Representation: ", chunk.value, " bits: ", chunk.bits)
			array_data.append(chunk)

	
#func decompress():
	#decompress

func convert_to_bits(value, bits):
	# A string is used here to append bit values instead off adding them up
	# A later conversion to an integer removes any leading zeroes for the first value only
	var bit_chunk: String = ""
	# For loop which loops starting at the highest bit index, iterates backwards and stops at 0
	for i in range(bits - 1, -1, -1):
		bit_chunk += str((value >> i) & 1)
		print("Bit chunk: ", bit_chunk)
	
	value = bit_chunk
	bits = len(value)
	
	return [value, bits]
