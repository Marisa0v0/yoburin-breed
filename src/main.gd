class_name MainWindow
extends Node2D
## 游戏主窗口

var dragging := false

@onready var test_yoburin: Yoburin = $"生物组/优布林"  ## FIXME 测试用
@onready var bar_health_point: ProgressBar = $"图形界面/玩家生命值进度条"
@onready var bar_attack_ready: ProgressBar = $"图形界面/玩家攻击进度条"

## 内置函数
## 该节点的所有子节点初始化后才初始化
func _ready() -> void:
	# 窗口初始化
	print_debug("主窗口准备完毕")
	get_viewport().transparent_bg = true
	
	## TODO 动态实例化生物
	# var yoburin := Yoburin.new()
	# add_sibling(yoburin)
	
	## 实例化进度条
	self.bar_health_point.max_value = self.test_yoburin.health_point
	self.bar_health_point.value = self.bar_health_point.max_value
	
	self.bar_attack_ready.value = self.test_yoburin.bar_attack_ready.min_value
	
	## 覆写玩家（优布林）进度条
	self.test_yoburin.bar_health_point = self.bar_health_point
	self.test_yoburin.bar_attack_ready = self.bar_attack_ready
	
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
		var new_position = current_position + Vector2i(event.relative)
		get_window().set_position(new_position)
		Window
		
