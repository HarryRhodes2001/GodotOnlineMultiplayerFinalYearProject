extends Node

var array_data: PackedInt32Array = []

# The final array will be made of DataChunk objects, which will contain a value and bits of that value
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
		# To do: Find a way to cut off the loop early if the remaining values has only zeroes
		for i in range(self.bits - 1, -1, -1):
			bit_chunk += str((self.value >> i) & 1)
			print("Bit chunk: ", bit_chunk)
		
		self.value = int(bit_chunk)

func compress(data):
	var bits = (var_to_bytes(data).size() * 8)
	var chunk = DataChunk.new(data, bits)
	chunk.convert_to_bits()
	print("Bit Representation: ", chunk.value, " bits: ", chunk.bits)
	
	#print("Size of packet before compression: ", packet_data)
	
	var bitstream = 0
	#for i in packet_data:
	#	bitstream |= data << i
	
	print(bitstream)
	array_data.append(bitstream)
	
#func decompress():
	#decompress
