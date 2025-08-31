extends Node2D

# Called when the node enters the scene tree for the first time.
var dragging = false

func _ready() -> void:
	get_viewport().transparent_bg = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			dragging = true
		else:
			dragging = false
	
	if event is InputEventMouseMotion and dragging:
		# 鼠标右键拖动窗口
		var current_position = get_window().position
		var new_position = current_position + Vector2i(event.relative)
		get_window().set_position(new_position)
		Window
		
