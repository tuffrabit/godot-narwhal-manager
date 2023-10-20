extends VBoxContainer

class_name Device

signal disconnectClick;

var profileScene: PackedScene = preload("res://profile.tscn")
var profileJoystickScene: PackedScene = preload("res://profileJoystick.tscn")

onready var tabs: TabContainer = $tabs
onready var profiles: Profiles = $tabs/hsplitMain/profiles
onready var pnlProfile: Panel = $tabs/hsplitMain/pnlProfile
onready var stickBoundLowX: SpinBoxSliderCombo = $tabs/vboxAdvanced/hboxSettings/vboxLeft/stickBoundLowX
onready var stickBoundHighX: SpinBoxSliderCombo = $tabs/vboxAdvanced/hboxSettings/vboxLeft/stickBoundHighX
onready var stickBoundLowY: SpinBoxSliderCombo = $tabs/vboxAdvanced/hboxSettings/vboxLeft/stickBoundLowY
onready var stickBoundHighY: SpinBoxSliderCombo = $tabs/vboxAdvanced/hboxSettings/vboxLeft/stickBoundHighY
onready var deadzoneSize: SpinBoxSliderCombo = $tabs/vboxAdvanced/hboxSettings/vboxRight/deadzoneSize
onready var kbModeStartOffsetX: SpinBoxSliderCombo = $tabs/vboxAdvanced/hboxSettings/vboxRight/kbModeStartOffsetX
onready var kbModeStartOffsetY: SpinBoxSliderCombo = $tabs/vboxAdvanced/hboxSettings/vboxRight/kbModeStartOffsetY
onready var kbModeYConeEnd: SpinBoxSliderCombo = $tabs/vboxAdvanced/hboxSettings/vboxRight/kbModeYConeEnd
onready var stickXAxis: OptionButton = $tabs/vboxAdvanced/vboxStickAxesOrientation/hboxAxes/xAxis/axis/axis
onready var stickXAxisReverse: CheckBox = $tabs/vboxAdvanced/vboxStickAxesOrientation/hboxAxes/xAxis/chkReverse
onready var stickYAxis: OptionButton = $tabs/vboxAdvanced/vboxStickAxesOrientation/hboxAxes/yAxis/axis/axis
onready var stickYAxisReverse: CheckBox = $tabs/vboxAdvanced/vboxStickAxesOrientation/hboxAxes/yAxis/chkReverse

func _ready() -> void:
	self.tabs.set_tab_title(0, "Profiles")
	self.tabs.set_tab_title(1, "Advanced")
	self.profiles.connect("profileSelected", self, "profileSelected")
	self.profiles.connect("profileRenamed", self, "profileRenamed")
	
	var response: Dictionary = SerialHelper.sendCommandAndGetResponse("getGlobalSettings")
	
	if response != null and "getGlobalSettings" in response:
		var globalSettings: Dictionary = response["getGlobalSettings"]
		
		if (globalSettings and
		"stickBoundaries" in globalSettings and
		"deadzoneSize" in globalSettings and
		"kbModeOffsets" in globalSettings and
		"kbModeYConeEnd" in globalSettings):
			self.stickBoundLowX.setValueNoSignal(int(globalSettings["stickBoundaries"]["lowX"]))
			self.stickBoundHighX.setValueNoSignal(int(globalSettings["stickBoundaries"]["highX"]))
			self.stickBoundLowY.setValueNoSignal(int(globalSettings["stickBoundaries"]["lowY"]))
			self.stickBoundHighY.setValueNoSignal(int(globalSettings["stickBoundaries"]["highY"]))
			self.deadzoneSize.setValueNoSignal(int(globalSettings["deadzoneSize"]))
			self.kbModeStartOffsetX.setValueNoSignal(int(globalSettings["kbModeOffsets"]["x"]))
			self.kbModeStartOffsetY.setValueNoSignal(int(globalSettings["kbModeOffsets"]["y"]))
			self.kbModeYConeEnd.setValueNoSignal(int(globalSettings["kbModeYConeEnd"]))
			self.stickXAxis.select(int(globalSettings["stickAxesOrientation"]["x"]["axis"]))
			self.stickXAxisReverse.pressed = bool(globalSettings["stickAxesOrientation"]["x"]["reverse"])
			self.stickYAxis.select(int(globalSettings["stickAxesOrientation"]["y"]["axis"]))
			self.stickYAxisReverse.pressed = bool(globalSettings["stickAxesOrientation"]["y"]["reverse"])
		
		self.stickBoundLowX.connect("valueChanged", self, "stickBoundLowXValueChanged")
		self.stickBoundHighX.connect("valueChanged", self, "stickBoundHighXValueChanged")
		self.stickBoundLowY.connect("valueChanged", self, "stickBoundLowYValueChanged")
		self.stickBoundHighY.connect("valueChanged", self, "stickBoundHighYValueChanged")
		self.deadzoneSize.connect("valueChanged", self, "deadzoneSizeValueChanged")
		self.kbModeStartOffsetX.connect("valueChanged", self, "kbModeStartOffsetXValueChanged")
		self.kbModeStartOffsetY.connect("valueChanged", self, "kbModeStartOffsetYValueChanged")
		self.kbModeYConeEnd.connect("valueChanged", self, "kbModeYConeEndValueChanged")
		self.stickXAxis.connect("item_selected", self, "stickXAxisItemSelected")
		self.stickXAxisReverse.connect("toggled", self, "stickXAxisReverseToggled")
		self.stickYAxis.connect("item_selected", self, "stickYAxisItemSelected")
		self.stickYAxisReverse.connect("toggled", self, "stickYAxisReverseToggled")

func profileSelected(profile: Dictionary) -> void:
	for child in self.pnlProfile.get_children():
		self.pnlProfile.remove_child(child)
		child.queue_free()
	
	var profileInstance: ProfileBase = self.profileScene.instance()
	
	if SerialHelper.deviceType == SerialHelper.DeviceType.Tuffpad:
		profileInstance = self.profileScene.instance()
	elif SerialHelper.deviceType == SerialHelper.DeviceType.Tuffjoystick:
		profileInstance = self.profileJoystickScene.instance()
	
	self.pnlProfile.add_child(profileInstance)
	profileInstance.setProfileName(profile['name'])
	profileInstance.setProfileData(profile)

func profileRenamed(oldProfileName: String, newProfileName: String) -> void:
	if oldProfileName and newProfileName:
		
		for child in self.pnlProfile.get_children():
			if child.getProfileName() == oldProfileName:
				child.setProfileName(newProfileName)
				break

func _on_btnDisconnect_pressed() -> void:
	self.emit_signal("disconnectClick")

func _on_btnSave_pressed() -> void:
	Dialogs.showConfirmationDialog("Are you sure? This will save all configurations to the device.", self, "saveEverything2")
	#Dialogs.showConfirmationDialog("Are you sure? This will save all configurations to the device, and it will self-reboot.", self, "saveEverything")

func getCorrectDriveName() -> String:
	var driveName: String = ""
	var dir: Directory = Directory.new()
	var driveCount: int = dir.get_drive_count()
	
	for driveIndex in driveCount:
		var drive: String = dir.get_drive(driveIndex)
		var checkFilename: String = drive + "\\iamindeedatuffpad"
		
		if dir.file_exists(checkFilename):
			driveName = drive
			break
	
	print("Good drivename: " + driveName)
	return driveName

func getCorrectDriveName2() -> String:
	var driveName: String = ""
	var dir: Directory = Directory.new()
	var possibleDrives = ["A:", "B:", "C:", "D:", "E:", "F:", "G:", "H:", "I:", "J:", "K:", "L:", "M:", "N:", "O:", "P:", "Q:", "R:", "S:", "T:", "U:", "V:", "W:", "X:", "Y:", "Z:"]
	
	for possibleDrive in possibleDrives:
		var checkFilename: String = possibleDrive + "\\iamindeedatuffpad"
		
		if dir.file_exists(checkFilename):
			driveName = possibleDrive
			break
	
	return driveName

func saveEverything() -> void:
	var drive: String = self.getCorrectDriveName2()
	
	if drive != "":
		var response: Dictionary = SerialHelper.sendCommandAndGetResponse("getSaveData")
		
		if response != null and "getSaveData" in response:
			var data: String = response["getSaveData"]
			var file: File = File.new()
			var configFilename: String = drive + "\\config.json"
			
			file.open(configFilename, File.WRITE)
			file.store_string(data)
			file.close()
		else:
			Dialogs.showAlertDialog("Could not retrieve valid data to save from TuFFpad.", "Can't save")
	else:
		Dialogs.showAlertDialog("Could not locate a TuFFpad config file location.", "Can't save")

func saveEverything2() -> void:
	var response: Dictionary = SerialHelper.sendCommandAndGetResponse("save")
	
	if response != null and "save" in response:
		pass
	else:
		Dialogs.showAlertDialog("Config write on device failed.", "Can't save")

func stickBoundLowXValueChanged(value: float) -> void:
	var commandName: String = "setStickXLow"
	self.stickBoundLowX.setEditable(false)
	
	var response: Dictionary = SerialHelper.sendCommandAndGetResponse(
		commandName, int(value))
	
	if response and commandName in response and response[commandName]:
		self.stickBoundLowX.setEditable(true)
	else:
		Dialogs.showAlertDialog("Could not update Stick Boundary Low X", "Update failed")

func stickBoundHighXValueChanged(value: float) -> void:
	var commandName: String = "setStickXHigh"
	self.stickBoundHighX.setEditable(false)
	
	var response: Dictionary = SerialHelper.sendCommandAndGetResponse(
		commandName, int(value))
	
	if response and commandName in response and response[commandName]:
		self.stickBoundHighX.setEditable(true)
	else:
		Dialogs.showAlertDialog("Could not update Stick Boundary High X", "Update failed")

func stickBoundLowYValueChanged(value: float) -> void:
	var commandName: String = "setStickYLow"
	self.stickBoundLowY.setEditable(false)
	
	var response: Dictionary = SerialHelper.sendCommandAndGetResponse(
		commandName, int(value))
	
	if response and commandName in response and response[commandName]:
		self.stickBoundLowY.setEditable(true)
	else:
		Dialogs.showAlertDialog("Could not update Stick Boundary Low Y", "Update failed")

func stickBoundHighYValueChanged(value: float) -> void:
	var commandName: String = "setStickYHigh"
	self.stickBoundHighY.setEditable(false)
	
	var response: Dictionary = SerialHelper.sendCommandAndGetResponse(
		commandName, int(value))
	
	if response and commandName in response and response[commandName]:
		self.stickBoundHighY.setEditable(true)
	else:
		Dialogs.showAlertDialog("Could not update Stick Boundary High Y", "Update failed")

func deadzoneSizeValueChanged(value: float) -> void:
	var commandName: String = "setDeadzone"
	self.deadzoneSize.setEditable(false)
	
	var response: Dictionary = SerialHelper.sendCommandAndGetResponse(
		commandName, int(value))
	
	if response and commandName in response and response[commandName]:
		self.deadzoneSize.setEditable(true)
	else:
		Dialogs.showAlertDialog("Could not update Deadzone Size", "Update failed")

func kbModeStartOffsetXValueChanged(value: float) -> void:
	var commandName: String = "setKbModeXStartOffset"
	self.kbModeStartOffsetX.setEditable(false)
	
	var response: Dictionary = SerialHelper.sendCommandAndGetResponse(
		commandName, int(value))
	
	if response and commandName in response and response[commandName]:
		self.kbModeStartOffsetX.setEditable(true)
	else:
		Dialogs.showAlertDialog("Could not update KB Mode Start Offset X", "Update failed")

func kbModeStartOffsetYValueChanged(value: float) -> void:
	var commandName: String = "setKbModeYStartOffset"
	self.kbModeStartOffsetY.setEditable(false)
	
	var response: Dictionary = SerialHelper.sendCommandAndGetResponse(
		commandName, int(value))
	
	if response and commandName in response and response[commandName]:
		self.kbModeStartOffsetY.setEditable(true)
	else:
		Dialogs.showAlertDialog("Could not update KB Mode Start Offset Y", "Update failed")

func kbModeYConeEndValueChanged(value: float) -> void:
	var commandName: String = "setKbModeYConeEnd"
	self.kbModeYConeEnd.setEditable(false)
	
	var response: Dictionary = SerialHelper.sendCommandAndGetResponse(
		commandName, int(value))
	
	if response and commandName in response and response[commandName]:
		self.kbModeYConeEnd.setEditable(true)
	else:
		Dialogs.showAlertDialog("Could not update KB Mode Y Cone End", "Update failed")

func stickXAxisItemSelected(value: int) -> void:
	var response: Dictionary = SerialHelper.sendCommandAndGetResponse(
			"setStickXOrientation", {"axis": value, "reverse": self.stickXAxisReverse.pressed})
	
	if response and "setStickXOrientation" in response:
		pass

func stickXAxisReverseToggled(value: bool) -> void:
	var response: Dictionary = SerialHelper.sendCommandAndGetResponse(
			"setStickXOrientation", {"axis": self.stickXAxis.selected, "reverse": value})
	
	if response and "setStickXOrientation" in response:
		pass

func stickYAxisItemSelected(value: int) -> void:
	var response: Dictionary = SerialHelper.sendCommandAndGetResponse(
			"setStickYOrientation", {"axis": value, "reverse": self.stickYAxisReverse.pressed})
	
	if response and "setStickYOrientation" in response:
		pass

func stickYAxisReverseToggled(value: bool) -> void:
	var response: Dictionary = SerialHelper.sendCommandAndGetResponse(
			"setStickYOrientation", {"axis": self.stickYAxis.selected, "reverse": value})
	
	if response and "setStickYOrientation" in response:
		pass
