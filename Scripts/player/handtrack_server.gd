extends Node

var PORT: int = 5005
var HOST: String = "127.0.0.1"

var server = UDPServer.new()

# Stable debounced outputs
var hand_type: String = "LEFT"
var cur_gesture: String = "NONE"
var hand_rel_pos: Vector3 = Vector3.ZERO

# Raw latest packet values
var raw_hand_type: String = "LEFT"
var raw_gesture: String = "NONE"

# Gesture debounce
var gesture_candidate: String = "NONE"
var gesture_candidate_packets: int = 0
@export var gesture_packets_needed: int = 3

# Handedness debounce
var hand_candidate: String = "LEFT"
var hand_candidate_packets: int = 0
@export var hand_packets_needed: int = 5

func process_the_data(data) -> void:
	var gesture_map = {
		0: "NONE",
		1: "PINCH",
		2: "FIST",
		3: "OPEN"
	}

	# Always update position immediately
	hand_rel_pos = Vector3(data["hp"][0], data["hp"][1], data["hp"][2])

	# Read raw gesture
	raw_gesture = gesture_map.get(int(data["g"]), "NONE")

	# Read raw hand type
	if int(data["ht"]) == 0:
		raw_hand_type = "LEFT"
	else:
		raw_hand_type = "RIGHT"

	# Debounce gesture
	_update_gesture(raw_gesture)

	# Debounce handedness
	_update_hand_type(raw_hand_type)


func _update_gesture(new_gesture: String) -> void:
	# Already stable, nothing to do
	if new_gesture == cur_gesture:
		gesture_candidate = new_gesture
		gesture_candidate_packets = 0
		return

	# New possible candidate
	if new_gesture != gesture_candidate:
		gesture_candidate = new_gesture
		gesture_candidate_packets = 1
	else:
		gesture_candidate_packets += 1
		if gesture_candidate_packets >= gesture_packets_needed:
			cur_gesture = gesture_candidate
			gesture_candidate_packets = 0


func _update_hand_type(new_hand_type: String) -> void:
	# Already stable, nothing to do
	if new_hand_type == hand_type:
		hand_candidate = new_hand_type
		hand_candidate_packets = 0
		return

	# New possible candidate
	if new_hand_type != hand_candidate:
		hand_candidate = new_hand_type
		hand_candidate_packets = 1
	else:
		hand_candidate_packets += 1
		if hand_candidate_packets >= hand_packets_needed:
			hand_type = hand_candidate
			hand_candidate_packets = 0


func _ready() -> void:
	print("Server starting...")
	server.listen(PORT, HOST)


func _process(delta: float) -> void:
	server.poll()

	while server.is_connection_available():
		var peer = server.take_connection()
		var packet = peer.get_packet()

		var packet_str: String = packet.get_string_from_utf8()
		var data = JSON.parse_string(packet_str)

		if typeof(data) == TYPE_DICTIONARY:
			process_the_data(data)
