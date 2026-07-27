extends Node

enum DeviceType {None, Tuffpad, Tuffjoystick}

const PARITY_NONE := 0
const STOP_BITS_ONE := 1
const BAUD_RATE := 115200
const DATA_BITS := 8
const TIMEOUT_MS := 1000

var serial: GdSerial
var deviceType: int = DeviceType.None

func setSerial(serial: GdSerial) -> void:
	self.serial = serial

func doHandshake() -> bool:
	deviceType = DeviceType.None
	
	if serial == null:
		return false
	
	if serial.is_open():
		serial.close()
	
	var ports: Dictionary = serial.list_ports()
	
	for i in ports:
		var portInfo: Dictionary = ports[i]
		var portName: String = portInfo.get("port_name", "")
		
		if portName.is_empty():
			continue
		
		serial.set_port(portName)
		serial.set_baud_rate(BAUD_RATE)
		serial.set_data_bits(DATA_BITS)
		serial.set_parity(PARITY_NONE)
		serial.set_stop_bits(STOP_BITS_ONE)
		serial.set_timeout(TIMEOUT_MS)
		
		if not serial.open():
			continue
		
		serial.writeline("areyouatuffpad?")
		var line: String = serial.readline()
		
		if not line.is_empty():
			var lineData = JSON.parse_string(line)
			
			if lineData != null:
				if lineData.get("areyouatuffpad?", false):
					deviceType = DeviceType.Tuffpad
					return true
				elif lineData.get("areyouatuffjoystick?", false):
					deviceType = DeviceType.Tuffjoystick
					return true
		
		serial.close()
	
	return false

func sendCommandAndGetResponse(command: String, commandValue = null) -> Dictionary:
	var result: Dictionary = {}
	
	if serial == null or not serial.is_open():
		return result
	
	var jsonData: String
	
	if commandValue != null:
		jsonData = JSON.stringify({command: commandValue})
	else:
		jsonData = JSON.stringify([command])
	
	serial.writeline(jsonData)
	var line: String = serial.readline()
	
	if not line.is_empty():
		var lineData = JSON.parse_string(line)
		
		if lineData != null and command in lineData:
			result = lineData
	
	return result
