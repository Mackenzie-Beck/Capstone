extends Area2D

@export var health = 100 #health is in %
@export var fuel = 50 #in whole units
@export var location = Vector2(0,0)
var tile_size = 22.620689655172413793103448275862

var screen_size
var rng = RandomNumberGenerator.new() #temp

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func makeLocation():
	screen_size = get_viewport_rect().size
	var locX = rng.randi_range(0,screen_size[0])
	var locY = rng.randi_range(0,screen_size[1])
	locX = floor(locX/tile_size)*tile_size
	locY = floor(locY/tile_size)*tile_size
	return Vector2(locX, locY)

func move(pos):
	var distX = position[0] - pos[0]
	var distY = position[1] - pos[1]
	fuel -= floor(sqrt(distX**2 + distY**2))
	position = pos

func turnStart(pos):
	move(pos)
	return pos
	
func playerHealth(damage = null):
	if damage == null: #getter
		return health
	else: #setter
		health -= damage
		$HealthBar.value = health

func isAlive():
	if health <= 0:
		return false
	else:
		return true

func displayMovement(expression_data):
	var expression = Expression.new()
	for i in range(0,20):#for each point on the width of the grid
		var expression_string = expression_data.expression
		#these ifs are to change the expression to what is actually desired
		if expression_string.contains("*x"):#may have to rework checking if its not accurate
			expression_string.replace("*x","*"+str(i))
		if expression_string.contains("+x"):
			expression_string.replace("+x","+"+str(i))
		if expression_string.contains("-x"):
			expression_string.replace("-x","-"+str(i))
		var error = expression.parse(expression_string)
		if error != OK:
			print(expression.get_error_text())
			return
		var result = expression.execute()
	
	

	
	
