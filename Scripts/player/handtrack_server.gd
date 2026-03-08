extends Node

var PORT: int = 5005
var HOST: String = "127.0.0.1"

var server = UDPServer.new()

var gesture

var hand_type: String = "LEFT"
var cur_gesture: String = "NONE"
var hand_rel_pos: Vector3 = Vector3(0, 0, 0)
var in_bounds: bool = false


func process_the_data(data):
	var gesture_map = {
		0: "NONE",
		1: "PINCH",
		2: "FIST",
		3: "OPEN"
	}
	cur_gesture = gesture_map[int(data["g"])]
	if data["ht"] == 0:
		hand_type = "LEFT"
	else:
		hand_type = "RIGHT"
	hand_rel_pos = Vector3(data["hp"][0], data["hp"][1], data["hp"][2])
	hand_rel_pos.x = clampf(hand_rel_pos.x, 0, 1)
	hand_rel_pos.y = clampf(hand_rel_pos.x, 0, 1)
	hand_rel_pos.z = clampf(hand_rel_pos.x, 0, 1)
	in_bounds = data["ib"]
	
	
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
		
		print(data["hp"])
		
		# this will modify the state variables (defined here cuz y not)
		process_the_data(data)
		
