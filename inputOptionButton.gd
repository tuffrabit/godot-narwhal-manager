extends OptionButton

class_name InputOptionButton

func _ready():
	for input in Inputs.getInputs():
		self.add_item(input)
