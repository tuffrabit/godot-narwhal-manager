extends RefCounted

class_name SteamHelper

# USB identities and Steam (SDL) controller mapping generation.
#
# Steam Input refuses to configure an unknown generic controller until it has
# an SDL-style button mapping. Its "Define Layout" wizard accepts a pasted
# gamecontrollerdb line ("Paste from Clipboard"), which is what the app copies
# for the user. Steam fills in the name CRC in the GUID itself, so the plain
# VID/PID GUID built here is sufficient.
#
# When the pid.codes allocation (VID 0x1209) lands and the firmware switches
# to the assigned PIDs, update the identities below: replace the legacy
# entries rather than appending, and make sure "name" matches the product
# string set in the firmware's boot.py via supervisor.set_usb_identification().
# Any future HID report descriptor change must also update MAPPING_BODY.
const DEVICE_INFO := {
	"tuffpad": {
		"identities": [
			{"vid": 0x239A, "pid": 0x80F4, "name": "Tuffpad"},
		],
	},
	"tuffjoystick": {
		# Two legacy board variants (Seeed / Waveshare) with different stock
		# identities but byte-identical descriptors. One mapping line per
		# variant; Steam picks whichever matches the plugged-in board.
		"identities": [
			{"vid": 0x2886, "pid": 0x0042, "name": "Tuffjoystick"},
			{"vid": 0x2E8A, "pid": 0x101F, "name": "Tuffjoystick"},
		],
	},
}

# SDL bindings for the shared gamepad report descriptor:
# buttons 1-16 (b0-b15), hat switch on the d-pad, X/Y on the stick.
# Z/Rz are intentionally unmapped; the firmware always holds them centered.
const MAPPING_BODY := "a:b0,b:b1,x:b2,y:b3,back:b6,start:b7,leftshoulder:b4,rightshoulder:b5,leftstick:b8,rightstick:b9,lefttrigger:b10,righttrigger:b11,leftx:a0,lefty:a1,dpup:h0.1,dpdown:h0.4,dpleft:h0.8,dpright:h0.2"

# SDL GUID for a USB device on Windows: bus type (03) and version (0000),
# then VID and PID little-endian, zero padded.
static func getSdlGuid(vid: int, pid: int) -> String:
	return "03000000%02x%02x0000%02x%02x000000000000" % [vid & 0xFF, vid >> 8, pid & 0xFF, pid >> 8]

static func getMappingStrings(deviceKey: String) -> Array[String]:
	var lines: Array[String] = []

	if DEVICE_INFO.has(deviceKey):
		for identity in DEVICE_INFO[deviceKey]["identities"]:
			lines.append("%s,%s,%s,platform:Windows" % [
				getSdlGuid(identity["vid"], identity["pid"]),
				identity["name"],
				MAPPING_BODY
			])

	return lines
