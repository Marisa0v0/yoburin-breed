class_name MarisaSlime
extends MarisaMonster
## 怪物 - 史莱姆

## 史莱姆独有属性
@onready var decay := 0.8                    ## 衰减系数
@onready var max_offset := Vector2(100, 75)    ## 
@onready var max_roll := 0.1                ##
@onready var follow_node: AnimatedSprite2D    ## 抖动跟随节点 (史莱姆立绘)
@onready var trauma := 0.0                    ## 攻击前摇 抖动底数
@onready var trauma_power := 2                ## 攻击前摇 抖动幂数
## 导入
@onready var animation_player: AnimationPlayer = $"动画立绘相关/动画立绘/动画播放器"  ## 动画播放器
@onready var animated_sprite_2d: AnimatedSprite2D = $"动画立绘相关/动画立绘"        ## 动画立绘


## 内置函数
## 类初始化
func _init() -> void:
	super._init()
	print_debug("初始化 Slime 类实例 %s" % self.to_string())


## 该节点的所有子节点初始化后才初始化
func _ready() -> void:
	super._ready()
	print_debug("Slime 类准备完毕")


## 判定进入攻击位置
func _on_in_battle_position(hurtbox: HurtBox) -> void:
	self.target_player = hurtbox.owner
	self.in_battle_position = true


## 业务函数
## 仅在生物需要进行动作时更新当前状态
func update_state(current_state: Status) -> Status:
	## TODO
	match current_state:
		Status.Default: ## 初始状态
			return Status.Move

		Status.Move: ## 常规状态
			if self.in_battle_position: ## 移动到位 -> 停止移动 闲置
				return Status.Idle
			return current_state

		Status.Idle:
			if self.can_attack: ## 攻击条涨满 -> 发动攻击
				return Status.Attack
			return current_state

		Status.Attack:
			if self.animation_end: ## 攻击动画结束 -> 返回闲置
				return Status.Idle
			return current_state

		Status.BeAttacked:
			print_debug("史莱姆挨打了")
			if self.animation_end:
				return Status.Idle
			return current_state

		## TODO
		Status.BeDefeated:
			return current_state

		_: ## fallback 落回常规状态
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
			## TODO 攻击动画
			## TODO 动画效果升级
			self.animation_player.play("attack")
		## TODO
		Status.BeAttacked:
			self.animated_sprite_2d.play("挨打动画")
		Status.BeDefeated:
			pass
		_: ## fallback
			pass


## 具体状态切换时调用
func on_state_change(current_state: Status, next_state: Status) -> void:
	if current_state == Status.Attack and next_state == Status.Idle:
		self.bar_attack_ready.value = self.bar_attack_ready.min_value
		self.can_attack = false

		self.animation_end = false

	elif current_state == Status.BeAttacked and next_state == Status.Idle:
		self.bar_attack_ready.value = self.bar_attack_ready.min_value
		self.can_attack = false

		self.animation_end = false


## 隐式调用
func _on_animation_finished(anim_name: StringName) -> void:
	print_debug("史莱姆动画结束啦！")
	self.attack(self.target_player)
	self.animation_end = true

	self.can_attack = false
	self.be_attacked = false

	self.bar_attack_ready.value = self.bar_attack_ready.min_value
