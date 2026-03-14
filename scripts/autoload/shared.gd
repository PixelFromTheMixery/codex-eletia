extends Node

const COLOUR_MAP: Dictionary[String, Color] = {
	"Sea": Color("#151B54"), # Night Blue
	"Mountain": Color("#36454F"), # Charcoal Blue
	"Fire": Color("#660000"), # Red Blood
	"Water": Color("#006A4E"), # Bottle Green
	"Air": Color("#C2B280"), # Sand
	"Earth": Color("#5C3317"), # Baker's Brown
	"Arcane": Color("#1589FF"), # Arcane
	"Plant": Color("#006400"), # Dark Green
	"Prismic": Color("#D4AF37"), #Metallic Gold
	"Ghost": Color("#8686AF"), # Pastel Indigo
	"Mystic": Color("#D462FF"), # Heliotrop Purple
	"Hallow": Color("#7D0552"), # Plum Velvet
	"Space": Color("#5539CC"), # Dark Blurple
	"Time": Color("#8B4513"), # Saddle Brown
	"Ice": Color("#DFD3E3"), # Purple White
}

const ICON_MAP: Dictionary[String, Texture2D] = {
	"Capital": preload("res://assets/icons/map/capital.png"),
	"City": preload("res://assets/icons/map/city.png"),
	"Town": preload("res://assets/icons/map/town.png"),
	"Hamlet": preload("res://assets/icons/map/hamlet.png"),
	"Colony": preload("res://assets/icons/map/colony.png"),
	"Refuge": preload("res://assets/icons/map/refuge.png"),
	"Sanctuary": preload("res://assets/icons/map/sanctuary.png"),
	"Outpost": preload("res://assets/icons/map/outpost.png"),
	"Fort": preload("res://assets/icons/map/fort.png"),
	"Stronghold": preload("res://assets/icons/map/stronghold.png"),
	# Transport
	"Road": preload("res://assets/icons/map/road.png"),
	"Path": preload("res://assets/icons/map/path.png"),
	"Trail": preload("res://assets/icons/map/trail.png"),
	"Cave": preload("res://assets/icons/map/cave.png"),
	"Port": preload("res://assets/icons/map/port.png"),
	# Natural Element
	"Sea": preload("res://assets/icons/map/sea.png"),
	"Mountain": preload("res://assets/icons/map/mountain.png"),
	#Essences
	"Fire": preload("res://assets/icons/map/mix.png"),
	"Water": preload("res://assets/icons/map/mix.png"),
	"Air": preload("res://assets/icons/map/mix.png"),
	"Earth": preload("res://assets/icons/map/mix.png"),
	"Arcane": preload("res://assets/icons/map/mix.png"),
	"Plant": preload("res://assets/icons/map/mix.png"),
	"Prismic": preload("res://assets/icons/map/mix.png"),
	"Ghost": preload("res://assets/icons/map/mix.png"),
	"Mystic": preload("res://assets/icons/map/mix.png"),
	"Hallow": preload("res://assets/icons/map/mix.png"),
	"Space": preload("res://assets/icons/map/mix.png"),
	"Time": preload("res://assets/icons/map/mix.png"),
	"Ice": preload("res://assets/icons/map/mix.png"),
}
