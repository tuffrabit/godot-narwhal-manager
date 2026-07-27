extends HBoxContainer

class_name SpinBoxSliderCombo

signal valueChanged(value);

@onready var label: Label = $label
@onready var spinner: SpinBox = $spinBox
@onready var slider: HSlider = $slider
@onready var emitValueChangedSignal: bool = true

@export var labelText: String = "": set = setLabelText
@export var rangeMin: float = 0: set = setRangeMin
@export var rangeMax: float = 0: set = setRangeMax
@export var value: float = 0: set = setValue

func _ready() -> void:
	self.label.text = self.labelText
	self.spinner.min_value = self.rangeMin
	self.slider.min_value = self.rangeMin
	self.spinner.max_value = self.rangeMax
	self.slider.max_value = self.rangeMax
	self.spinner.connect("value_changed", Callable(self, "spinnerValueChanged"))
	self.slider.connect("value_changed", Callable(self, "sliderValueChanged"))

func setLabelText(value: String) -> void:
	labelText = value

func setRangeMin(value: float) -> void:
	rangeMin = value

func setRangeMax(value: float) -> void:
	rangeMax = value

func setValue(value: float) -> void:
	self.emitValueChangedSignal = true
	self.spinner.value = value

func setValueNoSignal(value: float) -> void:
	self.emitValueChangedSignal = false
	self.spinner.value = value
	self.slider.value = value
	self.emitValueChangedSignal = true

func setEditable(value: bool) -> void:
	self.spinner.editable = value
	self.slider.editable = value

func spinnerValueChanged(value: float) -> void:
	if self.emitValueChangedSignal:
		if value != self.slider.value:
			self.slider.value = value
		
		self.valueChanged.emit(value)

func sliderValueChanged(value: float) -> void:
	if self.emitValueChangedSignal:
		if value != self.spinner.value:
			self.spinner.value = value
