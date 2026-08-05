extends Node
class_name PlayerCombat
## Aimed weapons + dash. Swap only at a placed Weapon Stand.

enum Weapon { STAFF, AXE, DAGGER }

signal weapon_changed(weapon: Weapon)

@export var staff_projectile_scene: PackedScene
@export var axe_slash_scene: PackedScene
@export var dagger_stab_scene: PackedScene
@export var staff_texture: Texture2D
@export var axe_texture: Texture2D
@export var dagger_texture: Texture2D

@export var staff_cooldown: float = 0.35
@export var axe_cooldown: float = 0.7
@export var dagger_cooldown: float = 0.45
@export var staff_damage: float = 8.0
@export var axe_damage: float = 12.0
@export var dagger_damage: float = 18.0

@export var dash_speed: float = 280.0
@export var dash_duration: float = 0.14
@export var dash_cooldown: float = 0.85
@export var dash_iframes: float = 0.18

var equipped: Weapon = Weapon.STAFF

var _player: CharacterBody2D
var _hurtbox: HurtboxComponent
var _weapon_sprite: Sprite2D
var _attack_cd: float = 0.0
var _dash_cd: float = 0.0
var _dash_time: float = 0.0
var _dash_dir: Vector2 = Vector2.ZERO


func _ready() -> void:
	_player = get_parent() as CharacterBody2D
	if _player != null:
		_hurtbox = _player.get_node_or_null("HurtboxComponent") as HurtboxComponent
	if staff_projectile_scene == null:
		staff_projectile_scene = load("res://scenes/ability/staff/staff_projectile.tscn")
	if axe_slash_scene == null:
		axe_slash_scene = load("res://scenes/ability/axe/axe_slash.tscn")
	if dagger_stab_scene == null:
		dagger_stab_scene = load("res://scenes/ability/dagger/dagger_stab.tscn")
	if staff_texture == null:
		staff_texture = load("res://assets/sprites/characters/weapons_/staff_.png")
	if axe_texture == null:
		axe_texture = load("res://assets/sprites/characters/weapons_/axe_.png")
	if dagger_texture == null:
		dagger_texture = load("res://assets/sprites/characters/weapons_/sword_.png")
	_ensure_weapon_sprite()
	_refresh_weapon_sprite()
	weapon_changed.emit(equipped)


func _process(delta: float) -> void:
	_attack_cd = max(_attack_cd - delta, 0.0)
	_dash_cd = max(_dash_cd - delta, 0.0)
	if _dash_time > 0.0:
		_dash_time = max(_dash_time - delta, 0.0)
	_aim_weapon_sprite()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack") or event.is_action_pressed("shoot"):
		if try_attack():
			get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("dash"):
		if try_dash():
			get_viewport().set_input_as_handled()


func get_weapon_name(weapon: Weapon = equipped) -> String:
	match weapon:
		Weapon.STAFF:
			return "Staff"
		Weapon.AXE:
			return "Axe"
		Weapon.DAGGER:
			return "Dagger"
	return "?"


func cycle_weapon() -> void:
	equipped = ((int(equipped) + 1) % 3) as Weapon
	_refresh_weapon_sprite()
	weapon_changed.emit(equipped)


func is_dashing() -> bool:
	return _dash_time > 0.0


func get_dash_velocity() -> Vector2:
	return _dash_dir * dash_speed


func try_attack() -> bool:
	if _player == null or _attack_cd > 0.0 or _dash_time > 0.0:
		return false
	var aim := _aim_direction()
	if aim == Vector2.ZERO:
		aim = Vector2.RIGHT
	match equipped:
		Weapon.STAFF:
			_fire_staff(aim)
			_attack_cd = staff_cooldown
		Weapon.AXE:
			_swing_axe(aim)
			_attack_cd = axe_cooldown
		Weapon.DAGGER:
			_stab_dagger(aim)
			_attack_cd = dagger_cooldown
	return true


func try_dash() -> bool:
	if _player == null or _dash_cd > 0.0 or _dash_time > 0.0:
		return false
	var dir := Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	if dir == Vector2.ZERO:
		dir = _aim_direction()
	if dir == Vector2.ZERO:
		dir = Vector2.RIGHT
	_dash_dir = dir.normalized()
	_dash_time = dash_duration
	_dash_cd = dash_cooldown
	if _hurtbox != null:
		_hurtbox.set_invulnerable_for(dash_iframes)
	return true


func _aim_direction() -> Vector2:
	return (_player.get_global_mouse_position() - _player.global_position).normalized()


func _vfx_parent() -> Node2D:
	var entities := get_tree().get_first_node_in_group(Groups.ENTITIES_LAYER) as Node2D
	if entities != null:
		return entities
	return get_tree().get_first_node_in_group(Groups.FOREGROUND_LAYER) as Node2D


func _ensure_weapon_sprite() -> void:
	if _player == null:
		return
	_weapon_sprite = _player.get_node_or_null("EquippedWeapon") as Sprite2D
	if _weapon_sprite != null:
		return
	_weapon_sprite = Sprite2D.new()
	_weapon_sprite.name = "EquippedWeapon"
	_weapon_sprite.z_index = 2
	_weapon_sprite.centered = true
	_player.add_child(_weapon_sprite)


func _refresh_weapon_sprite() -> void:
	if _weapon_sprite == null:
		return
	match equipped:
		Weapon.STAFF:
			_weapon_sprite.texture = staff_texture
		Weapon.AXE:
			_weapon_sprite.texture = axe_texture
		Weapon.DAGGER:
			_weapon_sprite.texture = dagger_texture
	_weapon_sprite.scale = Vector2(1.25, 1.25)


func _aim_weapon_sprite() -> void:
	if _weapon_sprite == null or _player == null:
		return
	var aim := _aim_direction()
	if aim == Vector2.ZERO:
		aim = Vector2.RIGHT
	_weapon_sprite.position = aim * 10.0
	_weapon_sprite.rotation = aim.angle() + PI * 0.5


func _configure_hitbox(hitbox: HitboxComponent, damage: float) -> void:
	hitbox.damage = damage
	hitbox.team = HitboxComponent.Team.PLAYER
	hitbox._apply_team_collision()
	hitbox._hit_ids.clear()


func _fire_staff(aim: Vector2) -> void:
	var parent := _vfx_parent()
	if parent == null or staff_projectile_scene == null:
		return
	var bolt := staff_projectile_scene.instantiate() as StaffProjectile
	parent.add_child(bolt)
	bolt.global_position = _player.global_position + aim * 12.0
	bolt.direction = aim
	_configure_hitbox(bolt.hitbox_component, staff_damage)


func _swing_axe(aim: Vector2) -> void:
	var parent := _vfx_parent()
	if parent == null or axe_slash_scene == null:
		return
	var slash := axe_slash_scene.instantiate() as Node2D
	parent.add_child(slash)
	slash.global_position = _player.global_position
	slash.rotation = aim.angle()
	_configure_hitbox(slash.get_node("HitboxComponent") as HitboxComponent, axe_damage)


func _stab_dagger(aim: Vector2) -> void:
	var parent := _vfx_parent()
	if parent == null or dagger_stab_scene == null:
		return
	var stab := dagger_stab_scene.instantiate() as Node2D
	parent.add_child(stab)
	stab.global_position = _player.global_position
	stab.rotation = aim.angle()
	_configure_hitbox(stab.get_node("HitboxComponent") as HitboxComponent, dagger_damage)
