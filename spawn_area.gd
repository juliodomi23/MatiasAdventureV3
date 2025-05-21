extends Area2D

@export var enemy_template: NodePath
@export var ingredient: NodePath
@export var spawn_points: Array[Vector2] = []

var current_enemy: CharacterBody2D
var enemies_defeated: int = 0
const MAX_ENEMIES: int = 5
var is_active: bool = false

func _ready():
	print("[SpawnArea] Inicializando zona...")
	get_node(enemy_template).hide()
	body_entered.connect(_on_body_entered)
	
	# Configuración inicial del ingrediente
	var ing = get_node(ingredient)
	ing.hide()
	ing.get_node("CollisionShape2D").set_deferred("disabled", true)

func _on_body_entered(body: Node2D):
	if body.name == "Player" and not is_active and enemies_defeated < MAX_ENEMIES:
		print("\n[SpawnArea] Jugador entró - Enemigos derrotados: ", enemies_defeated)
		is_active = true
		spawn_next_enemy()

func spawn_next_enemy():
	if enemies_defeated >= MAX_ENEMIES:
		return
	
	current_enemy = get_node(enemy_template)
	var spawn_pos = _calculate_spawn_position()
	
	print(" - Spawn #", enemies_defeated + 1, " en posición: ", spawn_pos)
	
	current_enemy.global_position = spawn_pos
	current_enemy.show()
	current_enemy.reset_enemy()
	
	# Conexión segura de señal
	if current_enemy.tree_exiting.is_connected(_on_enemy_defeated):
		current_enemy.tree_exiting.disconnect(_on_enemy_defeated)
	current_enemy.tree_exiting.connect(_on_enemy_defeated, CONNECT_ONE_SHOT)

func _calculate_spawn_position() -> Vector2:
	if spawn_points.size() > 0:
		return global_position + spawn_points[enemies_defeated % spawn_points.size()]
	return global_position + Vector2(randf_range(-50, 50), randf_range(-50, 50))

func _on_enemy_defeated():
	enemies_defeated += 1
	print("\n[SpawnArea] Enemigo derrotado! (", enemies_defeated, "/", MAX_ENEMIES, ")")
	
	current_enemy = null
	
	if enemies_defeated >= MAX_ENEMIES:
		spawn_ingredient()
	else:
		spawn_next_enemy()

func spawn_ingredient():
	var ing = get_node(ingredient)
	ing.global_position = global_position
	ing.activate()
	print("[SpawnArea] ¡Ingrediente activado en posición global: ", ing.global_position, "!")
	
	# Debug visual
	print(" - Estado del ingrediente:")
	print("   * Visible:", ing.visible)
	print("   * Posición:", ing.global_position)
	print("   * Colisión:", !ing.get_node("CollisionShape2D").disabled)
	
	is_active = false
