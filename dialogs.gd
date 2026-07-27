extends Node

@onready var textInputDialogScene: PackedScene = preload("res://textInputDialog.tscn")

func showAlertDialog(message: String, title: String = "Alert!") -> void:
	var dialog = AcceptDialog.new()
	
	dialog.dialog_text = message
	dialog.title = title
	dialog.confirmed.connect(dialog.queue_free)
	dialog.canceled.connect(dialog.queue_free)
	dialog.close_requested.connect(dialog.queue_free)
	
	var sceneTree = Engine.get_main_loop()
	
	sceneTree.current_scene.add_child(dialog)
	dialog.popup_centered()

func showConfirmationDialog(message: String, confirmedTarget: Object, confirmedMethod: String, title: String = "Are you sure?") -> void:
	var dialog = ConfirmationDialog.new()
	
	dialog.dialog_text = message
	dialog.title = title
	dialog.confirmed.connect(Callable(confirmedTarget, confirmedMethod))
	dialog.confirmed.connect(dialog.queue_free)
	dialog.canceled.connect(dialog.queue_free)
	dialog.close_requested.connect(dialog.queue_free)
	
	var sceneTree = Engine.get_main_loop()
	
	sceneTree.current_scene.add_child(dialog)
	dialog.popup_centered()

func showTextInputDialog(title: String, confirmedTarget: Object, confirmedMethod: String) -> void:
	var textInputDialog: TextInputDialog = self.textInputDialogScene.instantiate()
	
	textInputDialog.title = title
	textInputDialog.confirmedWithValue.connect(Callable(confirmedTarget, confirmedMethod))
	textInputDialog.confirmedWithValue.connect(textInputDialog.queue_free)
	textInputDialog.canceled.connect(textInputDialog.queue_free)
	textInputDialog.close_requested.connect(textInputDialog.queue_free)
	
	var sceneTree = Engine.get_main_loop()
	
	sceneTree.current_scene.add_child(textInputDialog)
	textInputDialog.popup_centered()
