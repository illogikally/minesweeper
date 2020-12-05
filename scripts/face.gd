extends Sprite

func _ready():
	pass
		
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if get_rect().has_point(to_local(event.position)):
				if event.pressed:
					get_parent().change_face("smile_click")
					get_node("../../").restart()
				else:
					get_parent().change_face("smile")
					get_tree().paused = false

