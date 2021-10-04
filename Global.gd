extends Node

enum DISASTER {RAIN, METEOR, WIND}

enum ITEMTYPE {WEAPON, HAMMER, AERIAL, AURA}
enum WEAPON {DAGGER, SWORD, SPEAR, HAMMER, PISTOL, SHURIKEN}
enum HAMMER {NORMAL, BOOMER, SPIKE, BETTER, AREA}
enum AERIAL {NONE, AIR_DASH, DOUBLE_JUMP, HOOK, JET}
enum AURA {MORE_DAMAGE, MORE_HAMMER, ALL_DAMAGE, ALL_HAMMER, FAST_MOVE, FAST_SCRAPHP, FAST_SCRAPSPAWN}

const GRAVITY = 800

var difficulty = 0

func _process(delta):
	if Input.is_key_pressed(KEY_F5):
		get_tree().reload_current_scene()

# 0 = weapons
# 1 = hammer
# 2 = aerial
# 3 = aura

const items = [
	[ITEMTYPE.WEAPON, WEAPON.DAGGER, "Dagger", "Short, weak, but reliable"],
	[ITEMTYPE.WEAPON, WEAPON.SWORD, "Sword", "Decent and lasts awhile"],
	[ITEMTYPE.WEAPON, WEAPON.SPEAR, "Spear", "Far-reaching"],
	[ITEMTYPE.WEAPON, WEAPON.HAMMER, "\"Hammer\"", "Why hammer when you can use a sword to hammer?"],
	[ITEMTYPE.WEAPON, WEAPON.PISTOL, "Revolver", "Powerful, but slow to reload"],
	[ITEMTYPE.WEAPON, WEAPON.SHURIKEN, "Shuriken", "Swift, far-reaching, but weak"],
	[ITEMTYPE.HAMMER, HAMMER.NORMAL, "Hammer", "Ol' reliable!"],
	[ITEMTYPE.HAMMER, HAMMER.BOOMER, "Hammerang", "Throw your hammer!"],
	[ITEMTYPE.HAMMER, HAMMER.SPIKE, "Spiky Hammer", "Why use a weapon when you can hammer them down?"],
	[ITEMTYPE.HAMMER, HAMMER.BETTER, "Gold Hammer", "Shiny, effective, but breaks easily."],
	[ITEMTYPE.HAMMER, HAMMER.AREA, "Wide Hammer", "Fix in a wider range!"],
	[ITEMTYPE.AERIAL, AERIAL.NONE, "Dash", "Feel good for throwing away your aerial maneuvers!"],
	[ITEMTYPE.AERIAL, AERIAL.AIR_DASH, "Air Dash", "Dash in the air!"],
	[ITEMTYPE.AERIAL, AERIAL.DOUBLE_JUMP, "Double Jump", "Jump twice in the air!"],
	#[ITEMTYPE.AERIAL, AERIAL.HOOK, "Hookshot", "Quickly reach other places!"],
	#[ITEMTYPE.AERIAL, AERIAL.JET, "Jetpack", "Float for a short amount of time!"],
	[ITEMTYPE.AURA, AURA.MORE_DAMAGE, "+20% Damage", "+20% weapon effectiveness but -20% hammer effectiveness"],
	[ITEMTYPE.AURA, AURA.MORE_HAMMER, "+20% Hammer", "+20% hammer effectiveness but -20% weapon effectiveness"],
	[ITEMTYPE.AURA, AURA.ALL_DAMAGE, "MAX DAMAGE", "+100% weapon effectiveness but disables hammers"],
	[ITEMTYPE.AURA, AURA.ALL_HAMMER, "MAX HAMMER", "+100% hammer effectiveness but disables weapons"],
	[ITEMTYPE.AURA, AURA.FAST_MOVE, "Double Time", "Makes your journey faster"],
	[ITEMTYPE.AURA, AURA.FAST_SCRAPHP, "Scrap 4 HP", "Enemy HP +50% for +50% scrap gained"],
	[ITEMTYPE.AURA, AURA.FAST_SCRAPSPAWN, "Scrap 4 Enemies", "Enemy spawn +50% for +50% scrap gained"],
]

const weapon_sprite_index = {
	WEAPON.DAGGER: 22,
	WEAPON.SWORD: 0,
	WEAPON.SPEAR: 1,
	WEAPON.HAMMER: 2,
	WEAPON.PISTOL: 3,
	WEAPON.SHURIKEN: 4,
}

const hammer_sprite_index = {
	HAMMER.NORMAL: 5,
	HAMMER.BOOMER: 6,
	HAMMER.SPIKE: 7,
	HAMMER.BETTER: 8,
	HAMMER.AREA: 9,
}

const aerial_sprite_index = {
	AERIAL.NONE: 11,
	AERIAL.AIR_DASH: 10,
	AERIAL.DOUBLE_JUMP: 12,
	AERIAL.HOOK: 13,
	AERIAL.JET: 14
}

const aura_sprite_index = {
	AURA.MORE_DAMAGE: 15,
	AURA.MORE_HAMMER: 17,
	AURA.ALL_DAMAGE: 16,
	AURA.ALL_HAMMER: 18,
	AURA.FAST_MOVE: 19,
	AURA.FAST_SCRAPHP: 20,
	AURA.FAST_SCRAPSPAWN: 21,
}

func _ready():
	randomize()
