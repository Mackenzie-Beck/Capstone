extends PanelContainer
class_name ExpressionSlot

#signal for changing expression
signal expression_changed(expression_data)
#signal to check validation
#Can a player move onto or use the expression? enough fuel or whatever
#Expression also has to have at least one variable
signal expression_validated(is_valid, expression_string)

@export var slot_name: String = "Movement"  # "Movement" or "Shooting"
@export var max_terms: int = 10  # Maximum number of terms in expression
@export var allowed_term_types: Array[String] = ["variable", "number", "operator", "function"] 
# Might not need this, used if we need to control order of terms placed in slots. EX: (1 2 x + *) vs (2 * x + 1)

var terms: Array[DraggableTerm] = [] # Array of terms
var expression_string: String = "" # Expression string for signal

# To adjust labels
@onready var terms_container: GridContainer = $MarginContainer/VBoxContainer/TermsContainer
@onready var title_label: Label = $MarginContainer/VBoxContainer/TitleLabel
@onready var expression_label: Label = $MarginContainer/VBoxContainer/ExpressionLabel
@onready var validation_label: Label = $MarginContainer/VBoxContainer/ValidationLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	title_label.text = slot_name #To have each set of slots labeled
	add_to_group("expression_slots")
	_update_display()
	
	"""
	print("ExpressionSlot '", slot_name, "' ready")
	if terms_container:
		print("  TermsContainer size: ", terms_container.size)
		print("  TermsContainer global_position: ", terms_container.global_position)
	#queue_redraw()
	"""
	
func get_terms_container() -> GridContainer:
	"""Return the TermsContainer for drop zone checking"""
	return terms_container


func can_accept_term(term: DraggableTerm) -> bool:
	"""Check if this slot can accept the given term"""
	print("Checking if slot '", slot_name, "' can accept term: ", term.term_value)
	
	if not terms_container:
		print("  REJECTED: No terms_container!")
		return false
	
	if terms.size() >= max_terms:
		print("  REJECTED: Too many terms (", terms.size(), "/", max_terms, ")")
		return false
	
	if not term.term_type in allowed_term_types:
		print("  REJECTED: Term type '", term.term_type, "' not in allowed types: ", allowed_term_types)
		return false
	
	print("  ACCEPTED!")
	return true
	

# Add term to the slot
func add_term(term: DraggableTerm) -> void:
	"""Add a term to this expression slot"""
	#Check if term is good to be accepted
	if not can_accept_term(term):
		print("  add_term: can_accept_term returned false")
		return
	
	#Remove from current parent and add to slot
	if term.get_parent():
		term.get_parent().remove_child(term)
		
	#Add to container and array
	terms_container.add_child(term)
	terms.append(term)
	
	#Make non-draggable (optional)
	#term.set_process_input(false)
	
	#Connect remove signal for right click removal
	term.gui_input.connect(_on_term_clicked.bind(term))
	
	get_tree().call_group("expression_slots", "_update_expression")
	get_tree().call_group("expression_slots", "_update_display")
	#Emit signals
	if _update_expression():
		_update_display()
	AudioControl.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UIACTIVATE3)

func remove_term(term: DraggableTerm) -> void:
	"""Remove a term from this expression slot"""
	var index = terms.find(term)
	if index >= 0:
		terms.remove_at(index)
		print(term.original_position)
		term._return_to_original()
		#Disconnect the signal for right click removal
		term.gui_input.disconnect(_on_term_clicked)
		#term.queue_free()
		if _update_expression():
			_update_display()
		
func _on_term_clicked(event: InputEvent, term: DraggableTerm) -> void:
	"""Handle right-click to remove terms"""
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			print("Right-clicked term: ", term.term_value, " - removing")
			remove_term(term)
			AudioControl.create_audio(SoundEffect.SOUND_EFFECT_TYPE.UIBUTTON2)

func _update_expression() -> bool:
	"""Build the expression string from current terms"""
	expression_string = ""
	terms = []
	var children = terms_container.get_children()
	for child in children:
		#print(child.name)
		if child is DraggableTerm:
			terms.append(child)
	for term in terms:
		expression_string += term.term_value
	
	return _validate_expression()

func _validate_expression() -> bool:
	"""Validate the mathematical expression"""
	
	var is_valid = true
	var error_message = ""
	
	if expression_string.is_empty():
		is_valid = false
		error_message = "Expression is empty"
	else:
		#Contains a variable
		var has_variable = expression_string.contains("x") or expression_string.contains("y")
		if not has_variable:
			is_valid = false
			error_message = "Expression should contain a variable (x or y)"

		elif _has_consecutive_operators(expression_string):
			is_valid = false
			error_message = "Consecutive operators are not allowed (+,-,* ...)"

		elif _has_leading_trailing_operators(expression_string):
			is_valid = false
			error_message = "Expression starts or ends with an operator (+,-,* ...)"
			
		elif _has_missing_operator(expression_string):
			is_valid = false
			error_message = "Expression missing an operator (+,-,* ...)"
			
		else:
			var expr = Expression.new()
			var parse_result = expr.parse(expression_string, ["x", "y"])
			if parse_result != OK:
				is_valid = false
				error_message = "Invalid syntax: " + expr.get_error_text()
	
	validation_label.text = error_message if not is_valid else "Valid"
	validation_label.modulate = Color.RED if not is_valid else Color.GREEN
	
	expression_validated.emit(is_valid, expression_string)
	return is_valid
	
func _has_consecutive_operators(expr: String) -> bool:
	var regex = RegEx.new()
	regex.compile("[+*/]{2,}|[+*/]-{2,}")
	return regex.search(expr) != null

func _has_leading_trailing_operators(expr: String) -> bool:
	var regex = RegEx.new()
	regex.compile("^[+*/]|[+\\-*/]$")
	return regex.search(expr) != null

func _has_missing_operator(expr: String) -> bool:
	var regex = RegEx.new()
	# digit followed by variable, or variable followed by digit or variable
	regex.compile("\\d[xy]|[xy][\\dxy]")
	return regex.search(expr) != null

func _update_display() -> void:
	"""Update the visual display of the expression"""
	expression_label.text = "%s: %s" % [slot_name, expression_string if not expression_string.is_empty() else "empty"]
	
	# Emit signal for other systems to react
	var expression_data = {
		"slot_name": slot_name,
		"expression": expression_string,
		"terms": terms.map(func(t): return t.get_term_data())
	}
	SB.expression_changed.emit(expression_data)

func clear_expression() -> void:
	"""Clear all terms from this slot"""
	for term in terms:
		term._return_to_original()
	terms.clear()
	_update_expression()
	_update_display()

func get_expression() -> String:
	"""Get the current expression string"""
	return expression_string


"func _draw() -> void:
	# Draw a debug rectangle showing the hit area
	if OS.is_debug_build():
		draw_rect(Rect2(Vector2.ZERO, size), Color.GREEN, false, 2.0)
"


""" Cloning is annoying but might help with controlling what can be dragged or not
	# Create a copy of the term for this slot
	var term_copy = term.clone()
	
	# Remove from current parent and add to this slot
	if term.get_parent():
		term.get_parent().remove_child(term)
		term.queue_free()  # Delete the original? Might change
	
	# Add copy to container
	terms_container.add_child(term_copy)
	terms.append(term_copy)
	
	# Make the copy non-draggable (should remove? Better to allow redragging but things are weird)
	term_copy.set_process_input(false)
	
	# Connect remove signal to right click
	term_copy.gui_input.connect(_on_term_clicked.bind(term_copy))
	"""
