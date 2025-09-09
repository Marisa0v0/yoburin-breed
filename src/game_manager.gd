# 全局处理
extends Node

## 唯一玩家 - 优里
#@onready var player = %Player/Yoburin#用不着这么复杂，直接%yoburin就能访问到了，唯一名称就是干这个的！！那就去掉yoburin的百分号【
## 所有怪物父节点
#@onready var monster =%Monster
## 
#@onready var atk_int: Label = %atk_int
##
#@onready var def_int: Label = %def_int
## 进度条 - 生命值
#@onready var health_bar: ProgressBar = %health_bar
## 进度条 - 攻击
#@onready var atk_speed_bar: ProgressBar = %atk_speed_bar
#
#func _ready() -> void:
	## 初始化生命条 UI
	#await owner.ready
	#health_bar.max_value = player.hp_value
	#health_bar.value = health_bar.max_value
#
#func amplifier(x=0):
	## TODO 礼物与攻击条增长速度挂钩
	#return 1-exp(-x)
#
#func increase_bar():
	## 攻击条自动增长
	#if atk_speed_bar.value == atk_speed_bar.max_value:
		#player.优里攻击准备就绪 = true
	#var delta = player.spd_value * (1 + amplifier(5))
	#atk_speed_bar.value += delta
#
#func animated_end():
	## 攻击动画完成
	#atk_speed_bar.value = atk_speed_bar.min_value
#
#func attack_player(monster_atk_int:int = 1):
	## 怪物攻击玩家
	## 伤害 = 攻 - 防
	#if monster_atk_int - player.def_value == 0:
		#player.hp_value -= 1
	#else:
		#player.hp_value -= monster_atk_int - player.def_value
		#health_bar.value = player.hp_value
