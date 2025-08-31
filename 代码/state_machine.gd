class_name StateMachine
extends Node

var 当前状态: int = -1:
	set(下一状态):
		owner.更改状态调用函数(当前状态, 下一状态)
		当前状态 = 下一状态


func _ready() -> void:
	await owner.ready
	当前状态 = 0
	# 他这里必须异步，因为 godot 是从最下层节点开始初始化的，如果不写他找不到父节点，会报错
	# 所以要等到父级节点初始化完成后再初始化他
	
func _physics_process(delta: float) -> void:
	while true:
		var 下一个状态 := owner.获取新的状态(当前状态) as int
		if 下一个状态 == 当前状态:
			break
		当前状态 = 下一个状态
	owner.每帧业务函数(当前状态,delta)
