extends Node2D

@export var start_atlas:AtlasTexture
@export var autoscroll_speed:float = 10.0
@export var vertical_scroll_scale:float = 0.04

@onready var beginning_ref:Parallax2D = $"Near Mountains"

func _ready() -> void:
	generate_water()

func generate_water() -> void:
	var atlas_width:int = int(start_atlas.region.size.x)
	var row_count:int = int(start_atlas.region.size.y)
	
	var y_offset:int = int(beginning_ref.scroll_offset.y)
	var speed_bandwidth:float = (1.0 - beginning_ref.scroll_scale.x) / float(row_count)
	
	var current_speed:float = beginning_ref.scroll_scale.x + speed_bandwidth
	
	var rng:RandomNumberGenerator = RandomNumberGenerator.new()
	
	for current_row:int in row_count:
		var current_atlas:AtlasTexture = AtlasTexture.new()
		current_atlas.atlas = start_atlas
		
		
		rng.randomize()
		var safe_random_x:int = clampi(current_row + rng.randi_range(-3, 3), 0, row_count)
		current_atlas.region.position = Vector2(0, safe_random_x)
		current_atlas.region.size = Vector2(atlas_width, 10)
		
		
		var current_parallax:Parallax2D = Parallax2D.new()
		current_parallax.name = "Water " + str(current_row)
		add_child(current_parallax)
		
		var new_sprite:Sprite2D = Sprite2D.new()
		new_sprite.texture = current_atlas
		
		current_parallax.add_child(new_sprite)
		
		current_parallax.scroll_scale = Vector2(current_speed, vertical_scroll_scale + (0.01 * float(current_row)))
		const half_reference_texture_x:int = 25
		current_parallax.scroll_offset = Vector2(0, y_offset + current_row + half_reference_texture_x)
		current_parallax.repeat_size = Vector2(atlas_width, 0)
		current_parallax.repeat_times = 6
		current_parallax.autoscroll = Vector2(current_speed * -autoscroll_speed, 0)
		
		current_speed += speed_bandwidth
