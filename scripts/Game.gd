extends Node2D

func _ready():
	pass

func restart():
	$Board.restart()
	$Clock.restart()
