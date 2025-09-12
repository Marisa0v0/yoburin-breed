class_name MarisaMonster
extends MarisaCreature
## 怪物基类

## 怪物独有基本属性
@onready var target_player: MarisaPlayer


## 内置函数
## 类初始化
func _init() -> void:
	super._init()
	self.logger.debug("初始化 Monster 类实例 %s" % self.to_string())


## 该节点的所有子节点初始化后才初始化
func _ready() -> void:
	super._ready()
	self.logger.debug("Monster 类准备完毕")
	self.move_speed = -50.0  ## 怪物向左移动


## 怪物碰撞箱接触到玩家的攻击范围后触发战斗
func _on_area_2d_area_entered(area: Area2D) -> void:
	self.in_battle_position = true
