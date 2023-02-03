extends Control

var connectScene: PackedScene = preload("res://connect.tscn")
var connectInstance: Connect
var deviceScene: PackedScene = preload("res://device.tscn")
var deviceInstance: Device

onready var serial = $serial
onready var pingTimer = $pingTimer

func _ready() -> void:
	SerialHelper.setSerial(self.serial)
	self.createConnectScene()
	self.connectInstance.getPortConnection()

func portConnected() -> void:
	self.deviceInstance = self.deviceScene.instance()
	
	self.remove_child(self.connectInstance)
	self.deviceInstance.connect("disconnectClick", self, "disconnectClick")
	self.add_child(self.deviceInstance)
	self.connectInstance.queue_free()
	self.pingTimer.start()

func createConnectScene() -> void:
	self.connectInstance = self.connectScene.instance()
	
	self.connectInstance.connect("portConnected", self, "portConnected")
	self.add_child(self.connectInstance)

func disconnectClick() -> void:
	self.pingTimer.stop()
	self.remove_child(self.deviceInstance)
	self.createConnectScene()
	self.connectInstance.showFields("Disconnected from TuFFpad")

func _on_pingTimer_timeout():
	var response: Dictionary = SerialHelper.sendCommandAndGetResponse("ping")
	
	if response != null and "ping" in response:
		pass
	else:
		self.pingTimer.stop()
		self.remove_child(self.deviceInstance)
		self.createConnectScene()
		self.connectInstance.showFields("Something went wrong, no response from TuFFpad")
