extends CenterContainer

class_name Connect

signal portConnected;

onready var lblError: Label = $vboxMain/lblError
onready var btnRetry: Button = $vboxMain/btnRetry

func getPortConnection() -> void:
	self.hideFields()
	var isConnected = SerialHelper.doHandshake()
	
	if isConnected:
		self.emit_signal("portConnected")
	else:
		self.showFields("Could not find a TuFFpad")

func showFields(errorMessage: String = "") -> void:
	self.lblError.text = errorMessage
	self.lblError.visible = true
	self.btnRetry.visible = true

func hideFields() -> void:
	self.lblError.visible = false
	self.btnRetry.visible = false

func _on_btnRetry_pressed():
	self.getPortConnection()
