# 怪物 - 生成
extends Node2D

var slime_scene = preload("res://场景/creature/slime.tscn")

func _input(event):
	# 按下空格生成史莱姆
	if event.is_action_pressed("ui_accept"):
		print("实例化场景")
		var slime_instance = slime_scene.instantiate()
		add_child(slime_instance)
