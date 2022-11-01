extends VBoxContainer

class_name Device

var profileScene: PackedScene = preload("res://profile.tscn")

onready var profiles: Profiles = $hsplitMain/profiles
onready var pnlProfile: Panel = $hsplitMain/pnlProfile

func _ready() -> void:
	self.profiles.connect("profileSelected", self, "profileSelected")

func profileSelected(profile: Dictionary) -> void:
	var profileInstance: Profile = self.profileScene.instance()
	
	for child in self.pnlProfile.get_children():
		self.pnlProfile.remove_child(child)
		child.queue_free()
	
	self.pnlProfile.add_child(profileInstance)
	profileInstance.setProfileData(profile)
