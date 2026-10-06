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
@onready var counter: CounterControl = $VBoxContainer/HBoxContainer6/test
#endregion

var selectedType = null
	
func _ready() -> void:
	# Alle Buttons als Toggle-Buttons konfigurieren und mit der Klick-Funktion verbinden
	for i in range(buttons.size()):
		var btn = buttons[i]
		btn.toggle_mode = true
		btn.pressed.connect(func(): _on_button_pressed(i))
	buttons[TYPES.INFANTRY].button_pressed = true

func _on_button_pressed(selected_index: int) -> void:
	selectedType = selected_index
	for i in range(buttons.size()):
		# Nur der geklickte Button bleibt gedrückt (button_pressed = true)
		buttons[i].button_pressed = (i == selected_index)

func getDefenseDices() -> int:
	var dices = 0
	match selectedType:
		TYPES.INFANTRY:
			dices += counter.getValue()
		TYPES.INFANTRY:
			dices += counter.getValue()
	return dices


func _on_compute_button_button_up() -> void:
	print(getDefenseDices())
