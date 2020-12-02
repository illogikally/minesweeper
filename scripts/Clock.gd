extends Node2D

var sprite_clock = []
var timer = 0
var num_of_mark = 0

func _ready():
	_load_sprites()
	$face.position = Vector2(OS.window_size.x/2, 32)
	$face.texture = preload("res://assets/button/restart.png")
	for clock in get_children():
		clock.position.y = 65/2
	$clock3.position.x = OS.window_size.x - 40
	$clock2.position.x = $clock3.position.x - $clock2.get_rect().size.x*1.3
	$clock1.position.x = $clock2.position.x - $clock1.get_rect().size.x*1.3
	
	$clock4.position.x = 40
	$clock5.position.x = $clock4.position.x + $clock5.get_rect().size.x*1.3
	$clock6.position.x = $clock5.position.x + $clock6.get_rect().size.x*1.3
	

func restart():
	timer = 0
	

func _load_sprites():
	for file in _list_files_in_directory("res://assets/clock"):
		sprite_clock.append(load("res://assets/clock/%s" % file))
	print(sprite_clock)


				
func _process(delta):			
	timer += delta
	$clock1.texture = sprite_clock[int(timer) / 100]
	$clock2.texture = sprite_clock[int(timer/10) % 10]
	$clock3.texture = sprite_clock[int(timer) % 10]
	
	var marks = get_parent().get_child(0).marks
	$clock4.texture = sprite_clock[int(marks / 100)]
	$clock5.texture = sprite_clock[int(marks/10) % 10]
	$clock6.texture = sprite_clock[marks % 10]
	
func _list_files_in_directory(path):
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
