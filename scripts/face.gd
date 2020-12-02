extends Sprite


func _ready():
	pass
		
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if get_rect().has_point(to_local(event.position)):
				if event.pressed:
					texture = preload("res://assets/button/restart_disable.png")
					get_parent().get_parent().restart()
				else:
					texture = preload("res://assets/button/restart.png")
					get_tree().paused = false

