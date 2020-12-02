extends Sprite

func _ready():
	pass

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			if get_rect().has_point(to_local(event.position)):
				texture = load("res://assets/button/gameover.png")
