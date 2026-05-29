extends Node

signal steam_ready(is_available: bool)

var initialized := false
var using_godotsteam := false

func _ready() -> void:
    initialized = _initialize_steam()
    steam_ready.emit(initialized)

func _initialize_steam() -> bool:
    if not Engine.has_singleton("Steam"):
        push_warning("GodotSteam singleton not found. Running without Steam services.")
        return false

    using_godotsteam = true
    var steam := Engine.get_singleton("Steam")
    var init_result = steam.steamInitEx()
    if int(init_result.get("status", 0)) != 0:
        push_warning("Steam initialization failed: %s" % [str(init_result)])
        return false

    return true

func create_online_lobby(max_players: int) -> void:
    if not using_godotsteam:
        push_warning("Steam lobby creation requested while Steam is unavailable.")
        return
    # Placeholder: integrate Steam lobby metadata and Steam Datagram Relay setup here.

func join_online_lobby(lobby_id: int) -> void:
    if not using_godotsteam:
        push_warning("Steam lobby join requested while Steam is unavailable.")
        return
    # Placeholder: integrate lobby join + SDR P2P session setup here.
