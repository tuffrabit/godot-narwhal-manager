extends Node

onready var textInputDialogScene: PackedScene = preload("res://textInputDialog.tscn")

func showAlertDialog(message: String, title: String = "Alert!") -> void:
	var dialog = AcceptDialog.new()
	
	dialog.dialog_text = message
	dialog.window_title = title
	dialog.connect('modal_closed', dialog, 'queue_free')
	
	var sceneTree = Engine.get_main_loop()
	
	sceneTree.current_scene.add_child(dialog)
	dialog.popup_centered()

func showConfirmationDialog(message: String, confirmedTarget: Object, confirmedMethod: String, title: String = "Are you sure?") -> void:
	var dialog = ConfirmationDialog.new()
	
	dialog.dialog_text = message
	dialog.window_title = title
	dialog.connect("confirmed", confirmedTarget, confirmedMethod)
	dialog.connect('modal_closed', dialog, 'queue_free')
	
	var sceneTree = Engine.get_main_loop()
	
	sceneTree.current_scene.add_child(dialog)
	dialog.popup_centered()

func showTextInputDialog(title: String, confirmedTarget: Object, confirmedMethod: String) -> void:
	var textInputDialog: TextInputDialog = self.textInputDialogScene.instance()
	
	textInputDialog.window_title = title
	textInputDialog.connect("confirmedWithValue", confirmedTarget, confirmedMethod)
	textInputDialog.connect("modal_closed", textInputDialog, "queue_free")
	
	var sceneTree = Engine.get_main_loop()
	
	sceneTree.current_scene.add_child(textInputDialog)
	textInputDialog.popup_centered()
