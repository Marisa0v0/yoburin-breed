class_name StateMachine
extends Node

var 状态数值: int = -1:
	set(v):
		owner.更改状态调用函数(状态数值,v)
		状态数值 = v


func _ready() -> void:
	await owner.ready
	状态数值 = 0
func _physics_process(delta: float) -> void:
	while true:
		var 下一个状态 := owner.获取新的状态(状态数值) as int
		if 下一个状态 == 状态数值:
			break
	
	owner.每帧业务函数(状态数值,delta)
