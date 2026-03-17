extends Marker2D


var expression = Expression.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func displayPlayerAction(expression_string):
	var line = Line2D.new()
	for i in range(0,1100,25): #for each x value
		var formula = expression_string
		#these ifs are to convert the x in the formula into the x-value
		if formula.contains("*x"):
			#print("star mult")
			formula = expression_string.replace("*x","*"+str(i))
		if formula.contains("+x"):
			#print("add")
			formula = expression_string.replace("+x","+"+str(i))
		if formula.contains("-x"):
			#print("subtract")
			formula = expression_string.replace("-x","-"+str(i))
		if formula.begins_with("x"):
			#print("start")
			formula = expression_string.replace("x",str(i))
		if formula.contains("x"):
			#print("base mult")
			formula = expression_string.replace("x","*"+str(i))
		#print(formula)
		var error = expression.parse(formula)
		if error != OK:
			print(expression.get_error_text())
			return
		var result = expression.execute()
		#print(result)
		line.add_point(Vector2(i,result))
	line.default_color = Color(1,0.8,0)
	return(line)
