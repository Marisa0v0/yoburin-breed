class_name HitBox
extends Area2D
## 攻击判定

## 攻击区域接触到受击区域时发出信号
signal hit(hurtbox: HurtBox)


## 内置函数
func _init() -> void:
	area_entered.connect(_on_area_entered)


## 功能函数
## 攻击区域接触到受击区域时发出信号
func _on_area_entered(hurtbox: HurtBox) -> void:
	self.hit.emit(hurtbox)
	hurtbox.hurt.emit(self)
