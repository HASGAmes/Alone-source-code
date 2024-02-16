extends Sprite2D
var shader_og_sec = Color("e9b0e6")
var shader_og_prim = Color("fffcce")
func _ready():
	material.set_shader_parameter("og_primary_color",shader_og_prim)
	material.set_shader_parameter("og_secondary_color",shader_og_sec)
