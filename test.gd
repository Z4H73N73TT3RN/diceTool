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

func _on_button_pressed(selected_index: int) -> void:
	selectedType = selected_index
	print("type is ", selected_index)
	for i in range(buttons.size()):
		# Nur der geklickte Button bleibt gedrückt (button_pressed = true)
		buttons[i].button_pressed = (i == selected_index)

func getDefenseDices() -> int:
	match selectedType:
		TYPES.INFANTRY:	return counter_ai.getValue()
		TYPES.LIGHT: return counter_ap.getValue()
		TYPES.LIGHT: return counter_ap.getValue()
		_: return 0

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
	print("selected type: ", selectedType)
	print("defense ", getDefenseDices())
	print("un damage ", getUnavaidoableDamage())
	print("damagerolls ", getDamageDices())
