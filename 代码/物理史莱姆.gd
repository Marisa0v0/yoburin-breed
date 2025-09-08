extends CharacterBody2D
class_name 物理史莱姆

enum 史莱姆状态 {移动,战斗,攻击,受击,战败}
@export var name_ = "我没有名字孩子们"
@export var move_speed = 260.0  # 这什么 移动速度
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
@onready var player = %Yoburin
@onready var atk_speed_bar: ProgressBar = $Control/atk_bar
@onready var hp_bar: ProgressBar = $Control/hp_bar


#func _init(name__: String = "我没有名字孩子们"):
#	name_ = name__ 
#
#func _enter_tree() -> void:
#	# TODO 接收参数 -> 投喂礼物的用户id
#	game_manager.GlobalCreatures["史莱姆"] = 物理史莱姆.new()


func _ready() -> void:
	hp_bar.max_value = health
	hp_bar.value = hp_bar.max_value
	atk_speed_bar.value = atk_speed_bar.min_value

func _on_area_2d_area_entered(area: Area2D) -> void:

	史莱姆进入攻击位置 = true

	
func 获取新的状态(当前状态: 史莱姆状态) -> 史莱姆状态:

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
	

func 更改状态调用函数(上一个状态: 史莱姆状态, 下一个状态: 史莱姆状态) -> void:

	if 上一个状态 == 史莱姆状态.移动:
		move_speed = 0
	if 上一个状态 == 史莱姆状态.攻击:
		atk_speed_bar.value = atk_speed_bar.min_value
		史莱姆动画播放完成 = false
	pass


func 每帧业务函数(当前状态: 史莱姆状态, delta):
	match 当前状态:
		史莱姆状态.战斗:
			# 判断优里攻击
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
	pass


func increase_bar():
	if atk_speed_bar.value == atk_speed_bar.max_value:
		史莱姆攻击准备就绪 = true
	var delta = spd_value * (1 + amplifier(5))
	atk_speed_bar.value += delta


func amplifier(x=0):
	return 1-exp(-x)

	
func attack_player():
	game_manager.attack_player(atk_value)


func animation_end():
	史莱姆攻击准备就绪 = false
	史莱姆动画播放完成 = true
