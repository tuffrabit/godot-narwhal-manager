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
const STICK_REQUEST_INTERVAL_MS := 16
const STICK_RESPONSE_TIMEOUT_MS := 150

signal stick_values_received(raw: Dictionary, calculated: Dictionary)
signal device_disconnected()

var manager: GdSerialManager
var deviceType: int = DeviceType.None

var _currentPort: String = ""
var _pendingCommand: String = ""
var _pendingResponse: Dictionary = {}
var _handshakeLines: Array[Dictionary] = []
var _stickPollingActive: bool = false
var _stickResponsePending: bool = false
var _stickRequestTime: int = 0

func setSerial(serial: GdSerialManager) -> void:
	manager = serial
	manager.data_received.connect(_on_data_received)
	manager.port_disconnected.connect(_on_port_disconnected)

func _process(_delta: float) -> void:
	if manager == null:
		return
	
	manager.poll_events()
	_updateStickPolling()

func getDeviceName() -> String:
	match deviceType:
		DeviceType.Tuffpad:
			return "TuFFpad"
		DeviceType.Tuffjoystick:
			return "TuFFjoystick"
		_:
			return "TuFFrabit device"

func doHandshake() -> bool:
	deviceType = DeviceType.None
	_currentPort = ""
	_pendingCommand = ""
	_pendingResponse = {}
	_handshakeLines.clear()
	_stickPollingActive = false
	_stickResponsePending = false
	
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
	_stickResponsePending = false
	_stickRequestTime = 0
	_updateStickPolling()

func stopStickPolling() -> void:
	_stickPollingActive = false
	_stickResponsePending = false

# Self-paced stick polling: a new request goes out as soon as the previous
# response arrives (capped at STICK_REQUEST_INTERVAL_MS), so the graphs track
# the device instead of a fixed timer. If a response is lost, the watchdog
# re-requests after STICK_RESPONSE_TIMEOUT_MS instead of stalling forever.
func _updateStickPolling() -> void:
	if not _stickPollingActive:
		return
	if manager == null or _currentPort.is_empty() or not manager.is_open(_currentPort):
		return
	
	var now: int = Time.get_ticks_msec()
	
	if _stickResponsePending:
		if now - _stickRequestTime < STICK_RESPONSE_TIMEOUT_MS:
			return
		_stickResponsePending = false
	
	if now - _stickRequestTime >= STICK_REQUEST_INTERVAL_MS:
		_stickResponsePending = true
		_stickRequestTime = now
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
			_stickResponsePending = false
			
			if _stickPollingActive:
				var values = lineData["readStickValues"]
				
				if values is Array and values.size() >= 2 and values[0] is Dictionary and values[1] is Dictionary:
					stick_values_received.emit(values[0], values[1])

func _on_port_disconnected(port: String) -> void:
	if port == _currentPort:
		# Emit before clearing state so handlers can still read the device name.
		device_disconnected.emit()
		_currentPort = ""
		deviceType = DeviceType.None
		_pendingCommand = ""
		_pendingResponse = {}
		_stickPollingActive = false
		_stickResponsePending = false

func _closeAllPorts() -> void:
	if manager == null:
		return
	
	var ports: Dictionary = manager.list_ports()
	
	for i in ports:
		var portName: String = ports[i].get("port_name", "")
		
		if not portName.is_empty() and manager.is_open(portName):
			manager.close(portName)
