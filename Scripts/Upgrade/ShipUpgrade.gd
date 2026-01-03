extends Upgrade
class_name ShipUpgrade

enum PlayerUpgradeEnum
{
	Life,
	LifeRegen,
	Shield,
	Damage,
	Cooldown,
	MoveSpeed
}

@export var upgrade_type : PlayerUpgradeEnum
@export var pick_max_number : float


func apply_upgrade(player : Player):
	match upgrade_type:
		PlayerUpgradeEnum.Life:
			var init_health_max = player.health_max
			player.health_max = apply_value_to_variable(player.health_max, player.init_health_max)
			player.health += player.health_max - init_health_max
			player.emit_health_changed()
		PlayerUpgradeEnum.LifeRegen:
			player.health_regen = apply_value_to_variable(player.health_regen, player.init_health_regen)
		PlayerUpgradeEnum.Shield:
			var init_shield_max = player.shield_max
			player.shield_max = apply_value_to_variable(player.shield_max, player.init_shield_max)
			player.shield += player.shield_max - init_shield_max
			player.emit_shield_changed()
		PlayerUpgradeEnum.Damage:
			player.damage_mult = apply_value_to_variable(player.damage_mult, player.init_damage_mult)
		PlayerUpgradeEnum.Cooldown:
			player.cooldown_mult = apply_value_to_variable(player.cooldown_mult, player.init_cooldown_mult)
		PlayerUpgradeEnum.MoveSpeed:
			player.speed_max = apply_value_to_variable(player.speed_max, player.init_speed_max)
