import PlaydateKit

// abstract
class ConfigMenuItem: BaseEntity {
	static nonisolated(unsafe) let bgBitmapTable = try! Graphics.BitmapTable(
		path: "entities/ui/ConfigMenuItem/bg")

	static let SELECTED_OFFSET_X: Float = 18

	static let SPRITE_WIDTH: Float = 192
	static let SPRITE_HEIGHT: Float = 44

	struct Config {
		let title: String
		let offsetX: Float
		let entityStore: EntityStore
	}

	class Sprite: PlaydateKit.Sprite.Sprite {
		override init() {
			super.init()
			zIndex = 5
			center = Point(x: 0, y: 0.5)
		}
	}

	class LineSprite: PlaydateKit.Sprite.Sprite {
		override init() {
			super.init()
			center = Point(x: 0, y: 0.5)
			setSize(width: 40, height: 5)
		}

		override func draw(bounds _: Rect, drawRect _: Rect) {
			let start = bounds.origin + Point(x: 0, y: 1)
			let end = bounds.origin + Point(x: bounds.width, y: 1)

			let line = Line(
				start: start,
				end: end,
			)

			Graphics.drawLine(line, lineWidth: 5, color: Graphics.Color.black)
			Graphics.drawLine(line, lineWidth: 3, color: Graphics.Color.white)
			Graphics.drawLine(line, lineWidth: 1, color: Graphics.Color.black)
		}
	}

	let offsetX: Float

	let title: String

	let sprite = Sprite()

	let lineSprite = LineSprite()

	var isFocused = false

	var focusAnimator: Animator<Float>?

	init(_ config: Config) {
		title = config.title
		offsetX = config.offsetX

		super.init(config.entityStore)

		sprite.image = Self.bgBitmapTable[0]

		sprite.moveTo(Point(x: offsetX, y: 0))
		lineSprite.moveTo(Point(x: 0, y: 0))

		lineSprite.addToDisplayList()
		sprite.addToDisplayList()
	}

	override func update() {
		if let focusAnimator = focusAnimator {
			focusAnimator.update()

			sprite.moveTo(Point(x: focusAnimator.currentValue, y: sprite.position.y))
			lineSprite.moveTo(Point(x: 0, y: lineSprite.position.y))

			if focusAnimator.ended {
				self.focusAnimator = nil
			}
		}
	}

	func moveTo(y: Float) {
		sprite.moveTo(Point(x: sprite.position.x, y: y))
		lineSprite.moveTo(Point(x: 0, y: y))
	}

	func focus() {
		if isFocused {
			return
		}
		isFocused = true
		sprite.image = ConfigMenuItem.bgBitmapTable[1]

		focusAnimator = Animator(
			Animator.Config(
				duration: 0.2,
				startValue: offsetX,
				endValue: offsetX + ConfigMenuItem.SELECTED_OFFSET_X,
				easingFn: EasingFn.basic(Ease.outQuad),
			))
	}

	func blur() {
		if !isFocused {
			return
		}
		isFocused = false
		sprite.image = ConfigMenuItem.bgBitmapTable[0]

		focusAnimator = Animator(
			Animator.Config(
				duration: 0.5,
				startValue: offsetX + ConfigMenuItem.SELECTED_OFFSET_X,
				endValue: offsetX,
				easingFn: EasingFn.basic(Ease.outQuad),
			))
	}
}
