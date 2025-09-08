# 游戏窗口
extends Node2D


# Called when the node enters the scene tree for the first time.
var dragging = false

func _ready() -> void:
	# 窗口初始化
	get_viewport().transparent_bg = true


func _input(event):
	# 接收输入事件
	# 实现拖动窗口
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
		
