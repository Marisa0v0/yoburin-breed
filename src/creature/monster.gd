class_name MarisaMonster
extends MarisaCreature
## 怪物基类

## 怪物独有基本属性

## 内置函数
## 类初始化
func _init() -> void:
	## 初始化 UI 相关
	print_debug("初始化 Monster 类")
	self.move_speed = -1.0  ## 怪物向左移动

## 该节点的所有子节点初始化后才初始化
func _ready() -> void:
	pass

## 每帧调用一次
func _process(delta: float) -> void:
	pass
	
## 碰撞箱重叠时准备战斗，停止移动
func _on_area_2d_area_entered(area: Area2D) -> void:
	self.is_in_battle = true
	self.move_speed = 0.0
	
## 业务函数
## 以状态机作为核心逻辑
func update_status(current_status: Status) -> Status:
	## TODO
	pass
