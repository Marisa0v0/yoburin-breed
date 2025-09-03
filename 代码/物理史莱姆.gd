extends CharacterBody2D


@export var SPEED = 60.0

@onready var game_manager: Node = %GameManager
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimatedSprite2D/AnimationPlayer
@onready var 死亡音效: AudioStreamPlayer2D = $"死亡音效"

func _physics_process(delta: float) -> void:
	position.x -= SPEED * delta


func _on_area_2d_area_entered(area: Area2D) -> void:
	SPEED = 0
	死亡音效.playing = true
