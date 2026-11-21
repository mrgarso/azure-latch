extends Control
class_name PopUpCamera

@export var polygon_2d: Polygon2D
@export var camera_3d: Camera3D
@onready var resolution := get_viewport().get_visible_rect().size
