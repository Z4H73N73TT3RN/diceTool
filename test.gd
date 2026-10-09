extends Control
enum TYPES {INFANTRY, LIGHT, HEAVY, FORT}
const probability_ai = { 0: 2/3, 1 : 1/3}
# Ziehe deine 4 Buttons aus dem Szenenbaum in dieses Array
#@export var buttons: Array[Button] = [$VBoxContainer/HBoxContainer3/Button, $VBoxContainer/HBoxContainer3/Button2, $VBoxContainer/HBoxContainer3/Button3, $VBoxContainer/HBoxContainer3/Button4]
#typebuttons
@onready var inf_btn: Button =  $VBoxContainer/HBoxContainer3/Button
@onready var light_btn: Button =  $VBoxContainer/HBoxContainer3/Button2
@onready var heavy_btn: Button =  $VBoxContainer/HBoxContainer3/Button3
@onready var fort_btn: Button =  $VBoxContainer/HBoxContainer3/Button4
@onready var buttons: Array[Button] = [inf_btn, light_btn, heavy_btn, fort_btn]
#region

@onready var health: CounterControl = $VBoxContainer/HBoxContainer6/health
@onready var defense: CounterControl = $VBoxContainer/HBoxContainer6/defense
@onready var counter_ai: CounterControl = $VBoxContainer/HBoxContainer/counter_ai
@onready var counter_ap: CounterControl = $VBoxContainer/HBoxContainer/counter_ap
@onready var counter_he: CounterControl = $VBoxContainer/HBoxContainer2/counter_he
@onready var counter_flames: CounterControl = $VBoxContainer/HBoxContainer2/counter_flame
@onready var output: RichTextLabel = $VBoxContainer/HBoxContainer4/RichTextLabel
#endregion

var selectedType = null
	
func _ready() -> void:
	selectedType = TYPES.INFANTRY
	# Alle Buttons als Toggle-Buttons konfigurieren und mit der Klick-Funktion verbinden
	for i in range(buttons.size()):
		var btn = buttons[i]
		btn.toggle_mode = true
		btn.pressed.connect(func(): _on_button_pressed(i))
	buttons[TYPES.INFANTRY].button_pressed = true
	health.setValue(4)
	health.setTitle("Health")
	defense.setTitle("Defense")
	counter_ai.setTitle("Anti-Infantry")
	counter_ai.setValue(2)
	counter_ap.setTitle("Armor-Piercing")
	counter_ap.setValue(2)
	counter_he.setTitle("High-Explosive")
	
	counter_flames.setTitle("Fire")

func _on_button_pressed(selected_index: int) -> void:
	selectedType = selected_index
	print("type is ", selected_index)
	for i in range(buttons.size()):
		# Nur der geklickte Button bleibt gedrückt (button_pressed = true)
		buttons[i].button_pressed = (i == selected_index)

func getDefenseDices() -> int:
	var _defenseDices = 0
	match selectedType:
		TYPES.INFANTRY:	_defenseDices += counter_ap.getValue()
		TYPES.LIGHT: _defenseDices += (counter_ai.getValue() + counter_he.getValue())
		TYPES.HEAVY: _defenseDices += (counter_ap.getValue() + counter_he.getValue())
		_: _defenseDices += 0
	_defenseDices += defense.getValue()
	return _defenseDices

func getDamageDices() -> int:
	match selectedType:
		TYPES.INFANTRY,TYPES.LIGHT:	return counter_ai.getValue()+counter_ap.getValue()
		TYPES.HEAVY: return counter_ai.getValue()
		_: return 0

func getUnavaidoableDamage() -> int:
	match selectedType:
		TYPES.INFANTRY,TYPES.LIGHT:	return counter_flames.getValue()
		#TYPES.HEAVY: return counter_ai.getValue()
		_: return 0
		
func _on_compute_button_button_up() -> void:
	var defenseRolls = getDefenseDices()
	var unavoidableDamage = getUnavaidoableDamage()
	var damageRolls = getDamageDices()
	var heDamageRolls = counter_he.getValue()
	
	print("selected type: ", selectedType)
	print("health ", health.getValue())
	print("defense ", defenseRolls)
	print("ai: ", counter_ai.getValue())
	print("ap: ", counter_ap.getValue())
	print("un damage ", unavoidableDamage)
	print("damagerolls ", damageRolls)
	#
	var dice_he: Dictionary = { 0: 1.0/3.0, 1: 1.0/2.0, 2: 1.0/6.0 }
	var dice_pb_ai: Dictionary = { 0: 0.0, 1: 1.0 }

	var liste_von_wuerfeln: Array = []
	# 1. Alle benötigten Angriffswürfel in einer Liste sammeln
	for i in range(damageRolls):
		# Für jeden Standard-Angriffswürfel (AI/PB) dessen Wahrscheinlichkeiten hinzufügen
		liste_von_wuerfeln.append(dice_pb_ai)
	for i in range(heDamageRolls):
		# Für jeden Hochexplosiv-Würfel (HE) dessen Wahrscheinlichkeiten hinzufügen
		liste_von_wuerfeln.append(dice_he)
	# 2. Gesamtwahrscheinlichkeiten berechnen (Faltung):
	# Berechnet für alle Würfel zusammen, wie wahrscheinlich jede mögliche Gesamtschadenssumme ist
	var endverteilung: Dictionary = DiceCalculator.falte_wahrscheinlichkeiten(liste_von_wuerfeln)
	
	# 3. Für jeden Schadenswert berechnen, wie wahrscheinlich die passende Verteidigung ist
	var abwehrRolls: Array = []
	var sorted_keys: Array = endverteilung.keys()
	sorted_keys.sort()
	
	for defenseRoll in sorted_keys:
		# Binomialverteilung: defenseRolls = Anzahl Würfel, defenseRoll = benötigte Erfolge, 2/3 = Erfolgswahrscheinlichkeit
		var abwehr = DiceCalculator.binom_pmf(defenseRolls, defenseRoll, 2.0 / 3.0)
		abwehrRolls.append(abwehr)
	
	# 4. Abwehr-Ergebnisse in Dictionary umwandeln (Index = abgefangener Schaden)
	var abwehrDict: Dictionary = {}
	for i in range(abwehrRolls.size()):
		abwehrDict[i] = abwehrRolls[i]
		
	# 5. Eingehenden Schaden um die abgewehrten Treffer reduzieren (Nettoschaden)
	var reduction: Dictionary = DiceCalculator.apply_reduction(endverteilung, abwehrDict)
	
	print(endverteilung)
	#output.text = str(endverteilung) + "\n" +str(abwehrRolls) + "\n"+str(abwehrDict)+ "\n" + str(reduction)
	# 6. Ergebnisse für die Anzeige im RichTextLabel formatieren
	var log_text: String = "Schaden | Wahrscheinlichkeit\n"
	log_text += "-------------------------------\n"
	
	var sorted_reduction_keys: Array = reduction.keys()
	sorted_reduction_keys.sort()
	
	for damage_val in sorted_reduction_keys:
		var prob: float = reduction[damage_val]
		# Formatiert die Wahrscheinlichkeit als Prozentwert mit 2 Nachkommastellen
		log_text += str(damage_val) + " Schaden | " + str(snapped(prob * 100.0, 0.01)) + "%\n"
	
	# 7. Zerstörungschance (Destruction Chance) berechnen
	var a: float = 0.0
	var current_health = health.getValue()
	
	if current_health <= unavoidableDamage or (current_health + defenseRolls) <= (unavoidableDamage + damageRolls):
		a = 1.0
	else:
		var p: float = 1.0 / 3.0
		var k: int = (current_health - unavoidableDamage + defenseRolls) - damageRolls
		var n: int = defenseRolls
		
		# Verhindern, dass k größer als n wird (sonst crasht prob_at_least_k)
		k = clampi(k, 0, n)
		
		a = DiceCalculator.prob_at_least_k(n, k, p)
		log_text += "\nMindestens " + str(k) + " Treffer bei " + str(n) + " Würfen: " + str(snapped(a * 100.0, 0.01)) + "%\n"
	
	log_text += "\nZerstörungschance: " + str(snapped(a * 100.0, 0.01)) + "%"
	
	# Am Ende das gesamte Log in das RichTextLabel schreiben
	output.text = log_text
	print(output.text)
	
