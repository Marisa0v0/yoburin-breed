@icon("res://resource/yoburin/待机1.png")
class_name Yoburin
extends MarisaPlayer
## 当前唯一玩家 - 优里

## 优里立绘
@onready var animated_sprite_2d: AnimatedSprite2D = $"动画立绘相关/动画立绘"


## 内置函数
## 类初始化
func _init() -> void:
	super._init()
	print_debug("初始化优里类实例 %s" % self.to_string())


## 该节点的所有子节点初始化后才初始化
func _ready() -> void:
	super._ready()
	print_debug("优里类准备完毕")
	self.attack_speed = 5.0


## 敌人撞上来了
func _on_in_battle_position(hurtbox: HurtBox) -> void:
	self.in_battle_position = true
	## 怪物加入将要攻击的序列
	self.enemies_in_battle.append(hurtbox.owner)


## 业务函数
## 仅在生物需要进行动作时更新当前状态
func update_state(current_state: Status) -> Status:
	match current_state:
		## 初始状态
		Status.Default:
			return Status.Move

		## 常规状态
		Status.Move:
			if self.in_battle_position: ## 移动到位 -> 停止移动 闲置
				return Status.Idle

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
			print_debug("优里挨打了！")
			if self.animation_end:
				return Status.Idle

		## TODO
		Status.BeDefeated:
			pass

		_: ## fallback 落回默认状态
			return Status.Default

	return current_state


## 每帧动作
func action(current_state: Status, delta: float) -> void:
	match current_state:
		Status.Move:
			self.animated_sprite_2d.play("移动动画")
		Status.Idle:
			self.animated_sprite_2d.play("闲置动画")
			self.bar_attack_ready_increase()
		Status.Attack:
			self.animated_sprite_2d.play("攻击动画")
		Status.BeAttacked:
			self.animated_sprite_2d.play("受击动画")
		Status.BeDefeated:
			self.animated_sprite_2d.play("战败动画")
		_: ## falback
			self.animated_sprite_2d.play("闲置动画")


## 具体状态切换时调用
func on_state_change(current_state: Status, next_state: Status) -> void:
	if current_state == Status.BeAttacked and next_state == Status.Idle:
		self.bar_attack_ready.value = self.bar_attack_ready.min_value
		self.can_attack = false

		self.animation_end = false

	elif current_state == Status.Attack and next_state == Status.Idle:
		self.bar_attack_ready.value = self.bar_attack_ready.min_value
		self.can_attack = false

		self.animation_end = false


## 动画结束了
func _on_animation_finished() -> void:
	print_debug("优里动画结束啦")
	self.attack(self.enemies_in_battle[0])
	self.animation_end = true

	self.can_attack = false
	self.be_attacked = false

	self.bar_attack_ready.value = self.bar_attack_ready.min_value
