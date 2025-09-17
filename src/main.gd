class_name MainWindow
extends Node2D
## 游戏主窗口
## 此处放置全局逻辑、可视化 UI 等

var dragging := false

@onready var node_creatures: Node = $生物组
## 接收 B 站发给 Python 客户端处理后发来的信息
@onready var ws_server: WebsocketServer = $网络通信服务器
@onready var 刷怪倒计时: Timer = $刷怪倒计时


## 场景
const scene_green_slime := preload("res://scene/creature/slime.tscn")
const scene_yoburin     := preload("res://scene/creature/yoburin.tscn")
const scene_purple_slime := preload("uid://dufno5oycana6")

## 怪物枚举
enum Monster { green_slime , purple_slime }

@onready var background: Sprite2D = $图形界面/背景图



## 内置函数
## 该节点的所有子节点初始化后才初始化
func _ready() -> void:
	# 窗口初始化
	Log.debug("主窗口准备完毕")
	get_viewport().transparent_bg = true
	
	## 启动网络通信
	self.ws_server.start_server()

	## 动态实例化
	var yoburin: Yoburin = scene_yoburin.instantiate()
	Log.debug("优里位置：%s, %s" % [yoburin.position.x, yoburin.position.y])
	self.node_creatures.add_child(yoburin)
	## 实例化进度条
	# self.bar_health_point.max_value = yoburin.health_point
	# self.bar_health_point.value = self.bar_health_point.max_value

	# self.bar_attack_ready.value = yoburin.bar_attack_ready.min_value

	## 覆写玩家（优布林）进度条
	# yoburin.bar_health_point = self.bar_health_point
	# yoburin.bar_attack_ready = self.bar_attack_ready
	
## 接收输入事件
func _input(event):
	# 实现拖动窗口
	if event is InputEventMouseButton:
		dragging = (event.button_index == MOUSE_BUTTON_RIGHT and event.pressed)

	if event is InputEventMouseMotion and dragging:
		# 鼠标右键拖动窗口
		var current_position := get_window().position
		var new_position     := current_position + Vector2i(event.relative)
		get_window().set_position(new_position)

	## FIXME 测试用
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_E:
			#var slime: MarisaSlime = scene_green_slime.instantiate()
			#self.node_creatures.add_child(slime)
			#slime.position = Vector2(576, 302.0)
			#Log.debug("史莱姆位置：%s, %s" % [slime.position.x, slime.position.y])
			add_monster()
			
		if event.keycode == KEY_G:
			var yoburin: Yoburin = get_node("生物组/优布林")
			var default_data: Dictionary = {
				"health_point": yoburin.health_point,
				"attack_speed": yoburin.attack_speed,
				"attack_point": yoburin.attack_point,
				"defence_point": yoburin.defence_point
			}
			yoburin.save_data(default_data)
		

func add_monster_timer() -> void:#生成怪物倒计时，按本地的实际时间流动进行生成
	Log.debug("计时器成功启动")
	if get_tree().get_nodes_in_group("monster_list").is_empty():
		add_monster()
	pass
	
func add_monster() -> void:#生成怪物，根据随机数与枚举决定生成哪一个
	var random_int := RandomNumberGenerator.new().randi_range(0,1)
	var monster_position := Vector2(576, 302.0)
	var monster
	
	match random_int:
		Monster.green_slime:
			monster = scene_green_slime.instantiate()
			self.node_creatures.add_child(monster)
			monster.position = Vector2(576, 302.0)
			Log.debug("怪物位置：%s, %s" % [monster.position.x, monster.position.y])
		Monster.purple_slime:
			monster = scene_purple_slime.instantiate()
			self.node_creatures.add_child(monster)
			monster.position = Vector2(576, 302.0)
			Log.debug("怪物位置：%s, %s" % [monster.position.x, monster.position.y])
		_:
			pass
		
	monster.add_to_group("monster_list")#将生成的怪物加入怪物列表，用来让倒计时判断结束后是否生成怪物，如果怪物列表里还有东西就不生成
