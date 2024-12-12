@tool
extends Path2D

class_name Slopeinator

@export_group("Editor", "editor_")
@export var editor_realtime_update:bool = false
@export var editor_draw_collision:bool = true:
	set(on):
		editor_draw_collision = on
		queue_redraw()
@export var editor_draw_texture:bool = true:
	set(on):
		editor_draw_texture = on
		queue_redraw()
@export var editor_collision_color:PackedColorArray = [Color8(52, 255, 255, 157)]:
	set(on):
		editor_collision_color = on
		queue_redraw()

@export_group("Floor", "floor_")
@export var floor_texture:Texture2D = Texture2D.new():
	set(new_val):
		floor_texture = new_val
		queue_redraw()
@export var floor_x_overlap_threshold:float = 0.5:
	set(new_thresh):
		floor_x_overlap_threshold = new_thresh
		generate_slope()
@export var floor_snap_x:bool = true:
	set(new_snap):
		floor_snap_x = new_snap
		generate_slope()
@export var floor_snap_y:bool = false:
	set(new_snap):
		floor_snap_y = new_snap
		generate_slope()

@export_group("Collision", "collision_")
@export_flags_2d_physics var collision_mask:int = 1
@export_flags_2d_physics var collision_layer:int = 1
@export var collision_point_interval:int = 10:
	set(new_interval):
		if collision_point_interval != new_interval:
			generate_slope()
		collision_point_interval = maxi(new_interval, 1) #it gets sketch if you move it lower than 1

@export_storage var poly_count:int

@export_storage var collision_polygon_array:PackedVector2Array
@export_storage var visual_polygon_array:PackedVector2Array

@export_storage var atlas_cut_size:Vector2
@export_storage var atlas_slice_count:int

##the count of vertical slices of the floor texture to draw.
@export_storage var length_slice_count:int
var slope_width:float 

var collision_node:CollisionPolygon2D = CollisionPolygon2D.new()

var canvas_rid:RID

var collision_body_rid:RID
var collision_shape_rid:RID

func _ready() -> void:
	if Engine.is_editor_hint():
		curve.connect(&"changed", generate_slope)
	
	collision_body_rid = PhysicsServer2D.body_create()
	collision_shape_rid = PhysicsServer2D.convex_polygon_shape_create()
	
	#PhysicsServer2D.body_set_mode(collision_body_rid, PhysicsServer2D.BODY_MODE_STATIC)
	#PhysicsServer2D.body_set_collision_layer(collision_body_rid, collision_layer)
	#PhysicsServer2D.body_set_collision_mask(collision_body_rid, collision_mask)
	#PhysicsServer2D.body_add_shape(collision_body_rid, collision_shape_rid)
	#PhysicsServer2D.body_set_space(collision_body_rid, get_world_2d().space)
	
	var body:StaticBody2D = StaticBody2D.new()
	add_child(body)
	body.add_child(collision_node)
	
	canvas_rid = RenderingServer.canvas_item_create()
	RenderingServer.canvas_item_set_parent(canvas_rid, get_canvas())
	
	generate_slope()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		RenderingServer.free_rid(canvas_rid)
		
		PhysicsServer2D.free_rid(collision_shape_rid)
		PhysicsServer2D.free_rid(collision_body_rid)

func _draw() -> void:
	RenderingServer.canvas_item_clear(canvas_rid)
	if Engine.is_editor_hint():
		if editor_draw_collision:
			var drawn_array:PackedVector2Array = collision_polygon_array.duplicate()
			for units:int in drawn_array.size():
				drawn_array[units] += global_position
			RenderingServer.canvas_item_add_polygon(canvas_rid, drawn_array, editor_collision_color)
		if editor_draw_texture:
			draw_slope()
	else:
		draw_slope()

func generate_slope() -> void:
	generate_collision_slope()
	generate_visual_slope()

func generate_collision_slope() -> void:
	atlas_slice_count = floor_texture.get_width()
	atlas_cut_size = Vector2(1, floor_texture.get_height())
	
	var bottom_y:float
	var left_x:float
	var right_x:float
	
	var collision_curve:Curve2D = curve.duplicate()
	collision_curve.bake_interval = collision_point_interval
	
	collision_polygon_array = collision_curve.get_baked_points()
	collision_polygon_array.sort() #sorts by x; this array is sorted left to right
	
	poly_count = collision_polygon_array.size()
	collision_polygon_array = collision_polygon_array.duplicate()
	
	var slope_point:Vector2
	for slope_point_index:int in poly_count:
		slope_point = collision_polygon_array[slope_point_index]
		left_x = minf(slope_point.x, left_x)
		right_x = maxf(slope_point.x, right_x)
		bottom_y = maxf(slope_point.y, bottom_y)
	
	#add a bottom right corner
	collision_polygon_array.append(Vector2(right_x, bottom_y + 1))
	#add a bottom left corner
	collision_polygon_array.append(Vector2(left_x, bottom_y + 1))
	
	#PhysicsServer2D.shape_set_data(collision_shape_rid, collision_polygon_array)
	#PhysicsServer2D.body_set_shape_transform(collision_body_rid, 0, transform)
	collision_node.polygon = collision_polygon_array
	
	slope_width = absf(left_x) + absf(right_x)
	length_slice_count = int(slope_width)


func generate_visual_slope() -> void:
	var visual_curve:Curve2D = curve.duplicate()
	visual_curve.bake_interval = 1
	var in_visual_polygon_array:PackedVector2Array = visual_curve.get_baked_points()
	in_visual_polygon_array.sort()
	
	var actual_length:float = visual_curve.get_baked_length()
	var length_slice_countf:float = slope_width
	
	visual_polygon_array.resize(in_visual_polygon_array.size() + 2)
	
	#get the x length and snap it to the nearest pixel
	var prev_point:Vector2
	var current_point:Vector2
	
	
	#the "0th" iteration of the loop
	if true:
		current_point = in_visual_polygon_array[0]
		
		var snapped_point_index:int = visual_curve.get_closest_offset(current_point.round())
		var snapped_point:Vector2 = visual_curve.sample_baked(snapped_point_index, floor_x_overlap_threshold)
		
		current_point = snapped_point
		
		if floor_snap_x:
			current_point.x = roundf(current_point.x)
		if floor_snap_y:
			current_point.y = roundf(current_point.y)
		
		visual_polygon_array[0] = current_point
		
		prev_point = current_point
		
		prev_point = current_point
	
	for slope_point_index:int in range(1, in_visual_polygon_array.size()):
		current_point = in_visual_polygon_array[slope_point_index].round()
		current_point.x = slope_point_index
		
		
		
		var pixel_gap:float = current_point.distance_to(prev_point)
		
		if pixel_gap > 0.4:
			printt("Gap between ", prev_point,"and", current_point, "is", pixel_gap)
			#to prevent intermittent line breaking, we "walk back" the x value when it floats off
			current_point.x -= pixel_gap
			current_point.x += 1
			
			current_point = visual_curve.get_closest_point(current_point)
		elif pixel_gap < 1.0:
			current_point.x += 1
			current_point = visual_curve.get_closest_point(current_point)
		
		if floor_snap_x:
			current_point.x = roundf(current_point.x)
		if floor_snap_y:
			current_point.y = roundf(current_point.y)
		
		visual_polygon_array[slope_point_index] = current_point
		
		prev_point = current_point
	
	
	
	queue_redraw()

func draw_slope() -> void:
	if not scale.is_equal_approx(Vector2.ONE):
		push_warning("Scale on Slope-inator ", name, " is not 1, this will cause the floor to not draw properly.")
	
	var source_atlas:Rect2 = Rect2(Vector2.ZERO, atlas_cut_size)
	source_atlas.size = atlas_cut_size
	var texture_x_index:int = 0
	
	var slice_position:Vector2
	var texture_atlas:Rect2
	for x_pix:int in visual_polygon_array.size():
		slice_position = visual_polygon_array[x_pix] + global_position
		
		source_atlas.position.x = texture_x_index
		texture_atlas = Rect2(slice_position, atlas_cut_size)
		
		floor_texture.draw_rect_region(canvas_rid, texture_atlas, source_atlas)
		
		texture_x_index = wrapi(texture_x_index + 1, 0, floor_texture.get_width())
