extends Control

@export var map1_path:String
@export var map2_path:String

@onready
var current_map:Sprite2D = $Map

@onready
var loading = $"../UI/Loading"

@onready
var animatedLoading = $"../UI/Animated Loading"

@onready
var spinner = $"../UI/Animated Loading/MarginContainer/HBoxContainer/Spinner/Sprite/AnimationPlayer"

@onready
var players = $Players

var asyncLoadingPath:String

func _input(event):
	
	if (event is InputEventKey):
		var e:InputEventKey = event as InputEventKey
		
		# Change the method called in this IF statement to illustrate the
		# different ways to change scenes.
		if (e.pressed and e.keycode == KEY_X):
			swap_scenes_animated_loader()


# Swaps the scenes by unloading the old node and loading the new one.
func swap_scenes_basic():
	var new_map
	
	if (current_map.name == "Map"):
		new_map = load(map2_path)
	else:
		new_map = load(map1_path)

	remove_child(current_map)
	current_map = new_map.instantiate()
	add_child(current_map)


# Similar to swap_scenes_basic() except that it uses a loading screen
# to mask the transition.
func swap_scenes_basic_loader():
	var new_map
	
	loading.visible = true
	
	remove_child(current_map)
	
	if (current_map.name == "Map"):
		new_map = load(map2_path)
	else:
		new_map = load(map1_path)
	
	current_map = new_map.instantiate()
	
	add_child(current_map)
	
	# yield for a bit to illustrate the actual process.
	# (it's too fast to see on a halfway-decent PC)
	await get_tree().create_timer(1.0).timeout
	
	loading.visible = false


# Swaps the scenes asynchronously so that an animated loading display can run.
func swap_scenes_animated_loader():
	var new_map
	
	if (current_map.name == "Map"):
		asyncLoadingPath = map2_path
	else:
		asyncLoadingPath = map1_path
	
	players.visible = false
	
	var tween = create_tween().tween_property(current_map, "modulate:a", 0, 0.5)
	
	await tween.finished
	
	animatedLoading.visible = true
	spinner.play("spinner")
	
	remove_child(current_map)
	
	ResourceLoader.load_threaded_request(asyncLoadingPath)


func _process(delta):
	if (animatedLoading.visible):
		if (ResourceLoader.load_threaded_get_status(asyncLoadingPath) == ResourceLoader.THREAD_LOAD_LOADED):
			current_map = ResourceLoader.load_threaded_get(asyncLoadingPath).instantiate()
			await get_tree().create_timer(1.0).timeout
			add_child(current_map)
			current_map.modulate.a = 0
			spinner.stop()
			animatedLoading.visible = false
			var tween = create_tween().tween_property(current_map, "modulate:a", 1, 0.5)
			await tween.finished
			players.visible = true
			
