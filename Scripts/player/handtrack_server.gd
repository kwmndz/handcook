extends Node

var PORT: int = 5005
var HOST: String = "127.0.0.1"

var server = UDPServer.new()


func _ready():
	print("Server starting...")
	server.listen(PORT, HOST)


func _process(delta):
	server.poll() # Important!
	if server.is_connection_available():
		var peer = server.take_connection()
		var packet = peer.get_packet()
		
		# convert the packet to data
		var packet_str: String = packet.get_string_from_utf8()
		var data = JSON.parse_string(packet_str)
		
		print("Received data:")
		print(data)
		
		# do we need this?
		# Reply so it knows we received the message.
		peer.put_packet(packet)
