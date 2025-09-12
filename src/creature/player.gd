class_name MarisaPlayer
extends MarisaCreature
## 玩家基类

## 玩家独有基本属性
## 按顺序将要与玩家作战的怪物
@onready var enemies_in_battle: Array[MarisaMonster] = []#


## 内置函数
## 类初始化
func _init() -> void:
	super._init()
	self.logger.debug("初始化 Player 类实例 %s" % self.to_string())


## 该节点的所有子节点初始化后才初始化
func _ready() -> void:
	super._ready()
	self.logger.debug("Player 类准备完毕")
