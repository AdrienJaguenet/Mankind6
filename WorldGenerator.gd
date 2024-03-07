class_name WorldGenerator
extends Resource

@export var terrain_noise : Noise

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func generate_chunk(x : int, y : int, z : int):
	var dbg_time = Time.get_ticks_msec()
	var chunk = load("res://voxel_chunk.tscn").instantiate()
	chunk.position = Vector3(x * Globals.CHUNK_SIZE, 0, z * Globals.CHUNK_SIZE)
	for i in range(Globals.CHUNK_SIZE):
		for j in range(Globals.CHUNK_SIZE):
			var height = terrain_noise.get_noise_2d(x * Globals.CHUNK_SIZE + i, z * Globals.CHUNK_SIZE + j)
			for k in range(Globals.CHUNK_SIZE):
				if k < height * 50:
					chunk.set_voxel(i, k, j, 1)
				else:
					chunk.set_voxel(i, k, j, 0)
	print("Chunk ",x,",",z," generated in ", Time.get_ticks_msec() - dbg_time, "ms")
	return chunk
