@icon("res://resource/assets/sprites/yoburin/待机1.png")
class_name Yoburin
extends MarisaCreature
## 当前唯一玩家 - 优里


## 特有属性 - 游戏界面显示
func _set_health_point(value: float, scale_: int = 1):
	super._set_health_point(value)
	value = max(MIN_VALUE, min(value, MAX_VALUE))
	if self.health_point_label:
		self.health_point_label.real_value = float(value * scale_)
	
func _set_attack_speed(value: float, scale_: int = 1):
	value = max(MIN_VALUE, min(value, MAX_VALUE))
	super._set_attack_speed(value)
	if self.attack_speed_label:
		self.attack_speed_label.real_value = float(value * scale_)
	
func _set_attack_point(value: float, scale_: int = 1):
	value = max(MIN_VALUE, min(value, MAX_VALUE))
	super._set_attack_point(value)
	if self.attack_point_label:
		self.attack_point_label.real_value = float(value * scale_)
	
func _set_defence_point(value: float, scale_: int = 1):
	value = max(MIN_VALUE, min(value, MAX_VALUE))
	super._set_defence_point(value)
	if self.defence_point_label:
		self.defence_point_label.real_value = float(value * scale_)
		
		
const DEFAULT_DATA: Dictionary = {
	"health_point": 100.0,
	"attack_point": 5.0,
	"defence_point": 2.0,
	"attack_speed": 1.0
}


## 节点
@onready var health_point_label: AnimatedNumber = $"动画立绘相关/动画立绘/可视化界面/生命值属性背景/生命值可视化/生命值数值容器/生命值数值"
@onready var attack_speed_label: AnimatedNumber = $"动画立绘相关/动画立绘/可视化界面/攻击速度属性背景/攻击速度可视化/攻击速度数值容器/攻击速度数值"
@onready var attack_point_label: AnimatedNumber = $"动画立绘相关/动画立绘/可视化界面/攻击力属性背景/攻击力可视化/攻击力数值容器/攻击力数值"
@onready var defence_point_label: AnimatedNumber = $"动画立绘相关/动画立绘/可视化界面/防御力属性背景/防御力可视化/防御力数值容器/防御力数值"

## 内置函数
## 类初始化
func _init() -> void:
	super._init()
	Log.debug("初始化优里类实例 %s" % self.to_string())


## 该节点的所有子节点初始化后才初始化
func _ready() -> void:
	self.type_ = "yoburin"
	super._ready()
	
	Log.debug("优里类准备完毕")


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

		## TODO
		Status.BeDefeated:
			self.remove_from_group(GROUP_CREATURE)

		_: ## fallback 落回默认状态
			return Status.Default

	return current_state


## 每帧动作 (帧)
## 若状态维持不变，则运行 action
## 调用具体行为发生在每帧最后一位
func action(current_state: Status, _delta: float) -> void:
	if self.bar_health_point.value > self.health_point:
		self.bar_health_point.value -= 1
	if self.bar_health_point.value < self.health_point:
		self.bar_health_point.value += 1
	match current_state:
		Status.Move:
			self.animated_sprite_2d.play("移动动画")
		Status.Idle:
			self.animated_sprite_2d.play("闲置动画")
			## 到达位置后攻击条自动增长
			## 仅在有敌人需要攻击时才增长
			if !self.pause and !get_tree().get_nodes_in_group(GROUP_ENEMIES_IN_BATTLE).is_empty():
				self.increase_bar_attack_ready()
			elif get_tree().get_nodes_in_group(GROUP_ENEMIES_IN_BATTLE).is_empty():
				self.bar_attack_ready.value = self.bar_attack_ready.min_value
		Status.Attack:
			self.animated_sprite_2d.play("攻击动画")
		Status.BeAttacked:
			self.animated_sprite_2d.play("挨打动画")
		Status.BeDefeated:
			if animation_end == false:
				self.animated_sprite_2d.play("战败动画")
		_: ## falback
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
	
	## 攻击状态结束，进入进度条蓄力状态前
	elif current_state == Status.Attack and next_state == Status.Idle:
		var target: MarisaCreature = get_tree().get_nodes_in_group(GROUP_ENEMIES_IN_BATTLE)[0]
		self._on_attack_end_before_state_change(target)

	## 从就位转至跑步状态（敌人死亡）
	elif current_state == Status.Idle and next_state == Status.Move:
		self._on_enemy_killed_before_state_change()
		var data: Dictionary = {
				"health_point": self.health_point,
				"attack_speed": self.attack_speed,
				"attack_point": self.attack_point,
				"defence_point": self.defence_point
			}
		self.save_data(data)

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
## 敌人撞上来了
func _on_yoburin_in_battle_position(hurtbox: HurtBox) -> void:
	## 怪物加入将要攻击的序列
	hurtbox.owner.add_to_group(GROUP_ENEMIES_IN_BATTLE)
	self.in_battle_position = true


## 敌人死亡
## 此时敌人已从敌对组及场景中移除
func _on_enemy_killed(_hurtbox: HurtBox) -> void:
	## 确实没有敌人了再退出战斗状态
	if get_tree().get_nodes_in_group(GROUP_ENEMIES_IN_BATTLE).is_empty():
		self.in_battle_position = false


## 作为玩家，战败后可以复活，而非从场上移除
## 优布林独有
func _on_be_defeated() -> void:
	## TODO 复活机制
	pass
	

## 贴图动画播放完后调用
## 动画播放在 action 调用后调用，即每帧最后运行
func _on_yoburin_animation_finished() -> void:
	var current_animation := self.animated_sprite_2d.animation
	## 播放完动画后调用
	self._on_after_animation_end(current_animation, get_tree().get_nodes_in_group(GROUP_ENEMIES_IN_BATTLE)[0])

	if current_animation == "攻击动画":
		## 播放完攻击动画之后才运行对方掉血逻辑
		var target: MarisaCreature = get_tree().get_nodes_in_group(GROUP_ENEMIES_IN_BATTLE)[0]
		## 攻击动画结束，调用攻击函数
		self._on_attack_after_animation_end(target)
		remove_from_group("attack_round")

	elif current_animation == "挨打动画":
		## 挨打动画结束，调用挨打函数
		self._on_be_attacked_after_animation_end()

	elif current_animation == "战败动画":
		## 挨打动画结束，调用战败函数
		self._on_be_defeated()
	

## 读写数据
func save_data(data: Dictionary = self.DEFAULT_DATA) -> Dictionary:
	return super.save_data(data)
	

func load_data() -> Dictionary:
	return super.load_data()
