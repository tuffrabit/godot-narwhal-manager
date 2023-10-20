extends HBoxContainer

class_name ProfileBase

var profileName: String = ""

func getProfileName() -> String:
	return self.profileName

func setProfileName(name: String) -> void:
	self.profileName = name

func setupInputBindingsForChildren(parent: Container) -> void:
	for container in parent.get_children():
		for childContainer in container.get_children():
			print(childContainer.get_class())
			if childContainer.is_class("OptionButton"):
				childContainer.connect("item_selected", self, "optionButtonSelectionChanged", [childContainer.name])
			
			if childContainer.is_class("CheckButton"):
				childContainer.connect("toggled", self, "checkButtonToggled", [childContainer.name])
			
			if childContainer.is_class("ColorPickerButton"):
				childContainer.connect("color_changed", self, "colorPickerButtonColorChanged", [childContainer.name])

func optionButtonSelectionChanged(selectionIndex: int, nodeName: String) -> void:
	var response: Dictionary = SerialHelper.sendCommandAndGetResponse(
			"setProfileValue", {"profile": self.profileName, "valueName": nodeName, "value": Inputs.getInputs()[selectionIndex]})
	
	if response and "setProfileValue" in response:
		pass

func checkButtonToggled(newState: bool, nodeName: String) -> void:
	var response: Dictionary = SerialHelper.sendCommandAndGetResponse(
			"setProfileValue", {"profile": self.profileName, "valueName": nodeName, "value": newState})
	
	if response and "setProfileValue" in response:
		pass

func colorPickerButtonColorChanged(newColor: Color, nodeName: String) -> void:
	var response: Dictionary = SerialHelper.sendCommandAndGetResponse(
			"setProfileValue", {"profile": self.profileName, "valueName": nodeName, "value": newColor.to_html(false)})
	
	if response and "setProfileValue" in response:
		pass
