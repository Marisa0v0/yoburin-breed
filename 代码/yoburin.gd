# 唯一玩家 - 优里
extends CharacterBody2D
class_name Yoburin

@onready var Gamemanager = %GameManager

# 控制优里行为
enum 优里状态 {待机,战斗,攻击,受击,跑步,战败}
# 优里立绘
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var 动画播放完成 = false
@export var 是否遭遇敌人 = false
@export var 是否遭遇攻击 = false
@export var 是否开始冒险 = false
@export var 生命是否用尽 = false
@export var 优里攻击准备就绪 = false
# 攻防血速
@export var atk_value = 1
@export var def_value = 1
@export var hp_value = 100
@export var spd_value = 1


func _ready() -> void:
	pass # Replace with function body.


func 获取新的状态(当前状态: 优里状态) -> 优里状态:
	# 这里写因为什么切换别的状态
	# 这里根据一系列逻辑判断应该进入哪个状态，当条件足时这个函数返回的状态就和目前状态不同，所以切换
	match 当前状态:
		优里状态.待机:  # 初始状态
			if 是否遭遇敌人 == true:
				return 优里状态.战斗
			return 当前状态
			
		优里状态.战斗:
			if 是否遭遇攻击 == true:
				return 优里状态.受击
			if 优里攻击准备就绪 == true:
				return 优里状态.攻击
			return 当前状态
			
		优里状态.攻击:
			if 动画播放完成 == true:
				return 优里状态.战斗
			if 是否开始冒险 == true and 是否遭遇敌人 == false:
				return 优里状态.跑步
			return 当前状态
			
		优里状态.受击:
			if 动画播放完成 == true:
				return 优里状态.战斗
			return 当前状态
			
		优里状态.跑步:
			if 是否开始冒险 == false:
				return 优里状态.战斗
			return 当前状态

		优里状态.战败:
			return 当前状态
			
		_:
			return 优里状态.待机

func 更改状态调用函数(上一个状态:优里状态, 下一个状态:优里状态) -> void:
	# 如果在状态变更的时候要做什么就写在这里
	if 上一个状态 == 优里状态.受击:
		动画播放完成 = false
	if 上一个状态 == 优里状态.攻击 and 下一个状态 == 优里状态.战斗:
		动画播放完成 = false
	pass

func 每帧业务函数(当前状态:优里状态,delta):
	# 每个状态里要做什么就写这里
	match 当前状态:
		优里状态.待机:
			animated_sprite_2d.play('待机')
		优里状态.战斗:
			animated_sprite_2d.play('待机')
			Gamemanager.increase_bar()
		优里状态.攻击:
			animated_sprite_2d.play('攻击')
		优里状态.受击:
			animated_sprite_2d.play('受击')
		优里状态.跑步:
			animated_sprite_2d.play('跑步')
		优里状态.战败:
			animated_sprite_2d.play('战败')
		_:
			animated_sprite_2d.play('待机')
	

func _on_animated_sprite_2d_animation_finished() -> void:
	动画播放完成 = true
	优里攻击准备就绪 = false
	Gamemanager.animated_end()
