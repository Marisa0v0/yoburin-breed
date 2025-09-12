class_name MarisaStateMachine
extends Node

## 状态机相关 - 生物行为核心机制

## 状态机相关变量
## 当前状态
var current_state: MarisaCreature.Status = MarisaCreature.Status.Default:
	set(next_state):
		self.owner.on_state_change(current_state, next_state)
		current_state = next_state


## 内置函数
## 该节点的所有子节点初始化后才初始化
func _ready() -> void:
	print_debug("状态机类准备完毕")
	await self.owner.ready #这里是获取父节点准备信号，也就是说只有一个场景全准备好了他才会进行
	self.current_state = MarisaCreature.Status.Default


# 他这里必须异步，因为 godot 是从最下层节点开始初始化的，如果不写他找不到父节点，会报错
# 所以要等到父级节点初始化完成后再初始化他

## 每物理帧调用一次
func _physics_process(delta: float) -> void:
	while true:
		## 先获取下一状态
		var next_state = owner.update_state(self.current_state)
		## 仅在状态更新时，说明生物需要进行动作
		if next_state == self.current_state:
			break
		## 状态滚动后移
		## 同时重置状态
		self.current_state = next_state

	## 仅在状态更新时，说明生物需要进行动作
	self.owner.action(self.current_state, delta)
