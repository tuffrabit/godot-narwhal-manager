extends Node

var serial

func setSerial(serial) -> void:
	self.serial = serial
	
func doHandshake() -> bool:
	var success: bool = false
	
	for portName in self.serial.getAvailablePortNames():
		var connected: bool = self.serial.connectToPort(portName)
		
		if connected:
			self.serial.writeLine("areyouatuffpad?")
			var line = self.serial.readLine()
			
			if line:
				var lineData: Dictionary = parse_json(line)
				
				if lineData != null and lineData["areyouatuffpad?"]:
					success = true
	
	return success

func sendCommandAndGetResponse(command: String, commandValue = null) -> Dictionary:
	var result: Dictionary
	
	if self.serial:
		var jsonData: String
		
		if commandValue != null:
			jsonData = JSON.print({command: commandValue})
		else:
			jsonData = JSON.print([command])
		
		self.serial.writeLine(jsonData)
		var line = self.serial.readLine()
		
		if line:
			var lineData: Dictionary = parse_json(line)
			
			if lineData != null and command in lineData:
				result = lineData
	
	return result
