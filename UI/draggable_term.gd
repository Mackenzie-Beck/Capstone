extends PanelContainer
class_name DraggableTerm

signal drag_started(term)
signal drag_ended(term)

@export var term_value: String = "x"  # The math term (e.g., "x", "2", "+", "sin")
@export var term_type: String = "variable"  # Types: "variable", "number", "operator", "function"

var is_dragging: bool = false
var original_position: Vector2 #Not currently used for anything
var original_parent: Node 
var drag_offset: Vector2

@onready var label: Label = $Label

func _ready() -> void:
	if label:
		label.text = term_value
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
	mouse_filter = Control.MOUSE_FILTER_PASS
	# Enable input processing
	set_process_input(true)
	
	#Set parent to return to later
	original_parent = get_parent()
	

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		print("Mouse button event: ", event.button_index, " pressed: ", event.pressed)
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				_start_drag(event.position)

func _input(event: InputEvent) -> void:
	if not is_dragging:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			_end_drag()
			var vp = get_viewport()
			if vp:
				vp.set_input_as_handled()
	
	elif event is InputEventMouseMotion:
		_update_drag()
		var vp = get_viewport()
		if vp:
			vp.set_input_as_handled()

func _start_drag(click_position: Vector2) -> void:
	is_dragging = true
	#original_position = global_position
	original_position = position
	#original_parent = get_parent()
	drag_offset = click_position
	
	# Move to canvas layer or root to draw on top
	var current_global_pos = global_position
	get_parent().remove_child(self)
	UIcontrol.player_control_ui.add_child(self)
	global_position = current_global_pos
	
	#z_index = 1000  # Draw on top
	modulate = Color(1, 1, 1, 0.7)  # Semi-transparent while dragging
	
	drag_started.emit(self)
	
	print("Started dragging: ", term_value)

func _update_drag() -> void:
	global_position = get_global_mouse_position() - drag_offset

func _end_drag() -> void:
	if not is_dragging:
		return
	
	print("=== Ending drag for: ", term_value, " ===")
	
	is_dragging = false
	var drop_pos = get_global_mouse_position()
	
	# Reset visuals
	modulate = Color(1, 1, 1, 1)
	z_index = 0
	
	print("Drop position: ", drop_pos)
	
	# Check if dropped on a valid ExpressionSlot's TermsContainer
	var slot = _find_expression_slot_under_mouse(drop_pos)
	
	if slot:
		print("Found slot: ", slot.slot_name)
		if slot.can_accept_term(self):
			print("Slot accepted term!")
			slot.add_term(self)
			drag_ended.emit(self)
			return  # Don't return to original, slot will do it
		else:
			print("Slot rejected term")
	else:
		print("No valid slot found")
	
	# Return to original position
	_return_to_original()

func _find_expression_slot_under_mouse(drop_pos: Vector2) -> ExpressionSlot:
	"""Find if mouse is over a TermsContainer inside an ExpressionSlot"""
	for node in get_tree().get_nodes_in_group("expression_slots"):
		if node is ExpressionSlot:
			# Check if mouse is over the TermsContainer specifically
			var terms_container = node.get_terms_container()
			if terms_container:
				var container_rect = Rect2(
					terms_container.global_position,
					terms_container.size
				)
				print("  Checking slot '", node.slot_name, "' TermsContainer: ", container_rect)
				if container_rect.has_point(drop_pos):
					print("    -> Mouse IS over TermsContainer!")
					return node
				else:
					print("    -> Mouse NOT over TermsContainer")
	
	return null

func _return_to_original() -> void:
	print("Returning to original position")
	if get_parent() == original_parent:
		return
	
	if get_parent() != original_parent:
		# Remove from current parent (root)
		get_parent().remove_child(self)
		# Add back to original parent
		original_parent.add_child(self)
		"""
		# Animate back to position
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_BACK)
		tween.tween_property(self, "position", original_position, 0.3)
		"""
	else:
		push_error("Original parent is null! Cannot return term.")
		queue_free()


# Create a copy of this term for use in expression slots
# No longer used, thought just moving term to new parent seems to work better
func clone() -> DraggableTerm:
	var new_term = duplicate()
	new_term.term_value = term_value
	new_term.term_type = term_type
	new_term.original_position = original_position
	return new_term

	
# Getter
func get_term_data() -> Dictionary:
	return {
		"value": term_value,
		"type": term_type
	}
