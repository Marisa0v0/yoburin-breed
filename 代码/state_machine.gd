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
	# print("调用状态机帧处理了")
	while true:
		var 下一个状态 := owner.获取新的状态(当前状态) as int
		# print("当前状态: ", 当前状态, "下一个状态: ", 下一个状态)
		if 下一个状态 == 当前状态 :
			break
		当前状态 = 下一个状态
		# 在这里设 false
	owner.每帧业务函数(当前状态,delta)
	#这个必须在if外面，因为他代替了所有角色的每帧循环函数
	#如果不在外面就意味着只有状态更新的时候其他角色才会步进一步，游戏根本没法运行
