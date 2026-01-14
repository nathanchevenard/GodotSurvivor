extends Upgrade
class_name WeaponUpgrade

enum WeaponUpgradeEnum
{
	ProjectileNumber,
	Cooldown,
	Damage,
	AreaOfEffect,
	ProjectileSpeed,
	ProjectileSize,
	AddWeapon,
	ReboundNumber,
	ReboundRange,
	WeaponRange,
}

@export var upgrade_type : WeaponUpgradeEnum
@export var impacted_weapon : Weapon.WeaponEnum
@export var pick_max_number : float
@export var weapon_scene : PackedScene
@export var weapon_upgrades : Array[WeaponUpgrade]


func apply_upgrade(weapon : Weapon):
	if weapon == null:
		push_warning("Weapon is null for apply_upgrade")
		return
	
	match upgrade_type:
		WeaponUpgradeEnum.ProjectileNumber:
			weapon.projectile_number = apply_value_to_variable(weapon.projectile_number)
		WeaponUpgradeEnum.Cooldown:
			weapon.cooldown = apply_value_to_variable(weapon.cooldown, weapon.init_cooldown)
		WeaponUpgradeEnum.Damage:
			weapon.damage = apply_value_to_variable(weapon.damage, weapon.init_damage)
		WeaponUpgradeEnum.AreaOfEffect:
			weapon.projectile_coef_area_of_effect = apply_value_to_variable(weapon.projectile_coef_area_of_effect, weapon.init_projectile_coef_area_of_effect)
		WeaponUpgradeEnum.ProjectileSpeed:
			weapon.projectile_speed = apply_value_to_variable(weapon.projectile_speed, weapon.init_projectile_speed)
		WeaponUpgradeEnum.ProjectileSize:
			weapon.projectile_size = apply_value_to_variable(weapon.projectile_size, weapon.init_projectile_size)
		WeaponUpgradeEnum.ReboundNumber:
			weapon.rebound_number = apply_value_to_variable(weapon.rebound_number, weapon.init_rebound_number)
		WeaponUpgradeEnum.ReboundRange:
			weapon.rebound_range = apply_value_to_variable(weapon.rebound_range, weapon.init_rebound_range)
		WeaponUpgradeEnum.WeaponRange:
			weapon.range = apply_value_to_variable(weapon.range, weapon.init_range)
			weapon.projectile_lifetime = apply_value_to_variable(weapon.projectile_lifetime, weapon.init_projectile_lifetime)
