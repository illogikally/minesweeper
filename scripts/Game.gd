extends Node2D


var SCALE = 1.8

func _ready():
	pass

func load_resource_dir(path) -> Array:
	var resources = []
	for file in _list_files_in_directory(path):
		resources.append(load(path+"/%s" % file))
	
	return resources
		
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
		
func restart():
	$Board.restart()
	$Clock.restart()
