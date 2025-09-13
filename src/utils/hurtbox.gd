class_name HurtBox
extends Area2D
## 受击判定

## 攻击区域接触到受击区域时发出信号
signal hurt(hitbox: HitBox)
## 本生物死亡时发出信号
signal killed(hitbox: HitBox)
