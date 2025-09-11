class_name MarisaCreature
extends CharacterBody2D
## 生物基类

## 生物基本状态 
##			 初始/默认   闲置  移动  发起攻击  受到攻击     被击败
enum Status { Default, Idle, Move, Attack, BeAttacked, BeDefeated }

## 生物基本属性
@export var name_ :=		 "咕咕嘎嘎"	## 名称

@export var move_speed := 	 0.0		## 移速 左负右正
@export var health_point :=  100.0		## 生命值
@export var attack_point :=  1.0		## 攻击力
@export var defence_point := 1.0		## 防御力
@export var attack_speed :=  1.0		## 攻击速度 游戏核心机制

## UI 相关
@onready var sprite: AnimatedSprite2D = 	 $"动画立绘相关/动画立绘"							## 立绘
@onready var bar_health_point: ProgressBar = $"动画立绘相关/动画立绘/可视化界面/生命值进度条"		## 生命值 进度条
@onready var bar_attack_ready: ProgressBar = $"动画立绘相关/动画立绘/可视化界面/攻击准备进度条"		## 能够发起攻击 进度条 游戏核心机制

## 业务逻辑相关
@onready var in_battle_position := 	 		false  ## 生物进入攻击距离
@onready var can_attack := 			 		false  ## 生物攻击进度条涨满 能够发起攻击
@onready var be_attacked :=			 		false  ## 生物收到攻击
@onready var animation_end :=				false  ## 动画结束

## 内置函数
## 类初始化
func _init() -> void:
	## 初始化 UI 相关
	print_debug("初始化 Creature 类实例 %s" % self.to_string())
	randomize()  ## 随机化随机器发生器种子

## 该节点的所有子节点初始化后才初始化
func _ready() -> void:
	print_debug("Creature 类准备完毕")
	print_debug("生命值：%s" % self.bar_health_point)  ## FIXME 为什么是null！！！
	self.bar_health_point.max_value = self.health_point
	self.bar_health_point.value = self.bar_health_point.max_value

	self.bar_attack_ready.value = self.bar_attack_ready.min_value
	
## 业务函数
## 攻击条自增
func bar_attack_ready_increase():
	## 攻击条涨满后能够发起攻击
	if self.bar_attack_ready.value == self.bar_attack_ready.max_value:
		self.can_attack = true
	
	## TODO 攻击条每帧自增步长与礼物价值/数量挂钩
	## TODO 即 amplifier 中的 x：价值越高 x 越大，数量越多 x 越大
	var increase_step: float = self.attack_speed * (1 + amplifier())
	self.bar_attack_ready.value += increase_step

## 功能函数
## a 值越小，x 的差额引起的变化越平滑
func amplifier(x: int = 0, a: float = 0.5) -> float:
	return 1 - exp(-a*x)
