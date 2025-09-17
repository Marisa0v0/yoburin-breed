extends Label
class_name AnimatedNumber
@export var duration: float = 1.0 #动画速度
@export var start_value: int = 0 #起始值
@export var default_color: Color = Color.WHITE #数字无变化时的颜色，常态显示
@export var increasing_color: Color = Color.GREEN #数字增加时播放的颜色
@export var decreasing_color: Color = Color.RED #数字减少时的颜色

var real_value: int = 0: set = _set_real_value
var _fake_value: int = 0: set = _set_fake_value
var _tween: Tween

func _ready() -> void:
	_fake_value = start_value

func set_immediate(value: int) -> void: #如果有特殊需求要在数字更改时不触发动画就用这个
	real_value = value
	_fake_value = value
	text = str(value)
	self.self_modulate = default_color

func _set_real_value(value: int) -> void:
	if real_value == value: #传入的变量和之前一样就什么都不发生
		return
	real_value = value
	_show_animation()

func _set_fake_value(value: int) -> void: #在label标签的text上渲染结果
	_fake_value = value
	text = str(_fake_value)

func _show_animation() -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	self.self_modulate = increasing_color if real_value > _fake_value else decreasing_color #通过判断当前值和补差值的差，判断是增还是减，从而采用不同的颜色
	_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE) #创建一个动画，并确认差值渲染动效的逻辑
	_tween.tween_property(self, "_fake_value", real_value, duration) #把结果向目标用动画的方式增或减，然后调用_set_fake_value方法
	_tween.finished.connect(func(): self.self_modulate = default_color)#奇怪的隐式调用？写法 在所有动画结束后把字体颜色设置成默认值
