extends Node2D

@export var playerOne: Player
@export var playerTwo: Player

@onready var beam = %Beam
@onready var hit_particule: GPUParticles2D = %HitParticule

signal link_broken


var _broken := false


func _process(delta):
	var diff_vector = (playerTwo.position - playerOne.position)
	var center = playerOne.position + (diff_vector / 2)
	var distance = diff_vector.length()

	position = center
	rotation = playerOne.position.angle_to_point(playerTwo.position)
	beam.scale.x = distance / 65

	var broken_position = _get_broken_position()
	if not _broken and broken_position != null:
		_broken = true
		_on_broke(broken_position)


func _on_broke(position: Vector2) -> void:
	beam.visible = false
	
	hit_particule.global_position = position
	hit_particule.emitting = true
	await hit_particule.finished
	
	link_broken.emit()


func _get_broken_position():
	var spaceState = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(playerOne.global_position, playerTwo.global_position)
	query.collision_mask = 0b100
	var result = spaceState.intersect_ray(query)
	
	if result != null and result.has("collider"):
		return result["position"]
	else:
		return null
