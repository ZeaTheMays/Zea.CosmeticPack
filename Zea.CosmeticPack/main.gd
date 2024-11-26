extends Node

const ID = "Zea.CosmeticPack"
onready var Lure = get_node("/root/SulayreLure")

var folder_path = "res://mods/Zea.CosmeticPack/Resources/"
var compat_path = "res://mods/Zea.CosmeticPack/Compat/"
var file_names = []
var cosmetic_colors = {
	"catbeanie": ["white", "tan", "brown", "red", "maroon", "salmon", "olive", "green", "blue", "grey", "purple", "yellow", "orange", "black", "brokie"],
	"newsboy": ["white", "tan", "brown", "red", "maroon", "salmon", "olive", "green", "blue", "grey", "purple", "yellow", "orange", "black"],
	"bubblegum": ["white", "tan", "brown", "red", "maroon", "salmon", "olive", "green", "blue", "grey", "purple", "yellow", "orange", "black"],
	"gradientglasses": ["white", "tan", "brown", "red", "maroon", "salmon", "olive", "green", "blue", "grey", "purple", "yellow", "orange", "black"],
}

func assign_cosmetics_for_dog_species():
	var species = "species_dog"
	var base_path = "res://mods/Zea.CosmeticPack/Assets/Models/Dog/"
	for cosmetic_name in cosmetic_colors.keys():
		var colors = cosmetic_colors[cosmetic_name]
		
		for color in colors:
			var colored_cosmetic_name = ID + "." + color + "_" + cosmetic_name
			var resource_path = base_path + cosmetic_name + ".tres"
			Lure.assign_cosmetic_mesh(ID, colored_cosmetic_name, species, resource_path)
			prints(ID, colored_cosmetic_name, species, resource_path)

func assign_cosmetics_from_compat():
	process_compat_folder(compat_path)

func process_compat_folder(path: String, mod_id: String = "", species: String = ""):
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.begins_with("."):
				file_name = dir.get_next()
				continue
			
			var full_path = path + "/" + file_name
			if dir.current_is_dir():
				if mod_id == "":
					process_compat_folder(full_path, file_name, species)
				elif species == "":
					process_compat_folder(full_path, mod_id, file_name)
				else:
					print("Unexpected folder structure at:", full_path)
			else:
				var cosmetic_name = file_name.get_basename().to_lower()
				assign_cosmetic_from_compat(mod_id, species, cosmetic_name)
			
			file_name = dir.get_next()
		
		dir.list_dir_end()

func assign_cosmetic_from_compat(mod_id: String, species: String, cosmetic_name: String):
	if cosmetic_name in cosmetic_colors:
		for color in cosmetic_colors[cosmetic_name]:
			var colored_cosmetic_name = color + "_" + cosmetic_name
			var id = ID + "." + colored_cosmetic_name
			var species_id = mod_id + ".species_" + species.to_lower()
			var resource_path = "res://mods/Zea.CosmeticPack/Compat/" + mod_id + "/" + species + "/" + cosmetic_name + ".tres"
			Lure.assign_cosmetic_mesh(ID, id, species_id, resource_path)
			print("Assigned color variation:", ID, id, species_id, resource_path)
	else:
		var id = ID + "." + cosmetic_name
		var species_id = mod_id + ".species_" + species.to_lower()
		var resource_path = "res://mods/Zea.CosmeticPack/Compat/" + mod_id + "/" + species + "/" + cosmetic_name + ".tres"
		Lure.assign_cosmetic_mesh(ID, id, species_id, resource_path)
		print("Assigned:", ID, id, species_id, resource_path)

func get_file_names(path: String) -> Array:
	var result = []
	var dir = Directory.new()
	
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name != "." and file_name != "..":
				var file_path = path + "/" + file_name
				if dir.current_is_dir():
					result += get_file_names(file_path + "/")
				elif file_name.ends_with(".tres"):
					var name_without_extension = file_name.get_basename()
					result.append(name_without_extension)
			file_name = dir.get_next()
		
		dir.list_dir_end()
	else:
		print("Failed to open directory: ", path)
	return result

func make_cosmetics():
	for cosmetic in file_names:
		var resource_path = folder_path + cosmetic + ".tres"
		Lure.add_content(ID, cosmetic, resource_path, [])

func _signals():
	get_tree().root.connect("child_entered_tree", self, "_custom_shop", [], CONNECT_DEFERRED)

func _custom_shop(node: Node):
	if node.name == "playerhud":
		node.get_node("main/shop").SETUPS["wardrobe"] = load("res://mods/Zea.CosmeticPack/NPC/wardrobe_shop.tscn")

func _ready():
	file_names = get_file_names(folder_path)
	assign_cosmetics_for_dog_species()
	assign_cosmetics_from_compat()
	make_cosmetics()
	Lure.add_content(ID, "wardrobe_prop", "mod:///NPC/wardrobe_npc.tres")
	Lure.add_actor(ID, "wardrobe_npc", "mod://NPC/Wardrobe.tscn")
	_signals()
