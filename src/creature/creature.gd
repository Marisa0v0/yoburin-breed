class_name MarisaCreature
extends CharacterBody2D
## 生物基类

## 生物基本状态 
##			闲置  移动	 准备战斗	   发起攻击  受到攻击	   被击败
enum Status {Idle, Move, InBattle, Attack, BeAttacked, BeDefeated }

## 生物基本属性
@export var move_speed: float		= 0.0		## 移速 左负右整
@export var health_point: float		= 100.0		## 生命值
@export var attack_point: float		= 1.0		## 攻击力
@export var defence_point: float	= 1.0		## 防御力
@export var attack_speed: float		= 1.0		## 攻击速度 游戏核心机制

## UI 相关
@onready var bar_health_point: ProgressBar = $Control/bar_health_point	## 生命值 进度条
@onready var bar_attack_ready: ProgressBar = $Control/bar_attack_ready  ## 能够发起攻击 进度条 游戏核心机制

## 业务逻辑相关
@onready var is_in_battle: bool = false  ## 生物准备战斗
@onready var can_attack: bool   = false  ## 生物能够进行攻击

## 内置函数
## 类初始化
func _init() -> void:
	## 初始化 UI 相关
	print_debug("初始化 Creature 类")
	self.bar_health_point.max_value = self.health_point
	self.bar_health_point.value = self.bar_health_point.max_value

	self.bar_attack_ready.value = self.bar_attack_ready.min_value

## 该节点的所有子节点初始化后才初始化
func _ready() -> void:
	pass
	
## 每帧调用一次
func _process(delta: float) -> void:
	pass
	
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
func amplifier(x: int = 0, a: float = 0.5):
	return 1 - exp(-a*x)