extends Node

@export var level = 1
@export var exp = 0
@onready var level_str: Label = $"../Container/Level/Level_int"
@onready var exp_str: Label = $"../Container/Label2/EXP"

func level_up():
	level += 1
	level_str.text = str(level)

func add_exp():
	exp +=10
	exp_str.text = str(exp)
