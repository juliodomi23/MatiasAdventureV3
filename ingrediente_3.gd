extends Area2D

var is_active := false
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D  # Asegúrate de que el nodo se llama igual en tu escena

func _ready():
	collision_shape.set_deferred("disabled", true)
	hide()
	body_entered.connect(_on_body_entered)
	print("[Ingrediente] Inicializado en ", global_position)

func activate():
	if is_active: 
		return
	
	is_active = true
	collision_shape.disabled = false
	show()
	
	print("[Ingrediente] ACTIVADO - Datos:")
	print(" - Posición global:", global_position)
	print(" - Visible:", visible)
	print(" - Colisiones:", !collision_shape.disabled)
	print(" - Sprite visible:", sprite.visible)

func _on_body_entered(body: Node2D):
	if is_active and body.name == "Player":
		print("\n[Ingrediente] ¡Recolectado por el jugador!")
		if body.has_method("recolectar_ingrediente"):
			body.recolectar_ingrediente(self)
			queue_free()
		else:
			printerr("Error: Falta método 'recolectar_ingrediente'")

func _on_visibility_changed():
	print("[Ingrediente] Cambio de visibilidad ->", visible, 
		  "| Activo:", is_active,
		  "| Colisión:", !collision_shape.disabled)
