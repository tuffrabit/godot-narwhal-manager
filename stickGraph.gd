extends VBoxContainer

class_name StickGraph

@onready var title: Label = $title
@onready var currentXy: Label = $info/currentXy/currentXy
@onready var limitsX: Label = $info/limitsX/limits
@onready var limitsY: Label = $info/limitsY/limits
@onready var graph: ReferenceRect = $graph
@onready var point: Control = $graph/point

@export var titleText: String = "": set = setTitleText
@export var graph_size: float = 0: set = setGraphSize
@export var rangeMin: float = 0: set = setRangeMin
@export var rangeMax: float = 0: set = setRangeMax

var lowX: float = 0
var highX: float = 0
var lowY: float = 0
var highY: float = 0

func _ready() -> void:
	self.title.text = self.titleText
	self.graph.size.x = self.graph_size
	self.graph.size.y = self.graph_size
	self.graph.custom_minimum_size.x = self.graph_size
	self.graph.custom_minimum_size.y = self.graph_size
	# The parent VBoxContainer repositions the graph after _ready, so the axes
	# must follow the graph's live rect at draw time, not cached coordinates.
	self.graph.item_rect_changed.connect(queue_redraw)
	self.lowX = self.rangeMax
	self.highX = self.rangeMin
	self.lowY = self.rangeMax
	self.highY = self.rangeMin

func setTitleText(value: String) -> void:
	titleText = value

func setGraphSize(value: float) -> void:
	graph_size = value

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
	
	var scaledX: float = self.rangeMap(x, self.rangeMin, self.rangeMax, 0, self.graph.size.x)
	var scaledY: float = self.rangeMap(y, self.rangeMin, self.rangeMax, 0, self.graph.size.y)
	self.point.position.x = scaledX - 5
	self.point.position.y = scaledY - 5

func drawVerticalAxis() -> void:
	var startY: float = self.graph.position.y
	var endY: float = self.graph.position.y + self.graph.size.y
	var middleX: float = self.graph.position.x + self.graph.size.x / 2
	
	self.draw_line(Vector2(middleX,startY), Vector2(middleX,endY), Color("8b8b8b"), 1)

func drawHorizontalAxis() -> void:
	var startX: float = self.graph.position.x
	var endX: float = self.graph.position.x + self.graph.size.x
	var middleY: float = self.graph.position.y + self.graph.size.y / 2
	
	self.draw_line(Vector2(startX,middleY), Vector2(endX,middleY), Color("8b8b8b"), 1)

func _draw():
	self.drawVerticalAxis()
	self.drawHorizontalAxis()

func rangeMap(x: float, inMin: float, inMax: float, outMin: float, outMax: float) -> float:
	return (x - inMin) * (outMax - outMin) / (inMax - inMin) + outMin
