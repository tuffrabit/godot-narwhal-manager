extends VBoxContainer

class_name Profiles

signal profileSelected(profile)

var profiles: Dictionary

onready var listProfiles: ItemList = $listProfiles

func _ready() -> void:
	self.getProfileNames()

func getProfileNames() -> void:
	self.listProfiles.clear()
	self.profiles = {}
	var response: Dictionary = SerialHelper.sendCommandAndGetResponse("getProfiles")
	
	if response != null and "getProfiles" in response:
		var profileNames: Array = response["getProfiles"]
		
		if profileNames:
			for profileName in profileNames:
				self.listProfiles.add_item(str(profileName))

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
