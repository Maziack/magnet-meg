class_name Main
extends Node
#Main booting point of the game
#Manages High Level Systems and Scene Loading

### WORLD ROOT NODES ###
@onready var level_root      : Node2D = %LevelRoot
@onready var entity_root     : Node2D = %EntityRoot
@onready var effect_root     : Node2D = %"Effect Root"

### USER INTERFACE ROOT NODES ###
@onready var hud_root        : Control = %HudRoot
@onready var menu_root       : Control = %MenuRoot
@onready var pause_root      : Control = %PauseRoot
@onready var transition_root : Control = %TransitionRoot
@onready var debug_root      : Control = %DebugRoot

### LEVELS ###
const TEST_LEVEL_01_UID      : String = "uid://ck664gu32dpa0"
const TEST_LEVEL_02_UID      : String = "uid://b8hyatoipvwd5"
const TEST_LEVEL_03_UID      : String = "uid://cjj7apak5ctj4"

### MENUS ###
const MENU_MAIN_UID          : String = "uid://bnw38lniqiabm"
const MENU_MAIN_OPTIONS_UID  : String = "uid://dg1a7e2xwwst4"

### ENTITIES ###
const PLAYER_UID             : String = "u5id://chi0hp6wl3wq"

### VARIABLES ###
var player                   : Player    = null
var current_menu             : BaseMenu  = null
var current_level            : BaseLevel = null


### FUNCTIONS ###
func _ready() -> void:
	_load_menu(MENU_MAIN_UID)

##To load a menu scene. Requires menu UID string.
##NOTE: The input UID scene must extend BaseMenu.
func _load_menu(menu_scene_uid : String) -> void:
	_load_menu_deferred.call_deferred(menu_scene_uid)

func _load_menu_deferred(menu_scene_uid : String) -> void:
	if is_instance_valid(current_menu):
		current_menu.queue_free()
		current_menu = null
		await get_tree().process_frame
	
	var new_menu_scene : PackedScene = ResourceLoader.load(menu_scene_uid, "PackedScene") as PackedScene
	
	if new_menu_scene == null:
		push_error("Unable to load menu scene ", menu_scene_uid)
		return
	
	current_menu = new_menu_scene.instantiate() as BaseMenu
	
	if not is_instance_valid(current_menu):
		push_error("Unable to instantiate menu scene ", menu_scene_uid)
		return
	
	if current_menu is BaseMenu:
		current_menu.load_menu_signal.connect(_load_menu)
		current_menu.load_level_signal.connect(_load_level)

	else:
		push_error("Loaded menu is not of type BaseMenu. Scene ", menu_scene_uid)
		current_menu.free()
		current_menu = null
		return
	
	
	
	menu_root.add_child(current_menu)

##To load a level scene. Requires level UID string.
##NOTE: The input UID scene must extend BaseLevel.
func _load_level(level_scene_uid : String) -> void:
	_load_level_deferred.call_deferred(level_scene_uid)


func _load_level_deferred(level_scene_uid : String) -> void:
	if is_instance_valid(current_level):
		current_level.queue_free()
		current_level = null
		await get_tree().process_frame
	
	var new_level_scene : PackedScene = ResourceLoader.load(level_scene_uid, "PackedScene") as PackedScene
	
	if new_level_scene == null:
		push_error("Unable to load level scene ", level_scene_uid)
		return
	
	current_level = new_level_scene.instantiate() as BaseLevel
	
	if not is_instance_valid(current_level):
		push_error("Unable to instantiate level scene ", level_scene_uid)
		return
	
	if not current_level is BaseLevel:
		push_error("Loaded level is not of type BaseLevel. Scene ", level_scene_uid)
		current_level.free()
		current_level = null
		return
	
	level_root.add_child(current_level)


func _load_player() -> void:
	var player_scene : PackedScene = ResourceLoader.load(PLAYER_UID) as PackedScene
	if player_scene == null:
		push_error("Unable to load player scene while initializing player. Scene ",PLAYER_UID)
		return
	
	player = player_scene.instantiate() as Player
	if player == null:
		push_error("Unable to instantiate loaded player scene. Scene ",PLAYER_UID)
		return
	
	entity_root.add_child(player)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
