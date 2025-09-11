class_name MarisaPlayer
extends MarisaCreature
## 玩家基类

## 玩家独有基本属性

## 内置函数
## 类初始化
func _init() -> void:
	super._init()
	print_debug("初始化 Player 类实例 %s" % self.to_string())

## 该节点的所有子节点初始化后才初始化
func _ready() -> void:
	super._ready()
	print_debug("Player 类准备完毕")

## 业务函数
## 以状态机作为核心逻辑 
## 仅在生物需要进行动作时更新当前状态
func update_state(current_state: Status) -> Status:
	## TODO 当前假设玩家默认站着不动，若玩家默认主动向右移动需改动逻辑
	match current_state:
		## 初始状态
		Status.Default:
			return Status.Idle
		
		## 常规状态
		Status.Idle:
			if self.be_attacked:
				return Status.BeAttacked
			
			## 攻击条涨满 -> 发动攻击
			if self.can_attack:
				return Status.Attack
			
			## 血量清零 -> 战败
			if self.bar_health_point.value == self.bar_health_point.min_value:
				return Status.BeDefeated
			
		Status.Attack:
			## 攻击动画结束 -> 返回闲置
			if self.animation_end:
				return Status.Idle
			
		Status.BeAttacked:
			## 受击动画结束 -> 返回闲置
			if self.animation_end:
				return Status.Idle

		## TODO
		Status.Move:
			pass
			
		Status.BeDefeated:
			pass
			
		_:  ## fallback 落回默认状态
			return Status.Default
			
	return current_state
