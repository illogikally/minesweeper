extends Node2D

class_name Board

class Square:
	var isRevealed: bool
	var isMine: bool
	var value: int
	var isMarked: bool
	var tile: Sprite
	
var BOARD = []
var sprite_tiles = []
var BOARD_H = 30
var BOARD_W = 30
var SQUARE_SIZE = 16
var NUM_OF_MINES: int = BOARD_H * BOARD_W / 9
var marks = NUM_OF_MINES
var isGameOver = false
var revealed = 0
export var SCALE = 1.3

func _ready():
	OS.window_size = Vector2(16*1.3*BOARD_W, 16*1.3*BOARD_H+65)
	_load_tiles()
	_init_board()
	
	
func restart():
	isGameOver = false
	revealed = 0
	marks = NUM_OF_MINES
	for row in BOARD:
		for square in row:
			square.tile.texture = sprite_tiles[10]
			square.value = 0
			square.isMine = false
			square.isMarked = false
			square.isRevealed = false
				
	_generate_mine()

func _generate_mine():
	var rng = RandomNumberGenerator.new()
	rng.seed = OS.get_time().second
	for i in range(NUM_OF_MINES):
		while true:
			var x = rng.randi_range(0, BOARD_W-1)
			var y = rng.randi_range(0, BOARD_H-1)
			if !BOARD[y][x].isMine:
				BOARD[y][x].isMine = true
				for ii in range(-1, 2):
					for jj in range(-1, 2):
						if not (y++ii > BOARD_H-1 or x+jj > BOARD_W-1 or y+ii < 0 or x+jj < 0):
							BOARD[y+ii][x+jj].value += 1
				break
				
func _init_board():
	for i in range(BOARD_H):
		var squares = []
		for j in range(BOARD_W):
			var square = Square.new()
			square.tile = Sprite.new()
			square.tile.position = Vector2(i, j) * SQUARE_SIZE*SCALE + Vector2(SQUARE_SIZE*SCALE/2, SQUARE_SIZE*SCALE/2)
			square.tile.scale = Vector2(SCALE, SCALE)
			squares.append(square)
			add_child(square.tile)
		BOARD.append(squares)
	
	_generate_mine()

	
				
func _load_tiles():
	var tiles = list_files_in_directory("res://assets/tiles")
	for file in tiles:
		sprite_tiles.append(load("res://assets/tiles/%s" % file))
		
	
func list_files_in_directory(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with(".") && not file.ends_with("import"):
			files.append(file)
	dir.list_dir_end()
	return files

func _process(delta):
	for row in BOARD:
		for square in row:
			if square.isRevealed:
				if square.isMine:
					pass
				else:
					square.tile.texture = sprite_tiles[8] if square.value == 0 else sprite_tiles[square.value-1]
			elif square.isMarked:
				square.tile.texture = sprite_tiles[9]
			else:
				square.tile.texture = sprite_tiles[10]
	if revealed == BOARD_W * BOARD_H - NUM_OF_MINES:
		get_parent().get_child(1).get_node("face").texture = preload("res://assets/button/victory.png")
		get_tree().paused = true		
			
func _input(event):
	if event is InputEventMouseButton:
		if event.position.y >= 65 && event.position.x < 16*1.3*BOARD_W && event.position.y < 16*1.3*BOARD_H+65 \
		&& event.position.x >= 0:
			var index = _position_to_index(to_local(event.position))
			var square = BOARD[index.x][index.y]
			if event.button_index == BUTTON_LEFT:
				if event.pressed && !square.isRevealed:
					print(event.position)
					get_parent().get_child(1).get_node("face").texture = load("res://assets/button/o.png")
					if square.isMine:
						_gameover(square)
					_reveal(index)	
				else:
					get_parent().get_child(1).get_node("face").texture = load("res://assets/button/restart.png")
			elif event.button_index == BUTTON_RIGHT and event.pressed:
				if !square.isRevealed:
					if square.isMarked:
						square.isMarked = false
						marks += 1
					elif marks > 0:
						square.isMarked = true
						marks -= 1
	

func _position_to_index(coord: Vector2) -> Vector2:
	var x: int = coord.x / (SQUARE_SIZE*SCALE)
	var y: int = coord.y / (SQUARE_SIZE*SCALE)
	return Vector2(x, y)

func _gameover(goSquare: Square):
	for row in BOARD:
		for square in row:
			if square.isMine:
				square.isRevealed = true
				square.tile.texture = sprite_tiles[11]
	goSquare.tile.texture = sprite_tiles[12]
	get_parent().get_node("Clock").get_node("face").texture = preload("res://assets/button/death.png")
	isGameOver = true
	get_tree().paused = true	
	
func _reveal(pos: Vector2):
	#if pos.x < BOARD_W and pos.x >= 0 and pos.y < BOARD_H and pos.y >= 0:
	if Rect2(0, 0, BOARD_W, BOARD_H).has_point(pos):
		var square = BOARD[pos.x][pos.y]
		if !square.isRevealed:
			revealed += 1
			if square.isMarked:
				marks += 1
			square.isRevealed = true
			if square.value == 0:
				for i in range(-1, 2):
					for j in range(-1, 2):
						_reveal(Vector2(pos.x+i, pos.y+j))
