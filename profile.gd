extends GridContainer

class_name Profile

onready var txtKey1: TextEdit = $txtKey1

func setProfileData(profile: Dictionary) -> void:
	self.txtKey1.text = profile["keys"][0]
