extends Node

const SAVE_PATH := "user://lama_save.json"
const TILE := 1.5
const GRID_W := 5
const GRID_H := 4

var player := {
	"name": "Kael", "age": 16, "race": "Umano", "class": "Errante Senza Via",
	"level": 1, "xp": 0, "hp": 38, "max_hp": 38, "stamina": 20, "max_stamina": 20,
	"mana": 16, "max_mana": 16, "gold": 25, "reputation": 0,
	"stats": {"Forza": 4, "Resistenza": 4, "Agilità": 5, "Precisione": 5,
		"Difesa": 3, "Resistenza Magica": 3, "Mana": 4, "Magia": 3,
		"Controllo Magico": 2, "Spada": 2, "Maestria della Spada": 1,
		"Intelligenza": 5, "Carisma": 4, "Fortuna": 3},
	"memories": 0, "route": "Equilibrio"
}
var scene_root: Node3D
var ui: CanvasLayer
var log_label: Label
var info_label: Label
var action_box: HBoxContainer
var mode := "hub"
var selected_cell := Vector2i(-1, -1)
var hero_cell := Vector2i(0, 3)
var enemy_cell := Vector2i(4, 0)
var enemy_hp := 28
var enemy_max_hp := 28
var battle_turn := "player"
var battle_done := false
var dialogue_step := 0
var chapter := "Capitolo I — Il Risveglio"
var world_objects: Array[Node3D] = []

func _ready() -> void:
	_build_world()
	_build_ui()
	_show_hub()
	_log("AETHERIA — La Frattura ha cancellato un millennio di conoscenze.")
	_log("Sei Kael, un Errante Senza Via. Nessuno conosce la tua vera eredità.")

func _build_world() -> void:
	scene_root = Node3D.new()
	scene_root.name = "World"
	add_child(scene_root)
	var env := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#10172e")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#9ba9e8")
	environment.ambient_light_energy = 0.8
	env.environment = environment
	scene_root.add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-55, -25, 0)
	sun.light_energy = 1.2
	scene_root.add_child(sun)
	var camera := Camera3D.new()
	camera.position = Vector3(0, 10, 12)
	camera.rotation_degrees = Vector3(-38, 0, 0)
	camera.current = true
	scene_root.add_child(camera)
	_make_box("Pavimento", Vector3(0, -0.35, 0), Vector3(16, 0.5, 13), Color("#29334d"))
	_make_box("Altare", Vector3(-4, 0.15, -2), Vector3(2.5, 0.8, 2.5), Color("#493d78"))
	_make_box("Cristallo", Vector3(-4, 1.2, -2), Vector3(0.45, 1.8, 0.45), Color("#8d7aff"))
	_make_box("Rovine", Vector3(4, 0.4, -3), Vector3(2.2, 1.1, 1.4), Color("#46516d"))
	_make_box("Albero", Vector3(5, 1.0, 3), Vector3(0.7, 2.0, 0.7), Color("#5b493d"))
	_make_sphere("Chioma", Vector3(5, 2.5, 3), 1.25, Color("#386d68"))
	_make_box("Protagonista", Vector3(0, 0.6, 2), Vector3(0.7, 1.2, 0.55), Color("#e2e7ff"))
	_make_sphere("Testa", Vector3(0, 1.45, 2), 0.38, Color("#e7c7ae"))
	_make_box("Lama", Vector3(0.55, 0.8, 2), Vector3(0.12, 1.0, 0.12), Color("#b9d7ff"))

func _make_material(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.82
	return mat

func _make_box(label: String, pos: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = label
	var mesh := BoxMesh.new()
	mesh.size = size
	node.mesh = mesh
	node.position = pos
	node.material_override = _make_material(color)
	scene_root.add_child(node)
	return node

func _make_sphere(label: String, pos: Vector3, radius: float, color: Color) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = label
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	node.mesh = mesh
	node.position = pos
	node.material_override = _make_material(color)
	scene_root.add_child(node)
	return node

func _build_ui() -> void:
	ui = CanvasLayer.new()
	add_child(ui)
	var bg := ColorRect.new()
	bg.color = Color(0.025, 0.035, 0.075, 0.88)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.add_child(bg)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	ui.add_child(margin)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	margin.add_child(v)
	var title := Label.new()
	title.text = "LAMA DELL’ERA PERDUTA   ✦   AETHERIA"
	title.add_theme_font_size_override("font_size", 23)
	title.add_theme_color_override("font_color", Color("#d9c8ff"))
	v.add_child(title)
	info_label = Label.new()
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_label.add_theme_color_override("font_color", Color("#e4e8ff"))
	v.add_child(info_label)
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(spacer)
	log_label = Label.new()
	log_label.custom_minimum_size = Vector2(0, 92)
	log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	log_label.add_theme_color_override("font_color", Color("#c6d0f4"))
	v.add_child(log_label)
	action_box = HBoxContainer.new()
	action_box.add_theme_constant_override("separation", 8)
	v.add_child(action_box)
	_refresh_info()

func _button(text: String, callback: Callable) -> void:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(130, 48)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.pressed.connect(callback)
	action_box.add_child(b)

func _clear_buttons() -> void:
	for child in action_box.get_children():
		child.queue_free()

func _refresh_info() -> void:
	info_label.text = "%s  |  Lv.%d  |  HP %d/%d  |  Mana %d/%d  |  Oro %d\nClasse: %s  |  Spada %d  |  Magia %d  |  Ricordi %d\n%s" % [
		player.name, player.level, player.hp, player.max_hp, player.mana, player.max_mana,
		player.gold, player["class"], player.stats["Spada"], player.stats["Magia"],
		player.memories, chapter
	]

func _log(message: String) -> void:
	if log_label:
		log_label.text = message + "\n" + log_label.text
		var lines := log_label.text.split("\n")
		log_label.text = "\n".join(lines.slice(0, 5))

func _show_hub() -> void:
	mode = "hub"
	_clear_buttons()
	_button("Allenati", _train)
	_button("Esplora", _start_battle)
	_button("Ricordi", _memory)
	_button("Salva", _save_game)
	_button("Carica", _load_game)
	_refresh_info()

func _train() -> void:
	player.stats["Spada"] += 1
	player.stats["Maestria della Spada"] += 1
	player.stamina = player.max_stamina
	player.xp += 8
	_log("Ti alleni con una lama di legno. La tua tecnica migliora, lentamente.")
	_check_level()
	_refresh_info()

func _memory() -> void:
	if player.memories == 0:
		player.memories = 1
		player.mana += 3
		_log("Un lampo: una lama attraversa il cielo. «Non dimenticare il respiro…»")
	else:
		player.mana = mini(player.max_mana, player.mana + 4)
		_log("Il ricordo è ancora incompleto. La Frattura ti osserva.")
	_refresh_info()

func _start_battle() -> void:
	mode = "battle"
	battle_done = false
	battle_turn = "player"
	enemy_hp = enemy_max_hp
	hero_cell = Vector2i(0, 3)
	enemy_cell = Vector2i(4, 0)
	_clear_buttons()
	_button("Muovi", _move_hero)
	_button("Lama", _sword_attack)
	_button("Dardo arcano", _magic_attack)
	_button("Difesa", _defend)
	_button("Fuga", _show_hub)
	_log("Un Segugio di Ferro blocca il sentiero! Tocca Muovi per avanzare, poi attacca.")
	_draw_battle_grid()
	_refresh_info()

func _draw_battle_grid() -> void:
	for n in world_objects:
		if is_instance_valid(n):
			n.queue_free()
	world_objects.clear()
	for y in range(GRID_H):
		for x in range(GRID_W):
			var c := Color("#47526e") if (x + y) % 2 == 0 else Color("#39445e")
			var tile := _make_box("Casella", Vector3((x - 2) * TILE, 0.05, (y - 1.5) * TILE), Vector3(1.35, 0.12, 1.35), c)
			world_objects.append(tile)
	var hero := _make_sphere("Eroe", Vector3((hero_cell.x - 2) * TILE, 0.75, (hero_cell.y - 1.5) * TILE), 0.42, Color("#e4e9ff"))
	world_objects.append(hero)
	var enemy := _make_sphere("Nemico", Vector3((enemy_cell.x - 2) * TILE, 0.75, (enemy_cell.y - 1.5) * TILE), 0.48, Color("#d65b77"))
	world_objects.append(enemy)

func _move_hero() -> void:
	if mode != "battle" or battle_turn != "player" or battle_done: return
	if player.stamina < 2:
		_log("Non hai abbastanza Stamina.")
		return
	var next := hero_cell
	if hero_cell.x < enemy_cell.x: next.x += 1
	elif hero_cell.y > enemy_cell.y: next.y -= 1
	if next == enemy_cell:
		_log("Il nemico blocca il passaggio.")
		return
	hero_cell = next
	player.stamina -= 2
	_log("Ti riposizioni sulla griglia tattica.")
	_draw_battle_grid()
	_refresh_info()

func _sword_attack() -> void:
	if mode != "battle" or battle_turn != "player" or battle_done: return
	if player.stamina < 4:
		_log("Stamina insufficiente: prova a difenderti.")
		return
	var distance := abs(hero_cell.x - enemy_cell.x) + abs(hero_cell.y - enemy_cell.y)
	if distance > 1:
		_log("Sei troppo lontano. Usa Muovi.")
		return
	player.stamina -= 4
	var damage := 5 + player.stats["Spada"] * 2
	enemy_hp -= damage
	_log("Lama Diretta: infliggi %d danni al Segugio di Ferro." % damage)
	_after_player_action()

func _magic_attack() -> void:
	if mode != "battle" or battle_turn != "player" or battle_done: return
	if player.mana < 5:
		_log("Mana insufficiente.")
		return
	player.mana -= 5
	var damage := 7 + player.stats["Magia"]
	enemy_hp -= damage
	_log("Dardo arcano: %d danni. Il mana antico vibra nelle tue mani." % damage)
	_after_player_action()

func _defend() -> void:
	if mode != "battle" or battle_turn != "player" or battle_done: return
	player.hp = mini(player.max_hp, player.hp + 3)
	player.stamina = mini(player.max_stamina, player.stamina + 5)
	_log("Assumi una guardia prudente: recuperi HP e Stamina.")
	_after_player_action()

func _after_player_action() -> void:
	if enemy_hp <= 0:
		_win_battle()
		return
	battle_turn = "enemy"
	_refresh_info()
	await get_tree().create_timer(0.65).timeout
	if mode != "battle" or battle_done: return
	var damage := maxi(2, 6 - player.stats["Difesa"])
	player.hp -= damage
	_log("Il Segugio contrattacca: perdi %d HP. HP nemico: %d/%d." % [damage, enemy_hp, enemy_max_hp])
	if player.hp <= 0:
		player.hp = 1
		_log("Cadi a terra, ma una scintilla dimenticata ti protegge. Sei costretto a ritirarti.")
		_show_hub()
		return
	battle_turn = "player"
	player.stamina = mini(player.max_stamina, player.stamina + 2)
	_refresh_info()

func _win_battle() -> void:
	battle_done = true
	player.xp += 25
	player.gold += 15
	player.reputation += 1
	player.hp = mini(player.max_hp, player.hp + 8)
	_log("VITTORIA! Il Segugio si dissolve. +25 PE, +15 oro, +1 reputazione.")
	_check_level()
	_clear_buttons()
	_button("Continua", _show_hub)
	_refresh_info()

func _check_level() -> void:
	var needed := player.level * 30
	if player.xp >= needed:
		player.xp -= needed
		player.level += 1
		player.max_hp += 5
		player.max_stamina += 2
		player.max_mana += 2
		player.hp = player.max_hp
		player.stamina = player.max_stamina
		player.mana = player.max_mana
		player.stats["Forza"] += 1
		player.stats["Resistenza"] += 1
		_log("LIVELLO AUMENTATO! Ora sei livello %d." % player.level)

func _save_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		_log("Errore durante il salvataggio.")
		return
	file.store_string(JSON.stringify(player))
	file.close()
	_log("Partita salvata sul dispositivo.")

func _load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		_log("Nessun salvataggio trovato.")
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) == TYPE_DICTIONARY:
		player = parsed
		_log("Salvataggio caricato.")
		_refresh_info()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_game()
