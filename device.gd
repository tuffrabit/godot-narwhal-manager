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
onready var deadzoneSize: LineEdit = $tabs/vboxAdvanced/hboxSettings/vboxRight/deadzoneSize/edit
onready var kbModeStartOffsetX: LineEdit = $tabs/vboxAdvanced/hboxSettings/vboxRight/kbModeStartOffsetX/edit
onready var kbModeStartOffsetY: LineEdit = $tabs/vboxAdvanced/hboxSettings/vboxRight/kbModeStartOffsetY/edit

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
			self.deadzoneSize.text = str(globalSettings["deadzoneSize"])
			self.kbModeStartOffsetX.text = str(globalSettings["kbModeOffsets"]["x"])
			self.kbModeStartOffsetY.text = str(globalSettings["kbModeOffsets"]["y"])
		
		self.stickBoundLowX.connect("value_changed", self, "stickBoundLowXValueChanged")
		self.stickBoundHighX.connect("value_changed", self, "stickBoundHighXValueChanged")
		self.stickBoundLowY.connect("value_changed", self, "stickBoundLowYValueChanged")
		self.stickBoundHighY.connect("value_changed", self, "stickBoundHighYValueChanged")

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
	Dialogs.showConfirmationDialog("Are you sure? This will save all configurations to the device, and it will self-reboot.", self, "saveEverything")

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
