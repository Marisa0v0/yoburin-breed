class_name MarisaMonster
extends MarisaCreature
## 怪物基类

## 怪物独有基本属性

## 导入
@onready var animation_player: AnimationPlayer = $"动画立绘/动画播放器"  ## 动画播放器

## 内置函数
## 类初始化
func _init() -> void:
	super._init()
	print_debug("初始化 Monster 类实例 %s" % self.to_string())
	self.move_speed = -1.0  ## 怪物向左移动

## 该节点的所有子节点初始化后才初始化
func _ready() -> void:
	super._ready()
	print_debug("Monster 类准备完毕")
	
## 碰撞箱重叠时准备战斗，停止移动
func _on_area_2d_area_entered(area: Area2D) -> void:
	self.in_battle_position = true
	
## 业务函数
## 以状态机作为核心逻辑 
## 仅在生物需要进行动作时更新当前状态
func update_state(current_state: Status) -> Status:
	## TODO
	match current_state:
		Status.Default:  ## 初始状态
			return Status.Move
			
		Status.Move:  ## 常规状态
			if self.in_battle_position:  ## 移动到位 -> 停止移动 闲置
				return Status.Idle
			return current_state
			
		Status.Idle:
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
		Status.BeDefeated:
			return current_state
			
		_:  ## fallback 落回常规状态
			return Status.Move
	
## 每帧动作
func action(current_state: Status, delta: float) -> void:
	match current_state:
		Status.Move:
			## 每帧移动
			self.position.x += self.move_speed * delta
		Status.Idle:
			## 到达位置后攻击条自动增长
			self.bar_attack_ready_increase()
		Status.Attack:
			## 播放动画 - 动画结束
			self.animation_player.play("attack")
	
			self.can_attack = false  ## TODO ? 干嘛用的
			self.animation_attack_end = true
			self.animation_be_attacked_end = true
		## TODO
		Status.BeAttacked:
			pass
		Status.BeDefeated:
			pass
		_:  ## fallback
			pass
