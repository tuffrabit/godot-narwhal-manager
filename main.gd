extends Control

var connectScene: PackedScene = preload("res://connect.tscn")
var connectInstance: Connect
var deviceScene: PackedScene = preload("res://device.tscn")
var deviceInstance: Device
var pingFailureCount: int = 0

@onready var pingTimer = $pingTimer

func _ready() -> void:
	SerialHelper.setSerial(GdSerialManager.new())
	SerialHelper.device_disconnected.connect(Callable(self, "_on_device_disconnected"))
	self.createConnectScene()
	self.connectInstance.getPortConnection()

func portConnected() -> void:
	self.pingFailureCount = 0
	self.deviceInstance = self.deviceScene.instantiate()
	
	self.remove_child(self.connectInstance)
	self.deviceInstance.connect("disconnectClick", Callable(self, "disconnectClick"))
	self.add_child(self.deviceInstance)
	self.connectInstance.queue_free()
	self.pingTimer.start()

func createConnectScene() -> void:
	self.connectInstance = self.connectScene.instantiate()
	
	self.connectInstance.connect("portConnected", Callable(self, "portConnected"))
	self.add_child(self.connectInstance)

func disconnectClick() -> void:
	var deviceName: String = SerialHelper.getDeviceName()
	# Tear down the UI before closing the port so a port_disconnected signal
	# emitted during close finds no device screen and is ignored.
	self.returnToConnectScreen("Disconnected from " + deviceName)
	SerialHelper.closeSerial()

func returnToConnectScreen(message: String) -> void:
	self.pingTimer.stop()
	
	if self.deviceInstance != null:
		self.remove_child(self.deviceInstance)
		self.deviceInstance.queue_free()
		self.deviceInstance = null
	
	self.createConnectScene()
	self.connectInstance.showFields(message)

func _on_device_disconnected() -> void:
	if self.deviceInstance == null:
		return
	
	self.returnToConnectScreen("Lost connection to " + SerialHelper.getDeviceName())

func _on_pingTimer_timeout():
	var response: Dictionary = SerialHelper.sendCommandAndGetResponse("ping")
	
	if response != null and "ping" in response:
		self.pingFailureCount = 0
	else:
		self.pingFailureCount = self.pingFailureCount + 1
		
		if self.pingFailureCount > 3:
			var deviceName: String = SerialHelper.getDeviceName()
			self.returnToConnectScreen("Something went wrong, no response from " + deviceName)
			SerialHelper.closeSerial()
