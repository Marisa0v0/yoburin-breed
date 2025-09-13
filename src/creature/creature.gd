class_name MarisaCreature
extends CharacterBody2D
## 生物基类
## 此处放置生物通用的逻辑


## 生物基本状态
##			 初始/默认   闲置  移动  发起攻击  受到攻击     被击败
enum Status { Default, Idle, Move, Attack, BeAttacked, BeDefeated }
## UI 相关
@onready var animated_sprite_2d: AnimatedSprite2D = $"动画立绘相关/动画立绘"
@onready var animation_player: AnimationPlayer = $"动画立绘相关/动画立绘/动画播放器"  ## 动画播放器                         ## 立绘
@onready var bar_health_point: ProgressBar = $"动画立绘相关/动画立绘/可视化界面/生命值进度条"        ## 生命值 进度条
@onready var bar_attack_ready: ProgressBar = $"动画立绘相关/动画立绘/可视化界面/攻击准备进度条"        ## 能够发起攻击 进度条 游戏核心机制

## 生物基本属性
@export var name_ := "咕咕嘎嘎"    ## 名称
@export var move_speed := 0.0        ## 移速 左负右正

@export var health_point := 100.0: ## 生命值
	set(value):
		## 限制在 0~100 之间
		value = max(0, min(value, 100.0))
		## 若血量被设为比当前值小的值 -> 受到攻击了 / 扣血了
		if health_point > value:
			self.be_attacked = true

		## 生命条成功初始化后再赋值
		if self.bar_health_point != null:
			self.bar_health_point.value = value

		## 血量清零则战败
		if value == 0:
			self.be_defeated = true

		health_point = value

@export var attack_point := 5.0        ## 攻击力
@export var defence_point := 2.0        ## 防御力
@export var attack_speed := 1.0        ## 攻击速度 游戏核心机制

## 标识变量
@onready var in_battle_position := false  ## 该生物是否进入能发动攻击的区域
@onready var can_attack := false  ## 该生物攻击进度条是否涨满（是否能够发起攻击）
@onready var be_attacked := false  ## 该生物是否正在被攻击
@onready var animation_end := false  ## 该动画是否结束
@onready var pause := false  ## 暂停生物逻辑，用于在其他生物进行行动/攻击时避免同时行动/攻击产生bug
@onready var be_defeated := false  ## 生物是否战败（血量清零）

var GROUP_CREATURE: StringName          = GameManager.NodeGroup.keys()[GameManager.NodeGroup.Creature]
var GROUP_ENEMIES_IN_BATTLE: StringName = GameManager.NodeGroup.keys()[GameManager.NodeGroup.EnemiesInBattle]


## 内置函数
## 类初始化
func _init() -> void:
	## 初始化 UI 相关
	Log.debug("初始化生物类实例 %s" % self.to_string())
	randomize()  ## 随机化随机器发生器种子


## 该节点的所有子节点初始化后才初始化
func _ready() -> void:
	Log.debug("生物类准备完毕")
	self.health_point = 100.0

	self.bar_health_point.max_value = self.health_point
	self.bar_health_point.value = self.bar_health_point.max_value

	self.bar_attack_ready.value = self.bar_attack_ready.min_value
	## 添加至全局生物组
	self.add_to_group(GROUP_CREATURE)


## 业务函数
## 攻击，在进入攻击状态前调用一次
func _on_attack_before_state_change() -> void:
	## 每次进入攻击状态都需重设攻击进度条，防御性
	self.bar_attack_ready.value = self.bar_attack_ready.min_value
	self.add_to_group("attack_ready")  ## FIXME ? 干嘛的
	## 即将发动攻击（播放动画前）
	## 暂停所有生物
	## 以免我攻击时对面还在攻击
	for attack_creature in get_tree().get_nodes_in_group(GROUP_CREATURE):
		attack_creature.pause = true


## 攻击，在攻击动画播放完后调用一次
func _on_attack_after_animation_end(target: MarisaCreature) -> void:
	## 掉血逻辑处理
	var damage := self.attack_point - target.defence_point
	if damage <= 0:
		return

	Log.info("%s攻击%s, 血量 %s -> %s" % [self.name, target.name, target.health_point, target.health_point-damage])
	target.health_point -= damage
	target.bar_health_point.value = target.health_point
	if target.bar_health_point.value < 0:
		pass

	## 攻击结束，攻击状态重置
	self.can_attack = false


## 被攻击，在挨打动画播放完后调用一次
func _on_be_attacked_after_animation_end() -> void:
	self.be_attacked = false
	## 挨打动画播放完后再解除其他生物暂停
	for attack_creature in get_tree().get_nodes_in_group(GROUP_CREATURE):
		attack_creature.pause = false


## 被击败，在进入战败状态前调用一次
func _on_be_defeated_before_state_change() -> void:
	## 即将战败（播放动画前）
	## 暂停所有生物
	## 以免战败时对面还在攻击
	for attack_creature in get_tree().get_nodes_in_group(GROUP_CREATURE):
		attack_creature.pause = true

	## 在进入动画前就需要设置战败状态
	self.be_defeated = true


## 被击败，在战败动画播放完后调用一次
func _on_be_defeated_after_animation_end() -> void:
	## 战败后从场上移除
	self.queue_free()
	## 战败动画结束，继续游戏进程
	for attack_creature in get_tree().get_nodes_in_group(GROUP_CREATURE):
		attack_creature.pause = false


## 击败敌人，在进入跑步状态前播放一次
func _on_enemy_killed_before_state_change() -> void:
	## 防御性重设攻击进度条
	self.bar_attack_ready.value = self.bar_attack_ready.min_value


## 攻击条自增
## 每帧最后调用 action 时调用一次
func increase_bar_attack_ready() -> void:
	## 攻击条涨满后能够发起攻击
	if self.bar_attack_ready.value == self.bar_attack_ready.max_value:
		## 当前生物能够发动攻击
		self.can_attack = true

	## TODO 攻击条每帧自增步长与礼物价值/数量挂钩
	## TODO 即 amplifier 中的 x：价值越高 x 越大，数量越多 x 越大
	var increase_step: float = self.attack_speed * (1 + _amplifier())
	self.bar_attack_ready.value += increase_step


## 功能函数
## a 值越小，x 的差额引起的变化越平滑
static func _amplifier(x: int = 0, a: float = 0.5) -> float:
	return 1 - exp(-a*x)
