extends Control

var connectScene: PackedScene = preload("res://connect.tscn")
var connectInstance: Connect
var deviceScene: PackedScene = preload("res://device.tscn")
var deviceInstance: Device

onready var serial = $serial

func _ready() -> void:
	SerialHelper.setSerial(self.serial)
	self.connectInstance = self.connectScene.instance()
	
	self.connectInstance.connect("portConnected", self, "portConnected")
	self.add_child(self.connectInstance)

func portConnected() -> void:
	self.deviceInstance = self.deviceScene.instance()
	
	self.remove_child(self.connectInstance)
	self.add_child(self.deviceInstance)
	self.connectInstance.queue_free()
