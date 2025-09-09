@icon("res://resource/yoburin/待机1.png")
class_name Yoburin
extends MarisaPlayer
## 当前唯一玩家 - 优里

## 优里立绘
@onready var animated_sprite_2d: AnimatedSprite2D = $"动画立绘"

## 内置函数
## 类初始化
func _init() -> void:
	super._init()
	print_debug("初始化优里类实例 %s" % self.to_string())

## 该节点的所有子节点初始化后才初始化
func _ready() -> void:
	super._ready()
	print_debug("优里类准备完毕")

func _on_animation_finished() -> void:
	print_debug("优里动画结束啦")
	self.animation_attack_end = true		## TODO ? 好像不用分开两种动画
	self.animation_be_attacked_end = true	## TODO ? 好像不用分开两种动画
	
	self.can_attack = false  		  ## TODO ? 干嘛用的
#	GlobalGameManager.animated_end()  ## TODO ? 干嘛用的

## 业务函数
## 每帧动作
func action(current_state: Status, delta: float) -> void:
	match current_state:
		Status.Idle:
			self.animated_sprite_2d.play("闲置动画")
			self.bar_attack_ready_increase()
		Status.Attack:
			self.animated_sprite_2d.play("攻击动画")
		Status.BeAttacked:
			self.animated_sprite_2d.play("受击")
		Status.Move:
			self.animated_sprite_2d.play("跑步")
		Status.BeDefeated:
			self.animated_sprite_2d.play("战败动画")
		_:  ## falback
			self.animated_sprite_2d.play("闲置动画")
