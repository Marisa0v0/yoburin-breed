extends Node
#
## 唯一玩家 - 优里
#@onready var player = get_tree().get_nodes_in_group("Player")[0]
## 所有怪物父节点
#@onready var monster =get_node("../主场景/Creature/Monster")
#
#func animated_end():
#	# 攻击动画完成
#	atk_speed_bar.value = atk_speed_bar.min_value
#
#func attack_player(monster_atk_int:int = 1):
#	# 怪物攻击玩家
#	# 伤害 = 攻 - 防
#	if monster_atk_int - player.def_value == 0:
#		player.hp_value -= 1
#	else:
#		player.hp_value -= monster_atk_int - player.def_value
#		health_bar.value = player.hp_value
