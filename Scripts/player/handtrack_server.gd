extends Node

var PORT: int = 5005
var HOST: String = "127.0.0.1"

var server = UDPServer.new()


func _ready():
	server.listen(PORT, HOST)


func _process(delta):
	server.poll() # Important!
	if server.is_connection_available():
		var peer = server.take_connection()
		var packet = peer.get_packet()
		
		
		
		
		print("Accepted peer: %s:%s" % [peer.get_packet_ip(), peer.get_packet_port()])
		print("Received data: %s" % [packet.get_string_from_utf8()])
		
		
		
		# do we need this?
		# Reply so it knows we received the message.
		peer.put_packet(packet)
