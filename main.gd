extends Control

enum DefenderType { INFANTRY, LIGHT, HEAVY, FORTIFIED }

const DICE_HE = {0: 1.0/3.0, 1: 0.5, 2: 1.0/6.0}
const DICE_PB_AI = {0: 0.0, 1: 1.0}

# Referenzen zu Counter-UI Elements
@onready var health_counter: CounterControl = $Scroll/VBox/DefenderPanel/VBoxDef/Counters/HealthCounter
@onready var defense_counter: CounterControl = $Scroll/VBox/DefenderPanel/VBoxDef/Counters/DefenseCounter
@onready var ai_counter: CounterControl = $Scroll/VBox/AttackerPanel/VBoxAtt/Counters/AICounter
@onready var pb_counter: CounterControl = $Scroll/VBox/AttackerPanel/VBoxAtt/Counters/PBCounter
@onready var he_counter: CounterControl = $Scroll/VBox/AttackerPanel/VBoxAtt/Counters/HECounter
@onready var flame_counter: CounterControl = $Scroll/VBox/AttackerPanel/VBoxAtt/Counters/FlameCounter

@onready var log_output: RichTextLabel = $Scroll/VBox/LogOutput
@onready var calc_button: Button = $Scroll/VBox/CalculateButton

var current_defender_type: DefenderType = DefenderType.INFANTRY

func _ready() -> void:
	calc_button.pressed.connect(_on_calculate_pressed)

func select_defender_type(type: DefenderType) -> void:
	current_defender_type = type

func _on_calculate_pressed() -> void:
	log_output.clear()
	
	var def_health = health_counter.value
	var def_defense = defense_counter.value
	
	var att_ai = ai_counter.value
	var att_pb = pb_counter.value
	var att_he = he_counter.value
	var att_flame = flame_counter.value

	# 1. Defense Rolls
	var defense_rolls = def_defense
	match current_defender_type:
		DefenderType.INFANTRY: defense_rolls += att_pb
		DefenderType.LIGHT: defense_rolls += att_ai + att_he
		DefenderType.HEAVY: defense_rolls += att_he

	# 2. Damage Rolls
	var damage_rolls = 0
	match current_defender_type:
		DefenderType.INFANTRY, DefenderType.LIGHT: damage_rolls += att_ai + att_pb
		DefenderType.HEAVY: damage_rolls += att_pb

	# 3. Unavoidable Damage
	var unavoidable_damage = 0
	if current_defender_type in [DefenderType.INFANTRY, DefenderType.LIGHT]:
		unavoidable_damage += att_flame

	var he_damage_rolls = att_he

	# Würfelliste zusammenstellen
	var liste_von_wuerfeln = []
	for i in range(damage_rolls):
		liste_von_wuerfeln.append(DICE_PB_AI)
	for i in range(he_damage_rolls):
		liste_von_wuerfeln.append(DICE_HE)

	var endverteilung = DiceMath.falte_wahrscheinlichkeiten(liste_von_wuerfeln)

	# Abwehr-Berechnung
	var abwehr_dict: Dictionary = {}
	var index = 0
	for defense_roll in endverteilung.keys():
		var abwehr = DiceMath.binom_pmf(defense_rolls, defense_roll, 2.0/3.0)
		abwehr_dict[index] = abwehr
		index += 1

	var reduction = DiceMath.apply_reduction(endverteilung, abwehr_dict)

	# Ausgabe
	log_text("Lebenspunkte | Wahrscheinlichkeit")
	var keys = reduction.keys()
	keys.sort()
	for damage_prob in keys:
		log_text("%d | %.2f%%" % [damage_prob, reduction[damage_prob] * 100.0])

	# Zerstörungschance
	var a = 0.0
	if def_health <= unavoidable_damage or (def_health + defense_rolls) <= (unavoidable_damage + damage_rolls):
		a = 1.0
	else:
		var p = 1.0 / 3.0
		var k = (def_health - unavoidable_damage + defense_rolls) - damage_rolls
		var n = defense_rolls
		a = DiceMath.prob_at_least_k(n, k, p)
		log_text("Mindestens %d Treffer bei %d Würfen: %.2f%%" % [k, n, a * 100.0])

	log_text("Zerstörungschance: %.2f%%" % [a * 100.0])

func log_text(text: String) -> void:
	log_output.append_text(text + "\n")
