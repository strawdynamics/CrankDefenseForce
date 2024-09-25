import PlaydateKit

class CrtTransitionDetails {
	static let FRAME_DURATION: Float = 0.025
	static let MAX_FRAME_INDEX = 11
	static let FADE_DURATION: Float = 0.3
	static nonisolated(unsafe) let CRT_ZOOM_BITMAP_TABLE: Graphics.BitmapTable = try! Graphics.BitmapTable.init(path: "crtZoom")
}
