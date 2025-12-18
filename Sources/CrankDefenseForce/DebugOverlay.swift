import PlaydateKit

class DebugOverlay {
	class LineSprite: Sprite.Sprite {
		var width: Float

		var label: String

		var value: String

		init(width: Float, x: Float, y: Float, label: String, value: String) {
			self.width = width
			self.label = label
			self.value = value
			super.init()

			setSize(width: width, height: Float(CdfFont.NicoPups16.height))
			zIndex = 9999
			center = Point.zero
			position = Point(x: x, y: y)
		}

		override func draw(bounds _: Rect, drawRect _: Rect) {
			Graphics.fillRect(
				Rect(
					x: position.x,
					y: position.y,
					width: width,
					height: Float(CdfFont.NicoPups16.height),
				),
				color: Graphics.Color.getBayer4x4FadeColor(
					foreground: GameSettings.timeOfDay == .day ? 1 : 0,
					alpha: 0.5
				),
			)

			Graphics.drawMode = GameSettings.timeOfDay == .day ? .fillBlack : .fillWhite
			Graphics.setFont(CdfFont.NicoPups16)
			Graphics.drawText(label, at: position + Point(x: 2, y: 0))
			Graphics.drawTextInRect(
				value,
				in: Rect(
					origin: position,
					width: width - 2,
					height: Float(CdfFont.NicoPups16.height)
				), aligned: .right)
		}
	}

	var debugMode: DebugMode

	let fpsSprite = LineSprite(width: 60, x: 0, y: 0, label: "FPS:", value: "0")
	let entitiesSprite = LineSprite(
		width: 60, x: 60, y: 0, label: "Ents:", value: "0")

	init() {
		debugMode = GameSettings.debugMode
		fpsSprite.setIgnoresDrawOffset(true)
		entitiesSprite.setIgnoresDrawOffset(true)
		updateDisplay()
	}

	func update() {
		fpsSprite.value = String(Int(roundf(Display.fps)))

		if let entityStore = EntityStore.instance {
			entitiesSprite.value = String(entityStore.entityCount)
		}

		if GameSettings.debugMode != debugMode {
			debugMode = GameSettings.debugMode
			updateDisplay()
		}
	}

	private func updateDisplay() {
		switch debugMode {
		case .disabled:
			fpsSprite.removeFromDisplayList()
			entitiesSprite.removeFromDisplayList()
		case .fpsOnly:
			fpsSprite.addToDisplayList()
			entitiesSprite.removeFromDisplayList()
		case .enabled:
			fpsSprite.addToDisplayList()
			entitiesSprite.addToDisplayList()
		}
	}
}
