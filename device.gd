extends VBoxContainer

class_name Device

var profileScene: PackedScene = preload("res://profile.tscn")

onready var tabs: TabContainer = $tabs
onready var profiles: Profiles = $tabs/hsplitMain/profiles
onready var pnlProfile: Panel = $tabs/hsplitMain/pnlProfile
onready var stickBoundLowX: LineEdit = $tabs/vboxAdvanced/hboxSettings/vboxLeft/stickBoundLowX/edit
onready var stickBoundHighX: LineEdit = $tabs/vboxAdvanced/hboxSettings/vboxLeft/stickBoundHighX/edit
onready var stickBoundLowY: LineEdit = $tabs/vboxAdvanced/hboxSettings/vboxLeft/stickBoundLowY/edit
onready var stickBoundHighY: LineEdit = $tabs/vboxAdvanced/hboxSettings/vboxLeft/stickBoundHighY/edit
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
			self.stickBoundLowX.text = str(globalSettings["stickBoundaries"]["lowX"])
			self.stickBoundHighX.text = str(globalSettings["stickBoundaries"]["highX"])
			self.stickBoundLowY.text = str(globalSettings["stickBoundaries"]["lowY"])
			self.stickBoundHighY.text = str(globalSettings["stickBoundaries"]["highY"])
			self.deadzoneSize.text = str(globalSettings["deadzoneSize"])
			self.kbModeStartOffsetX.text = str(globalSettings["kbModeOffsets"]["x"])
			self.kbModeStartOffsetY.text = str(globalSettings["kbModeOffsets"]["y"])

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
