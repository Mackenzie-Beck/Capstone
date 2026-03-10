extends Control

# Controller Node for all UI elements

# I was looking into some MVC and MVVC architectures they could both be a handy way to organize the UI scenes. 
# Indiviudal UI scenes are "views" which are seperate from the game state "model" and the controller mediates between the two
# https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller
# https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93viewmodel

# For example:
# The player will use the controller to manipulate the model. So player inputs will be gathered in the UIcontrol.tscn scene, and then those inputs can 
# be sent to the relevant parts of the model (game) for processing. This can be done by just bubbling signals up and emiting them from the top UIcontrol node. 
# On the combat grid the player will move a certain distance in a turn. Thus depleting their fuel. 
# This change in the model (game state), will then update the view (UI element representing player fuel) using a function like UIcontrol.set_fuel().


# All of the views should be added as children of this canvas layer. So they are all on the same 'level'
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var main_menu: PanelContainer = $CanvasLayer/MainMenu
@onready var pause_menu: PanelContainer = $CanvasLayer/PauseMenu
@onready var player_control_ui: PlayerControlUI = $CanvasLayer/PlayerControlUI



"""
Whenever a new view (ui_scene) must be added

1. Add an enum to VIEWS
2. Add the view (ui scene) as a child of the UIcontrols canvas layer, 
and create an onready reference to that node in UIcontrol.gd (as above)
3. Add a case to the match statement in switch_views(view:VIEWS) which will reveal that view after hiding the others
"""

enum VIEWS {
	PAUSE,
	MAIN,
	PLAYER
}



func hide_views() -> void:
	for view in canvas_layer.get_children():
		view.hide()


func switch_view(view: VIEWS) -> void:
	match view:
		VIEWS.PAUSE:
			hide_views()
			pause_menu.show()
			#print(pause_menu.visible)
		VIEWS.PLAYER:
			hide_views()
			player_control_ui.show()
		VIEWS.MAIN:
			hide_views()
			main_menu.show()
			
