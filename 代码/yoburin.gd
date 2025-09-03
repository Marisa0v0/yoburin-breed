extends CharacterBody2D

enum 状态 {待机,战斗,攻击,受击,跑步,战败}
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var 动画播放完成 = false
@export var 是否遭遇敌人 = false
@export var 是否遭遇攻击 = false
@export var 是否开始冒险 = false
@export var 生命是否用尽 = false
@export var 攻击准备就绪 = false
@export var atk_value = 1
@export var def_value = 1
@export var hp_value = 100
@export var spd_value = 1
@onready var atk_bar: ProgressBar = $Control/atk_bar
@onready var hp_bar: ProgressBar = $Control/hp_bar

#export只能显示var，不能直接显示枚举，必须把枚举赋值到一个变量里
var dragging = false
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	#再写油梨小游戏！
	#写些什么
	if hp_bar.max_value < hp_value:
		hp_bar.max_value = hp_value
	hp_bar.value = hp_value
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func 获取新的状态(当前状态: 状态) -> 状态:
	#这里写因为什么切换别的状态
	#这里根据一系列逻辑判断应该进入哪个状态，当条件足时这个函数返回的状态就和目前状态不同，所以切换
	match 当前状态:
		状态.待机:
			if 是否遭遇敌人 == true:
				return 状态.战斗
			if hp_bar.value == hp_bar.min_value:
				return 状态.战败
			return 当前状态
		状态.战斗:
			if 是否遭遇攻击 == true:
				return 状态.受击
			if 攻击准备就绪 == true:
				return 状态.攻击
			if hp_bar.value == hp_bar.min_value:
				return 状态.战败
			return 当前状态
			
		状态.攻击:
			if 动画播放完成 == true:
				return 状态.战斗
			if 是否开始冒险 == true:
				return 状态.跑步
			return 当前状态
		状态.受击:
			if 动画播放完成 == true:
				return 状态.战斗
			if hp_bar.value == hp_bar.min_value:
				return 状态.战败
			return 当前状态
		状态.跑步:
			if 是否开始冒险 == false:
				return 状态.战斗
			if hp_bar.value == hp_bar.min_value:
				return 状态.战败
			return 当前状态

		状态.战败:
			if hp_bar.value > hp_bar.min_value:
				return 状态.战败
			return 当前状态
		_:
			return 状态.战斗

func 更改状态调用函数(上一个状态:状态, 下一个状态:状态) -> void:
	#如果在状态变更的时候要做什么就写在这里
	if 上一个状态 == 状态.受击:
		动画播放完成 = false
	if 上一个状态 == 状态.攻击 and 下一个状态 == 状态.战斗:
		动画播放完成 = false
		atk_bar.value = atk_bar.min_value
	pass

func 每帧业务函数(当前状态:状态,delta):
	#每个状态里要做什么就写这里
	if hp_bar.value > hp_bar.max_value:
		hp_bar.max_value = hp_bar.value
	match 当前状态:
		状态.待机:
			animated_sprite_2d.play('待机')
		状态.战斗:
			animated_sprite_2d.play('待机')
			increase_bar()
		状态.攻击:
			animated_sprite_2d.play('攻击')
		状态.受击:
			animated_sprite_2d.play('受击')
		状态.跑步:
			animated_sprite_2d.play('跑步')
		状态.战败:
			animated_sprite_2d.play('战败')
		_:
			animated_sprite_2d.play('待机')
	

func _on_animated_sprite_2d_animation_finished() -> void:
	动画播放完成 = true
	攻击准备就绪 = false
	pass # Replace with function body.
	
func increase_bar():
	if atk_bar.value == atk_bar.max_value:
		攻击准备就绪 = true
	var delta = spd_value * (1 + amplifier(5))
	atk_bar.value += delta
	
func amplifier(x=0):
	return 1-exp(-x)


func _on_atk_area_2d_2_area_entered(area: Area2D) -> void:
	print('test')
	是否遭遇敌人 = true
	pass # Replace with function body.
