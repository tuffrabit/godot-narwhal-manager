extends Node

enum DeviceType {None, Tuffpad, Tuffjoystick}

var serial
var deviceType: int = DeviceType.None

func setSerial(serial) -> void:
	self.serial = serial
	
func doHandshake() -> bool:
	var success: bool = false
	
	if self.serial == null:
		return success
	
	for portName in self.serial.getAvailablePortNames():
		var connected: bool = self.serial.connectToPort(portName)
		
		if connected:
			self.serial.writeLine("areyouatuffpad?")
			var line = self.serial.readLine()
			
			if line:
				var lineData = JSON.parse_string(line)
				
				if lineData != null:
					if lineData.has("areyouatuffpad?") and lineData["areyouatuffpad?"]:
						self.deviceType = DeviceType.Tuffpad
						success = true
					elif lineData.has("areyouatuffjoystick?") and lineData["areyouatuffjoystick?"]:
						self.deviceType = DeviceType.Tuffjoystick
						success = true
					
					if success:
						break
	
	return success

func sendCommandAndGetResponse(command: String, commandValue = null) -> Dictionary:
	var result: Dictionary
	
	if self.serial:
		var jsonData: String
		
		if commandValue != null:
			jsonData = JSON.stringify({command: commandValue})
		else:
			jsonData = JSON.stringify([command])
		
		self.serial.writeLine(jsonData)
		var line = self.serial.readLine()
		
		if line:
			var lineData = JSON.parse_string(line)
			
			if lineData != null and command in lineData:
				result = lineData
	
	return result
