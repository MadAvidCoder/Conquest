extends Node2D

enum {
	ATTACK,
	UPGRADE,
	TRANSFER,
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

var transferrable: bool = false

var stats: Dictionary

var selection_marks: Dictionary
var opposition_marks: Dictionary

var selected: bool = false
var secondary: String = "Scotland"

var phase: int = ATTACK

var path: PackedStringArray = ["Scotland"]

func _ready() -> void:
	get_tree().call_group("sidebar", "hide")
	for i in COUNTRIES.values():
		stats[i] = {
			"relation": NEUTRAL,
			"population": randi_range(20000, 50000),
			"pop_randomizer": randf_range(0.7, 1.3),
			"army_randomizer": randf_range(0.7, 1.3),
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
		stats[i]["army"] = stats[i]["population"] * randf_range(0.1, 0.15)
		
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
	
	var starting_territories = randi_range(2,5)
	var yours = []
	yours.append(COUNTRIES.values().pick_random())
	var iterator = 0
	while starting_territories > 0:
		for i in NETWORK[yours[iterator]]:
			starting_territories -= 1
			if starting_territories == 0:
				break
			yours.append(i)
		iterator += 1
	
	for i in yours:
		stats[i]["relation"] = ALLIED
		opposition_marks[i].hide()

func format_pop(pop: int) -> String:
	if pop < 1_000:
		return "Pop. " + str(pop)
	elif pop < 1_000_000:
		return "Pop. " + str(pop/1000) + "K"
	elif pop < 1_000_000_000:
		return "Pop. " + str(pop/1_000_000) + "M"
	else:
		return "Pop. " + str(pop/1_000_000_000) + "B"

func format_army(army: int) -> String:
	if army < 1_000:
		return "Army " + str(army)
	elif army < 1_000_000:
		return "Army " + str(army/1_000) + "K"
	elif army < 1_000_000_000:
		return "Army " + str(army/1_000_000) + "M"
	else:
		return "Army " + str(army/1_000_000_000) + "B"

func format_resource(resource: int) -> String:
	if resource < 1_000:
		return str(resource)
	else:
		return str(resource/1_000) + "K"

func _process(delta: float) ->  void:
	cursor.position = get_global_mouse_position()
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if cursor.position.x > 250:
			if "country" in str(cursor.get_overlapping_areas()):
				for i in cursor.get_overlapping_areas():
					if "country" in i.name:
						var sel = i.name.split("_")[0]
						if phase == ATTACK and selected and stats[$Sidebar/Territory.text]["relation"] == ALLIED and sel in NETWORK[$Sidebar/Territory.text] and stats[sel]["relation"] != ALLIED:
							get_tree().call_group("secondary", "show")
							$Sidebar/TerritoryTo.text = sel
							$Sidebar/PopulationTo.text = format_pop(stats[sel]["population"])
							$Sidebar/ArmyTo.text = "Est. " + format_army(stats[sel]["army"] * stats[sel]["army_randomizer"])
							if stats[sel]["relation"] == NEUTRAL:
								$Sidebar/ControllerTo.text = "Neutral"
								$Sidebar/ControllerTo.set("theme_override_colors/font_color", Color(0.77,0.77,0.77))
							elif stats[sel]["relation"] == HOSTILE:
								$Sidebar/ControllerTo.text = "Hostile"
								$Sidebar/ControllerTo.set("theme_override_colors/font_color", Color(1,0,0))
							if secondary != "":
								selection_marks[secondary].hide()
							selection_marks[sel].show()
							secondary = sel
							$Sidebar/Confirm.text = "ATTACK\n"+sel
							$Sidebar/Confirm.disabled = false
						elif phase == TRANSFER and transferrable and selected and stats[$Sidebar/Territory.text]["relation"] != HOSTILE and (sel in NETWORK[$Sidebar/Territory.text] or sel in path) and sel != path[0]:
							$Sidebar/Confirm.disabled = false
							if sel in path:
								for j in path.slice(path.find(sel), len(path)):
									selection_marks[j].hide()
								path = path.slice(0, path.find(sel))
							path.append(sel)
							selection_marks[sel].show()
							$Sidebar/Territory.text = sel
							get_tree().call_group("secondary", "show")
							if stats[sel]["relation"] == ALLIED:
								$Sidebar/ControllerTo.text = "Allied"
								$Sidebar/ControllerTo.set("theme_override_colors/font_color", Color(0,1,0))
								$Sidebar/PopulationTo.text = format_pop(stats[sel]["population"])
								$Sidebar/ArmyTo.text = format_army(stats[sel]["army"])
							elif stats[sel]["relation"] == NEUTRAL:
								$Sidebar/ControllerTo.text = "Neutral"
								$Sidebar/ControllerTo.set("theme_override_colors/font_color", Color(0.77,0.77,0.77))
								$Sidebar/PopulationTo.text = format_pop(stats[sel]["population"])
								$Sidebar/ArmyTo.text = "Est. " + format_army(stats[sel]["army"] * stats[sel]["army_randomizer"])
								get_tree().call_group("resource", "hide")
						else:
							if phase == ATTACK:
								$Sidebar/Confirm.disabled = true
								$Sidebar/Confirm.text = "ATTACK\n..."
							transferrable = false
							selected = true
							get_tree().call_group("sidebar", "show")
							get_tree().call_group("secondary", "hide")
							get_tree().call_group("resource", "hide")
							selection_marks[$Sidebar/Territory.text].hide()
							if secondary != "":
								selection_marks[secondary].hide()
							$Sidebar/Territory.text = sel
							if phase == TRANSFER:
								$Sidebar/Confirm.text = "TRANSFER FROM\n..."
								$Sidebar/Confirm.disabled = true
								for j in path:
									selection_marks[j].hide()
							selection_marks[sel].show()
							if stats[sel]["relation"] == ALLIED:
								$Sidebar/Controller.text = "Allied"
								$Sidebar/Controller.set("theme_override_colors/font_color", Color(0,1,0))
								$Sidebar/Population.text = format_pop(stats[sel]["population"])
								$Sidebar/Army.text = format_army(stats[sel]["army"])
								$Sidebar/WoodValue.text = format_resource(stats[sel]["resources"]["wood"])
								$Sidebar/StoneValue.text = format_resource(stats[sel]["resources"]["stone"])
								$Sidebar/GrainValue.text = format_resource(stats[sel]["resources"]["grain"])
								$Sidebar/CoalValue.text = format_resource(stats[sel]["resources"]["coal"])
								$Sidebar/LivestockValue.text = format_resource(stats[sel]["resources"]["livestock"])
								$Sidebar/IronValue.text = format_resource(stats[sel]["resources"]["iron"])
								$Sidebar/GoldValue.text = format_resource(stats[sel]["resources"]["gold"])
								$Sidebar/TechnologyValue.text = format_resource(stats[sel]["resources"]["technology"])
								if phase == UPGRADE:
									$Sidebar/Confirm.disabled = false
									get_tree().call_group("resource", "show")
								elif phase == TRANSFER:
									$Sidebar/Confirm.text = "TRANSFER FROM\n" + sel
									transferrable = true
									path = [sel]
							elif stats[sel]["relation"] == NEUTRAL:
								$Sidebar/Controller.text = "Neutral"
								$Sidebar/Controller.set("theme_override_colors/font_color", Color(0.77,0.77,0.77))
								$Sidebar/Population.text = format_pop(stats[sel]["population"])
								$Sidebar/Army.text = "Est. " + format_army(stats[sel]["army"] * stats[sel]["army_randomizer"])
								get_tree().call_group("resource", "hide")
								if phase == UPGRADE:
									$Sidebar/Confirm.disabled = true
							elif stats[sel]["relation"] == HOSTILE:
								$Sidebar/Controller.text = "Hostile"
								$Sidebar/Controller.set("theme_override_colors/font_color", Color(1,0,0))
								$Sidebar/Population.text = "Est. " + format_pop(stats[sel]["population"] * stats[sel]["pop_randomizer"])
								$Sidebar/Army.text = "Army Unknown"
								get_tree().call_group("resource", "hide")
								if phase == UPGRADE:
									$Sidebar/Confirm.disabled = true
			else:
				transferrable = false
				get_tree().call_group("sidebar", "hide")
				selection_marks[$Sidebar/Territory.text].hide()
				if secondary != "":
					selection_marks[secondary].hide()
				$Sidebar/Confirm.disabled = true
				if phase == ATTACK:
					$Sidebar/Confirm.text = "ATTACK\n..."
				elif phase == TRANSFER:
					$Sidebar/Confirm.text = "TRANSFER TO\n..."
				selected = false
				for i in path:
					selection_marks[i].hide()

func _on_confirm_pressed() -> void:
	if phase == ATTACK:
		var lost: float = 0
		while stats[$Sidebar/Territory.text]["army"] > 501 and stats[secondary]["army"] > 0:
			var losing: float = randfn(0.8, 0.166)
			stats[$Sidebar/Territory.text]["army"] -= losing
			lost += losing
			stats[secondary]["army"] -= 1
		if stats[secondary]["army"] > 0:
			stats[secondary]["relation"] = HOSTILE
			var sel = $Sidebar/Territory.text
			$Sidebar/Controller.text = "Allied"
			$Sidebar/Controller.set("theme_override_colors/font_color", Color(0,1,0))
			$Sidebar/Population.text = format_pop(stats[sel]["population"])
			$Sidebar/Army.text = format_army(stats[sel]["army"])
			get_tree().call_group("secondary", "hide")
			selection_marks[secondary].hide()
		else:
			stats[secondary]["relation"] = ALLIED
			opposition_marks[secondary].hide()
			stats[secondary]["army"] = lost / 2
			selected = true
			var sel = secondary
			secondary = ""
			get_tree().call_group("secondary", "hide")
			selection_marks[$Sidebar/Territory.text].hide()
			$Sidebar/Territory.text = sel
			selection_marks[sel].show()
			$Sidebar/Controller.text = "Allied"
			$Sidebar/Controller.set("theme_override_colors/font_color", Color(0,1,0))
			$Sidebar/Population.text = format_pop(stats[sel]["population"])
			$Sidebar/Army.text = format_army(stats[sel]["army"])
			$Sidebar/WoodValue.text = format_resource(stats[sel]["resources"]["wood"])
			$Sidebar/StoneValue.text = format_resource(stats[sel]["resources"]["stone"])
			$Sidebar/GrainValue.text = format_resource(stats[sel]["resources"]["grain"])
			$Sidebar/CoalValue.text = format_resource(stats[sel]["resources"]["coal"])
			$Sidebar/LivestockValue.text = format_resource(stats[sel]["resources"]["livestock"])
			$Sidebar/IronValue.text = format_resource(stats[sel]["resources"]["iron"])
			$Sidebar/GoldValue.text = format_resource(stats[sel]["resources"]["gold"])
			$Sidebar/TechnologyValue.text = format_resource(stats[sel]["resources"]["technology"])
	elif phase == UPGRADE:
		print("upgrading " + $Sidebar/Territory.text)
	elif phase == TRANSFER:
		print($Sidebar/Territory.text + " transferring to " + secondary)

func _on_continue_pressed() -> void:
	if phase == ATTACK:
		phase = UPGRADE
		get_tree().call_group("sidebar", "hide")
		selection_marks[$Sidebar/Territory.text].hide()
		if secondary != "":
			selection_marks[secondary].hide()
		$Sidebar/Confirm.disabled = true
		$Sidebar/Confirm.text = "UPGRADE"
		$Sidebar/Confirm.disabled = true
		selected = false
	elif phase == UPGRADE:
		phase = TRANSFER
		get_tree().call_group("sidebar", "hide")
		selection_marks[$Sidebar/Territory.text].hide()
		if secondary != "":
			selection_marks[secondary].hide()
		$Sidebar/Confirm.disabled = true
		$Sidebar/Confirm.text = "TRANSFER TO\n..."
		$Sidebar/Confirm.disabled = true
		selected = false
	elif phase == TRANSFER:
		get_tree().call_group("sidebar", "hide")
		selection_marks[$Sidebar/Territory.text].hide()
		if secondary != "":
			selection_marks[secondary].hide()
		$Sidebar/Confirm.disabled = true
		$Sidebar/Confirm.text = "COMPUTING..."
		$Sidebar/Confirm.disabled = true
		selected = false
