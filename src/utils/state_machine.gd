class_name MarisaStateMachine
extends Node
## 状态机相关 - 生物行为核心机制

## 状态机相关变量
## 当前状态
var current_state: MarisaCreature.Status = MarisaCreature.Status.Default:
	set(next_state):
		## 仅在状态更新时，调用 on_state_change
		self.owner._before_state_change(current_state, next_state)
		current_state = next_state


## 内置函数
## 该节点的所有子节点初始化后才初始化
func _ready() -> void:
	Log.debug("状态机类准备完毕")
	await self.owner.ready #这里是获取父节点准备信号，也就是说只有一个场景全准备好了他才会进行
	self.current_state = MarisaCreature.Status.Default

	
## 每物理帧调用一次
func _physics_process(delta: float) -> void:
	while true:
		## 先获取下一状态
		var next_state = owner.update_state(self.current_state)
		
		## 若状态切换，则调用 on_state_change 一次，继续循环，当前帧继续处理
		if next_state != self.current_state:
			## 状态滚动后移 同时重置状态
			self.current_state = next_state
			continue
		break
		
	## 若状态维持不变，则跳出循环，调用 action 一次，当前帧结束
	self.owner.action(self.current_state, delta)
