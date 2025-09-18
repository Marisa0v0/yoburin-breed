class_name MarisaSlime
extends MarisaCreature
## 怪物 - 史莱姆

var target_player: MarisaCreature = null
		
		
const DEFAULT_DATA: Dictionary = {
	"health_point": 100.0,
	"attack_point": 5.0,
	"defence_point": 2.0,
	"attack_speed": 1.0
}


## 内置函数
## 类初始化
func _init() -> void:
	super._init()
	Log.debug("初始化史莱姆类实例 %s" % self.to_string())
	
	self.health_point = 5.0
	self.attack_point = 2.0


## 该节点的所有子节点初始化后才初始化
func _ready() -> void:
	self.type_ = "slime"
	super._ready()
	
	self.move_speed = -100.0    ## 怪物向左移动
	Log.debug("史莱姆类准备完毕")

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

			## 血量清零 -> 战败
			if self.be_defeated:
				return Status.BeDefeated

		Status.Idle:
			## 攻击条涨满 -> 发动攻击
			if self.can_attack:
				return Status.Attack

			## 挨打了 -> 挨打
			if self.be_attacked:
				return Status.BeAttacked

			## 血量清零 -> 战败
			if self.be_defeated:
				return Status.BeDefeated

			## 不处于战斗位置（敌人死亡） -> 继续跑
			if !self.in_battle_position:
				return Status.Move

		Status.Attack:
			## 攻击动画结束 -> 返回闲置
			if self.animation_end:
				return Status.Idle

		Status.BeAttacked:
			## 受击动画结束 -> 返回闲置
			## NOTE 此处 animation_end 初次应该为 false 才能正常运行
			if self.animation_end:
				return Status.Idle

			if self.health_point <= 0:
				return Status.BeDefeated

		## TODO
		Status.BeDefeated:
			pass

		_: ## fallback 落回常规状态
			return Status.Default

	return current_state


## 每帧动作 (帧)
## 若状态维持不变，则运行 action
func action(current_state: Status, delta: float) -> void:
	if self.bar_health_point.value > self.health_point:
		self.bar_health_point.value -= 1
	if self.bar_health_point.value < self.health_point:
		self.bar_health_point.value += 1
		
	match current_state:
		Status.Move:
			animated_sprite_2d.play("闲置动画")
			## 每帧移动
			self.position.x += self.move_speed * delta
		Status.Idle:
			animated_sprite_2d.play("闲置动画")
			## 到达位置后攻击条自动增长
			if !self.pause and self.target_player != null:
				self.increase_bar_attack_ready()
			elif self.target_player == null:  ## FIXME 怎么没用
				self.bar_attack_ready.value = self.bar_attack_ready.min_value
		Status.Attack:
			## 播放动画
			## TODO 攻击动画
			## TODO 动画效果升级
			self.animation_player.play("攻击动画")
		Status.BeAttacked:
			self.animated_sprite_2d.play("挨打动画")
		Status.BeDefeated:
			self.animated_sprite_2d.play("战败动画")
		_: ## fallback
			self.animated_sprite_2d.play("闲置动画")


## 具体状态切换时调用
## 每帧仅在状态从 current_state 切换至 next_state 前调用
## 每帧可能发生多次状态切换，也可能一次都不发生
## 若发生则在 update 与 action 之间调用
func _before_state_change(current_state: Status, next_state: Status) -> void:
	## 总之先重设动画结束标识
	self.animation_end = false

	## 无论何种情况下进入攻击状态
	if next_state == Status.Attack:
		self._on_attack_before_state_change()
		## 进入挨打状态

	elif current_state == Status.Idle and next_state == Status.BeAttacked:
		self.be_attacked = true

	## 挨打结束
	elif current_state == Status.BeAttacked and next_state == Status.Idle:
		pass

	## 无论何种情况下进入战败
	elif next_state == Status.BeDefeated:
		self._on_be_defeated_before_state_change()
		

## 信号连接
## 判定进入攻击位置
func _on_slime_in_battle_position(hurtbox: HurtBox) -> void:
	## 玩家设为攻击目标
	if hurtbox.owner is Yoburin:
		Log.debug("%s撞到玩家了" % self.name)
		self.target_player = hurtbox.owner
		self.in_battle_position = true
	## 撞到清除边界了
	else:
		Log.debug("%s撞到怪物清除边界了" % self.name)
		self.remove_from_group(GROUP_MONSTERS)
		self.queue_free()
		


## 击杀玩家 TODO 相关处理
## 需要玩家受击区域碰撞箱消失以触发
func _on_player_killed(_hurtbox: HurtBox) -> void:
	self.target_player = null
	self.in_battle_position = false
	
	
## 贴图动画播放完后调用
func _on_slime_animation_finished() -> void:
	var current_animation := self.animated_sprite_2d.animation
	## 播放完动画后调用
	self._on_after_animation_end(current_animation, self.target_player)
	
	if current_animation == "挨打动画":
		## 挨打动画结束，调用挨打函数
		self._on_be_attacked_after_animation_end()

	elif current_animation == "战败动画":
		## 战败动画结束，调用战败函数
		self._on_be_defeated_after_animation_end()
		## 从玩家的攻击序列中移除 
		self.remove_from_group(GROUP_ENEMIES_IN_BATTLE)


## 播放器动画播放完后调用
func _on_slime_animation_player_finished(current_animation: StringName):
	## 播放完动画后调用
	self._on_after_animation_end(current_animation, self.target_player)
	if current_animation == "攻击动画":
		## 播放完攻击动画之后才运行对方掉血逻辑
		## 攻击动画结束，调用攻击函数
		self._on_attack_after_animation_end(self.target_player)
		remove_from_group("attack_round")


## 读写数据
func save_data(data: Dictionary) -> Dictionary:
	return super.save_data(data)


func load_data() -> Dictionary:
	return super.load_data()
