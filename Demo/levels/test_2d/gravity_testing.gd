extends Node2D


@export var stage_bounds:Vector2 = Vector2(1000, 1000)

var bounds_body:StaticBody2D = StaticBody2D.new()

var bounds:Array[CollisionShape2D] = [
	CollisionShape2D.new(),
	CollisionShape2D.new(),
	CollisionShape2D.new(),
	CollisionShape2D.new()
]

func _ready() -> void:
	configure_bounds()

func configure_bounds() -> void:
	add_child(bounds_body)
	
	var bound_plane:WorldBoundaryShape2D = WorldBoundaryShape2D.new()
	
	#left
	bounds_body.add_child(bounds[SIDE_LEFT])
	bounds[SIDE_LEFT].position.x = -stage_bounds.x
	bound_plane.normal = Vector2.RIGHT
	bounds[SIDE_LEFT].shape = bound_plane.duplicate()
	#right
	bounds_body.add_child(bounds[SIDE_RIGHT])
	bounds[SIDE_RIGHT].position.x = stage_bounds.x
	bound_plane.normal = Vector2.LEFT
	bounds[SIDE_RIGHT].shape = bound_plane.duplicate()
	#up
	bounds_body.add_child(bounds[SIDE_TOP])
	bounds[SIDE_TOP].position.y = -stage_bounds.y
	bound_plane.normal = Vector2.DOWN
	bounds[SIDE_TOP].shape = bound_plane.duplicate()
	#down
	bounds_body.add_child(bounds[SIDE_BOTTOM])
	bounds[SIDE_BOTTOM].position.y = stage_bounds.y
	bound_plane.normal = Vector2.UP
	bounds[SIDE_BOTTOM].shape = bound_plane.duplicate()
