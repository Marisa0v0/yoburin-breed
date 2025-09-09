class_name MarisaPlayer
extends MarisaCreature
## 玩家基类

## 玩家独有基本属性

## 导入
@onready var animation_player: AnimationPlayer = $"动画立绘/动画播放器"  ## 动画播放器

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
		Status.Default:  ## 初始状态
			return Status.Idle
			
		Status.Idle:  ## 常规状态
			if self.be_attacked:
				return Status.BeAttacked
			if self.can_attack:  ## 攻击条涨满 -> 发动攻击
				return Status.Attack
			return current_state
			
		Status.Attack:
			if self.animation_attack_end:  ## 攻击动画结束 -> 返回闲置
				return Status.Idle
			return current_state
			
		Status.BeAttacked:
			if self.animation_be_attacked_end:
				return Status.Idle
			return current_state

		## TODO
		Status.Move:
			return current_state
			
		Status.BeDefeated:
			return current_state
			
		_:  ## fallback 落回常规状态
			return Status.Idle
