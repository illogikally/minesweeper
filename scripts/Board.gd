extends Node2D

class_name Board

class Square:
	var isRevealed: bool
	var isMine: bool
	var value: int
	var isFlagged: bool
	var tile: Sprite
	
	func change_texture(texture: Resource):
		tile.texture = texture 

signal change_face(face)
signal game_over

var BOARD = []
var square_textures = {}
var BOARD_H = 16
var BOARD_W = BOARD_H
onready var SCALE = get_parent().SCALE
onready var SQUARE_SIZE = 16 * SCALE

var NUM_OF_MINES: int = BOARD_H * BOARD_W / 9
var flags = NUM_OF_MINES
var revealed = 0



func _ready():
	OS.window_size = Vector2(SQUARE_SIZE*BOARD_W, SQUARE_SIZE*BOARD_H+65)
	_load_square_textures()
	_init_board()

func _load_square_textures():
	var textures = get_parent().load_resource_dir("res://assets/tiles")
	var names = [
		"1", "2", "3", "4", "5", "6", "7", "8", "0", "flag", "hidden", \
		"mine", "mine_red"
	]
	for i in range(names.size()):
		square_textures[names[i]] = textures[i]
		
func restart() -> void:
	revealed = 0
	flags = NUM_OF_MINES
	for row in BOARD:
		for square in row:
			square.change_texture(square_textures["hidden"])
			square.value = 0
			square.isMine = false
			square.isFlagged = false
			square.isRevealed = false
				
	_generate_mine()

func _generate_mine():
	var rng = RandomNumberGenerator.new()
	rng.seed = OS.get_time().second
	for i in range(NUM_OF_MINES):
		while true:
			var x = rng.randi_range(0, BOARD_W-1)
			var y = rng.randi_range(0, BOARD_H-1)
			if not BOARD[y][x].isMine:
				BOARD[y][x].isMine = true
				for yoff in range(-1, 2):
					for xoff in range(-1, 2):
						if Rect2(0, 0, BOARD_W, BOARD_H).has_point(Vector2(x+xoff, y+yoff)):
							BOARD[y+yoff][x+xoff].value += 1
				break
				
func _init_board():
	for i in range(BOARD_H):
		var squares = []
		for j in range(BOARD_W):
			var square = Square.new()
			square.tile = Sprite.new()
			square.tile.centered = false
			square.tile.position = Vector2(j, i) * SQUARE_SIZE
			square.tile.scale = Vector2(SCALE, SCALE)
			square.change_texture(square_textures["hidden"])
			squares.append(square)
			add_child(square.tile)
		BOARD.append(squares)
	
	_generate_mine()

func _process(delta):
	for row in BOARD:
		for square in row:
			if square.isRevealed:
				if not square.isMine:
					square.change_texture(square_textures[square.value as String])
			elif square.isFlagged:
				square.change_texture(square_textures["flag"])
			else:
				square.change_texture(square_textures["hidden"])
				
	if revealed == BOARD_W * BOARD_H - NUM_OF_MINES:
		for row in BOARD:
			for square in row:
				if square.isMine:
					square.change_texture(square_textures["flag"])
		emit_signal("change_face", "glasses")
		emit_signal("change_face", "glasses")
		get_tree().paused = true
		
func _input(event):
	if event is InputEventMouseButton:
		var BOARD_W_IN_PIXEL = SQUARE_SIZE * BOARD_W
		var BOARD_H_IN_PIXEL = SQUARE_SIZE * BOARD_H
		if Rect2(position, Vector2(BOARD_W_IN_PIXEL, BOARD_H_IN_PIXEL)).has_point(event.position):
			var index = _position_to_index(to_local(event.position))
			var square = BOARD[index.y][index.x]
			if event.button_index == BUTTON_LEFT:
				if event.pressed && !square.isRevealed:
					emit_signal("change_face", "o")
					if square.isMine:
						_game_over(square)
					_reveal(index)	
				else:
					emit_signal("change_face", "smile")
			elif event.button_index == BUTTON_RIGHT and event.pressed:
				_flag(square)
				
func _reveal(pos: Vector2) -> void:
	if Rect2(0, 0, BOARD_W, BOARD_H).has_point(pos):
		var square = BOARD[pos.y][pos.x]
		if not (square.isRevealed || square.isMine):
			if square.isFlagged:
				flags += 1
			square.isRevealed = true
			revealed += 1
			if square.value == 0:
				for i in [-1, 0, 1]:
					for j in [-1, 0, 1]:
						_reveal(Vector2(pos.x+j, pos.y+i))
						
func _flag(square: Square):
	if !square.isRevealed:
		if square.isFlagged:
			square.isFlagged = false
			flags += 1
		elif flags > 0:
			square.isFlagged = true
			flags -= 1
		
func _position_to_index(coord: Vector2) -> Vector2:
	var x: int = coord.x / SQUARE_SIZE
	var y: int = coord.y / SQUARE_SIZE
	return Vector2(x, y)

func _game_over(mine_square: Square) -> void:
	for row in BOARD:
		for square in row:
			if square.isMine:
				square.isRevealed = true
				square.change_texture(square_textures["mine"])
	mine_square.change_texture(square_textures["mine_red"])
	emit_signal("change_face", "sad")
	emit_signal("game_over")
	get_tree().paused = true	


	

