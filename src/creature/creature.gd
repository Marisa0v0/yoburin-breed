class_name MarisaCreature
extends CharacterBody2D
## 生物基类


## 生物基本状态
##			 初始/默认   闲置  移动  发起攻击  受到攻击     被击败
enum Status { Default, Idle, Move, Attack, BeAttacked, BeDefeated }

## UI 相关
@onready var sprite: AnimatedSprite2D = $"动画立绘相关/动画立绘"                            ## 立绘
@onready var bar_health_point: ProgressBar = $"动画立绘相关/动画立绘/可视化界面/生命值进度条"        ## 生命值 进度条
@onready var bar_attack_ready: ProgressBar = $"动画立绘相关/动画立绘/可视化界面/攻击准备进度条"        ## 能够发起攻击 进度条 游戏核心机制

## 生物基本属性
@export var name_ := "咕咕嘎嘎"    ## 名称
@export var move_speed := 0.0        ## 移速 左负右正
@export var health_point: float:			## 生命值
	set(value):
		value = max(0, min(value, 100.0))   ## 限制在 0~100 之间
		if bar_health_point != null:
			bar_health_point.value = value
		health_point = value
@export var attack_point := 5.0        ## 攻击力
@export var defence_point := 2.0        ## 防御力
@export var attack_speed := 1.0        ## 攻击速度 游戏核心机制

## 业务逻辑相关
@onready var in_battle_position := false  ## 生物进入攻击距离
@onready var can_attack := false  ## 生物攻击进度条涨满 能够发起攻击
@onready var be_attacked := false  ## 生物收到攻击
@onready var animation_end := false  ## 动画结束
@onready var pause := false  ##暂停生物逻辑，用于在其他生物进行行动/攻击时避免同时行动/攻击产生bug

var logger := LogStream.new("Creature", LogStream.LogLevel.DEBUG)


## 内置函数
## 类初始化
func _init() -> void:
	## 初始化 UI 相关
	self.logger.debug("初始化 Creature 类实例 %s" % self.to_string())
	randomize()  ## 随机化随机器发生器种子


## 该节点的所有子节点初始化后才初始化
func _ready() -> void:
	self.logger.debug("Creature 类准备完毕")
	self.health_point = 100.0
	
	self.bar_health_point.max_value = self.health_point
	self.bar_health_point.value = self.bar_health_point.max_value

	self.bar_attack_ready.value = self.bar_attack_ready.min_value
	self.add_to_group("creature")


## 业务函数
## 攻击！攻击动画播放完后调用一次
func attack(target: MarisaCreature):
	## 掉血逻辑处理
	target.be_attacked = true
	var damage := self.attack_point - target.defence_point
	if damage <= 0:
		return

	self.logger.info("%s 攻击 %s, %s血量%s->%s" % [self.name, target.name, target.name, target.health_point, target.health_point-damage])
	target.health_point -= damage
	target.bar_health_point.value = target.health_point
	if target.bar_health_point.value < 0:
		pass
	
	## 攻击完后（播放完动画后）解除所有生物暂停
	for attack_creature in get_tree().get_nodes_in_group("creature"):
		attack_creature.pause = false


## TODO

## 攻击条自增
## 每帧最后调用 action 时调用一次
func bar_attack_ready_increase():
	## 攻击条涨满后能够发起攻击
	if self.bar_attack_ready.value == self.bar_attack_ready.max_value:
		self.add_to_group("attack_ready")
		## 即将发动攻击（播放动画前）
		## 暂停所有生物
		for attack_creature in get_tree().get_nodes_in_group("creature"):
			attack_creature.pause = true
		## 当前生物能够发动攻击
		self.can_attack = true

	## TODO 攻击条每帧自增步长与礼物价值/数量挂钩
	## TODO 即 amplifier 中的 x：价值越高 x 越大，数量越多 x 越大
	var increase_step: float = self.attack_speed * (1 + amplifier())
	self.bar_attack_ready.value += increase_step


## 功能函数
## a 值越小，x 的差额引起的变化越平滑
func amplifier(x: int = 0, a: float = 0.5) -> float:
	return 1 - exp(-a*x)
