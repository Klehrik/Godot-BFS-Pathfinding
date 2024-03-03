### General purpose BFS for orthogonal pathfinding
## By Klehrik	Created Feb 29, 2024	Updated Mar 3, 2024

## Constants
# INFINITY : int		An integer of value 1,000,000,000

## Fields
# terrain : Array		A 2D map of terrain populated with movement costs; tiles should cost 1 point in most circumstances
# size : Vector2		The size of the terrain map

# pathmap : Array		A 2D map generated by calculate_pathmap() containing valid move tiles and their costs from a starting position
# start : Vector2		The starting (0) position as given in calculate_pathmap()


## Methods
# set_terrain(terrain : Array) -> void
# Takes in a 2D terrain map to be used,
# and also resets the pathmap to an empty array

# calculate_pathmap(start_position : Vector2, move_points : int) -> bool
# Calculates valid move tiles and their costs from a starting position
# Returns false if the map size is 0 x 0

# calculate_path(destination : Vector2) -> Array
# Calculates the path from the start position (0) of the pathmap to a specified destination
# Returns an array containing each step as a unit Vector2
# Otherwise, returns an empty array ([]) if the pathmap does not exist,
# or if the destination is out of the move range as determined in calculate_pathmap()

# terrain_to_string() -> String
# Returns a visual of the terrain map as a string

# pathmap_to_string() -> String
# Returns a visual of the pathmap map as a string; invalid tiles are represented with an "x"

# copy(other : Node) -> bool
# Copies data from another BFS object
# Returns false if other is not a BFS object


## General
# General purpose 2D map scripts for many uses

# create_map(size : Vector2, value = 0) -> Array
# Returns a 2D map of the specified size, populated by the given value (default 0)

# set_tile(map : Array, position : Vector2, value) -> bool
# Sets a tile of the specified map to a given value
# Returns false if the position is out of bounds

# get_tile(map : Array, position : Vector2)
# Returns the value at the specified position from the given map
# Returns null if the position is out of bounds

# get_size(map : Array) -> Vector2
# Returns the size of the map
# Returns Vector2.ZERO if the map array is empty

# map_to_string(map : Array) -> String
# Returns a visual of a map as a string
# Values equal to the INFINITY constant are represented with an "x"

# is_adjacent(pos1 : Vector2, pos2 : Vector2) -> bool
# Returns true if the two positions are adjacent orthogonally

# is_in_bounds(map : Array, position : Vector2) -> bool
# Returns true if the specified position is within the given map


# =============================

extends Node
const IS_BFS : bool = true

const INFINITY : int = 1_000_000_000

var terrain : Array = []
var size : Vector2 = Vector2.ZERO

var pathmap : Array = []
var start : Vector2 = Vector2.ZERO


# ========== METHODS ==========

func set_terrain(terrain : Array) -> void:
	self.terrain = terrain
	size = Vector2(terrain[0].size(), terrain.size())
	pathmap = []	# Reset for safety, since the new terrain may not be the same size
	

func calculate_pathmap(start_position : Vector2, move_points : int) -> bool:
	if size == Vector2.ZERO:
		return false
	
	pathmap = create_map(size, INFINITY)
	start = start_position
	
	# Initialize the starting position tile
	var open : Array = []
	open.append(start_position)
	set_tile(pathmap, start_position, 0)
	
	while open.size() > 0:
		var current : Vector2 = open[0]
		var current_value : int = get_tile(pathmap, current)
		
		var neighbors : Array = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
		
		# Check all four neighboring tiles
		for i in neighbors:
			var nb : Vector2 = current + i
			
			# Check if within the map bounds
			if Rect2(0, 0, size.x, size.y).has_point(nb):
				
				# Check if moving to neighbor tile will not exceed move_points
				var cost : int = get_tile(terrain, nb)
				var final_cost : int = current_value + cost
				if final_cost <= move_points:
					
					# Check if neighbor value is currently greater; if so, set neighbor to current + cost
					# Add to open list only if the new value is under move_points
					#	> If it already at the maximum then it cannot propagate anyway
					if get_tile(pathmap, nb) > final_cost:
						set_tile(pathmap, nb, final_cost)
						if final_cost < move_points:
							open.append(nb)
						
		open.remove_at(0)
	
	return true
	
	
func calculate_path(destination : Vector2) -> Array:
	if pathmap.is_empty():
		return []
	if get_tile(pathmap, destination) == INFINITY:
		return []
		
	var inverted_path : Array = []
	var current : Vector2 = destination
	
	# Start at the destination and work backwards to the start
	while current != start:
		var lowest : int = INFINITY
		var direction : Vector2 = Vector2.ZERO
		var neighbors : Array = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
		
		# Check all four neighboring tiles
		for i in neighbors:
			var nb : Vector2 = current + i
			
			# Check if within the map bounds
			if Rect2(0, 0, size.x, size.y).has_point(nb):
				var value : int = get_tile(pathmap, nb)
				
				# Store direction if it is the lowest value
				if value < lowest:
					lowest = value
					direction = i
				
		current += direction
		inverted_path.append(direction)
		
	# Convert inverted_path to normal path (start -> destination) by reversing directions
	var path : Array = []
	for i in range(inverted_path.size() - 1, -1, -1):
		path.append(-inverted_path[i])
		
	return path
	
	
func terrain_to_string() -> String:
	return map_to_string(terrain)
	

func pathmap_to_string() -> String:
	return map_to_string(pathmap)
	

func copy(other : Node) -> bool:
	if "IS_BFS" in other:
		terrain = other.terrain
		size = other.size
		pathmap = other.pathmap
		start = other.start
		return true
	return false


# ========== GENERAL ==========

func create_map(size : Vector2, value = 0) -> Array:
	var map : Array = []
	for y in range(size.y):
		var line : Array = []
		for x in range(size.x):
			line.append(value)
		map.append(line)
	return map
	

func set_tile(map : Array, position : Vector2, value) -> bool:
	if not is_in_bounds(map, position):
		return false
	map[position.y][position.x] = value
	return true
	

func get_tile(map : Array, position : Vector2):
	if not is_in_bounds(map, position):
		return null
	return map[position.y][position.x]
	

func get_size(map : Array) -> Vector2:
	if map.is_empty():
		return Vector2.ZERO
	return Vector2(map[0].size(), map.size())


func map_to_string(map : Array) -> String:
	var text : String = ""
	for y in map:
		for x in y:
			var chr = x
			if chr == INFINITY:
				chr = "x"
			chr = str(chr)
			if chr.length() == 1:
				chr = "  " + chr
			text += chr + " "
		text += "\n"
	return text


func is_adjacent(pos1 : Vector2, pos2 : Vector2) -> bool:
	return (pos1 - pos2).length() == 1


func is_in_bounds(map : Array, position : Vector2) -> bool:
	if map.is_empty():
		return false
	var size : Vector2 = get_size(map)
	return Rect2(0, 0, size.x, size.y).has_point(position)
