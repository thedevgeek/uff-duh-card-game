class_name NetworkSession
extends RefCounted

enum Mode {
LOCAL_HOTSEAT,
LOCAL_VS_AI,
ONLINE_STEAM
}

var mode: Mode = Mode.LOCAL_VS_AI

func is_online() -> bool:
	return mode == Mode.ONLINE_STEAM
