class_name MarisaSlime
extends MarisaMonster
## 怪物 - 史莱姆

## 内置函数
## 类初始化
func _init() -> void:
	super._init()
	print_debug("初始化 Slime 类实例 %s" % self.to_string())

## 该节点的所有子节点初始化后才初始化
func _ready() -> void:
	super._ready()
	print_debug("Slime 类准备完毕")

## 隐式调用
func attack_player(monster_atk_int: int = 1):
	# godot的动画机可以自己在特定帧调用函数，实现很方便的效果，这里直接在动画里和攻击动画同时调用攻击函数
	# 就可以做到动画播放的同时攻击，不用对轴什么的了
#	GlobalGameManager.attack_player(atk_value)
	print(self.to_string() + " | 攻击！")
