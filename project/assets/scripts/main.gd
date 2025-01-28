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

signal upgrade(what: String)

signal global_upgrade(what: String)

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

var territory_tree: Dictionary

var transferrable: bool = false

var stats: Dictionary

var selection_marks: Dictionary
var opposition_marks: Dictionary

var selected: bool = false
var secondary: String = "Scotland"

var phase: int = ATTACK

var path: PackedStringArray = ["Scotland"]

var to_be_upgraded: String

var global_tree: Dictionary

var your_global_tree: PackedStringArray = ["Research"]

var gold: int = 0
var gold_pans: int = 0

var research: int = 5

func _ready() -> void:
	territory_tree = {
		"Base": {
			"node": $TerritoryTree/Base,
			"before": "Base",
			"locked": false,
			"costs": {
				"wood": 0,
				"stone": 0,
				"iron": 0,
				"grain": 0,
			},
		},
		"BarracksI": {
			"node": $TerritoryTree/BarracksI,
			"before": "Base",
			"locked": false,
			"costs": {
				"wood": 20,
				"stone": 20,
				"iron": 0,
				"grain": 20,
			},
		},
		"BarracksII": {
			"node": $TerritoryTree/BarracksII,
			"before": "BarracksI",
			"locked": false,
			"costs": {
				"wood": 20,
				"stone": 20,
				"iron": 0,
				"grain": 20,
			},
		},
		"BarracksIII": {
			"node": $TerritoryTree/BarracksIII,
			"before": "BarracksII",
			"locked": false,
			"costs": {
				"wood": 30,
				"stone": 30,
				"iron": 10,
				"grain": 30,
			},
		},
		"PlunderI": {
			"node": $TerritoryTree/PlunderI,
			"before": "BarracksI",
			"locked": false,
			"costs": {
				"wood": 10,
				"stone": 0,
				"iron": 15,
				"grain": 0,
			},
		},
		"PlunderII": {
			"node": $TerritoryTree/PlunderII,
			"before": "PlunderI",
			"locked": false,
			"costs": {
				"wood": 15,
				"stone": 0,
				"iron": 20,
				"grain": 0,
			},
		},
		"Espionage": {
			"node": $TerritoryTree/Espionage,
			"before": "BarracksI",
			"locked": true,
			"costs": {
				"wood": 0,
				"stone": 10,
				"iron": 0,
				"grain": 20,
			},
		},
		"SiegeEnginesI": {
			"node": $TerritoryTree/SiegeEnginesI,
			"before": "PlunderI",
			"locked": true,
			"costs": {
				"wood": 20,
				"stone": 0,
				"iron": 20,
				"grain": 0,
			},
		},
		"SiegeEnginesII": {
			"node": $TerritoryTree/SiegeEnginesII,
			"before": "SiegeEnginesII",
			"locked": true,
			"costs": {
				"wood": 20,
				"stone": 0,
				"iron": 20,
				"grain": 0,
			},
		},
		"FortificationsI": {
			"node": $TerritoryTree/FortificationsI,
			"before": "Espionage",
			"locked": true,
			"costs": {
				"wood": 10,
				"stone": 20,
				"iron": 0,
				"grain": 0,
			},
		},
		"FortificationsII": {
			"node": $TerritoryTree/FortificationsII,
			"before": "FortificationsI",
			"locked": true,
			"costs": {
				"wood": 10,
				"stone": 20,
				"iron": 0,
				"grain": 0,
			},
		},
		"Conscription": {
			"node": $TerritoryTree/Conscription,
			"before": "FortificationsI,SiegeEnginesI",
			"locked": false,
			"costs": {
				"wood": 10,
				"stone": 10,
				"iron": 5,
				"grain": 30,
			},
		},
		"ResourceGatheringI": {
			"node": $TerritoryTree/ResourceGatheringI,
			"before": "Base",
			"locked": false,
			"costs": {
				"wood": 25,
				"stone": 25,
				"iron": 15,
				"grain": 30,
			},
		},
		"ResourceGatheringII": {
			"node": $TerritoryTree/ResourceGatheringII,
			"before": "ResourceGatheringI",
			"locked": false,
			"costs": {
				"wood": 30,
				"stone": 30,
				"iron": 20,
				"grain": 40,
			},
		},
		"LumberMill": {
			"node": $TerritoryTree/LumberMill,
			"before": "ResourceGatheringI",
			"locked": true,
			"costs": {
				"wood": 60,
				"stone": 15,
				"iron": 10,
				"grain": 25,
			},
		},
		"Brickworks": {
			"node": $TerritoryTree/Brickworks,
			"before": "ResourceGatheringI",
			"locked": true,
			"costs": {
				"wood": 20,
				"stone": 50,
				"iron": 10,
				"grain": 25,
			},
		},
		"IronSmelting": {
			"node": $TerritoryTree/IronSmelting,
			"before": "ResourceGatheringI",
			"locked": true,
			"costs": {
				"wood": 20,
				"stone": 15,
				"iron": 30,
				"grain": 25,
			},
		},
		"Cultivation": {
			"node": $TerritoryTree/Cultivation,
			"before": "ResourceGatheringI",
			"locked": true,
			"costs": {
				"wood": 30,
				"stone": 25,
				"iron": 15,
				"grain": 60,
			},
		},
		"GoldProspecting": {
			"node": $TerritoryTree/GoldProspecting,
			"before": "LumberMill,Brickworks,IronSmelting",
			"locked": true,
			"costs": {
				"wood": 30,
				"stone": 25,
				"iron": 20,
				"grain": 40,
			},
		},
		"ImmigrationI": {
			"node": $TerritoryTree/ImmigrationI,
			"before": "Cultivation",
			"locked": false,
			"costs": {
				"wood": 25,
				"stone": 20,
				"iron": 10,
				"grain": 40,
			},
		},
		"ImmigrationII": {
			"node": $TerritoryTree/ImmigrationII,
			"before": "ImmigrationI",
			"locked": false,
			"costs": {
				"wood": 25,
				"stone": 20,
				"iron": 10,
				"grain": 40,
			},
		},
	}
	global_tree = {
		"Research": {
			"node": $GlobalTree/Research,
			"before": "Research",
			"costs": {
				"gold": 0,
				"research": 0,
			},
		},
		"MilitaryAcademy": {
			"node": $GlobalTree/MilitaryAcademy,
			"before": "Research",
			"costs": {
				"gold": 0,
				"research": 5,
			},
		},
		"GoldTreasury": {
			"node": $GlobalTree/GoldTreasury,
			"before": "Research",
			"costs": {
				"gold": 0,
				"research": 5,
			},
		},
		"Taxation": {
			"node": $GlobalTree/Taxation,
			"before": "GoldTreasury",
			"costs": {
				"gold": 0,
				"research": 30,
			},
		},
		"GoldPanning": {
			"node": $GlobalTree/GoldPanning,
			"before": "GoldTreasury",
			"costs": {
				"gold": 0,
				"research": 20,
			},
		},
		"Medicine": {
			"node": $GlobalTree/Medicine,
			"before": "Taxation,GoldPanning",
			"costs": {
				"gold": 150,
				"research": 30,
			},
		},
		"RoadBuilding": {
			"node": $GlobalTree/RoadBuilding,
			"before": "MilitaryAcademy",
			"costs": {
				"gold": 40,
				"research": 10,
			},
		},
		"SiegeMastery": {
			"node": $GlobalTree/SiegeMastery,
			"before": "RoadBuilding",
			"costs": {
				"gold": 80,
				"research": 25,
			},
		},
		"WallBuilding": {
			"node": $GlobalTree/WallBuilding,
			"before": "RoadBuilding",
			"costs": {
				"gold": 60,
				"research": 20,
			},
		},
		"AgricultureI": {
			"node": $GlobalTree/AgricultureI,
			"before": "Research",
			"costs": {
				"gold": 0,
				"research": 10,
			},
		},
		"Forestry": {
			"node": $GlobalTree/Forestry,
			"before": "AgricultureI",
			"costs": {
				"gold": 5,
				"research": 15,
			},
		},
		"Masonry": {
			"node": $GlobalTree/Masonry,
			"before": "AgricultureI",
			"costs": {
				"gold": 5,
				"research": 15,
			},
		},
		"Blacksmiths": {
			"node": $GlobalTree/Blacksmiths,
			"before": "AgricultureI",
			"costs": {
				"gold": 5,
				"research": 15,
			},
		},
		"CropRotation": {
			"node": $GlobalTree/CropRotation,
			"before": "AgricultureI",
			"costs": {
				"gold": 5,
				"research": 15,
			},
		},
		"AgricultureII": {
			"node": $GlobalTree/AgricultureII,
			"before": "Forestry,Masonry,Blacksmiths,CropRotation",
			"costs": {
				"gold": 120,
				"research": 30,
			},
		},
		"PoliticalIdeology": {
			"node": $GlobalTree/PoliticalIdeology,
			"before": "Research",
			"costs": {
				"gold": 0,
				"research": 10,
			},
		},
		"Espionage": {
			"node": $GlobalTree/Espionage,
			"before": "PoliticalIdeology",
			"costs": {
				"gold": 40,
				"research": 20,
			},
		},
		"Pacifism": {
			"node": $GlobalTree/Pacifism,
			"before": "Espionage",
			"costs": {
				"gold": 250,
				"research": 30,
			},
		},
	}
	get_tree().call_group("sidebar", "hide")
	for i in COUNTRIES.values():
		stats[i] = {
			"relation": NEUTRAL,
			"spied_on": false,
			"population": randi_range(20000, 50000),
			"pop_randomizer": randf_range(0.7, 1.3),
			"army_randomizer": randf_range(0.7, 1.3),
			"tree": [
				"Base",
			],
			"resources": {
				"wood": randi_range(25, 60),
				"stone": randi_range(20, 50),
				"grain": randi_range(25, 60),
				"iron": clamp(randi_range(-10,20),0,20),
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
	
	var finished: bool = false
	while not finished:
		var chosen: String = stats.keys().pick_random()
		if stats[chosen]["relation"] ==  NEUTRAL:
			finished = true
			opposition_marks[chosen].self_modulate = Color(1, 0.28, 0.28, 0.79)
			stats[chosen]["relation"] = HOSTILE

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
		return "Army " + str(snapped(army/1000.0, 0.1)) + "K"
	elif army < 1_000_000_000:
		return "Army " + str(snapped(army/1_000_000.0, 0.1)) + "M"
	else:
		return "Army " + str(snapped(army/1_000_000_000.0, 0.1)) + "B"

func format_resource(resource: int) -> String:
	if resource < 1_000:
		return str(resource)
	else:
		return str(resource/1_000) + "K"

func _process(delta: float) ->  void:
	cursor.position = get_global_mouse_position()
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if cursor.position.x > 250 and not $TransferSelect.visible and not $TerritoryTree.visible and not $GlobalTree.visible:
			if "country" in str(cursor.get_overlapping_areas()):
				for i in cursor.get_overlapping_areas():
					if "country" in i.name:
						var sel = i.name.split("_")[0]
						if phase == ATTACK and selected and stats[$Sidebar/Territory.text]["relation"] == ALLIED and sel in NETWORK[$Sidebar/Territory.text] and stats[sel]["relation"] != ALLIED:
							get_tree().call_group("secondary", "show")
							$Sidebar/TerritoryTo.text = sel
							if stats[sel]["relation"] == NEUTRAL:
								$Sidebar/PopulationTo.text = format_pop(stats[sel]["population"])
								if stats[sel]["spied_on"]:
									$Sidebar/ArmyTo.text = format_army(stats[sel]["army"])
								else:
									$Sidebar/ArmyTo.text = "Est. " + format_army(stats[sel]["army"] * stats[sel]["army_randomizer"])
								$Sidebar/ControllerTo.text = "Neutral"
								$Sidebar/ControllerTo.set("theme_override_colors/font_color", Color(0.77,0.77,0.77))
							elif stats[sel]["relation"] == HOSTILE:
								if stats[sel]["spied_on"]:
									$Sidebar/PopulationTo.text = format_pop(stats[sel]["population"])
									$Sidebar/ArmyTo.text = "Est. " + format_army(stats[sel]["army"] * stats[sel]["army_randomizer"])
								else:
									$Sidebar/PopulationTo.text = "Est. " + format_pop(stats[sel]["population"] * stats[sel]["pop_randomizer"])
									$Sidebar/ArmyTo.text = "Army Unknown"
								$Sidebar/ControllerTo.text = "Hostile"
								$Sidebar/ControllerTo.set("theme_override_colors/font_color", Color(1,0,0))
							if secondary != "":
								selection_marks[secondary].hide()
							selection_marks[sel].show()
							secondary = sel
							$Sidebar/Confirm.text = "ATTACK\n"+sel
							$Sidebar/Confirm.disabled = false
						elif phase == TRANSFER and transferrable and selected and stats[$Sidebar/Territory.text]["relation"] != HOSTILE and (sel in NETWORK[$Sidebar/TerritoryTo.text] or sel in path) and sel != path[0]:
							if stats[sel]["relation"] == ALLIED:
								$Sidebar/Confirm.disabled = false
							else:
								$Sidebar/Confirm.disabled = true
							if sel in path:
								for j in path.slice(path.find(sel), len(path)):
									selection_marks[j].hide()
								path = path.slice(0, path.find(sel))
							path.append(sel)
							selection_marks[sel].show()
							$Sidebar/TerritoryTo.text = sel
							get_tree().call_group("secondary", "show")
							if stats[sel]["relation"] == ALLIED:
								$Sidebar/ControllerTo.text = "Allied"
								$Sidebar/ControllerTo.set("theme_override_colors/font_color", Color(0,1,0))
								$Sidebar/PopulationTo.text = format_pop(stats[sel]["population"])
								$Sidebar/ArmyTo.text = format_army(stats[sel]["army"])
							elif stats[sel]["relation"] == NEUTRAL:
								$Sidebar/ControllerTo.text = "Neutral"
								$Sidebar/ControllerTo.set("theme_override_colors/font_color", Color(0.77,0.77,0.77))
								if stats[sel]["spied_on"]:
									$Sidebar/ArmyTo.text = format_army(stats[sel]["army"])
								else:
									$Sidebar/ArmyTo.text = "Est. " + format_army(stats[sel]["army"] * stats[sel]["army_randomizer"])
								$Sidebar/PopulationTo.text = format_pop(stats[sel]["population"])
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
							$Sidebar/TerritoryTo.text = sel
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
								$Sidebar/IronValue.text = format_resource(stats[sel]["resources"]["iron"])
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
								if stats[sel]["spied_on"]:
									$Sidebar/Army.text = format_army(stats[sel]["army"])
								else:
									$Sidebar/Army.text = "Est. " + format_army(stats[sel]["army"] * stats[sel]["army_randomizer"])
								get_tree().call_group("resource", "hide")
								if phase == UPGRADE:
									$Sidebar/Confirm.disabled = true
							elif stats[sel]["relation"] == HOSTILE:
								$Sidebar/Controller.text = "Hostile"
								$Sidebar/Controller.set("theme_override_colors/font_color", Color(1,0,0))
								if stats[sel]["spied_on"]:
									$Sidebar/Population.text = format_pop(stats[sel]["population"])
									$Sidebar/Army.text = "Est. " + format_army(stats[sel]["army"] * stats[sel]["army_randomizer"])
								else:
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
			var multiplier: float = 1
			if "MilitaryAcademy" in your_global_tree:
				multiplier = 1.05
			if "SiegeEnginesII" in stats[$Sidebar/Territory.text]["tree"]:
				stats[secondary]["army"] -= 1.1 * multiplier
			if "SiegeEnginesI" in stats[$Sidebar/Territory.text]["tree"]:
				stats[secondary]["army"] -= 1.05 * multiplier
			else:
				stats[secondary]["army"] -= 1 * multiplier
		if stats[secondary]["army"] > 0:
			opposition_marks[secondary].self_modulate = Color(1, 0.28, 0.28, 0.79)
			stats[secondary]["relation"] = HOSTILE
			var sel = $Sidebar/Territory.text
			$Sidebar/Controller.text = "Allied"
			$Sidebar/Controller.set("theme_override_colors/font_color", Color(0,1,0))
			$Sidebar/Population.text = format_pop(stats[sel]["population"])
			$Sidebar/Army.text = format_army(stats[sel]["army"])
			get_tree().call_group("secondary", "hide")
			selection_marks[secondary].hide()
		else:
			if "PlunderII" in stats[$Sidebar/Territory.text]["tree"]:
				stats[$Sidebar/Territory.text]["resources"]["wood"] += stats[secondary]["resources"]["wood"] * 0.25
				stats[$Sidebar/Territory.text]["resources"]["stone"] += stats[secondary]["resources"]["stone"] * 0.25
				stats[$Sidebar/Territory.text]["resources"]["grain"] += stats[secondary]["resources"]["grain"] * 0.25
				stats[$Sidebar/Territory.text]["resources"]["iron"] += stats[secondary]["resources"]["iron"] * 0.25
			elif "PlunderI" in stats[$Sidebar/Territory.text]["tree"]:
				stats[$Sidebar/Territory.text]["resources"]["wood"] += stats[secondary]["resources"]["wood"] * 0.15
				stats[$Sidebar/Territory.text]["resources"]["stone"] += stats[secondary]["resources"]["stone"] * 0.15
				stats[$Sidebar/Territory.text]["resources"]["grain"] += stats[secondary]["resources"]["grain"] * 0.15
				stats[$Sidebar/Territory.text]["resources"]["iron"] += stats[secondary]["resources"]["iron"] * 0.15
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
			$Sidebar/IronValue.text = format_resource(stats[sel]["resources"]["iron"])
	elif phase == UPGRADE:
		$Sidebar/Continue.text = "Close"
		$TerritoryTree/Base.text = $Sidebar/Territory.text
		$TerritoryTree.show()
		get_tree().call_group("territory_tree_button", "remove_theme_color_override", "font_disabled_color")
		get_tree().set_group("territory_tree_button", "disabled", true)
		for i in stats[$Sidebar/Territory.text]["tree"]:
			territory_tree[i]["node"].set("theme_override_colors/font_disabled_color", Color(0,1,0))
		for i in territory_tree.keys():
			var before_checked: bool = false
			for j in territory_tree[i]["before"].split(","):
				if j in stats[$Sidebar/Territory.text]["tree"]:
					before_checked = true
			if before_checked and not territory_tree[i]["locked"] and not i in stats[$Sidebar/Territory.text]["tree"]:
				territory_tree[i]["node"].disabled = false
	elif phase == TRANSFER:
		$TransferSelect.show()
		$TransferSelect/Soldiers.max_value = stats[path[0]]["army"] - 100
		$TransferSelect/CountryLabel.text = "from " + path[0] + "\nto " + path[-1]

func _on_continue_pressed() -> void:
	if $TerritoryTree.visible:
		$TerritoryTree.hide()
		$Sidebar/Continue.text = "Next Phase"
	elif $GlobalTree.visible:
		$GlobalTree.hide()
		$Sidebar/Continue.text = "Next Phase"
	else:
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
			$Sidebar/Confirm.text = "TRANSFER FROM\n..."
			$Sidebar/Confirm.disabled = true
			selected = false
		elif phase == TRANSFER:
			for country in stats.keys():
				if stats[country]["relation"] == HOSTILE:
					if randf() <= 0.5:
						var allied: PackedStringArray = []
						var least_allied_troops = INF
						var least_allied = ""
						var neutral: PackedStringArray = []
						var least_neutral_troops = INF
						var least_neutral = ""
						for neighbour in NETWORK[country]:
							match stats[neighbour]["relation"]:
								ALLIED:
									allied.append(neighbour)
								NEUTRAL:
									neutral.append(neighbour)
						for i in allied:
							if stats[i]["army"] < least_allied_troops:
								least_allied_troops = stats[i]["army"]
								least_allied = i
						for i in neutral:
							if stats[i]["army"] < least_neutral_troops:
								least_neutral_troops = stats[i]["army"]
								least_neutral = i
						if least_allied_troops <= stats[country]["army"]:
							var lost: float = 0
							while stats[country]["army"] > 501 and stats[least_allied]["army"] > 0:
								var losing: float = randfn(0.8, 0.166)
								stats[country]["army"] -= losing
								lost += losing
								if "FortificationsII" in stats[least_allied]["tree"]:
									stats[least_allied]["army"] -= 0.7
								if "FortificationsI" in stats[least_allied]["tree"]:
									stats[least_allied]["army"] -= 0.85
								else:
									stats[least_allied]["army"] -= 1
							if stats[least_allied]["army"] <= 0:
								opposition_marks[least_allied].self_modulate = Color(1, 0.28, 0.28, 0.79)
								stats[least_allied]["relation"] = HOSTILE
								opposition_marks[least_allied].show()
								stats[least_allied]["army"] = lost / 2
							else:
								opposition_marks[country].self_modulate = Color(1, 1, 1, 0.95)
								stats[country]["relation"] = NEUTRAL
						elif len(allied) == 0:
							if least_neutral_troops <= stats[country]["army"]:
								var lost: float = 0
								while stats[country]["army"] > 501 and stats[least_neutral]["army"] > 0:
									var losing: float = randfn(0.8, 0.166)
									stats[country]["army"] -= losing
									lost += losing
									stats[least_neutral]["army"] -= 1
								if stats[least_neutral]["army"] <= 0:
									opposition_marks[least_neutral].self_modulate = Color(1, 0.28, 0.28, 0.79)
									stats[least_neutral]["relation"] = HOSTILE
									stats[least_neutral]["army"] = lost / 2
								else:
									opposition_marks[country].self_modulate = Color(1,1,1,0.95)
									stats[country]["relation"] = NEUTRAL
			if "Pacifism" in your_global_tree:
				if randf() <= 0.4:
					var finished: bool = false
					while not finished:
						var chosen: String = stats.keys().pick_random()
						if stats[chosen]["relation"] == NEUTRAL:
							finished = true
							opposition_marks[chosen].self_modulate = Color(1, 0.28, 0.28, 0.79)
							stats[chosen]["relation"] = HOSTILE
			else:
				if randf() <= 0.5:
					var finished: bool = false
					while not finished:
						var chosen: String = stats.keys().pick_random()
						if stats[chosen]["relation"] == NEUTRAL:
							finished = true
							opposition_marks[chosen].self_modulate = Color(1, 0.28, 0.28, 0.79)
							stats[chosen]["relation"] = HOSTILE
			for i in COUNTRIES.values():
				var increasing_by: float
				var multiplier: float = 1
				if "Medicine" in your_global_tree:
					multiplier = 1.2
				if "ImmigrationI" in stats[i]["tree"]:
					increasing_by = stats[i]["population"] * randf_range(0.15, 0.20) * multiplier
				if "ImmigrationII" in stats[i]["tree"]:
					increasing_by = stats[i]["population"] * randf_range(0.12, 0.175) * multiplier
				else:
					increasing_by = stats[i]["population"] * randf_range(0.1, 0.15) * multiplier
				stats[i]["population"] += increasing_by
				if "BarracksIII" in stats[i]["tree"]:
					stats[i]["army"] += increasing_by * randf_range(0.36, 0.40)
				elif "BarracksII" in stats[i]["tree"]:
					stats[i]["army"] += increasing_by * randf_range(0.30, 0.34)
				elif "BarracksI" in stats[i]["tree"]:
					stats[i]["army"] += increasing_by * randf_range(0.24, 0.28)
				else:
					stats[i]["army"] += increasing_by * randf_range(0.18, 0.22)
				
				multiplier = 1
				if "AgricultureII" in your_global_tree:
					multiplier = 1.4
				elif "AgricultureI" in your_global_tree:
					multiplier = 1.2
				if "ResourceGatheringII" in stats[i]["tree"]:
					stats[i]["resources"]["wood"] += randi_range(20, 35) * multiplier
					stats[i]["resources"]["stone"] += randi_range(15, 25) * multiplier
					stats[i]["resources"]["grain"] += randi_range(20, 35) * multiplier
					stats[i]["resources"]["iron"] += randi_range(0, 15) * multiplier
				elif "ResourceGatheringI" in stats[i]["tree"]:
					stats[i]["resources"]["wood"] += randi_range(15, 35) * multiplier
					stats[i]["resources"]["stone"] += randi_range(10, 25) * multiplier
					stats[i]["resources"]["grain"] += randi_range(15, 35) * multiplier
					stats[i]["resources"]["iron"] += clamp(randi_range(-5, 15), 0, INF) * multiplier
				else:
					stats[i]["resources"]["wood"] += randi_range(10, 30) * multiplier
					stats[i]["resources"]["stone"] += randi_range(7, 20) * multiplier
					stats[i]["resources"]["grain"] += randi_range(10, 30) * multiplier
					stats[i]["resources"]["iron"] += clamp(randi_range(-3, 10), 0, INF) * multiplier
				
				if "LumberMill" in stats[i]["tree"]:
					stats[i]["resources"]["wood"] += randi_range(10, 15)
				if "Brickworks" in stats[i]["tree"]:
					stats[i]["resources"]["stone"] += randi_range(8, 12)
				if "Cultivation" in stats[i]["tree"]:
					stats[i]["resources"]["grain"] += randi_range(10, 15)
				if "IronSmelting" in stats[i]["tree"]:
					stats[i]["resources"]["iron"] += randi_range(5, 8)
			
			gold += gold_pans * randf_range(10, 20)
			for i in COUNTRIES.values():
				if stats[i]["relation"] == ALLIED:
						research += 1
						if "Taxation" in your_global_tree:
							gold += 2
			phase = ATTACK
			get_tree().call_group("sidebar", "hide")
			selection_marks[$Sidebar/Territory.text].hide()
			if secondary != "":
				selection_marks[secondary].hide()
			$Sidebar/Confirm.disabled = true
			$Sidebar/Confirm.text = "ATTACK..."
			$Sidebar/Confirm.disabled = true
			selected = false
			for i in path:
				selection_marks[i].hide()

func _on_transfer_confirm_pressed() -> void:
	var troops = clamp($TransferSelect/Soldiers.value, $TransferSelect/Soldiers.min_value, $TransferSelect/Soldiers.max_value)
	stats[$Sidebar/Territory.text]["army"] -= troops
	for i in path:
		if "RoadBuilding" in your_global_tree:
			if stats[i]["relation"] == NEUTRAL:
				troops = troops * randf_range(0.98, 1)
		else:
			if stats[i]["relation"] == ALLIED:
				troops = troops * randf_range(0.98, 1)
			elif stats[i]["relation"] == NEUTRAL:
				troops = troops * randf_range(0.95, 1)
	stats[$Sidebar/TerritoryTo.text]["army"] += troops
	$Sidebar/Army.text = format_army(stats[$Sidebar/Territory.text]["army"])
	$Sidebar/ArmyTo.text = format_army(stats[$Sidebar/TerritoryTo.text]["army"])
	$TransferSelect.hide()

func _on_upgrade_requested(what: String) -> void:
	to_be_upgraded = what
	$TerritoryTree/ConfirmDialogue.show()
	$TerritoryTree/ConfirmDialogue/Title.text = territory_tree[what]["node"].text
	if territory_tree[what]["costs"]["wood"] <= stats[$Sidebar/Territory.text]["resources"]["wood"] and territory_tree[what]["costs"]["stone"] <= stats[$Sidebar/Territory.text]["resources"]["stone"] and territory_tree[what]["costs"]["iron"] <= stats[$Sidebar/Territory.text]["resources"]["iron"] and territory_tree[what]["costs"]["grain"] <= stats[$Sidebar/Territory.text]["resources"]["grain"]:
		$TerritoryTree/ConfirmDialogue/FinalConfirm.disabled = false
	else:
		$TerritoryTree/ConfirmDialogue/FinalConfirm.disabled = true
	$TerritoryTree/ConfirmDialogue/WoodValue.text = str(territory_tree[what]["costs"]["wood"])
	$TerritoryTree/ConfirmDialogue/StoneValue.text = str(territory_tree[what]["costs"]["stone"])
	$TerritoryTree/ConfirmDialogue/IronValue.text = str(territory_tree[what]["costs"]["iron"])
	$TerritoryTree/ConfirmDialogue/GrainValue.text = str(territory_tree[what]["costs"]["grain"])

func _on_global_upgrade_requested(what: String) -> void:
	to_be_upgraded = what
	$GlobalTree/ConfirmDialogue.show()
	$GlobalTree/ConfirmDialogue/Title.text = global_tree[what]["node"].text
	if global_tree[what]["costs"]["gold"] <= gold and global_tree[what]["costs"]["research"] <= research:
		$GlobalTree/ConfirmDialogue/FinalConfirm.disabled = false
	else:
		$GlobalTree/ConfirmDialogue/FinalConfirm.disabled = true
	$GlobalTree/ConfirmDialogue/GoldValue.text = str(global_tree[what]["costs"]["gold"])
	$GlobalTree/ConfirmDialogue/ResearchValue.text = str(global_tree[what]["costs"]["research"])

func _on_cancel_pressed() -> void:
	$TerritoryTree/ConfirmDialogue.hide()

func _on_global_cancel_pressed() -> void:
	$GlobalTree/ConfirmDialogue.hide()

func _on_final_confirm_pressed() -> void:
	stats[$Sidebar/Territory.text]["resources"]["wood"] -= territory_tree[to_be_upgraded]["costs"]["wood"]
	stats[$Sidebar/Territory.text]["resources"]["stone"] -= territory_tree[to_be_upgraded]["costs"]["stone"]
	stats[$Sidebar/Territory.text]["resources"]["iron"] -= territory_tree[to_be_upgraded]["costs"]["iron"]
	stats[$Sidebar/Territory.text]["resources"]["grain"] -= territory_tree[to_be_upgraded]["costs"]["grain"]
	$Sidebar/WoodValue.text = format_resource(stats[$Sidebar/Territory.text]["resources"]["wood"])
	$Sidebar/StoneValue.text = format_resource(stats[$Sidebar/Territory.text]["resources"]["stone"])
	$Sidebar/GrainValue.text = format_resource(stats[$Sidebar/Territory.text]["resources"]["grain"])
	$Sidebar/IronValue.text = format_resource(stats[$Sidebar/Territory.text]["resources"]["iron"])
	stats[$Sidebar/Territory.text]["tree"].append(to_be_upgraded)
	if to_be_upgraded == "Espionage":
		for i in NETWORK[$Sidebar/Territory.text]:
			stats[i]["spied_on"] = true
	elif to_be_upgraded == "Conscription":
		stats[$Sidebar/Territory.text]["army"] += stats[$Sidebar/Territory.text]["population"] * 0.05
	elif to_be_upgraded == "GoldProspecting":
		gold_pans += 1
	get_tree().set_group("territory_tree_button", "disabled", true)
	get_tree().call_group("territory_tree_button", "remove_theme_color_override", "font_disabled_color")
	for i in stats[$Sidebar/Territory.text]["tree"]:
		territory_tree[i]["node"].set("theme_override_colors/font_disabled_color", Color(0,1,0))
	for i in territory_tree.keys():
		var before_checked: bool = false
		for j in territory_tree[i]["before"].split(","):
			if j in stats[$Sidebar/Territory.text]["tree"]:
				before_checked = true
		if before_checked and not territory_tree[i]["locked"] and not i in stats[$Sidebar/Territory.text]["tree"]:
			territory_tree[i]["node"].disabled = false
	$TerritoryTree/ConfirmDialogue.hide()

func _on_global_final_confirm_pressed() -> void:
	match to_be_upgraded:
		"SiegeMastery":
			territory_tree["SiegeEnginesI"]["locked"] = false
			territory_tree["SiegeEnginesI"]["node"].tooltip_text = "Launch more effective attacks."
			territory_tree["SiegeEnginesII"]["locked"] = false
			territory_tree["SiegeEnginesII"]["node"].tooltip_text = "Launch more effective attacks."
		"WallBuilding":
			territory_tree["FortificationsI"]["locked"] = false
			territory_tree["FortificationsI"]["node"].tooltip_text = "Take fewer losses when attacked."
			territory_tree["FortificationsII"]["locked"] = false
			territory_tree["FortificationsII"]["node"].tooltip_text = "Take fewer losses when attacked."
		"GoldPanning":
			territory_tree["GoldProspecting"]["locked"] = false
			territory_tree["GoldProspecting"]["node"].tooltip_text = "Increases empire's gold production."
		"Forestry":
			territory_tree["LumberMill"]["locked"] = false
			territory_tree["LumberMill"]["node"].tooltip_text = "Increases wood production."
		"Masonry":
			territory_tree["Brickworks"]["locked"] = false
			territory_tree["Brickworks"]["node"].tooltip_text = "Increases brick production."
		"Blacksmiths":
			territory_tree["IronSmelting"]["locked"] = false
			territory_tree["IronSmelting"]["node"].tooltip_text = "Increases iron production."
		"CropRotation":
			territory_tree["Cultivation"]["locked"] = false
			territory_tree["Cultivation"]["node"].tooltip_text = "Increases grain production."
		"Espionage":
			territory_tree["Espionage"]["locked"] = false
			territory_tree["Espionage"]["node"].tooltip_text = "Enables spying on neighbouring territories."
		
	gold -= global_tree[to_be_upgraded]["costs"]["gold"]
	research -= global_tree[to_be_upgraded]["costs"]["research"]
	$GlobalTree/GoldValue.text = str(format_resource(gold))
	$GlobalTree/ResearchValue.text = str(format_resource(research))
	your_global_tree.append(to_be_upgraded)
	get_tree().call_group("territory_tree_button", "remove_theme_color_override", "font_disabled_color")
	get_tree().set_group("territory_tree_button", "disabled", true)
	for i in your_global_tree:
		global_tree[i]["node"].set("theme_override_colors/font_disabled_color", Color(0,1,0))
	for i in global_tree.keys():
		var before_checked: bool = false
		for j in global_tree[i]["before"].split(","):
			if j in your_global_tree:
				before_checked = true
		if before_checked and not i in your_global_tree:
			global_tree[i]["node"].disabled = false
	$GlobalTree/ConfirmDialogue.hide()

func _on_research_tree_pressed() -> void:
	$GlobalTree/GoldValue.text = str(format_resource(gold))
	$GlobalTree/ResearchValue.text = str(format_resource(research))
	$Sidebar/Continue.text = "Close"
	$GlobalTree.show()
	get_tree().call_group("territory_tree_button", "remove_theme_color_override", "font_disabled_color")
	get_tree().set_group("territory_tree_button", "disabled", true)
	for i in your_global_tree:
		global_tree[i]["node"].set("theme_override_colors/font_disabled_color", Color(0,1,0))
	for i in global_tree.keys():
		var before_checked: bool = false
		for j in global_tree[i]["before"].split(","):
			if j in your_global_tree:
				before_checked = true
		if before_checked and not i in your_global_tree:
			global_tree[i]["node"].disabled = false

func _on_base_pressed() -> void:
	upgrade.emit("Base")

func _on_barracks_i_pressed() -> void:
	upgrade.emit("BarracksI")

func _on_barracks_ii_pressed() -> void:
	upgrade.emit("BarracksII")

func _on_barracks_iii_pressed() -> void:
	upgrade.emit("BarracksIII")

func _on_plunder_i_pressed() -> void:
	upgrade.emit("PlunderI")

func _on_plunder_ii_pressed() -> void:
	upgrade.emit("PlunderII")

func _on_espionage_pressed() -> void:
	upgrade.emit("Espionage")

func _on_siege_engines_i_pressed() -> void:
	upgrade.emit("SiegeEnginesI")

func _on_siege_engines_ii_pressed() -> void:
	upgrade.emit("SiegeEnginesII")

func _on_fortifications_i_pressed() -> void:
	upgrade.emit("FortificationsI")

func _on_fortifications_ii_pressed() -> void:
	upgrade.emit("FortificationsII")

func _on_conscription_pressed() -> void:
	upgrade.emit("Conscription")

func _on_resource_gathering_i_pressed() -> void:
	upgrade.emit("ResourceGatheringI")

func _on_resource_gathering_ii_pressed() -> void:
	upgrade.emit("ResourceGatheringII")

func _on_lumber_mill_pressed() -> void:
	upgrade.emit("LumberMill")

func _on_brickworks_pressed() -> void:
	upgrade.emit("Brickworks")

func _on_iron_smelting_pressed() -> void:
	upgrade.emit("IronSmelting")

func _on_cultivation_pressed() -> void:
	upgrade.emit("Cultivation")

func _on_gold_prospecting_pressed() -> void:
	upgrade.emit("GoldProspecting")

func _on_immigration_i_pressed() -> void:
	upgrade.emit("ImmigrationI")

func _on_immigration_ii_pressed() -> void:
	upgrade.emit("ImmigrationII")

func _on_research_pressed() -> void:
	global_upgrade.emit("Research")

func _on_military_academy_pressed() -> void:
	global_upgrade.emit("MilitaryAcademy")

func _on_gold_treasury_pressed() -> void:
	global_upgrade.emit("GoldTreasury")

func _on_taxation_pressed() -> void:
	global_upgrade.emit("Taxation")

func _on_gold_panning_pressed() -> void:
	global_upgrade.emit("GoldPanning")

func _on_medicine_pressed() -> void:
	global_upgrade.emit("Medicine")

func _on_road_building_pressed() -> void:
	global_upgrade.emit("RoadBuilding")

func _on_siege_mastery_pressed() -> void:
	global_upgrade.emit("SiegeMastery")

func _on_wall_building_pressed() -> void:
	global_upgrade.emit("WallBuilding")

func _on_agriculture_i_pressed() -> void:
	global_upgrade.emit("AgricultureI")

func _on_forestry_pressed() -> void:
	global_upgrade.emit("Forestry")

func _on_masonry_pressed() -> void:
	global_upgrade.emit("Masonry")

func _on_blacksmiths_pressed() -> void:
	global_upgrade.emit("Blacksmiths")

func _on_crop_rotation_pressed() -> void:
	global_upgrade.emit("CropRotation")

func _on_agriculture_ii_pressed() -> void:
	global_upgrade.emit("AgricultureII")

func _on_political_ideology_pressed() -> void:
	global_upgrade.emit("PoliticalIdeology")

func _on_global_espionage_pressed() -> void:
	global_upgrade.emit("Espionage")

func _on_pacifism_pressed() -> void:
	global_upgrade.emit("Pacifism")
