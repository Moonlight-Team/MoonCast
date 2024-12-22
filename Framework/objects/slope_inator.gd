@tool
extends Path2D
##A node that can generate a slope, featuring aligned textures and collision, from
## [Curve2D].
class_name Slopeinator

#Note from c08o: Special thanks to my friend Alex for helping me brainstorm
#algorithms for the textures

#TODO: Cache generated arrays so that runtime does not have computation wait times
#for simply loading in

@export_group("Editor", "editor_")
##If true, collision will be shown in the editor. 
##This value does not affect it being visible in-game.
@export var editor_show_collision:bool = true:
	set(on):
		editor_show_collision = on
		
		if collision_canvas_rid.is_valid():
			if on:
				RenderingServer.canvas_item_set_canvas_group_mode(collision_canvas_rid, RenderingServer.CANVAS_GROUP_MODE_CLIP_AND_DRAW)
				generate_collision_slope()
			else:
				RenderingServer.canvas_item_set_canvas_group_mode(collision_canvas_rid, RenderingServer.CANVAS_GROUP_MODE_CLIP_ONLY)
		else:
			if on:
				load_collision_slope()
		
		queue_redraw()
##If true, the texturing for the slope will be shown in the editor. 
##This value does not affect it being visible in-game.
@export var editor_show_textures:bool = true:
	set(on):
		editor_show_textures = on
		if on:
			generate_visual_slope()
		queue_redraw()

@export_group("Floor", "floor_")
##The value for the floor texture. This texture will be aligned to and repeated 
##along the edge of the slope.
@export var floor_texture:Texture2D = null:
	set(new_val):
		floor_texture = new_val
		#The floor margin CANNOT be 0 if there is no texture!
		if not is_instance_valid(floor_texture):
			collision_bottom_margin = maxi(collision_bottom_margin, 1)
		draw_visual_slope()
		queue_redraw()
##The self-modulation (tint) of the floor texture.
@export var floor_self_modulate:Color = Color.WHITE:
	set(new_color):
		floor_self_modulate = new_color
		draw_visual_slope()
		queue_redraw()
##Snap each column of the floor texture to the nearest integer. 
##Enable this to get a more "retro-authentic" looking slope.
@export var floor_snap_x:bool = true:
	set(new_snap):
		floor_snap_x = new_snap
		generate_visual_slope()
##Snap the y offset of each column of the floor texture to the nearest integer. 
##Enable this to get a more "retro-authentic" looking slope.
@export var floor_snap_y:bool = false:
	set(new_snap):
		floor_snap_y = new_snap
		generate_visual_slope()

@export_group("Background", "background_")
##The texture for the "background" of the slope. This tiles and fills the space 
##of the collision area.
@export var background_texture:Texture2D = null:
	set(new_texture):
		background_texture = new_texture
		draw_visual_slope()
		queue_redraw()
##The self-modulation applied to the background texture.
@export var background_self_modulate:Color = Color.WHITE:
	set(new_color):
		background_self_modulate = new_color
		draw_visual_slope()
		queue_redraw()
##If the center of the background texture's nine-patch will render.
@export var background_draw_center:bool = true:
	set(new_val):
		background_draw_center = new_val
		draw_visual_slope()
		queue_redraw()
##The top and left margins defining the background texture's nine-patch rectangle.
@export var background_margin_top_left:Vector2i:
	set(new_pos):
		background_margin_top_left = new_pos
		draw_visual_slope()
		queue_redraw()
##The bottom and right margins defining the background texture's nine-patch rectangle.
@export var background_margin_bottom_right:Vector2i:
	set(new_pos):
		background_margin_bottom_right = new_pos
		draw_visual_slope()
		queue_redraw()

@export_group("Collision", "collision_")
##The collision mask of the slope.
@export_flags_2d_physics var collision_mask:int = 1:
	set(new_mask):
		if collision_body_rid.is_valid():
			PhysicsServer2D.body_set_collision_mask(collision_body_rid, new_mask)
	get():
		if collision_body_rid.is_valid():
			return PhysicsServer2D.body_get_collision_mask(collision_body_rid)
		else:
			return 1
##The collision layer of the slope.
@export_flags_2d_physics var collision_layer:int = 1:
	set(new_layer):
		if collision_body_rid.is_valid():
			PhysicsServer2D.body_set_collision_layer(collision_body_rid, new_layer)
	get():
		if collision_body_rid.is_valid():
			return PhysicsServer2D.body_get_collision_layer(collision_body_rid)
		else:
			return 1
##The [PhysicsMaterial] for this body.
@export var collision_physics_material:PhysicsMaterial = PhysicsMaterial.new():
	set(new_material):
		collision_physics_material = new_material
		if is_instance_valid(new_material) and collision_body_rid.is_valid():
			PhysicsServer2D.body_set_param(collision_body_rid, PhysicsServer2D.BODY_PARAM_BOUNCE, new_material.bounce)
			PhysicsServer2D.body_set_param(collision_body_rid, PhysicsServer2D.BODY_PARAM_FRICTION, new_material.friction)

##The bake interval of collision points in the geometric shape for the slope. 
##Set this lower if you are running into performance issues, and higher if you 
##are running into instances where the slope's floor texture does not match up 
##with the collision.
@export var collision_point_interval:int = 10:
	set(new_interval):
		collision_point_interval = maxi(new_interval, 1) #it gets sketch if you move it lower than 1
		if collision_point_interval != new_interval:
			generate_collision_slope()
@export var collision_bottom_margin:int = 1:
	set(new_margin):
		if is_instance_valid(floor_texture):
			collision_bottom_margin = maxi(0, new_margin)
		else:
			collision_bottom_margin = maxi(1, new_margin)
		generate_collision_slope()

var collision_count:int

@export_storage var collision_polygon_array:PackedVector2Array
@export_storage var visual_polygon_array:PackedVector2Array

var top_y:float
var left_x:float
var right_x:float
var bottom_y:float

var curve_rect:Rect2i

##RID of the floor texture canvas item.
var floor_canvas_rid:RID
##RID of the collision canvas item. This is using as a clipping mask for the 
##background texture.
var collision_canvas_rid:RID
##RID of the background texture canvas item.
var background_canvas_rid:RID

var collision_body_rid:RID
var collision_shape_rids:Array[RID] = []

func _init() -> void:
	#TODO: Update delay to reduce real-time update lag by updating less
	#wait for changes to NOT happen for a second or two, *then* update
	curve.connect(&"changed", generate_all_slopes)
	
	set_notify_transform(true)
	set_notify_local_transform(true)
	
	collision_body_rid = PhysicsServer2D.body_create()
	PhysicsServer2D.body_attach_object_instance_id(collision_body_rid, get_instance_id())
	
	floor_canvas_rid = RenderingServer.canvas_item_create()
	collision_canvas_rid = RenderingServer.canvas_item_create()
	background_canvas_rid = RenderingServer.canvas_item_create()

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_PREDELETE:
			for each_shape:int in collision_shape_rids.size():
				PhysicsServer2D.body_remove_shape(collision_body_rid, 0)
				PhysicsServer2D.free_rid(collision_shape_rids[each_shape])
			
			PhysicsServer2D.free_rid(collision_body_rid)
			
			RenderingServer.free_rid(collision_canvas_rid)
			RenderingServer.free_rid(floor_canvas_rid)
			
			curve.disconnect(&"changed", generate_all_slopes)
		
		NOTIFICATION_ENTER_TREE:
			PhysicsServer2D.body_set_state(collision_body_rid, PhysicsServer2D.BODY_STATE_TRANSFORM, global_transform)
		NOTIFICATION_EXIT_TREE:
			PhysicsServer2D.body_set_space(collision_body_rid, RID())
		NOTIFICATION_READY:
			setup_collision()
			setup_rendering()
			
			if collision_polygon_array.is_empty() or visual_polygon_array.is_empty():
				generate_all_slopes()
			else:
				load_all_slopes()
			
			print("Slope ready")
		
		NOTIFICATION_DRAW:
			draw_all_slopes()
		NOTIFICATION_VISIBILITY_CHANGED:
			#can't implement input pickability in GDScript, sorry
			queue_redraw()
		
		NOTIFICATION_TRANSFORM_CHANGED, NOTIFICATION_LOCAL_TRANSFORM_CHANGED:
			PhysicsServer2D.body_set_shape_transform(collision_body_rid, 0, global_transform)
			draw_all_slopes()
		NOTIFICATION_WORLD_2D_CHANGED:
			PhysicsServer2D.body_set_space(collision_body_rid, get_world_2d().get_rid())
		
		NOTIFICATION_PARENTED:
			if is_visible_in_tree():
				draw_all_slopes()
		
		NOTIFICATION_ENTER_CANVAS:
			var canvas_layer:CanvasLayer = get_canvas_layer_node()
			var obj_id:int
			if is_instance_valid(canvas_layer):
				obj_id = canvas_layer.get_instance_id()
			
			PhysicsServer2D.body_attach_canvas_instance_id(collision_body_rid, obj_id)
		NOTIFICATION_EXIT_CANVAS:
			PhysicsServer2D.body_attach_canvas_instance_id(collision_body_rid, 0)
		
		NOTIFICATION_ENABLED:
			if is_instance_valid(get_world_2d()):
				PhysicsServer2D.body_set_space(collision_body_rid, get_world_2d().get_rid())
		NOTIFICATION_DISABLED:
			PhysicsServer2D.body_set_space(collision_body_rid, RID())

func calculate_curve_rect(from_array:PackedVector2Array) -> void:
	top_y = 0.0
	left_x = 0.0
	bottom_y = 0.0
	right_x = 0.0
	
	for slope_point:Vector2 in from_array:
		left_x = minf(slope_point.x, left_x)
		right_x = maxf(slope_point.x, right_x)
		top_y = minf(slope_point.y, top_y)
		bottom_y = maxf(slope_point.y, bottom_y)
	
	top_y = floorf(top_y)
	left_x = floorf(left_x)
	bottom_y = ceilf(bottom_y)
	right_x = ceilf(right_x)
	
	curve_rect.size.x = int(absf(left_x) + absf(right_x))
	curve_rect.size.y = int(absf(top_y) + absf(bottom_y))
	
	curve_rect.position.x = int(left_x)
	curve_rect.position.y = int(top_y)

func setup_collision() -> void:
	PhysicsServer2D.body_set_mode(collision_body_rid, PhysicsServer2D.BODY_MODE_STATIC)
	PhysicsServer2D.body_set_collision_layer(collision_body_rid, collision_layer)
	PhysicsServer2D.body_set_collision_mask(collision_body_rid, collision_mask)
	
	PhysicsServer2D.body_set_state(collision_body_rid, PhysicsServer2D.BODY_STATE_TRANSFORM, global_transform)
	
	if is_instance_valid(get_world_2d()):
		PhysicsServer2D.body_set_space(collision_body_rid, get_world_2d().space)

func setup_rendering() -> void:
	RenderingServer.canvas_item_set_parent(collision_canvas_rid, get_canvas_item())
	RenderingServer.canvas_item_set_parent(floor_canvas_rid, get_canvas_item())
	
	RenderingServer.canvas_item_set_parent(background_canvas_rid, collision_canvas_rid)
	
	if editor_show_collision:
		RenderingServer.canvas_item_set_canvas_group_mode(collision_canvas_rid, RenderingServer.CANVAS_GROUP_MODE_CLIP_AND_DRAW)
	else:
		RenderingServer.canvas_item_set_canvas_group_mode(collision_canvas_rid, RenderingServer.CANVAS_GROUP_MODE_CLIP_ONLY)
	

func generate_all_slopes() -> void:
	if not is_instance_valid(curve) or curve.get_baked_points().size() < 3:
		return
	
	if Engine.is_editor_hint():
		generate_collision_slope()
		
		if editor_show_textures:
			generate_visual_slope()
	else:
		generate_collision_slope()
		generate_visual_slope()

func generate_collision_slope() -> void:
	var collision_curve:Curve2D = curve.duplicate()
	collision_curve.bake_interval = collision_point_interval
	
	#tesellating here gives us "free optimization" by culling "duplicate" points
	#in the collision geometry, eg. (2,2) being between points (1,1) and (3,3)
	collision_polygon_array = collision_curve.tessellate().duplicate()
	collision_count = collision_polygon_array.size()
	
	calculate_curve_rect(collision_polygon_array)
	
	var bottom_left:Vector2 = Vector2(left_x, bottom_y)
	var bottom_right:Vector2 = Vector2(right_x, bottom_y)
	
	#add bottom right and bottom left corners
	if is_instance_valid(floor_texture):
		#add a margin for the texture so the background clips properly
		bottom_left.y += floor_texture.get_height()
		bottom_right.y += floor_texture.get_height()
	
	#Give a margin so that the resulting shape doesn't have 0 thickness in its thinnest areas
	bottom_right.y += collision_bottom_margin
	bottom_left.y += collision_bottom_margin
	
	collision_polygon_array.append(bottom_right)
	collision_polygon_array.append(bottom_left)
	
	load_collision_slope()
	draw_collision_slope()
	queue_redraw()

func generate_visual_slope() -> void:
	var visual_curve:Curve2D = curve.duplicate()
	visual_curve.bake_interval = 1
	
	#we want to scan x from left to right. For each point, we sample for the point 
	#between the current point and the next point where x is closest to an integer.
	
	var in_visual_polygon_array:PackedVector2Array = visual_curve.get_baked_points()
	
	var visual_point_count:int = in_visual_polygon_array.size()
	visual_polygon_array.clear()
	visual_polygon_array.resize(visual_point_count)
	
	calculate_curve_rect(in_visual_polygon_array)
	
	if floor_snap_x:
		var prev_point:Vector2 = in_visual_polygon_array.get(0)
		var round_prev_x:float = roundf(prev_point.x) #this var exists for optimization
		prev_point.x = round_prev_x
		
		var current_point:Vector2 = in_visual_polygon_array.get(1)
		
		visual_polygon_array[0] = prev_point
		
		var current_curve_index:int = 1
		var point_index:int = 1
		while current_curve_index < visual_point_count:
			current_point = in_visual_polygon_array[point_index]
			
			if not is_equal_approx(round_prev_x, roundf(current_point.x)):
				var new_point:Vector2
				
				new_point.x = roundf(current_point.x)
				
				if floor_snap_y:
					new_point.y = roundf(current_point.y)
				else:
					new_point.y = current_point.y
				
				visual_polygon_array[current_curve_index] = new_point
				
				prev_point = current_point
				round_prev_x = roundf(prev_point.x)
				
				current_curve_index += 1
			
			point_index += 1
			
			if point_index > in_visual_polygon_array.size() - 1:
				break
	else:
		visual_polygon_array = in_visual_polygon_array.duplicate()
		
		if floor_snap_y:
			for current_index:int in visual_polygon_array.size():
				var current_point:Vector2 = visual_polygon_array[current_index]
				#(we multiply by sign of y to re-sign the values unsigned in order to average
				current_point.y = roundf(current_point.y)
				visual_polygon_array[current_index] = current_point
	
	load_visual_slope()
	draw_visual_slope()
	queue_redraw()

func load_all_slopes() -> void:
	load_collision_slope()
	load_visual_slope()

##Load the data for the collision slope so that collision will be updated. This does
##not update the data, just load what is in place.
func load_collision_slope() -> void:
	if collision_polygon_array.is_empty():
		push_error("Cannot load collision slope because cache is empty")
	
	var convex_polys:Array[PackedVector2Array] = Geometry2D.decompose_polygon_in_convex(collision_polygon_array)
	
	if convex_polys.is_empty():
		return
	
	var poly_count:int = convex_polys.size()
	var rid_count:int = collision_shape_rids.size()
	
	#clear out the "extra" RIDs 
	if rid_count != poly_count:
		#TODO: Skip to "overflow" section and only free those
		for current_rid:int in range(0, rid_count):
			#This is effectively "popping" the value cause the underlying array does that
			PhysicsServer2D.body_remove_shape(collision_body_rid, 0)
			PhysicsServer2D.free_rid(collision_shape_rids[current_rid])
			collision_shape_rids[current_rid] = RID()
	
	collision_shape_rids.resize(poly_count)
	
	for current_shape:int in poly_count:
		var current_shape_rid:RID = collision_shape_rids[current_shape]
		
		if not current_shape_rid.is_valid():
			collision_shape_rids[current_shape] = PhysicsServer2D.convex_polygon_shape_create()
			current_shape_rid = collision_shape_rids[current_shape]
			PhysicsServer2D.body_add_shape(collision_body_rid, current_shape_rid, Transform2D())
		
		PhysicsServer2D.shape_set_data(current_shape_rid, convex_polys[current_shape])

func load_visual_slope() -> void:
	#TODO: Offload some of the processing from draw_visual_slope to here
	pass


func draw_all_slopes() -> void:
	RenderingServer.canvas_item_clear(floor_canvas_rid)
	RenderingServer.canvas_item_clear(collision_canvas_rid)
	RenderingServer.canvas_item_clear(background_canvas_rid)
	
	if is_visible_in_tree():
		#we have to draw this regardless because it acts as a clip mask for 
		#the background texture
		draw_collision_slope()
		
		if Engine.is_editor_hint():
			if editor_show_textures:
				draw_visual_slope()
		else:
			draw_visual_slope()

##Draw the collision shape for the slope. This must happen regardless of if it 
##"should" be visible (eg. editor visiblity is on or debug collision is on), because
##this acts as a clip mask for the background texture.
func draw_collision_slope() -> void:
	RenderingServer.canvas_item_clear(collision_canvas_rid)
	
	if collision_polygon_array.is_empty():
		return
	
	var draw_color:Color = Color.WHITE
	
	var draw_in_scene:bool = false
	if is_inside_tree():
		var tree:SceneTree = get_tree()
		if is_instance_valid(tree):
			draw_in_scene = tree.debug_collisions_hint
	
	if (Engine.is_editor_hint() and editor_show_collision) or draw_in_scene:
		draw_color = ProjectSettings.get_setting("debug/shapes/collision/shape_color", Color.WHITE)
	else:
		draw_color = Color8(255, 255, 255, 255)
	
	#multiplying this transform2D offsets the array to the right position so it draws at the right spot
	RenderingServer.canvas_item_add_polygon(collision_canvas_rid, collision_polygon_array, [draw_color])

func draw_visual_slope() -> void:
	RenderingServer.canvas_item_clear(floor_canvas_rid)
	RenderingServer.canvas_item_clear(background_canvas_rid)
	
	if not visible or visual_polygon_array.is_empty():
		return
	
	if is_instance_valid(background_texture):
		var texture_rect:Rect2 = curve_rect
		
		texture_rect.position.y += collision_bottom_margin
		#Add a little extra so the floor textre doesn't "hang off the edge" at the lowest area
		if is_instance_valid(floor_texture):
			texture_rect.size.y += floor_texture.get_height()
		
		RenderingServer.canvas_item_set_self_modulate(background_canvas_rid, background_self_modulate)
		
		RenderingServer.canvas_item_add_nine_patch(
			background_canvas_rid, 
			texture_rect,
			Rect2(Vector2.ZERO, background_texture.get_size()), 
			background_texture.get_rid(), 
			background_margin_top_left, 
			background_margin_bottom_right, 
			RenderingServer.NINE_PATCH_TILE, RenderingServer.NINE_PATCH_TILE,
			background_draw_center
		)
	
	if is_instance_valid(floor_texture):
		var slice_position:Vector2 = visual_polygon_array[0]
		var prev_slice_position:Vector2
		
		var source_atlas:Rect2 = Rect2(Vector2.ZERO, Vector2(1, floor_texture.get_height()))
		var texture_atlas:Rect2 = Rect2(source_atlas)
		texture_atlas.position = slice_position
		
		var texture_x_index:int = 1
		
		floor_texture.draw_rect_region(floor_canvas_rid, texture_atlas, source_atlas, floor_self_modulate)
		
		prev_slice_position = slice_position
		
		for x_pix:int in range(1, visual_polygon_array.size()):
			slice_position = visual_polygon_array[x_pix]
			
			source_atlas.position.x = texture_x_index
			texture_atlas.position = slice_position
			
			#"flip" the "direction" of the sprite so that it doesn't get unintentionally offset
			if slice_position.x < prev_slice_position.x:
				texture_x_index = wrapi(texture_x_index - 1, 0, floor_texture.get_width())
			else:
				floor_texture.draw_rect_region(floor_canvas_rid, texture_atlas, source_atlas, floor_self_modulate)
				texture_x_index = wrapi(texture_x_index + 1, 0, floor_texture.get_width())
			
			prev_slice_position = slice_position
