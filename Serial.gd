extends Node

const serial_res = preload("res://bin/gdserial.gdns")
onready var serial_port = serial_res.new()

var is_port_open = false
var text = ""

signal esquerda()
signal direita()
signal parado()
signal jump()
signal attack()
signal cesquerda()
signal cdireita()

func _ready():
	open()

func _exit_tree():
	close()

func open():
	is_port_open = serial_port.open_port("COM3", 9600)
	print(is_port_open)

func write(text):
	serial_port.write_text(text)

func close():
	is_port_open = false
	serial_port.close_port()

func _process(delta):
	if is_port_open:
		var t = serial_port.read_text()
		
		if t.length() > 0:
			for c in t:
				if c == "\n":
					on_text_received(text)
					text = ""
				else:
					text+=c

func on_text_received(text): #"1 Sobe"
	var command_array = text.split(" ")
	
	#print(command_array)
	if command_array.size() < 1:
		return
		
	if str(command_array[0]) == "Esquerda":
		#print("igual")
		emit_signal("esquerda")
	elif str(command_array[0]) == "Direita":
		emit_signal("direita")
	elif str(command_array[0]) == "Parado":
		emit_signal("parado")
	elif str(command_array[0]) == "Jump":
		emit_signal("jump")
	elif str(command_array[0]) == "Attack":
		emit_signal("attack")
	elif str(command_array[0]) == "Cesquerda":
		emit_signal("cesquerda")
	elif str(command_array[0]) == "Cdireita":
		emit_signal("cdireita")
		
