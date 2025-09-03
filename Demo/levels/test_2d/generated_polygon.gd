@tool
extends CollisionPolygon2D

class_name GeneratedCornerSlope

@export var slope_size:Vector2 = Vector2(100, -100):
	set(new_size):
		slope_size = new_size
		generate_slope()

@export var slope_middle:Vector2 = Vector2(75.0, -25.0):
	set(new_point):
		slope_middle = new_point
		generate_slope()

@export var detail_level:float = 5.0:
	set(new_detail_level):
		detail_level = new_detail_level
		generate_slope()

@export_custom(PROPERTY_HINT_RANGE, "radians_as_degrees, 90.0", PROPERTY_USAGE_EDITOR) var slope_angle:float = deg_to_rad(45.0):
	set(new_angle):
		slope_angle = new_angle
		generate_slope()

var generated_polygon:PackedVector2Array

var in_point:Vector2 
var out_point:Vector2

func _ready() -> void:
	generate_slope()
	polygon = generated_polygon

func generate_slope() -> void:
	generated_polygon.clear()
	
	#origin point
	generated_polygon.append(Vector2.ZERO)
	
	#curve
	var curve:Curve2D = Curve2D.new()
	
	curve.bake_interval = detail_level
	
	var slope:Vector2 = Vector2.from_angle(slope_angle)
	
	var slope_y:Vector2 = Vector2(0.0, slope_size.y)
	var slope_x:Vector2 = Vector2(slope_size.x, 0.0)
	
	#var x_intercept:Vector2 = slope_middle - ((slope / slope.y) * slope_middle.y)
	var x_intercept:Vector2 = slope_size - ((slope / slope.y) * slope_size.y)
	#var y_intercept:Vector2 = slope_middle - ((slope / slope.x) * slope_middle.x)
	var y_intercept:Vector2 = slope_size - ((slope / slope.x) * slope_size.x)
	
	curve.add_point(y_intercept)
	
	in_point = x_intercept
	out_point = y_intercept
	
	curve.add_point(
		slope_middle,
		#in_point, #in, left
		#out_point #out, right
		
	)
	
	printt("Mid:", slope_middle, "In:", in_point, "Out:", out_point)
	
	curve.add_point(x_intercept)
	
	generated_polygon.append_array(curve.get_baked_points())
	
	#bottom right corner
	generated_polygon.append(Vector2(slope_size.x, 0.0))
	
	editor_state_changed.emit()
	queue_redraw()

func _draw() -> void:
	draw_polygon(generated_polygon, [Color.BLUE])
	
	draw_circle(slope_middle, 2.5, Color.GREEN)
	
	draw_circle(in_point, 2.5, Color.RED)
	
	draw_circle(out_point, 2.5, Color.YELLOW)
