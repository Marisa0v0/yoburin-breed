class_name MarisaSlime
extends MarisaMonster
## 怪物 - 史莱姆

## 史莱姆独有属性
@onready var decay := 0.8					## 衰减系数
@onready var max_offset := Vector2(100, 75)	## 
@onready var max_roll := 0.1				##
@onready var follow_node: AnimatedSprite2D	## 抖动跟随节点 (史莱姆立绘)
@onready var trauma := 0.0					## 攻击前摇 抖动底数
@onready var trauma_power := 2				## 攻击前摇 抖动幂数

@onready var timer_before_attack: Timer = $"攻击前摇计时器"  ## 攻击前摇

## 内置函数
## 类初始化
func _init() -> void:
	super._init()
	print_debug("初始化 Slime 类实例 %s" % self.to_string())

## 该节点的所有子节点初始化后才初始化
func _ready() -> void:
	super._ready()
	print_debug("Slime 类准备完毕")

## 每帧调用
#你写状态机的帧
func _process(delta: float) -> void:
	pass

## 业务函数
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
			## TODO Timer
			self.timer_before_attack.start(1)
			self.shake(delta)
			# self.animation_player.play("attack")
	
			self.can_attack = false  ## TODO ? 干嘛用的 #干嘛用的？
			self.bar_attack_ready.value = self.bar_attack_ready.min_value
		## TODO
		Status.BeAttacked:
			pass
		Status.BeDefeated:
			pass
		_:  ## fallback
			pass

## 功能函数
## 攻击前抖动
func shake(delta: float) -> void:
	if not self.trauma:
		return

	## 每帧执行：随时间衰减抖动强度
	self.trauma = max(self.trauma - self.decay * delta, 0)
	
	## 每帧执行: 随机修改贴图位置
	var amount := pow(trauma, trauma_power)
	self.sprite.rotation = self.max_roll * amount * randf_range(-1, 1)
	self.sprite.offset.x = max_offset.x * amount * randf_range(-1, 1)
	self.sprite.offset.y = max_offset.y * amount * randf_range(-1, 1)
	

## 隐式调用
func attack_player(monster_atk_int: int = 1):
	# godot的动画机可以自己在特定帧调用函数，实现很方便的效果，这里直接在动画里和攻击动画同时调用攻击函数
	# 就可以做到动画播放的同时攻击，不用对轴什么的了
#	GlobalGameManager.attack_player(atk_value)
	print(self.to_string() + " | 攻击！")
