extends Node2D

@onready var background: Sprite2D = $Background
@onready var head: Sprite2D = $Head
@onready var body: Sprite2D = $Body
@onready var tail: Sprite2D = $Tail
@onready var timer: Timer = $Timer
@onready var label: Label = $Label

@export var apple_scene : PackedScene
@export var body_scene : PackedScene
@export var tail_scene : PackedScene
var apple : Sprite2D


var direction := Vector2(0,0)
var offset := 60
var grid_size := 15
var rows : Array[float] = []
var columns : Array[float] = []
var current_pos : Vector2
var new_pos : Vector2
var head_pos : Vector2
var game_started = false
var can_change_direction : bool ## prevents snake from changing directions twice before update_pos runs
var board_positions : Array[Vector2]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_started = true
	#initial direction will be to the right
	direction = Vector2(1,0)
	#connect signals
	
	timer.timeout.connect(_on_timeout)
	head.apple_eaten.connect(eat_apple)
	head.apple_eaten.connect(grow)
	head.game_over.connect(on_game_over)
	
	# initialize arrays to store positions of each tile
	var iter = 0.0
	for x in range(grid_size):
		columns.append(120.0 + (offset * iter))
		iter += 1.0
		
	iter = 0
	for y in range(grid_size):
		rows.append(120.0 + (offset * iter))
		iter += 1.0
	
	# create an array of all possible_positions on the board
	for column in columns:
		for row in rows:
			board_positions.append(Vector2(column, row))
	
	#spawn first apple randomly
	var spawn_row = randi_range(0,grid_size-1)
	var spawn_col = randi_range(0,grid_size-1)
	apple = apple_scene.instantiate()
	add_child(apple)
	apple.position = Vector2(columns[spawn_col], rows[spawn_row])





func _physics_process(delta: float) -> void:
	var current_direction := direction
	#if the game is started, change direction based on key input
	if game_started == true and can_change_direction == true:
		if Input.is_action_just_pressed("up") and direction != Vector2(0,1):
			direction = Vector2(0,-1)
			head.rotation = -0.5*PI
			can_change_direction = false
		if Input.is_action_just_pressed("down") and direction != Vector2(0,-1):
			direction = Vector2(0,1)
			head.rotation = 0.5*PI
			can_change_direction = false
		if Input.is_action_just_pressed("right") and direction != Vector2(-1,0):
			direction = Vector2(1,0)
			head.rotation = 0
			can_change_direction = false
		if Input.is_action_just_pressed("left") and direction != Vector2(1,0):
			direction = Vector2(-1,0)
			head.rotation = PI
			can_change_direction = false


# create arrays to track snake parts, positions, and rotations
var snake_array : Array[Sprite2D]
var positions : Array[Vector2]
var tail_position : Vector2
var rotations : Array[float]
var tail_rotations : float


var snake_data : Dictionary
func _on_timeout():
	snake_data = update_pos()
	can_change_direction = true

# a function to update the position of every snake section
func update_pos():
	snake_array = []
	positions = []
	rotations = []
	
	for child in get_children():
		if child.is_in_group("snake"):
			snake_array.append(child)
			
	for i in len(snake_array):
		positions.append(snake_array[i].position)
		rotations.append(snake_array[i].rotation)
		var tail_ind
		
		if i == 0:
			current_pos = snake_array[i].position
			new_pos = snake_array[i].position + (direction*offset)
			snake_array[i].position = new_pos
		else:
			snake_array[i].position = positions[i-1]
			snake_array[i].rotation = rotations[i-1]
			
	var snake_data_dict = {
		"tail position" : positions.back(),
		"tail rotation" : rotations.back(),
		"snake array" : snake_array}
	
	return snake_data_dict


var score = 0
func eat_apple() -> void:
	score += 1                  #update score
	label.text = ("Score: " + str(score))
	spawn_apple()


 ##Create function to spawn apple, excluding positions of snake
func spawn_apple():
	var possible_positions = board_positions
	for child in get_children():
		if child.is_in_group("apple"):
			child.queue_free()
		if child.is_in_group("snake"):
			var position_to_remove = child.position
			possible_positions.erase(position_to_remove)
	
	var apple = apple_scene.instantiate()
	add_child(apple)
	apple.position = possible_positions.pick_random()


# fucntion to grow the snake. use dictionary from update_pos func
func grow() -> void:

	snake_array = snake_data["snake array"]
	var curr_pos = null
	var curr_rot = null
	var new_body = null
	for child in get_children():
		if child.is_in_group("tail"):
			curr_pos = child.position
			curr_rot = child.rotation
			child.queue_free()
	
	new_body = body_scene.instantiate()
	add_child(new_body)
	new_body.position = curr_pos
	new_body.rotation = curr_rot
	var new_tail = tail_scene.instantiate()
	add_child(new_tail)
	new_tail.position = snake_data["tail position"]
	new_tail.rotation = snake_data["tail rotation"]



func on_game_over():
	game_started = false
	for child in get_children():
		if child.is_in_group("snake"):
			child.queue_free()
	#
	#
