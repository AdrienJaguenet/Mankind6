extends Node3D

class_name VoxelChunk

const CHUNK_SIZE = 16

var data : PackedByteArray
var dirty : bool = false
var faces_count : int = 0

# Called when the node enters the scene tree for the first time.
func _init():
	data.resize(CHUNK_SIZE * CHUNK_SIZE * CHUNK_SIZE)
	data.fill(0)

func get_voxel(x : int, y : int, z : int) -> int:
	return get_voxelv(Vector3i(x, y, z))

func get_voxelv(pos : Vector3i) -> int:
	return data[pos.z + pos.y * CHUNK_SIZE + pos.x * CHUNK_SIZE * CHUNK_SIZE]

func set_voxel(x : int, y : int, z : int, value : int):
	set_voxelv(Vector3i(x, y, z), value)

func set_voxelv(pos : Vector3i, value : int):
	dirty = true
	data[pos.z + pos.y * CHUNK_SIZE + pos.x * CHUNK_SIZE * CHUNK_SIZE] = value

func push_face(arrays : Array, v0 : Vector3, v1 : Vector3, v2 : Vector3, v3 : Vector3, normal : Vector3, uv0 : Vector2, uv1 : Vector2, uv2 : Vector2, uv3 : Vector2):
	faces_count += 1
	var vertices = arrays[Mesh.ARRAY_VERTEX]
	var normals = arrays[Mesh.ARRAY_NORMAL]
	var uvs = arrays[Mesh.ARRAY_TEX_UV]
	vertices.append(v0)
	vertices.append(v1)
	vertices.append(v2)
	uvs.append(uv0)
	uvs.append(uv1)
	uvs.append(uv2)

	vertices.append(v1)
	vertices.append(v3)
	vertices.append(v2)
	uvs.append(uv1)
	uvs.append(uv3)
	uvs.append(uv2)
	for l in range(6):
		normals.append(normal)

func generate_mesh():
	faces_count = 0
	var dbg_time = Time.get_ticks_msec()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_NORMAL] = PackedVector3Array()
	arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array()
	arrays[Mesh.ARRAY_TEX_UV] = PackedVector2Array()
	const FRONT_NORMAL = Vector3(0, 0, 1)
	const BACK_NORMAL = Vector3(0, 0, -1)
	const TOP_NORMAL = Vector3(0, 1, 0)
	const BOTTOM_NORMAL = Vector3(0, -1, 0)
	const LEFT_NORMAL = Vector3(-1, 0, 0)
	const RIGHT_NORMAL = Vector3(1, 0, 0)

	for i in range(CHUNK_SIZE):
		for j in range(CHUNK_SIZE):
			for k in range(CHUNK_SIZE):
				var value = get_voxel(i, j, k)
				if value == 0:
					continue
				# These are the indices of all 8 corners
				#   6--7
				#  /| /|
				# 2--3 5
				# | 4|/
				# |/ |/
				# 0--1
				#
				# ^y ^z
				# |/
				# .--> x
				#
				var v0 = Vector3(i, j, k)
				var v1 = Vector3(i + 1, j, k)
				var v2 = Vector3(i, j + 1, k)
				var v3 = Vector3(i + 1, j + 1, k)
				var v4 = Vector3(i, j, k + 1)
				var v5 = Vector3(i + 1, j, k + 1)
				var v6 = Vector3(i, j + 1, k + 1)
				var v7 = Vector3(i + 1, j + 1, k + 1)

				var CELL_SCALE = 1/16.
				var uv2 = Vector2(value % 16, (value / 16)) * CELL_SCALE
				var uv1 = uv2 + Vector2(1, 1) * CELL_SCALE
				var uv0 = uv2 + Vector2(0, 1) * CELL_SCALE
				var uv3 = uv2 + Vector2(1, 0) * CELL_SCALE

				# Make the faces
				# Front face
				var front_neighbour = get_parent().get_voxelv(Vector3i(position) + Vector3i(i, j, k - 1))
				if front_neighbour == 0:
					push_face(arrays, v0, v1, v2, v3, FRONT_NORMAL, uv0, uv1, uv2, uv3)

				# Back face
				var back_neighbour = get_parent().get_voxelv(Vector3i(position) + Vector3i(i, j, k + 1))
				if back_neighbour == 0:
					push_face(arrays, v5, v4, v7, v6, BACK_NORMAL, uv0, uv1, uv2, uv3)

				# Top face
				var top_neighbour = get_parent().get_voxelv(Vector3i(position) + Vector3i(i, j + 1, k))
				if top_neighbour == 0 or true:
					push_face(arrays, v2, v3, v6, v7, TOP_NORMAL, uv0, uv1, uv2, uv3)

				# Bottom face
				var bottom_neighbour = get_parent().get_voxelv(Vector3i(position)+ Vector3i(i, j - 1, k))
				if bottom_neighbour == 0:
					push_face(arrays, v1, v0, v5, v4, BOTTOM_NORMAL, uv0, uv1, uv2, uv3)

				# Left face
				var left_neighbour = get_parent().get_voxelv(Vector3i(position) + Vector3i(i - 1, j, k))
				if left_neighbour == 0:
					push_face(arrays, v4, v0, v6, v2, LEFT_NORMAL, uv0, uv1, uv2, uv3)

				# Right face
				var right_neighbour = get_parent().get_voxelv(Vector3i(position) + Vector3i(i + 1, j, k))
				if right_neighbour == 0:
					push_face(arrays, v1, v5, v3, v7, RIGHT_NORMAL, uv0, uv1, uv2, uv3)

	if arrays[Mesh.ARRAY_VERTEX].size() > 0:
		$Mesh.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	print("generate_mesh for ",position.x / Globals.CHUNK_SIZE, ", ", position.y / Globals.CHUNK_SIZE, ",", position.z / Globals.CHUNK_SIZE," took: ", Time.get_ticks_msec() - dbg_time, "ms, rendered faces: ", faces_count)

func _process(delta):
	if dirty:
		generate_mesh()
		dirty = false