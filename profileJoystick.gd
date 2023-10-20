extends ProfileBase

class_name ProfileJoystick

onready var vboxLeft: VBoxContainer = $vboxLeft
onready var vboxMiddle: VBoxContainer = $vboxMiddle
onready var vboxRight: VBoxContainer = $vboxRight
onready var btnJoystickButton: InputOptionButton = $vboxLeft/joystickButton/joystickButton
onready var btnKbModeEnabled: CheckButton = $vboxLeft/kbModeEnabled/isKbModeEnabled
onready var btnKbModeUp: InputOptionButton = $vboxLeft/kbModeUp/kbup
onready var btnKbModeDown: InputOptionButton = $vboxLeft/kbModeDown/kbdown
onready var btnKbModeLeft: InputOptionButton = $vboxLeft/kbModeLeft/kbleft
onready var btnKbModeRight: InputOptionButton = $vboxLeft/kbModeRight/kbright

func getProfileName() -> String:
	return self.profileName

func setProfileName(name: String) -> void:
	self.profileName = name

func setProfileData(profile: Dictionary) -> void:
	self.btnJoystickButton.select(Inputs.getIndexFromName(profile["joystickButton"]))
	self.btnKbModeEnabled.pressed = profile["isKbModeEnabled"]
	self.btnKbModeUp.select(Inputs.getIndexFromName(profile["kbMode"]["up"]))
	self.btnKbModeDown.select(Inputs.getIndexFromName(profile["kbMode"]["down"]))
	self.btnKbModeLeft.select(Inputs.getIndexFromName(profile["kbMode"]["left"]))
	self.btnKbModeRight.select(Inputs.getIndexFromName(profile["kbMode"]["right"]))
	
	self.setupInputBindingsForChildren(self.vboxLeft)
	self.setupInputBindingsForChildren(self.vboxMiddle)
	self.setupInputBindingsForChildren(self.vboxRight)
