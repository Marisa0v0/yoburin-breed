extends CharacterBody2D
class_name Yoburin

enum 优里状态 {待机,战斗,攻击,受击,跑步,战败}#其实我自己也忍不住了，但是懒得改
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var 动画播放完成 = false
@export var 是否遭遇敌人 = false
@export var 是否遭遇攻击 = false
@export var 是否开始冒险 = false
@export var 生命是否用尽 = false
@export var 优里攻击准备就绪 = false
@export var atk_value = 1
@export var def_value = 1
@export var hp_value = 100
@export var spd_value = 1
@onready var Gamemanager = %GameManager

#export只能显示var，不能直接显示枚举，必须把枚举赋值到一个变量里
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	#再写油梨小游戏！
	#写些什么
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func 获取新的状态(当前状态: 优里状态) -> 优里状态:
	#这里写因为什么切换别的状态
	#这里根据一系列逻辑判断应该进入哪个状态，当条件足时这个函数返回的状态就和目前状态不同，所以切换
	match 当前状态:
		优里状态.待机:
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
	#如果在状态变更的时候要做什么就写在这里
	if 上一个状态 == 优里状态.受击:
		动画播放完成 = false
	if 上一个状态 == 优里状态.攻击 and 下一个状态 == 优里状态.战斗:
		动画播放完成 = false
	pass

func 每帧业务函数(当前状态:优里状态,delta):
	#每个状态里要做什么就写这里
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
	pass # Replace with function body.

func _on_atk_area_2d_area_entered(area: Area2D) -> void:
	是否遭遇敌人 = true
	pass # Replace with function body.
