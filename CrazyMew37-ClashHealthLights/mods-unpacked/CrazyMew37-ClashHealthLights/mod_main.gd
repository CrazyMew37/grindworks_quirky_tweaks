extends Node

# ! Comments prefixed with "!" mean they are extra info. Comments without them
# ! should be kept because they give your mod structure and make it easier to
# ! read by other modders
# ! Comments with "?" should be replaced by you with the appropriate information

# ! This template file is statically typed. You don't have to do that, but it can help avoid bugs
# ! You can learn more about static typing in the docs
# ! https://docs.godotengine.org/en/3.5/tutorials/scripting/gdscript/static_typing.html

# ? Brief overview of what your mod does...

const MOD_DIR := "CrazyMew37-ClashHealthLights" # Name of the directory that this file is in
const LOG_NAME := "CrazyMew37-ClashHealthLights:Main" # Full ID of the mod (AuthorName-ModName)

var mod_dir_path := ""
var extensions_dir_path := ""
var translations_dir_path := ""


# ! your _ready func.
func _init() -> void:
	mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(MOD_DIR)

	# Add extensions
	install_script_extensions()
	install_script_hook_files()

	# Add translations
	add_translations()


func install_script_extensions() -> void:
	# ! any script extensions should go in this directory, and should follow the same directory structure as vanilla
	extensions_dir_path = mod_dir_path.path_join("extensions")


func install_script_hook_files() -> void:
	extensions_dir_path = mod_dir_path.path_join("extensions")
	ModLoaderMod.install_script_hooks("res://objects/cog/cog.gd", extensions_dir_path.path_join("objects/cog/cog.hooks.gd"))


func add_translations() -> void:
	# ! Place all of your translation files into this directory
	translations_dir_path = mod_dir_path.path_join("translations")


func _ready() -> void:
	pass
