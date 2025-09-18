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

## 优里特有动画
@onready var clover_meteor: GPUParticles2D = $"动画立绘相关/四叶草流星"


## 标识变量
## 能否释放技能
@onready var can_cast_skill := false


## 场景
## 玩家复活计时器
const scene_respawn_timer: PackedScene = preload("res://scene/utils/player_respawn_timer.tscn")

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
			## 复活了
			if !self.be_defeated:
				return Status.Default

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
		
	## 任意情况下若能够释放技能，优先释放技能
	if self.can_cast_skill:
		self.cast_skill()

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
func _on_be_defeated_after_animation_end() -> void:
	self.bar_attack_ready.value = self.bar_attack_ready.min_value
	## 死亡后，敌人转身离开
	for attack_creature in get_tree().get_nodes_in_group(GROUP_CREATURE):
		attack_creature.pause = false
	
	## 暂停新怪物生成
	var timer: Timer = get_node("/root/主场景/功能组件集合/刷怪倒计时")		## NOTE 修改结构时要修改
	timer.paused = true
	for monster in get_tree().get_nodes_in_group(GROUP_MONSTERS):
		if monster is MarisaSlime:	## FIXME 暂时只有史莱姆
			await monster.animation_end  ## FIXME ? 不确定能不能这么写
			## 如果当前有正在交战的怪物，停止交战
			if monster.target_player != null:
				## 退出交战状态
				monster.in_battle_position = false
				monster.target_player = null
				monster.remove_from_group(GROUP_ENEMIES_IN_BATTLE)
			## 所有怪物反向加速逃离
			## 修改贴图方向
			monster.animated_sprite_2d.flip_h = false
			## 修改速度
			monster.move_speed = - 2.0 * monster.move_speed
			## 修改状态
			monster.update_state(MarisaCreature.Status.Move)
	
	## 自动启动复活倒计时
	var respawn_timer: PlayerRespawnTimer = scene_respawn_timer.instantiate()
	## 如果有重复的就删除
	var respawn_timer_duplicated = get_node("/root/主场景/功能组件集合/玩家复活计时器")
	if respawn_timer_duplicated != null:
		respawn_timer_duplicated.queue_free()
		
	get_node("/root/主场景/功能组件集合").add_child(respawn_timer)
	Log.info("优布林死了！！")
		
			
## 复活
func respawn() -> void:
	## 如果倒计时还在那就释放掉
	var respawn_timer = get_node("/root/主场景/功能组件集合/玩家复活计时器")
	if respawn_timer != null:
		respawn_timer.queue_free()
		
	## 设置初始属性
	for property in DEFAULT_DATA:
		self.set(property, DEFAULT_DATA[property])

	## 取消战败状态
	self.be_defeated = false
	## 重新开始刷怪计时
	Log.info("优布林复活了！！")
	var timer: Timer = get_node("/root/主场景/功能组件集合/刷怪倒计时")		## NOTE 修改结构时要修改
	timer.paused = false
	
	
## 使用技能 TODO 当前为四叶草流星，以后做兼容其他技能的通用代码
func cast_skill() -> void:
	self.animated_sprite_2d.play("闲置动画")
	self.clover_meteor.emitting = true
	## 暂停生物行动
	for attack_creature in get_tree().get_nodes_in_group(GROUP_CREATURE):
		attack_creature.pause = true

	## 所有敌人百分比扣血至清零
	for target in get_tree().get_nodes_in_group(GROUP_MONSTERS):
		var tween: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		tween.tween_property(target, "health_point", 0, self.clover_meteor.lifetime - self.clover_meteor.preprocess)
		
	## 优布林回血
	self.health_point = self.bar_health_point.max_value

## 技能动画播放完毕
func _on_yoburin_particles_finished() -> void:
	## 恢复生物行动
	## 回复标识符
	self.can_cast_skill = false
	
	## 解除暂停
	for attack_creature in get_tree().get_nodes_in_group(GROUP_CREATURE):
		attack_creature.pause = false

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
		self._on_be_defeated_after_animation_end()

## 读写数据
func save_data(data: Dictionary = self.DEFAULT_DATA) -> Dictionary:
	return super.save_data(data)
	

func load_data() -> Dictionary:
	return super.load_data()
