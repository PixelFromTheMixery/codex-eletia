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
	"Fort": preload("res://assets/icons/map/fort.png"),
	"Stronghold": preload("res://assets/icons/map/stronghold.png")
}
