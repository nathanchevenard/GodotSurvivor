extends Upgrade
class_name WeaponUpgrade

enum WeaponUpgradeEnum
{
	ProjectileNumber,
	Cooldown,
	Damage,
	AreaOfEffect,
}

@export var upgrade_type : WeaponUpgradeEnum
@export var impacted_weapon : Weapon.WeaponEnum
@export var value : float
@export var pick_max_number : float

func apply_upgrade(weapon : Weapon):
	if weapon == null:
		push_warning("Weapon is null for apply_upgrade")
		return
	
	if upgrade_type == WeaponUpgrade.WeaponUpgradeEnum.ProjectileNumber:
		weapon.projectile_number += value
