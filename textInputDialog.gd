extends ConfirmationDialog

class_name TextInputDialog

signal confirmedWithValue(value)

onready var txtValue: LineEdit = $txtValue

func _ready() -> void:
	self.txtValue.text = ""

func _on_textInputDialog_confirmed():
	self.emit_signal("confirmedWithValue", self.txtValue.text)
