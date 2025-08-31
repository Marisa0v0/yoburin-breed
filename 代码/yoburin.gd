extends CharacterBody2D

enum 状态 {待机,攻击,受击,跑步,战败}
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var 动画播放完成 = false
@export var 是否遭遇敌人 = false
@export var 是否遭遇攻击 = false
@export var 是否开始冒险 = false
@export var 生命是否用尽 = false
#export只能显示var，不能直接显示枚举，必须把枚举赋值到一个变量里

# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	#再写油梨小游戏！
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func 获取新的状态(当前状态: 状态) -> 状态:
	match 当前状态:
		状态.待机:
			if 是否开始冒险 == true:
				return 状态.跑步
			if 是否遭遇攻击 == true:
				return 状态.受击
			if 生命是否用尽 == true:
				return 状态.战败
			return 当前状态
			#这里写因为什么切换别的状态
		状态.攻击:
			if 动画播放完成 == true:
				return 状态.待机
			if 是否开始冒险 == true:
				return 状态.跑步
			return 当前状态
			#这里写因为什么切换别的状态
		状态.受击:
			if 动画播放完成 == true:
				return 状态.待机
			return 当前状态
		状态.跑步:
			if 是否开始冒险 == false:
				return 状态.待机
			return 当前状态
			#这里写因为什么切换别的状态
		状态.战败:
			if 生命是否用尽 == false:
				return 状态.待机
			return 当前状态
			#这里写因为什么切换别的状态
		_:
			return 状态.待机

func 更改状态调用函数(上一个状态:状态, 下一个状态:状态) -> void:
	pass

func 每帧业务函数(当前状态:状态,delta):
	animated_sprite_2d.play('待机')
	print(当前状态)
	pass

func _on_animated_sprite_2d_animation_finished() -> void:
	动画播放完成 = true
	pass # Replace with function body.
