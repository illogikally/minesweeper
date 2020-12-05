extends Node2D

onready var sprite_clock = get_parent().load_resource_dir("res://assets/clock")
onready var face_textures = get_parent().load_resource_dir("res://assets/button")
onready var SCALE = get_parent().SCALE
var timer = 0
onready var time_counter = [$Time1, $Time2, $Time3]
onready var flag_counter = [$Flag1, $Flag2, $Flag3]

func _ready():
	$Face.position = Vector2(OS.window_size.x/2, 32)
	change_face("smile")	
	
	var DIGIT_SIZE = sprite_clock[0].get_size().x * SCALE
	var pos = 40
	for counter in flag_counter:
		counter.position.x = pos
		pos += DIGIT_SIZE
		
	pos = OS.window_size.x - 40
	for counter in time_counter:
		counter.position.x = pos
		pos -= DIGIT_SIZE

	for clock in get_children():
		clock.position.y = 65/2
		clock.scale = Vector2(SCALE, SCALE)
	
	connect("game_over", self, "_game_over")
	get_node("../Board").connect("change_face", self, "change_face")
	
func restart():
	timer = 0

func _game_over():
	change_face("sad")
	
func _process(delta):			
	timer += delta
	var digits = _extract_digit(timer as int)
	for i in range(digits.size()):
		_set_texture(time_counter[-i-1], digits[i])
	
	var flags = get_node("../Board").flags
	digits = _extract_digit(flags)
	for i in range(digits.size()):
		_set_texture(flag_counter[i], digits[i])

func _set_texture(counter: Sprite, value: int):
	counter.texture = sprite_clock[value]
	
func _extract_digit(number: int) -> Array:
	var digits = []
	for i in range(3):
		digits.append(number%10)
		number /= 10
	digits.invert()	
	return digits
	
func change_face(face: String) -> void:
	var faces = {
		"glasses": face_textures[0],
		"o": face_textures[1],
		"sad": face_textures[2],
		"smile": face_textures[3],
		"smile_click": face_textures[4]
	}
	$Face.texture = faces[face]
	if face == "glasses":
		for counter in flag_counter:
			_set_texture(counter, 0)
	



