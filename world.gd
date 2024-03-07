extends Node3D

@export var generator : WorldGenerator

var chunks : Dictionary
var chunk_scene = load("res://voxel_chunk.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	load_chunks()

func load_chunks():
	for i in range(0, 2):
		for k in range(0, 2):
			add_child(get_chunk_or_generate(i, 0, k))

func get_chunk_or_generate(x : int, y : int, z : int):
	var chunk
	if chunks.has(x) and chunks[x].has(y) and chunks[x][y].has(z):
		chunk = chunks[x][y][z]
	else:
		chunk = generator.generate_chunk(x, y, z)
		set_chunk(x, y, z, chunk)
	return chunk

func set_chunk(x : int, y : int, z : int, chunk : VoxelChunk):
	if not chunks.has(x):
		chunks[x] = {}
	if not chunks[x].has(y):
		chunks[x][y] = {}
	chunks[x][y][z] = chunk

func get_voxelv(pos : Vector3i):
	return get_voxel(pos.x, pos.y, pos.z)

func get_voxel(x : int, y : int, z : int):
	var i = x / Globals.CHUNK_SIZE
	var j = y / Globals.CHUNK_SIZE
	var k = z / Globals.CHUNK_SIZE
	var chunk
	if chunks.has(i) and chunks[i].has(j) and chunks[i][j].has(k):
		chunk = chunks[i][j][k]
	else:
		chunk = generator.generate_chunk(i, j, k)
		set_chunk(i, j, k, chunk)
	return chunk.get_voxel(x % Globals.CHUNK_SIZE, y % Globals.CHUNK_SIZE, z % Globals.CHUNK_SIZE)	


func _unhandled_input(event):
	if event is InputEventKey:
		pass
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
