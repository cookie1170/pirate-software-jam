class_name Upgrade
extends Resource

@export_range(-50, 50, 0.25) var attack_speed_change : float
@export_range(-50, 50) var bullet_amt_change : int
@export_range(0, 1, 0.05) var bullet_save_chance : float
@export_range(-100, 100) var damage_increase : int
@export_range(-20, 20, 0.5) var move_speed_increase : float
@export_range(0, 10) var pierce_increase : int
@export_range(-10 , 10, 0.5) var accuracy_change : float
@export_range(-10, 10, 0.05) var knockback_change : float
@export var defense : int
@export_enum("blocks", "coins") var price_type : String = "coins"
@export_range(1, 100) var price : int = 10
@export var name : String
@export var icon : Texture
@export var tooltip : String
