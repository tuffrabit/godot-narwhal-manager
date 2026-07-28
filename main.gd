extends Control

var connectScene: PackedScene = preload("res://connect.tscn")
var connectInstance: Connect
var deviceScene: PackedScene = preload("res://device.tscn")
var deviceInstance: Device
var pingFailureCount: int = 0

@onready var pingTimer = $pingTimer

func _ready() -> void:
	SerialHelper.setSerial(GdSerialManager.new())
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
	self.pingTimer.stop()
	SerialHelper.closeSerial()
	self.remove_child(self.deviceInstance)
	self.createConnectScene()
	self.connectInstance.showFields("Disconnected from TuFFpad")

func _on_pingTimer_timeout():
	var response: Dictionary = SerialHelper.sendCommandAndGetResponse("ping")
	
	if response != null and "ping" in response:
		self.pingFailureCount = 0
		pass
	else:
		self.pingFailureCount = self.pingFailureCount + 1
		
		if self.pingFailureCount > 3:
			self.pingTimer.stop()
			SerialHelper.closeSerial()
			self.remove_child(self.deviceInstance)
			self.createConnectScene()
			self.connectInstance.showFields("Something went wrong, no response from TuFFpad")
