extends Node2D

enum {
	ATTACK,
	UPGRADE,
	TRANSFER,
	COMPUTE,
}

enum {
	ALLIED,
	NEUTRAL,
	HOSTILE,
}

const COUNTRIES: Dictionary = {
	0: "Scotland",
	1: "Norway",
	2: "Sweden",
	3: "Novgorod",
	4: "Rostov",
	5: "Ireland",
	6: "London",
	7: "Ribe",
	8: "Balts",
	9: "Kiev",
	10: "Cumans",
	11: "Wales",
	12: "Frisia",
	13: "Lusatia",
	14: "Pomerania",
	15: "Cracow",
	16: "Lorraine",
	17: "Aachen",
	18: "Thuringia",
	19: "Bohemia",
	20: "Pechenegs",
	21: "Brittany",
	22: "Paris",
	23: "Alemannia",
	24: "Bavaria",
	25: "Budapest",
	26: "Crimea",
	27: "Bordeaux",
	28: "Burgundy",
	29: "Pavia",
	30: "Venetia",
	31: "Serbia",
	32: "Bulgaria",
	33: "Leon",
	34: "Navarra",
	35: "Rome",
	36: "Lusitania",
	37: "Toledo",
	38: "Aragona",
	39: "Sardinia",
	40: "Naples",
	41: "Athens",
	42: "Constantinople",
	43: "Anatolia",
	44: "Al-Andalus",
	45: "Granada",
	46: "Palermo",
}

const NETWORK: Dictionary = {
	"Scotland": ["Norway", "Ireland", "London"],
	"Norway": ["Scotland", "Ribe", "Sweden"],
	"Sweden": ["Norway", "Ribe", "Cracow", "Novgorod"],
	"Novgorod": ["Sweden", "Balts", "Kiev", "Cumans", "Rostov"],
	"Rostov": ["Novgorod", "Cumans"],
	"Ireland": ["Scotland", "Wales"],
	"London": ["Scotland", "Frisia", "Lorraine", "Brittany", "Wales"],
	"Ribe": ["Norway", "Sweden", "Lusatia"],
	"Balts": ["Novgorod", "Kiev", "Cracow"],
	"Kiev": ["Novgorod", "Cumans", "Pechenegs", "Cracow", "Balts"],
	"Cumans": ["Rostov", "Crimea", "Pechenegs", "Kiev", "Novgorod"],
	"Wales": ["Ireland", "London"],
	"Frisia": ["Lusatia", "Aachen", "Lorraine", "London"],
	"Lusatia": ["Ribe", "Pomerania", "Aachen", "Frisia"],
	"Pomerania": ["Cracow", "Bohemia", "Thuringia", "Aachen", "Lusatia"],
	"Cracow": ["Balts", "Kiev", "Pechenegs", "Budapest", "Bohemia", "Pomerania", "Sweden"],
	"Lorraine": ["London", "Frisia", "Aachen", "Alemannia", "Burgundy", "Paris", "Brittany"],
	"Aachen": ["Frisia", "Lusatia", "Pomerania", "Thuringia", "Alemannia", "Lorraine"],
	"Thuringia": ["Pomerania", "Bohemia", "Bavaria", "Alemannia", "Aachen"],
	"Bohemia": ["Cracow", "Budapest", "Bavaria", "Thuringia", "Pomerania"],
	"Pechenegs": ["Kiev", "Cumans", "Crimea", "Bulgaria", "Budapest", "Cracow"],
	"Brittany": ["London", "Lorraine", "Paris", "Bordeaux"],
	"Paris": ["Brittany", "Lorraine", "Burgundy", "Bordeaux"],
	"Alemannia": ["Aachen", "Thuringia", "Bavaria", "Pavia", "Burgundy", "Lorraine"],
	"Bavaria": ["Thuringia", "Bohemia", "Budapest", "Venetia", "Pavia", "Alemannia"],
	"Budapest": ["Cracow", "Pechenegs", "Bulgaria", "Serbia", "Venetia", "Bavaria", "Bohemia"],
	"Crimea": ["Cumans", "Bulgaria", "Pechenegs"],
	"Bordeaux": ["Paris", "Burgundy", "Aragona", "Navarra", "Leon", "Brittany"],
	"Burgundy": ["Lorraine", "Alemannia", "Pavia", "Aragona", "Bordeaux", "Paris"],
	"Pavia": ["Alemannia", "Bavaria", "Venetia", "Rome", "Burgundy"],
	"Venetia": ["Bavaria", "Budapest", "Serbia", "Naples", "Pavia"],
	"Serbia": ["Budapest", "Bulgaria", "Athens", "Venetia"],
	"Bulgaria": ["Pechenegs", "Crimea", "Constantinople", "Athens", "Serbia", "Budapest"],
	"Leon": ["Bordeaux", "Navarra", "Toledo", "Lusitania"],
	"Navarra": ["Bordeaux", "Aragona", "Granada", "Toledo", "Leon"],
	"Rome": ["Pavia", "Naples", "Sardinia"],
	"Lusitania": ["Leon", "Toledo", "Al-Andalus"],
	"Toledo": ["Leon", "Navarra", "Granada", "Al-Andalus", "Lusitania"],
	"Aragona": ["Bordeaux", "Burgundy", "Granada", "Navarra"],
	"Sardinia": ["Rome", "Palermo"],
	"Naples": ["Rome", "Venetia", "Athens", "Palermo"],
	"Athens": ["Serbia", "Bulgaria", "Constantinople", "Naples"],
	"Constantinople": ["Bulgaria", "Anatolia", "Athens"],
	"Anatolia": ["Constantinople"],
	"Al-Andalus": ["Toledo", "Granada", "Lusitania"],
	"Granada": ["Aragona", "Al-Andalus", "Toledo", "Navarra"],
	"Palermo": ["Naples", "Sardinia"],
}

@onready var cursor = $Cursor

var stats: Dictionary

var selection_marks: Dictionary
var opposition_marks: Dictionary

var phase: int = -1

func _ready() -> void:
	for i in COUNTRIES.values():
		stats[i] = {
			"relation": NEUTRAL,
			"population": randi_range(20000, 50000),
			"pop_randomizer": randf_range(0.7, 1.3),
			"tree": [],
			"resources": {
				"wood": randi_range(25, 60),
				"stone": randi_range(20, 50),
				"coal": randi_range(10, 25),
				"grain": randi_range(25, 60),
				"livestock": randi_range(20, 50),
				"iron": clamp(randi_range(-10,20),0,20),
				"gold": clamp(randi_range(-20,10),0,10),
				"technology": randi_range(0,5),
			},
		}
		stats[i]["military"] = stats[i]["population"] * randf_range(0.1, 0.15)
		
		# Opponent Masks
		var new_texture = load("res://assets/map/opponent/"+i+".png")
		var new_sprite = Sprite2D.new()
		new_sprite.z_index = 2
		new_sprite.texture = new_texture
		new_sprite.position = Vector2(574.5, 355)
		new_sprite.scale = Vector2(0.951, 0.951)
		new_sprite.self_modulate = Color(1,1,1,0.85)
		add_child(new_sprite)
		opposition_marks[i] = new_sprite
	
		# Selection Masks
		new_texture = load("res://assets/map/selected/"+i+".png")
		new_sprite = Sprite2D.new()
		new_sprite.texture = new_texture
		new_sprite.z_index = 2
		new_sprite.position = Vector2(574.5, 355)
		new_sprite.scale = Vector2(0.951, 0.951)
		new_sprite.self_modulate = Color(1,1,1,0.95)
		add_child(new_sprite)
		new_sprite.hide()
		selection_marks[i] = new_sprite
	
		# Click Masks
		new_texture = load("res://assets/map/click_masks/"+i+".png.bmp")
		var polygons = new_texture.opaque_to_polygons(Rect2(Vector2.ZERO, new_texture.get_size()))
		var new_area = Area2D.new()
		new_area.position = Vector2(-338, -159)
		new_area.scale = Vector2(0.951, 0.951)
		new_area.name = i + "_country_area"
		add_child(new_area)
		for j in polygons:
			var new_collider = CollisionPolygon2D.new()
			new_collider.polygon = j
			new_area.add_child(new_collider)

func format_pop(pop: int) -> String:
	if pop < 1_000:
		return "Pop. " + str(pop)
	elif pop < 1_000_000:
		return "Pop. " + str(pop/1000) + "K"
	elif pop < 1_000_000_000:
		return "Pop. " + str(pop/1_000_000) + "M"
	else:
		return "Pop. " + str(pop/1_000_000_000) + "B"

func _process(delta: float) ->  void:
	cursor.position = get_global_mouse_position()
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if "country" in str(cursor.get_overlapping_areas()):
			for i in cursor.get_overlapping_areas():
				if "country" in i.name:
					get_tree().call_group("sidebar", "show")
					var sel = i.name.split("_")[0]
					selection_marks[$Sidebar/Territory.text].hide()
					$Sidebar/Territory.text = sel
					selection_marks[sel].show()
					
					if stats[sel]["relation"] == ALLIED:
						$Sidebar/Controller.text = "Allied"
						$Sidebar/Controller.set("theme_override_colors/font_color", Color(0,1,0))
						$Sidebar/Population.text = format_pop(stats[sel]["population"])
					elif stats[sel]["relation"] == NEUTRAL:
						$Sidebar/Controller.text = "Neutral"
						$Sidebar/Controller.set("theme_override_colors/font_color", Color(0.77,0.77,0.77))
						$Sidebar/Population.text = format_pop(stats[sel]["population"])
					elif stats[sel]["relation"] == HOSTILE:
						$Sidebar/Controller.text = "Hostile"
						$Sidebar/Controller.set("theme_override_colors/font_color", Color(1,0,0))
						$Sidebar/Population.text = "Est. "+format_pop(stats[sel]["population"] * stats[sel]["pop_randomizer"])
		else:
			get_tree().call_group("sidebar", "hide")
			selection_marks[$Sidebar/Territory.text].hide()

	## Game Loop 
	if phase == ATTACK:
		# On selected (from) territorys
		# Show "ATTACKING FROM: [TERRITORY]" at the top
		# On selected (to) territory
		# Show attack button
		# use a TBD algorithm to fight
		pass
	elif phase == UPGRADE:
		# On Selected territory
		# Show tree, and upgrade options
		# On Click research icon
		# Show research tree, and upgrade options
		pass
	elif phase == TRANSFER:
		# On selected (from) territory
		# Show "TRANSFERING FROM: [TERRITORY]" at the top
		# On selected (to) territory
		# Select what, and how much, to transfer
		# On click transfer
		# Lose some on the way, if through hostile territories
		pass
	elif phase == COMPUTE:
		# TBD: Some territories retaliate/attack back (weighted towards player)
		# Resource, population, army regeneration
		pass
	
	## Other stuff
	# Hover/click territories
	# Show stats
	# Click (either) tree
	# Show fullscreen tree view
	# Zoom in/out / Pan
