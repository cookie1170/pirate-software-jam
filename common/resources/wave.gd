class_name Wave
extends Resource

@export var enemies : Array[PackedScene]
@export_range(0, 10, 0.25) var time_between_enemy_sec : float = 2
@export_range(0, 60, 0.5) var stall_time_sec : float = 15
