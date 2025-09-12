class_name MainWindow
extends Node2D
## 游戏主窗口

var dragging := false

@onready var bar_health_point: ProgressBar = $"图形界面/玩家生命值进度条"
@onready var bar_attack_ready: ProgressBar = $"图形界面/玩家攻击进度条"
@onready var node_creatures: Node = $生物组
## 场景
const scene_slime   = preload("res://scene/creature/slime.tscn")
const scene_yoburin = preload("res://scene/creature/yoburin.tscn")


## 内置函数
## 该节点的所有子节点初始化后才初始化
func _ready() -> void:
	# 窗口初始化
	Log.debug("主窗口准备完毕")
	get_viewport().transparent_bg = true

	## 动态实例化
	var yoburin: Yoburin = scene_yoburin.instantiate()
	self.node_creatures.add_child(yoburin)
	## 实例化进度条
	self.bar_health_point.max_value = yoburin.health_point
	self.bar_health_point.value = self.bar_health_point.max_value

	self.bar_attack_ready.value = yoburin.bar_attack_ready.min_value

	## 覆写玩家（优布林）进度条
	yoburin.bar_health_point = self.bar_health_point
	yoburin.bar_attack_ready = self.bar_attack_ready


## 接收输入事件
func _input(event):
	# 实现拖动窗口
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			dragging = true
		else:
			dragging = false

	if event is InputEventMouseMotion and dragging:
		# 鼠标右键拖动窗口
		var current_position = get_window().position
		var new_position     = current_position + Vector2i(event.relative)
		get_window().set_position(new_position)

	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_E:
			var slime: MarisaSlime = scene_slime.instantiate()
			self.node_creatures.add_child(slime)
			slime.position = Vector2(576, -128.0)
		
