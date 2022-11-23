extends HBoxContainer

class_name Profile

onready var vboxLeft: VBoxContainer = $vboxLeft
onready var vboxMiddle: VBoxContainer = $vboxMiddle
onready var vboxRight: VBoxContainer = $vboxRight
onready var btnKey1: InputOptionButton = $vboxLeft/hboxKey1/key0
onready var btnKey2: InputOptionButton = $vboxLeft/hboxKey2/key1
onready var btnKey3: InputOptionButton = $vboxLeft/hboxKey3/key2
onready var btnKey4: InputOptionButton = $vboxLeft/hboxKey4/key3
onready var btnKey5: InputOptionButton = $vboxLeft/hboxKey5/key4
onready var btnKey6: InputOptionButton = $vboxLeft/hboxKey6/key5
onready var btnKey7: InputOptionButton = $vboxLeft/hboxKey7/key6
onready var btnKey8: InputOptionButton = $vboxLeft/hboxKey8/key7
onready var btnKey9: InputOptionButton = $vboxLeft/hboxKey9/key8
onready var btnKey10: InputOptionButton = $vboxLeft/hboxKey10/key9
onready var btnThumbKey: InputOptionButton = $vboxLeft/thumbKey/thumbButton
onready var btnKey11: InputOptionButton = $vboxMiddle/hboxKey11/key10
onready var btnKey12: InputOptionButton = $vboxMiddle/hboxKey12/key11
onready var btnKey13: InputOptionButton = $vboxMiddle/hboxKey13/key12
onready var btnKey14: InputOptionButton = $vboxMiddle/hboxKey14/key13
onready var btnKey15: InputOptionButton = $vboxMiddle/hboxKey15/key14
onready var btnKey16: InputOptionButton = $vboxMiddle/hboxKey16/key15
onready var btnKey17: InputOptionButton = $vboxMiddle/hboxKey17/key16
onready var btnKey18: InputOptionButton = $vboxMiddle/hboxKey18/key17
onready var btnKey19: InputOptionButton = $vboxMiddle/hboxKey19/key18
onready var btnKey20: InputOptionButton = $vboxMiddle/hboxKey20/key19
onready var btnJoystickButton: InputOptionButton = $vboxMiddle/joystickButton/joystickButton
onready var btnKbModeEnabled: CheckButton = $vboxRight/kbModeEnabled/isKbModeEnabled
onready var btnKbModeUp: InputOptionButton = $vboxRight/kbModeUp/kbup
onready var btnKbModeDown: InputOptionButton = $vboxRight/kbModeDown/kbdown
onready var btnKbModeLeft: InputOptionButton = $vboxRight/kbModeLeft/kbleft
onready var btnKbModeRight: InputOptionButton = $vboxRight/kbModeRight/kbright
onready var btnDpadUp: InputOptionButton = $vboxRight/dpadUp/dpadup
onready var btnDpadDown: InputOptionButton = $vboxRight/dpadDown/dpaddown
onready var btnDpadLeft: InputOptionButton = $vboxRight/dpadLeft/dpadleft
onready var btnDpadRight: InputOptionButton = $vboxRight/dpadRight/dpadright
onready var btnRgb: ColorPickerButton = $vboxRight/rgb/rgb

func setProfileData(profile: Dictionary) -> void:
	self.btnKey1.select(Inputs.getIndexFromName(profile["keys"][0]))
	self.btnKey2.select(Inputs.getIndexFromName(profile["keys"][1]))
	self.btnKey3.select(Inputs.getIndexFromName(profile["keys"][2]))
	self.btnKey4.select(Inputs.getIndexFromName(profile["keys"][3]))
	self.btnKey5.select(Inputs.getIndexFromName(profile["keys"][4]))
	self.btnKey6.select(Inputs.getIndexFromName(profile["keys"][5]))
	self.btnKey7.select(Inputs.getIndexFromName(profile["keys"][6]))
	self.btnKey8.select(Inputs.getIndexFromName(profile["keys"][7]))
	self.btnKey9.select(Inputs.getIndexFromName(profile["keys"][8]))
	self.btnKey10.select(Inputs.getIndexFromName(profile["keys"][9]))
	self.btnKey11.select(Inputs.getIndexFromName(profile["keys"][10]))
	self.btnKey12.select(Inputs.getIndexFromName(profile["keys"][11]))
	self.btnKey13.select(Inputs.getIndexFromName(profile["keys"][12]))
	self.btnKey14.select(Inputs.getIndexFromName(profile["keys"][13]))
	self.btnKey15.select(Inputs.getIndexFromName(profile["keys"][14]))
	self.btnKey16.select(Inputs.getIndexFromName(profile["keys"][15]))
	self.btnKey17.select(Inputs.getIndexFromName(profile["keys"][16]))
	self.btnKey18.select(Inputs.getIndexFromName(profile["keys"][17]))
	self.btnKey19.select(Inputs.getIndexFromName(profile["keys"][18]))
	self.btnKey20.select(Inputs.getIndexFromName(profile["keys"][19]))
	self.btnThumbKey.select(Inputs.getIndexFromName(profile["thumbButton"]))
	self.btnJoystickButton.select(Inputs.getIndexFromName(profile["joystickButton"]))
	self.btnKbModeEnabled.pressed = profile["isKbModeEnabled"]
	self.btnKbModeUp.select(Inputs.getIndexFromName(profile["kbMode"]["up"]))
	self.btnKbModeDown.select(Inputs.getIndexFromName(profile["kbMode"]["down"]))
	self.btnKbModeLeft.select(Inputs.getIndexFromName(profile["kbMode"]["left"]))
	self.btnKbModeRight.select(Inputs.getIndexFromName(profile["kbMode"]["right"]))
	self.btnDpadUp.select(Inputs.getIndexFromName(profile["dpad"]["up"]))
	self.btnDpadDown.select(Inputs.getIndexFromName(profile["dpad"]["down"]))
	self.btnDpadLeft.select(Inputs.getIndexFromName(profile["dpad"]["left"]))
	self.btnDpadRight.select(Inputs.getIndexFromName(profile["dpad"]["right"]))
	self.btnRgb.color = Color8(profile["rgb"]["red"], profile["rgb"]["green"], profile["rgb"]["blue"])
	
	self.setupInputBindingsForChildren(self.vboxLeft)
	self.setupInputBindingsForChildren(self.vboxMiddle)
	self.setupInputBindingsForChildren(self.vboxRight)

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
			"setProfileValue", {"name": nodeName, "value": Inputs.getInputs()[selectionIndex]})
	
	if response and "setProfileValue" in response:
		pass

func checkButtonToggled(newState: bool, nodeName: String) -> void:
	var response: Dictionary = SerialHelper.sendCommandAndGetResponse(
			"setProfileValue", {"name": nodeName, "value": newState})
	
	if response and "setProfileValue" in response:
		pass

func colorPickerButtonColorChanged(newColor: Color, nodeName: String) -> void:
	var response: Dictionary = SerialHelper.sendCommandAndGetResponse(
			"setProfileValue", {"name": nodeName, "value": newColor.to_html(false)})
	
	if response and "setProfileValue" in response:
		pass
