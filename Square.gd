extends Area2D

var index
signal clicked(index)

func _ready():
	print($CollisionPolygon2D.polygon)
	connect("clicked", get_parent(), "printss")

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton \
	and event.button_index == BUTTON_LEFT \
	and event.pressed:
		print("wot")
		emit_signal("clicked", index)
			
