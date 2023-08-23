extends VBoxContainer

class_name Device

signal disconnectClick;

var profileScene: PackedScene = preload("res://profile.tscn")

onready var tabs: TabContainer = $tabs
onready var profiles: Profiles = $tabs/hsplitMain/profiles
onready var pnlProfile: Panel = $tabs/hsplitMain/pnlProfile
onready var stickBoundLowX: SpinBox = $tabs/vboxAdvanced/hboxSettings/vboxLeft/stickBoundLowX/edit
onready var stickBoundHighX: SpinBox = $tabs/vboxAdvanced/hboxSettings/vboxLeft/stickBoundHighX/edit
onready var stickBoundLowY: SpinBox = $tabs/vboxAdvanced/hboxSettings/vboxLeft/stickBoundLowY/edit
onready var stickBoundHighY: SpinBox = $tabs/vboxAdvanced/hboxSettings/vboxLeft/stickBoundHighY/edit
onready var deadzoneSize: SpinBox = $tabs/vboxAdvanced/hboxSettings/vboxRight/deadzoneSizeCont/deadzoneSize/edit
onready var kbModeStartOffsetX: SpinBox = $tabs/vboxAdvanced/hboxSettings/vboxRight/kbModeStartOffsetX/edit
onready var kbModeStartOffsetY: SpinBox = $tabs/vboxAdvanced/hboxSettings/vboxRight/kbModeStartOffsetY/edit
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
		"kbModeOffsets" in globalSettings):
			self.stickBoundLowX.value = int(globalSettings["stickBoundaries"]["lowX"])
			self.stickBoundHighX.value = int(globalSettings["stickBoundaries"]["highX"])
			self.stickBoundLowY.value = int(globalSettings["stickBoundaries"]["lowY"])
			self.stickBoundHighY.value = int(globalSettings["stickBoundaries"]["highY"])
			self.deadzoneSize.value = int(globalSettings["deadzoneSize"])
			self.kbModeStartOffsetX.value = int(globalSettings["kbModeOffsets"]["x"])
			self.kbModeStartOffsetY.value = int(globalSettings["kbModeOffsets"]["y"])
			self.stickXAxis.select(int(globalSettings["stickAxesOrientation"]["x"]["axis"]))
			self.stickXAxisReverse.pressed = bool(globalSettings["stickAxesOrientation"]["x"]["reverse"])
			self.stickYAxis.select(int(globalSettings["stickAxesOrientation"]["y"]["axis"]))
			self.stickYAxisReverse.pressed = bool(globalSettings["stickAxesOrientation"]["y"]["reverse"])
		
		self.stickBoundLowX.connect("value_changed", self, "stickBoundLowXValueChanged")
		self.stickBoundHighX.connect("value_changed", self, "stickBoundHighXValueChanged")
		self.stickBoundLowY.connect("value_changed", self, "stickBoundLowYValueChanged")
		self.stickBoundHighY.connect("value_changed", self, "stickBoundHighYValueChanged")
		self.deadzoneSize.connect("value_changed", self, "deadzoneSizeValueChanged")
		self.kbModeStartOffsetX.connect("value_changed", self, "kbModeStartOffsetXValueChanged")
		self.kbModeStartOffsetY.connect("value_changed", self, "kbModeStartOffsetYValueChanged")
		self.stickXAxis.connect("item_selected", self, "stickXAxisItemSelected")
		self.stickXAxisReverse.connect("toggled", self, "stickXAxisReverseToggled")
		self.stickYAxis.connect("item_selected", self, "stickYAxisItemSelected")
		self.stickYAxisReverse.connect("toggled", self, "stickYAxisReverseToggled")

func profileSelected(profile: Dictionary) -> void:
	var profileInstance: Profile = self.profileScene.instance()
	
	for child in self.pnlProfile.get_children():
		self.pnlProfile.remove_child(child)
		child.queue_free()
	
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
	var response: Dictionary = SerialHelper.sendCommandAndGetResponse(
			"setStickXLow", int(value))
	
	if response and "setStickXLow" in response:
		pass

func stickBoundHighXValueChanged(value: float) -> void:
	var response: Dictionary = SerialHelper.sendCommandAndGetResponse(
			"setStickXHigh", int(value))
	
	if response and "setStickXHigh" in response:
		pass

func stickBoundLowYValueChanged(value: float) -> void:
	var response: Dictionary = SerialHelper.sendCommandAndGetResponse(
			"setStickYLow", int(value))
	
	if response and "setStickYLow" in response:
		pass

func stickBoundHighYValueChanged(value: float) -> void:
	var response: Dictionary = SerialHelper.sendCommandAndGetResponse(
			"setStickYHigh", int(value))
	
	if response and "setStickYHigh" in response:
		pass

func deadzoneSizeValueChanged(value: float) -> void:
	var response: Dictionary = SerialHelper.sendCommandAndGetResponse(
			"setDeadzone", int(value))
	
	if response and "setDeadzone" in response:
		pass

func kbModeStartOffsetXValueChanged(value: float) -> void:
	var response: Dictionary = SerialHelper.sendCommandAndGetResponse(
			"setKbModeXStartOffset", int(value))
	
	if response and "setKbModeXStartOffset" in response:
		pass

func kbModeStartOffsetYValueChanged(value: float) -> void:
	var response: Dictionary = SerialHelper.sendCommandAndGetResponse(
			"setKbModeYStartOffset", int(value))
	
	if response and "setKbModeYStartOffset" in response:
		pass

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
