extends Node

signal noray_connected

# This is the address of the stun server that will handle the NAT punchthrough
# Port number 8890 must be used here, the previous port number does not work
const STUNADDRESS = "tomfol.io"
const PORT = 8890
var playerNo = 8
var peer = null

var host = false
var external_address = ""

# NOTICE: A fair amount of this code was taken from this tutorial: www.youtube.com/watch?v=n8D3vEx7NAE
# This was helpful to connect emitting signals from the players whilst also using RPC functions
# Some of the code in the tutorial is present in other scripts, the most relevant information starts at 24:53

# NOTICE: Noray connection code was provided by: https://www.youtube.com/watch?v=g-k_cM7aFgo

# Upon opening an instance this ready function runs automatically and connects the user to the STUN server
# Other functions are connected through here, see the function definitions for descriptions
func _ready():
	Noray.on_connect_to_host.connect(on_noray_connected)
	Noray.on_connect_nat.connect(handle_nat)
	Noray.on_connect_relay.connect(handle_relay_connection)
	Noray.connect_to_host(STUNADDRESS, PORT)

# This works in a similar way to the original code, except that this server is made on the local port provided by Noray
func create_server():
	peer = ENetMultiplayerPeer.new()
	if peer.create_server(Noray.local_port, playerNo) == OK:
		multiplayer.multiplayer_peer = peer
		print("Server started on port:", PORT)
		host = true
		return true
	else:
		print("Failed to start server.")
		peer = null
		return false

# This join function attempts to connect using NAT punchthrough
# External address
func join(address):
	Noray.connect_nat(address)
	external_address = address

# This function registers the new instance with Noray
# This will allow the user running this instance to get an address from the server, which they can use to host games
func on_noray_connected():
	Noray.register_host()
	await Noray.on_pid
	await Noray.register_remote()
	noray_connected.emit()

# The handle_nat function will attempt to connect to the server using NAT, if this doesn't work it will connect via relay instead
func handle_nat(address, port):
	var err = await connect_to_server(address, port)
	
	if err != OK and !host:
		print("NAT failed! Using relay...")
		Noray.connect_relay(external_address)
		err = OK
		
	return err

# Once NAT fails, a relay connection is attempted instead using the external address
func handle_relay_connection(address, port):
	return await connect_to_server(address, port)

# The function will connect to the server via NAT punchthrough or relay
# If the client successfully connects, this function will load the scene for them
# Connections can take some time to complete
func connect_to_server(address, port):
	var err = OK
	
	if !host:
		var udp = PacketPeerUDP.new()
		udp.bind(Noray.local_port)
		udp.set_dest_address(address, port)
	
		err = await PacketHandshake.over_packet_peer(udp)
		udp.close()
	
		if err != OK:
			if err != ERR_BUSY:
				print("Handshake failed")
				return err
			else:
				print("Handshake success")
		
		peer = ENetMultiplayerPeer.new()
		err = peer.create_client(address, port, 0, 0, 0, Noray.local_port)
		
		if err != OK:
			return err
		
		multiplayer.multiplayer_peer = peer
		get_tree().change_scene_to_file("res://Scenes/world.tscn")
		
		return OK
	else:
		err = await PacketHandshake.over_enet(multiplayer.multiplayer_peer.host, address, port)
	
	return err
