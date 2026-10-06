extends Control
class_name CounterControl

signal value_changed(new_value: int)

@export var title: String = "Counter":
	set(v):
		title = v
		if is_node_ready(): $HBoxContainer/LabelTitle.text = v

@export var value: int = 0:
	set(v):
		value = max(0, v)
		if is_node_ready(): $HBoxContainer/LabelValue.text = str(value)

func _ready() -> void:
	#$HBoxContainer/LabelTitle.text = title
	$HBoxContainer/LabelValue.text = str(value)
	$HBoxContainer/BtnMinus.pressed.connect(func(): value -= 1; value_changed.emit(value))
	$HBoxContainer/BtnPlus.pressed.connect(func(): value += 1; value_changed.emit(value))
