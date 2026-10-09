extends Control
class_name CounterControl

signal value_changed(new_value: int)
@onready var labelTitle: Label = $VBoxContainer/Label
@onready var labelValue: Label = $VBoxContainer/HBoxContainer/LabelValue
@onready var btnMinus: Button = $VBoxContainer/HBoxContainer/BtnMinus
@onready var btnPlus: Button = $VBoxContainer/HBoxContainer/BtnPlus

@export var title: String = "Counter":
	set(v):
		title = v
		if is_node_ready(): labelTitle.text = v

@export var value: int = 0:
	set(v):
		value = max(0, v)
		#if is_node_ready(): $HBoxContainer/LabelValue.text = str(value)
		if is_node_ready(): labelValue.text = str(value)

func _ready() -> void:
	#$HBoxContainer/LabelTitle.text = title
	#$HBoxContainer/LabelValue.text = str(value)
	labelValue.text = str(value)
	#$HBoxContainer/BtnMinus.pressed.connect(func(): value -= 1; value_changed.emit(value))
	#$HBoxContainer/BtnPlus.pressed.connect(func(): value += 1; value_changed.emit(value))
	btnMinus.pressed.connect(func(): value -= 1; value_changed.emit(value))
	btnPlus.pressed.connect(func(): value += 1; value_changed.emit(value))

func getValue() -> int:
	return value

func setValue(_value: int ):
	value = _value

func setTitle(_title: String):
	title = _title
