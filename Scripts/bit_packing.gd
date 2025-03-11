extends Node

var array_data: Array = []
var decompressed_data: Array = []

# A DataChunk object will contain the compressed value as well as the bits sizes and types of the variables inside
class DataChunk:
	var value: String
	var bits: Array
	var types: Array
	
	func _init(value, bits, types):
		self.value = value
		self.bits = bits
		self.types = types

# Compress the data into one value
# Two arrays are made that keep track of the variable types for later decompression
# All items are sent as one object
func compress(data):
	print(data)
	array_data.clear()
	var dataChunk = ""
	var bits_array = []
	var types = []
	
	for value in data:
		var type = typeof(value)
		if typeof(value) == TYPE_STRING or typeof(value) == TYPE_STRING_NAME:
			value = value.to_int()
		
		var result = convert_to_bits(value, (var_to_bytes(value).size() * 8))
		var bitValue = result[0]
		var bits = result[1]
		
		var trimmedValue = bitValue.lstrip("0")
		if trimmedValue == "":
			trimmedValue = "0"
		
		dataChunk += trimmedValue
		print("Value: ", dataChunk)
		bits_array.append(bits)
		types.append(type)
	
	var chunk = DataChunk.new(dataChunk, bits_array, types)
	print("Bit Representation: ", chunk.value, " bits: ", chunk.bits, chunk.types)
	array_data.append(chunk)
	
	return array_data

# Decompression will take the object and iterate through the number of values inside
# The for loop will extract the bit values inside the packet and decompress them using their size and type
# These values are then added to a new array and returned

func decompress(compressedPacket: Array):
	print(compressedPacket)
	
	decompressed_data.clear()
	
	var chunk = compressedPacket[0]
	var string = chunk.value
	var bits = chunk.bits
	var types = chunk.types
	print(string, bits, types)
	
	for i in range(bits.size()):
		var value = string.substr(i, bits[i])
		var decompressed_value = convert_to_variable(value, types[i])
		decompressed_data.append(decompressed_value)
	
	print(decompressed_data)
	
	return decompressed_data

func convert_to_bits(value, bits):
	# A string is used here to append bit values instead off adding them up
	var bit_chunk: String = ""
	# For loop which loops starting at the highest bit index, iterates backwards and stops at 0
	for i in range(bits - 1, -1, -1):
		bit_chunk += str((value >> i) & 1)
		print("Bit chunk: ", bit_chunk)
	
	# This variable strips any leading zeroes from the front of the bit value and creates the values new length from that
	var trimmedValue = bit_chunk.lstrip("0")
	if trimmedValue == "":
		trimmedValue = "0"
	
	value = trimmedValue
	bits = len(trimmedValue)
	
	return [value, bits]

# Since the bit_packing script only accepts integers and strings that store numbers, we can simply
# convert the value to an integer using Godot's in-build binary converter
func convert_to_variable(value, type):
	var variable
	
	if type == 2:
		variable = value.bin_to_int()
	elif type == TYPE_STRING_NAME or type == TYPE_STRING:
		variable = str(value.bin_to_int())
	
	return variable 
