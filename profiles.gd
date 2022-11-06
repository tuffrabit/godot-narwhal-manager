extends VBoxContainer

class_name Profiles

signal profileSelected(profile)

var profiles: Dictionary
var previousActiveProfile: int
var profileToDelete: int

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
			Dialogs.showAlertDialog("Set active profile failed.", "Error")

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

func _on_btnAdd_pressed() -> void:
	if self.listProfiles.get_item_count() < 20:
		Dialogs.showTextInputDialog("New profile name...", self, "createNewProfile")
	else:
		Dialogs.showAlertDialog("You have reached the profile limit.", "Can't create new profile")

func createNewProfile(newProfileName: String) -> void:
	if newProfileName and self.listProfiles.get_item_count() < 20:
		var newProfileNameExists: bool = false
		
		for index in range(self.listProfiles.get_item_count()):
			if newProfileName == self.listProfiles.get_item_text(index):
				newProfileNameExists = true
				break
		
		if newProfileNameExists == false:
			var response: Dictionary = SerialHelper.sendCommandAndGetResponse(
				"createNewProfile", newProfileName)
			
			if response != null and "createNewProfile" in response:
				if response["createNewProfile"]:
					self.listProfiles.add_item(newProfileName)
					self.btnActiveProfile.add_item(newProfileName)
					Dialogs.showAlertDialog("Profile successfully created.", "Success!")
				else:
					Dialogs.showAlertDialog("Profile creation failed on the device.", "Can't create new profile")
		else:
			Dialogs.showAlertDialog("Profile with that name already exists.", "Can't create new profile")

func _on_btnDelete_pressed() -> void:
	var selectedItemIndexes: PoolIntArray = self.listProfiles.get_selected_items()
	
	if selectedItemIndexes.size() > 0:
		if selectedItemIndexes[0] != self.btnActiveProfile.selected:
			self.profileToDelete = selectedItemIndexes[0]
			Dialogs.showConfirmationDialog("Are you sure you want to remove the selected profile", self, "deleteProfile")
		else:
			Dialogs.showAlertDialog("You can't remove the active profile.", "Can't remove profile")

func deleteProfile():
	if self.profileToDelete > -1:
		var profileIndex = self.profileToDelete
		var profileName: String = self.listProfiles.get_item_text(self.profileToDelete)
		self.profileToDelete = -1
		var response: Dictionary = SerialHelper.sendCommandAndGetResponse(
				"deleteProfile", profileName)
		
		if response and "deleteProfile" in response:
			if response["deleteProfile"]:
				self.btnActiveProfile.remove_item(profileIndex)
				self.listProfiles.remove_item(profileIndex)
				Dialogs.showAlertDialog("Profile successfully removed.", "Success!")
			else:
				Dialogs.showAlertDialog("Profile removal failed on the device.", "Can't remove profile")
