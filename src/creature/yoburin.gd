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
	self.logger.debug("初始化优里类实例 %s" % self.to_string())


## 该节点的所有子节点初始化后才初始化
func _ready() -> void:
	super._ready()
	self.logger.debug("优里类准备完毕")
	self.attack_speed = 5.0  ## TODO 测试用


## 敌人撞上来了
func _on_in_battle_position(hurtbox: HurtBox) -> void:
	## 怪物加入将要攻击的序列
	self.enemies_in_battle.append(hurtbox.owner)
	self.in_battle_position = true


## 业务函数 (帧)
## 每帧第一个运行 update_state 函数
## 状态切换发生在每帧第一位
func update_state(current_state: Status) -> Status:
	match current_state:
		## 初始状态
		Status.Default:
			return Status.Move

		## 常规状态
		Status.Move:
			## 移动到位 -> 停止移动 闲置
			if self.in_battle_position: 
				return Status.Idle

		Status.Idle:
			## 攻击条涨满 -> 发动攻击
			if self.can_attack:
				return Status.Attack
			
			## 挨打了 -> 挨打
			if self.be_attacked:
				return Status.BeAttacked

			## 血量清零 -> 战败
			if self.bar_health_point.value == self.bar_health_point.min_value:
				return Status.BeDefeated

		Status.Attack:
			## 攻击动画结束 -> 返回闲置
			if self.animation_end:
				return Status.Idle

		Status.BeAttacked:
			## 受击动画结束 -> 返回闲置
			## NOTE 此处 animation_end 初次应该为 false 才能正常运行
			if self.animation_end:
				return Status.Idle

		## TODO
		Status.BeDefeated:
			pass

		_: ## fallback 落回默认状态
			return Status.Default

	return current_state


## 每帧动作 (帧)
## 若状态维持不变，则运行 action
## 调用具体行为发生在每帧最后一位
func action(current_state: Status, _delta: float) -> void:
	match current_state:
		Status.Move:
			self.animated_sprite_2d.play("移动动画")
		Status.Idle:
			self.animated_sprite_2d.play("闲置动画")
			## 到达位置后攻击条自动增长
			if !self.pause:
				self.bar_attack_ready_increase()
		Status.Attack:
			self.enemies_in_battle[0].be_attacked = true
			self.animated_sprite_2d.play("攻击动画")
		Status.BeAttacked:
			self.animated_sprite_2d.play("挨打动画")
		Status.BeDefeated:
			if animation_end == false:
				self.animated_sprite_2d.play("战败动画")
		_: ## falback
			self.animated_sprite_2d.play("闲置动画")


## 具体状态切换时调用
## 每帧仅在状态从 current_state 切换至 next_state 时调用
## 每帧可能发生多次状态切换，也可能一次都不发生
## 若发生则在 update 与 action 之间调用
func on_state_change(current_state: Status, next_state: Status) -> void:
	## 总之先重设动画结束标识
	self.animation_end = false

	## 进入攻击状态
	if current_state == Status.Idle and next_state == Status.Attack:
		## 每次进入攻击状态都需重设攻击进度条，防御性
		self.bar_attack_ready.value = self.bar_attack_ready.min_value

	## 攻击结束 (目标死亡)
	elif current_state == Status.Attack and next_state == Status.Idle:
		## 防御性重设攻击标识
		self.can_attack = false
		## 防御性，以免条涨到一半目标死亡了
		self.bar_attack_ready.value = self.bar_attack_ready.min_value

	## 进入挨打状态
	elif current_state == Status.Idle and next_state == Status.BeAttacked:
		self.be_attacked = true

	## 挨打结束
	elif current_state == Status.BeAttacked and next_state == Status.Idle:
		self.be_attacked = false


## 隐式调用
## 贴图动画播放完后调用
## 动画播放在 action 调用后调用，即每帧最后运行
func _on_animation_finished() -> void:
	var current_animation := self.animated_sprite_2d.animation
	self.logger.info("%s的'%s'动画结束了" % [self.name, current_animation])
	
	if current_animation == "攻击动画":
		## 播放完攻击动画之后才运行对方掉血逻辑
		var target := self.enemies_in_battle[0]
		self.attack(target)
	
		## 攻击动画结束
		self.can_attack = false
		## ：对方挨打动画结束
		target.be_attacked = false
	
	elif current_animation == "挨打动画":
		## 挨打动画结束
		self.be_attacked = false
	
	## 设置动画结束标识
	self.animation_end = true
