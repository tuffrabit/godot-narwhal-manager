extends HBoxContainer

class_name Profile

onready var btnKey1: InputOptionButton = $vboxLeft/hboxKey1/button
onready var btnKey2: InputOptionButton = $vboxLeft/hboxKey2/button
onready var btnKey3: InputOptionButton = $vboxLeft/hboxKey3/button
onready var btnKey4: InputOptionButton = $vboxLeft/hboxKey4/button
onready var btnKey5: InputOptionButton = $vboxLeft/hboxKey5/button
onready var btnKey6: InputOptionButton = $vboxLeft/hboxKey6/button
onready var btnKey7: InputOptionButton = $vboxLeft/hboxKey7/button
onready var btnKey8: InputOptionButton = $vboxLeft/hboxKey8/button
onready var btnKey9: InputOptionButton = $vboxLeft/hboxKey9/button
onready var btnKey10: InputOptionButton = $vboxLeft/hboxKey10/button
onready var btnThumbKey: InputOptionButton = $vboxLeft/thumbKey/button
onready var btnKey11: InputOptionButton = $vboxMiddle/hboxKey11/button
onready var btnKey12: InputOptionButton = $vboxMiddle/hboxKey12/button
onready var btnKey13: InputOptionButton = $vboxMiddle/hboxKey13/button
onready var btnKey14: InputOptionButton = $vboxMiddle/hboxKey14/button
onready var btnKey15: InputOptionButton = $vboxMiddle/hboxKey15/button
onready var btnKey16: InputOptionButton = $vboxMiddle/hboxKey16/button
onready var btnKey17: InputOptionButton = $vboxMiddle/hboxKey17/button
onready var btnKey18: InputOptionButton = $vboxMiddle/hboxKey18/button
onready var btnKey19: InputOptionButton = $vboxMiddle/hboxKey19/button
onready var btnKey20: InputOptionButton = $vboxMiddle/hboxKey20/button
onready var btnJoystickButton: InputOptionButton = $vboxMiddle/joystickButton/button
onready var btnKbModeEnabled: CheckButton = $vboxRight/kbModeEnabled/button
onready var btnKbModeUp: InputOptionButton = $vboxRight/kbModeUp/button
onready var btnKbModeDown: InputOptionButton = $vboxRight/kbModeDown/button
onready var btnKbModeLeft: InputOptionButton = $vboxRight/kbModeLeft/button
onready var btnKbModeRight: InputOptionButton = $vboxRight/kbModeRight/button
onready var btnDpadUp: InputOptionButton = $vboxRight/dpadUp/button
onready var btnDpadDown: InputOptionButton = $vboxRight/dpadDown/button
onready var btnDpadLeft: InputOptionButton = $vboxRight/dpadLeft/button
onready var btnDpadRight: InputOptionButton = $vboxRight/dpadRight/button
onready var btnRgb: ColorPickerButton = $vboxRight/rgb/button

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
