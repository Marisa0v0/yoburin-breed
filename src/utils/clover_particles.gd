class_name CloverParticles
extends GPUParticles2D

func _ready():
	# 设置粒子系统
	emitting = true
	one_shot = false
	amount = 50
	lifetime = 3.0
	preprocess = 1.0
	
	# 设置绘制参数
	draw_order = DRAW_ORDER_INDEX
	
	# 设置粒子行为
	explosiveness = 0
	randomness = 0.2
	
	# 设置方向 - 从左上到右下
	direction = Vector2(1, 1)
	spread = 45
	
	# 设置初始速度
	initial_velocity_min = 100
	initial_velocity_max = 200
	
	# 设置重力（向下拉的效果）
	gravity = Vector2(50, 100)
	
	# 设置大小和旋转
	scale_amount_min = 0.2
	scale_amount_max = 0.5
	angle_min = 0
	angle_max = 360
	
	# 设置颜色
	color = Color(1, 1, 1, 1)
	
	# 设置发射区域 - 从左上角
	emission_shape = ParticlesMaterial.EMISSION_SHAPE_BOX
	emission_box_extents = Vector2(100, 50)
