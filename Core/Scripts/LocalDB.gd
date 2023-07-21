extends Node

const db_path : String = "user://local_db.json"

var _initialized : bool
var data : Dictionary

func has_key(key: String):
	_initialize()
	assert(data != null, "Data is null!")
	return data.has(key)

func read_key(key: String):
	_initialize()
	assert(data != null, "Data is null!")
	assert(data.has(key), "Data doesn't have %s!" % key)
	return data[key]

func write_key(key: String, value):
	_initialize()
	data[key] = value
	var json = JSON.stringify(data)
	
	assert(json != null,
			"Could not serialize data to JSON when adding { %s : %s }\nData: %s" \
			% [key, value, data])
	
	var db_file = FileAccess.open(db_path, FileAccess.WRITE)
	db_file.store_string(json)

func _initialize():
	if _initialized:
		return
	
	if not FileAccess.file_exists(db_path):
		data = Dictionary()
		return
	
	var db_file = FileAccess.open(db_path, FileAccess.READ)
	data = JSON.parse_string(db_file.get_as_text())
	
	assert(data != null, "Couldn't load file: %s" % db_file.get_path_absolute())
	_initialized = true
