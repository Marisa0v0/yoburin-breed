# 怪物 - 史莱姆
extends CharacterBody2D
class_name Slime

# 控制行动
enum 史莱姆状态 {移动,战斗,攻击,受击,战败}
@export var name_ = "我没有名字孩子们"
# 移动速度
@export var move_speed = 200.0
@export var health = 100
@export var atk_value = 2
@export var spd_value = 1
@export var def_value = 1

@onready var 史莱姆进入攻击位置 = false
@onready var 史莱姆攻击准备就绪 = false
@onready var 史莱姆动画播放完成 = false

@onready var game_manager: Node = %GameManager
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimatedSprite2D/AnimationPlayer
@onready var 死亡音效: AudioStreamPlayer2D = $"死亡音效"
@onready var player = %Player/Yoburin
@onready var atk_speed_bar: ProgressBar = $Control/atk_bar
@onready var hp_bar: ProgressBar = $Control/hp_bar
@onready var node_creature: Node = %Creature

var slime_scene = preload("res://scene/creature/slime.tscn")


#func _init(name__: String = "我没有名字孩子们"):
#	name_ = name__ 
#
#func _enter_tree() -> void:
#	# TODO 接收参数 -> 投喂礼物的用户id
#	game_manager.GlobalCreatures["史莱姆"] = 物理史莱姆.new()

"""内置函数"""
func _ready() -> void:
	# 初始化各种进度条
	hp_bar.max_value = health
	hp_bar.value = hp_bar.max_value
	atk_speed_bar.value = atk_speed_bar.min_value

func _on_area_2d_area_entered(area: Area2D) -> void:
	史莱姆进入攻击位置 = true

"""核心业务"""
func 更改状态调用函数(上一个状态: 史莱姆状态, 下一个状态: 史莱姆状态) -> void:
	# 只调用一次
	if 上一个状态 == 史莱姆状态.移动:
		move_speed = 0
	if 上一个状态 == 史莱姆状态.攻击:
		atk_speed_bar.value = atk_speed_bar.min_value
		史莱姆动画播放完成 = false
	
func 获取新的状态(当前状态: 史莱姆状态) -> 史莱姆状态:
	# 每帧最先调用
	match 当前状态:
		史莱姆状态.移动:  # 初始状态
			if 史莱姆进入攻击位置 == true:
				return 史莱姆状态.战斗
			return 当前状态
		史莱姆状态.战斗:
			if 史莱姆攻击准备就绪 == true:
				return 史莱姆状态.攻击
			return 当前状态
		史莱姆状态.攻击:
			if 史莱姆动画播放完成 == true:
				return 史莱姆状态.战斗
			return 当前状态
		史莱姆状态.受击:
			return 当前状态
		史莱姆状态.战败:
			return 当前状态
		_:
			return 史莱姆状态.移动
	return 史莱姆状态.移动

func 每帧业务函数(当前状态: 史莱姆状态, delta):
	# 状态切换时调用
	match 当前状态:
		史莱姆状态.战斗:
			# TODO 判断是否有任意生物在攻击
			increase_bar()
		史莱姆状态.攻击:
			animation_player.play("attack")
			animation_end()
		史莱姆状态.受击:
			pass
		史莱姆状态.移动:
			position.x -= move_speed * delta
		史莱姆状态.战败:
			pass
		_:
			pass

func is_any_other_creature_attacking() -> void:	
	"""判断是否有除自己外任意其他生物在攻击"""
	pass
	

"""功能函数"""
func amplifier(x=0):
	return 1-exp(-x)

func increase_bar():
	# 攻击条自增
	if atk_speed_bar.value == atk_speed_bar.max_value:
		史莱姆攻击准备就绪 = true
	var delta = spd_value * (1 + amplifier(5))
	atk_speed_bar.value += delta

"""隐式调用"""
func attack_player(monster_atk_int: int = 1):
	# godot的动画机可以自己在特定帧调用函数，实现很方便的效果，这里直接在动画里和攻击动画同时调用攻击函数
	# 就可以做到动画播放的同时攻击，不用对轴什么的了
	GlobalGameManager.attack_player(atk_value)
	print(self.to_string() + " | 攻击！")

func animation_end():
	# 攻击动画播放完毕
	史莱姆攻击准备就绪 = false
	史莱姆动画播放完成 = true
