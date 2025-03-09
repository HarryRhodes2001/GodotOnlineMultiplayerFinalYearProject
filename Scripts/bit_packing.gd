extends Node

var array_data: Array = []
var decompressed_data: Array = []
var types_array: Array = []

# The final array will be made of DataChunk objects, which will contain a value and the number of bits of that value
class DataChunk:
	var value: String
	var bits: int
	var type
	
	func _init(value, bits, type):
		self.value = value
		self.bits = bits
		self.type = type

# Compresses the data into eight bit chunks
# Each individual variable in the data packet is converted to bits and then separated into data chunks
# This is then appended to an array, which is sent to the recipient and later decompressed
# Work in progress, but nearly finished
func compress(data):
	print(data)
	array_data.clear()
	
	for value in data:
		var type = typeof(value)
		if typeof(value) == TYPE_STRING or typeof(value) == TYPE_STRING_NAME:
			value = value.to_int()
		var result = convert_to_bits(value, (var_to_bytes(value).size() * 8))
		var bitValue = result[0]
		var bits = result[1]
		var inc = 0
		var leading_zeroes = true
		for i in range(0, bits, 8):
			var dataChunk = bitValue.substr(i+inc, 8)
			if dataChunk == "00000000" and leading_zeroes == true:
				continue
			if i == 0 or dataChunk == "00000000":
				dataChunk = int(dataChunk)
				dataChunk = str(dataChunk)
			elif leading_zeroes == true:
				dataChunk = int(dataChunk)
				dataChunk = str(dataChunk)
				leading_zeroes = false
			
			
			while len(dataChunk) < 8 and dataChunk != "0" and i+len(dataChunk)+inc != bits:
				dataChunk += bitValue.substr(i+8+inc, 1)
				inc += 1
			var chunk = DataChunk.new(dataChunk, bits, type)
			print("Bit Representation: ", chunk.value, " bits: ", chunk.bits)
			array_data.append(chunk)

	return array_data


func decompress(compressedPacket: Array):
	print(compressedPacket)
	
	decompressed_data.clear()
	print(compressedPacket)
	var variable_data: String = ""
	var bit_length: int = 0
	var var_type
	
	print(compressedPacket.size())
	
	for chunk in compressedPacket:
		if var_type != chunk.type:
			var_type = chunk.type
			types_array.append(var_type)
		
		if chunk is DataChunk:
			if bit_length >= chunk.bits:
				decompressed_data.append(variable_data)
				print(variable_data)
				variable_data = ""
			
			if chunk.value == "0":
				variable_data += "00000000"
			else:
				variable_data += chunk.value
			
			bit_length += 8
	decompressed_data.append(variable_data)
	for i in range(0, decompressed_data.size()):
		decompressed_data[i] = convert_to_variable(decompressed_data[i], types_array[i])
		print("Decompression Result: ", decompressed_data[i])
	
	return decompressed_data

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

func convert_to_variable(value, type):
	var variable
	
	if type == 2:
		variable = value.bin_to_int()
	elif type == TYPE_STRING_NAME:
		variable = str(value.bin_to_int())
	
	return variable 
