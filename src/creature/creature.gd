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
@onready var bar_health_point: TextureProgressBar = $"动画立绘相关/动画立绘/可视化界面/生命值进度条"        ## 生命值 进度条
@onready var bar_attack_ready: TextureProgressBar = $"动画立绘相关/动画立绘/可视化界面/攻击准备进度条"        ## 能够发起攻击 进度条 游戏核心机制

## 生物基本属性
const MIN_VALUE := 0.0					## 数值可以设置的最小值
const MAX_VALUE := 99_9999.0			## FIXME UI 机制限制，最大显示六位数 999999
@export var name_ := "咕咕嘎嘎"    		## 名称
@export var move_speed := 0.0        	## 移速 左负右正

@export var health_point := 1.0:
	set = _set_health_point

func _set_health_point(value: float):
	value = max(MIN_VALUE, min(value, MAX_VALUE))
	## 若血量被设为比当前值小的值 -> 受到攻击了 / 扣血了
	if health_point > value:
		self.be_attacked = true

	## 生命条成功初始化后再赋值
	if self.bar_health_point != null:
		self.bar_health_point.value = value

	## 血量清零则战败
	if value == 0:
		self.be_defeated = true

	## 为 label 赋值
	health_point = value

	
@export var attack_speed := 1.0:        ## 攻击速度 游戏核心机制
	set = _set_attack_speed

func _set_attack_speed(value: float):
	value = max(MIN_VALUE, min(value, MAX_VALUE))
	attack_speed = value
	
	
@export var attack_point := 1.0:        ## 攻击力
	set = _set_attack_point

func _set_attack_point(value: float):
	value = max(MIN_VALUE, min(value, MAX_VALUE))
	attack_point = value
	
	
@export var defence_point := 1.0:        ## 防御力
	set = _set_defence_point

func _set_defence_point(value: float):
	value = max(MIN_VALUE, min(value, MAX_VALUE))
	defence_point = value

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
	## 防御性初始化
	self.health_point = 1.0
	self.attack_speed = 1.0
	self.attack_point = 1.0
	self.defence_point = 1.0
	
	## 禁用步长
	# self.bar_health_point.step = 0
	# self.bar_attack_ready.step = 0
	
	self.bar_health_point.max_value = self.health_point
	self.bar_health_point.value = self.bar_health_point.max_value

	self.bar_attack_ready.value = self.bar_attack_ready.min_value
	## 添加至全局生物组
	self.add_to_group(GROUP_CREATURE)


## 业务函数
## 在任一动画播放完后用
func _on_after_animation_end(animation: StringName, target: MarisaCreature) -> void:
	## 设置动画结束标识
	Log.debug("%s的动画“%s”结束了" % [self.name, animation])
	self.animation_end = true
	if animation == "挨打动画" or animation == "战败动画":
		target.bar_attack_ready.value = target.bar_attack_ready.min_value

	
## 攻击，在进入攻击状态前调用一次
func _on_attack_before_state_change() -> void:
	self.add_to_group("attack_ready")  ## FIXME ? 干嘛的
	## 即将发动攻击（播放动画前）
	## 暂停所有生物
	## 以免我攻击时对面还在攻击
	for attack_creature in get_tree().get_nodes_in_group(GROUP_CREATURE):
		attack_creature.pause = true

		
## 攻击状态结束，进入闲置状态（攻击条蓄力）之前
func _on_attack_end_before_state_change(target: MarisaCreature) -> void:
	## 对方挨打/战败动画播放结束后，重置攻击进度条
	if target.animation_end:
		self.bar_attack_ready.value = self.bar_attack_ready.min_value


## 攻击，在攻击动画播放完后调用一次
func _on_attack_after_animation_end(target: MarisaCreature) -> void:
	## 掉血逻辑处理
	## 仿照明日方舟
	var damage: float = max(0.05 * self.attack_point, self.attack_point - target.defence_point)

	Log.debug("%s攻击%s, 血量 %s -> %s" % [self.name, target.name, target.health_point, target.health_point-damage])
	target.health_point -= damage
	target.bar_health_point.value = target.health_point

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
	pass


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
