extends VBoxContainer

class_name StickGraph

onready var title: Label = $title
onready var currentXy: Label = $info/currentXy/currentXy
onready var limitsX: Label = $info/limitsX/limits
onready var limitsY: Label = $info/limitsY/limits
onready var graph: ReferenceRect = $graph
onready var point: Control = $graph/point

export var titleText: String = "" setget setTitleText
export var size: float = 0 setget setSize
export var rangeMin: float = 0 setget setRangeMin
export var rangeMax: float = 0 setget setRangeMax

var middleX: float = 0
var middleY: float = 0
var lowX: float = 0
var highX: float = 0
var lowY: float = 0
var highY: float = 0

func _ready() -> void:
	self.title.text = self.titleText
	self.graph.rect_size.x = self.size
	self.graph.rect_size.y = self.size
	self.graph.rect_min_size.x = self.size
	self.graph.rect_min_size.y = self.size
	self.middleX = self.graph.rect_position.x + self.size / 2
	self.middleY = self.graph.rect_position.y + self.size / 2
	self.lowX = self.rangeMax
	self.highX = self.rangeMin
	self.lowY = self.rangeMax
	self.highY = self.rangeMin

func setTitleText(value: String) -> void:
	titleText = value

func setSize(value: float) -> void:
	size = value

func setRangeMin(value: float) -> void:
	rangeMin = value

func setRangeMax(value: float) -> void:
	rangeMax = value

func setRunning(running: bool) -> void:
	if running:
		self.limitsX.text = ""
		self.limitsY.text = ""
		self.point.visible = true
	else:
		self.lowX = self.rangeMax
		self.highX = self.rangeMin
		self.lowY = self.rangeMax
		self.highY = self.rangeMin
		self.point.visible = false
		self.currentXy.text = ""

func setPoint(x: float, y: float) -> void:
	self.currentXy.text = "%s,%s" % [x, y]
	
	if x < self.lowX:
		self.lowX = x
	
	if x > self.highX:
		self.highX = x
	
	if y < self.lowY:
		self.lowY = y
	
	if y > self.highY:
		self.highY = y
	
	self.limitsX.text = "%s,%s" % [self.lowX, self.highX]
	self.limitsY.text = "%s,%s" % [self.lowY, self.highY]
	
	var scaledX: float = self.rangeMap(x, self.rangeMin, self.rangeMax, 0, self.size)
	var scaledY: float = self.rangeMap(y, self.rangeMin, self.rangeMax, 0, self.size)
	self.point.rect_position.x = scaledX - 5
	self.point.rect_position.y = scaledY - 5

func drawVerticalAxis() -> void:
	var startY: float = self.graph.rect_position.y
	var endY: float = self.graph.rect_position.y + self.size
	
	self.draw_line(Vector2(self.middleX,startY), Vector2(self.middleX,endY), Color("8b8b8b"), 1)

func drawHorizontalAxis() -> void:
	var startX: float = self.graph.rect_position.x
	var endX: float = self.graph.rect_position.x + self.size
	
	self.draw_line(Vector2(startX,self.middleY), Vector2(endX,self.middleY), Color("8b8b8b"), 1)

func _draw():
	self.drawVerticalAxis()
	self.drawHorizontalAxis()

func rangeMap(x: float, inMin: float, inMax: float, outMin: float, outMax: float) -> float:
	return (x - inMin) * (outMax - outMin) / (inMax - inMin) + outMin
