extends Node

var client
var wrapped_client
var connected = false

var text = ""

signal left_joystick(x,y)
signal right_joystick(xy)
signal parado()
signal jump()
signal attack()
signal cesquerda()
signal cdireita()

func _ready():
	client = StreamPeerTCP.new()
	client.set_no_delay(true)
	connect_to_server()
	
func _exit_tree():
	disconnect_from_server()

func connect_to_server():
	var ip = "192.168.1.12"
	var port = 80
	print("Connecting to server: %s : %s" % [ip, str(port)])
	var connect = client.connect_to_host(ip, port)
	if client.is_connected_to_host():
		connected = true
		print("Connected!")
	
func disconnect_from_server():
	connected = false
	client.disconnect_from_host()

func _process(delta):
	if not connected:
		pass
	if connected and not client.is_connected_to_host():
		connected = false
	if client.is_connected_to_host():
		poll_server()


func poll_server():
	while client.get_available_bytes() > 0:
		var msg = client.get_utf8_string(client.get_available_bytes())
		if msg == null:
			continue;
			
		if msg.length() > 0:
			for c in msg:
				if c == "\n":
					on_text_received(text)
					text = ""
				else:
					text+=c

func on_text_received(text): #"1 Sobe"
	var command_array = text.split(" ")
	
	if command_array.size() < 1:
		return
		
	if str(command_array[0]) == "Direction":
		emit_signal("left_joystick",command_array[1])
		
	elif str(command_array[0]) == "Camera":
		
		emit_signal("right_joystick",command_array[1],command_array[1])
	elif str(command_array[0]) == "Jump":
		emit_signal("jump")
	elif str(command_array[0]) == "Attack":
		emit_signal("attack")
	elif str(command_array[0]) == "Cesquerda":
		emit_signal("cesquerda")
	elif str(command_array[0]) == "Cdireita":
		emit_signal("cdireita")

func write_text(text):
	if connected and client.is_connected_to_host():
		print("Sending: %s" % text)
		client.put_data(text.to_ascii())
