class_name AnimatedNumber
extends Label

@export var duration := 1.0 #动画速度
@export var start_value := 0.0 #起始值
@export var default_color := Color.WHITE #数字无变化时的颜色，常态显示
@export var increasing_color := Color.GREEN #数字增加时播放的颜色
@export var decreasing_color := Color.RED #数字减少时的颜色

## 实际存储的数据
var real_value := 0.0: 
	set = _set_real_value

func _set_real_value(value: float) -> void:
	if real_value == value: #传入的变量和之前一样就什么都不发生
		return
	real_value = value
	_show_animation()

	
## 显示用的假数据
var _fake_value := 0.0: 
	set = _set_fake_value

func _set_fake_value(value: float) -> void:
	_fake_value = value
	self.text = "%06.0f" % _fake_value

	
var _tween: Tween


func _ready() -> void:
	self._fake_value = self.start_value


## 如果有特殊需求要在数字更改时不触发动画就用这个
func set_immediate(value: float) -> void: 
	self.real_value = value
	self._fake_value = value
	self.text = str(value)
	self.self_modulate = self.default_color
	

func _show_animation() -> void:
	if self._tween and self._tween.is_valid():
		self._tween.kill()

	## 通过判断当前值和补差值的差，判断是增还是减，从而采用不同的颜色
	self.self_modulate = self.increasing_color if self.real_value > self._fake_value else self.decreasing_color 
	## 创建一个动画，并确认差值渲染动效的逻辑
	self._tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE) 
	## 把结果向目标用动画的方式增或减，然后调用_set_fake_value方法 
	self._tween.tween_property(self, "_fake_value", self.real_value, self.duration) 
	## 奇怪的隐式调用？写法 在所有动画结束后把字体颜色设置成默认值
	self._tween.finished.connect(func(): self.self_modulate = self.default_color)
