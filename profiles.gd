extends VBoxContainer

class_name Profiles

signal profileSelected(profile)

var profiles: Dictionary
var previousActiveProfile: int

onready var btnActiveProfile: OptionButton = $hboxActiveProfile/btnActiveProfile
onready var listProfiles: ItemList = $listProfiles

func _ready() -> void:
	self.getProfileNames()
	self.getActiveProfile()

func getProfileNames() -> void:
	self.btnActiveProfile.clear()
	self.listProfiles.clear()
	self.profiles = {}
	var response: Dictionary = SerialHelper.sendCommandAndGetResponse("getProfiles")
	
	if response != null and "getProfiles" in response:
		var profileNames: Array = response["getProfiles"]
		
		if profileNames:
			for profileName in profileNames:
				self.btnActiveProfile.add_item(str(profileName))
				self.listProfiles.add_item(str(profileName))

func getActiveProfile() -> void:
	var response: Dictionary = SerialHelper.sendCommandAndGetResponse("getActiveProfile")
	
	if response != null and "getActiveProfile" in response:
		var activeProfile: String = response["getActiveProfile"]
		var newActiveIndex: int = -1
		
		if activeProfile != null and activeProfile != "":
			for index in range(self.btnActiveProfile.get_item_count()):
				if self.btnActiveProfile.get_item_text(index) == activeProfile:
					newActiveIndex = index
					break
		
		if newActiveIndex > -1:
			self.btnActiveProfile.select(newActiveIndex)

func setActiveProfile(profileName: String) -> void:
	var response: Dictionary = SerialHelper.sendCommandAndGetResponse("setActiveProfile", profileName)
	
	if response != null and "setActiveProfile" in response:
		if response["setActiveProfile"] == false:
			self.btnActiveProfile.select(self.previousActiveProfile)

func getProfile(profileName: String) -> Dictionary:
	var profile: Dictionary
	
	if profileName in self.profiles:
		profile = self.profiles[profileName]
	else:
		var response: Dictionary = SerialHelper.sendCommandAndGetResponse("getProfile", profileName)
		
		if response != null and "getProfile" in response:
			profile = response["getProfile"]
			self.profiles[profileName] = profile
	
	return profile

func _on_listProfiles_item_selected(index):
	var profileName: String = self.listProfiles.get_item_text(index)
	
	if profileName:
		var profile: Dictionary = self.getProfile(profileName)
		
		if profile:
			self.emit_signal("profileSelected", profile)

func _on_btnActiveProfile_item_selected(index):
	self.previousActiveProfile = index
	var profileName: String = self.btnActiveProfile.get_item_text(index)
	
	if profileName:
		self.setActiveProfile(profileName)
