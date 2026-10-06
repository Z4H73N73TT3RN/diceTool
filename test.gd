extends Control

const probability_ai = { 0: 2/3, 1 : 1/3}
# Ziehe deine 4 Buttons aus dem Szenenbaum in dieses Array
@export var buttons: Array[Button] = [$VBoxContainer/HBoxContainer3/Button, $VBoxContainer/HBoxContainer3/Button2, $VBoxContainer/HBoxContainer3/Button3, $VBoxContainer/HBoxContainer3/Button4]

func _ready() -> void:
	# Alle Buttons als Toggle-Buttons konfigurieren und mit der Klick-Funktion verbinden
	for i in range(buttons.size()):
		var btn = buttons[i]
		btn.toggle_mode = true
		btn.pressed.connect(func(): _on_button_selected(i))

func _on_button_selected(selected_index: int) -> void:
	for i in range(buttons.size()):
		# Nur der geklickte Button bleibt gedrückt (button_pressed = true)
		buttons[i].button_pressed = (i == selected_index)
