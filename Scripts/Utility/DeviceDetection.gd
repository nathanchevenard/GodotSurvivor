class_name DeviceDetection

static func is_mobile() -> bool:
	match OS.get_name():
		"Android", "iOS":
			return true
		_:
			return false

static func is_computer() -> bool:
	match OS.get_name():
		"Windows", "macOS", "Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD", "Web":
			return true
		_:
			return false
