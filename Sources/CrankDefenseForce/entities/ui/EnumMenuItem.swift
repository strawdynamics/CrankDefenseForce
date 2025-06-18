import PlaydateKit

class EnumMenuItem: StepperMenuItem {
	struct Config {
		let offsetX: Float
		let entityStore: EntityStore
		let getValue: () -> String
		let prevHandler: () -> Void
		let nextHandler: () -> Void
	}

	class DisplaySprite: ConfigMenuItem.Sprite {
		let getValue: () -> String

		init(getValue: @escaping () -> String) {
			self.getValue = getValue

			super.init()
			zIndex = 10
			setSize(width: ConfigMenuItem.SPRITE_WIDTH, height: ConfigMenuItem.SPRITE_HEIGHT)
		}

		override func draw(bounds _: Rect, drawRect _: Rect) {
			Graphics.setFont(CdfFont.NicoClean16)
			Graphics.drawMode = .fillWhite
			Graphics.drawText(
				getValue(),
				at: bounds.origin + Point(x: 16, y: 16)
			)
		}
	}

	let displaySprite: DisplaySprite

	let prevHandler: () -> Void

	let nextHandler: () -> Void

	init(_ config: Config) {
		displaySprite = DisplaySprite(
			getValue: config.getValue
		)

		prevHandler = config.prevHandler
		nextHandler = config.nextHandler

		super.init(StepperMenuItem.Config(
			title: "",
			offsetX: config.offsetX,
			entityStore: config.entityStore,
		))

		displaySprite.addToDisplayList()
	}

	override func prev() {
		super.prev()
		prevHandler()
	}

	override func next() {
		super.next()
		nextHandler()
	}
	override func lateUpdate() {
		displaySprite.moveTo(sprite.position)
		super.lateUpdate()
	}
}
