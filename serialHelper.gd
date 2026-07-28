extends Node

enum DeviceType {None, Tuffpad, Tuffjoystick}

const PARITY_NONE := 0
const STOP_BITS_ONE := 1
const BAUD_RATE := 115200
const DATA_BITS := 8
const TIMEOUT_MS := 100
const HANDSHAKE_TIMEOUT_MS := 1000
const COMMAND_TIMEOUT_MS := 1000
const POLL_INTERVAL_MS := 5

signal stick_values_received(raw: Dictionary, calculated: Dictionary)

var manager: GdSerialManager
var deviceType: int = DeviceType.None

var _currentPort: String = ""
var _pendingCommand: String = ""
var _pendingResponse: Dictionary = {}
var _handshakeLines: Array[Dictionary] = []
var _stickPollingActive: bool = false
var _stickResponsePending: bool = false

func setSerial(serial: GdSerialManager) -> void:
	manager = serial
	manager.data_received.connect(_on_data_received)
	manager.port_disconnected.connect(_on_port_disconnected)

func _process(_delta: float) -> void:
	if manager != null:
		manager.poll_events()

func doHandshake() -> bool:
	deviceType = DeviceType.None
	_currentPort = ""
	_pendingCommand = ""
	_pendingResponse = {}
	_handshakeLines.clear()
	
	if manager == null:
		return false
	
	_closeAllPorts()
	
	var ports: Dictionary = manager.list_ports()
	var openedPorts: Array[String] = []
	var probeLine: String = "areyouatuffpad?"
	
	for i in ports:
		var portInfo: Dictionary = ports[i]
		var portName: String = portInfo.get("port_name", "")
		
		if portName.is_empty():
			continue
		
		if manager.open(portName, BAUD_RATE, TIMEOUT_MS, GdSerialManager.MODE_LINE_BUFFERED):
			openedPorts.append(portName)
			manager.write(portName, (probeLine + "\n").to_utf8_buffer())
	
	var elapsed: float = 0.0
	var handshakeFound: bool = false
	
	while elapsed < HANDSHAKE_TIMEOUT_MS and not handshakeFound:
		manager.poll_events()
		
		for entry in _handshakeLines:
			var lineData = JSON.parse_string(entry.line)
			
			if lineData != null:
				if lineData.get("areyouatuffpad?", false):
					deviceType = DeviceType.Tuffpad
					_currentPort = entry.port
					handshakeFound = true
					break
				elif lineData.get("areyouatuffjoystick?", false):
					deviceType = DeviceType.Tuffjoystick
					_currentPort = entry.port
					handshakeFound = true
					break
		
		_handshakeLines.clear()
		
		if not handshakeFound:
			OS.delay_msec(POLL_INTERVAL_MS)
			elapsed += POLL_INTERVAL_MS
	
	for portName in openedPorts:
		if handshakeFound and portName == _currentPort:
			continue
		manager.close(portName)
	
	return handshakeFound

func sendCommandAndGetResponse(command: String, commandValue = null) -> Dictionary:
	var result: Dictionary = {}
	
	if manager == null or _currentPort.is_empty() or not manager.is_open(_currentPort):
		return result
	
	var jsonData: String
	
	if commandValue != null:
		jsonData = JSON.stringify({command: commandValue})
	else:
		jsonData = JSON.stringify([command])
	
	_pendingCommand = command
	_pendingResponse = {}
	
	manager.write(_currentPort, (jsonData + "\n").to_utf8_buffer())
	
	var elapsed: float = 0.0
	
	while elapsed < COMMAND_TIMEOUT_MS:
		manager.poll_events()
		
		if _pendingCommand == "":
			result = _pendingResponse
			break
		
		OS.delay_msec(POLL_INTERVAL_MS)
		elapsed += POLL_INTERVAL_MS
	
	_pendingCommand = ""
	return result

func startStickPolling() -> void:
	_stickPollingActive = true
	_requestStickValues()

func stopStickPolling() -> void:
	_stickPollingActive = false

func _requestStickValues() -> void:
	if manager == null or _currentPort.is_empty() or not manager.is_open(_currentPort):
		return
	if _stickResponsePending:
		return
	
	_stickResponsePending = true
	manager.write(_currentPort, "[\"readStickValues\"]\n".to_utf8_buffer())

func closeSerial() -> void:
	_closeAllPorts()
	_currentPort = ""
	deviceType = DeviceType.None
	_pendingCommand = ""
	_pendingResponse = {}
	_handshakeLines.clear()
	_stickPollingActive = false
	_stickResponsePending = false

func _on_data_received(port: String, data: PackedByteArray) -> void:
	var line: String = data.get_string_from_utf8().strip_edges()
	
	if line.is_empty():
		return
	
	if _pendingCommand != "":
		var lineData = JSON.parse_string(line)
		
		if lineData != null and _pendingCommand in lineData:
			_pendingResponse = lineData
			_pendingCommand = ""
			return
	
	if _currentPort == "":
		_handshakeLines.append({"port": port, "line": line})
	elif port == _currentPort:
		var lineData = JSON.parse_string(line)
		
		if lineData != null and lineData.has("readStickValues"):
			var values = lineData["readStickValues"]
			
			if values is Array and values.size() >= 2:
				stick_values_received.emit(values[0], values[1])
			
			_stickResponsePending = false

func _on_port_disconnected(port: String) -> void:
	if port == _currentPort:
		_currentPort = ""
		deviceType = DeviceType.None

func _closeAllPorts() -> void:
	if manager == null:
		return
	
	var ports: Dictionary = manager.list_ports()
	
	for i in ports:
		var portName: String = ports[i].get("port_name", "")
		
		if not portName.is_empty() and manager.is_open(portName):
			manager.close(portName)
