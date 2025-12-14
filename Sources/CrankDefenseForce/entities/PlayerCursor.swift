import PlaydateKit

class PlayerCursor: BaseEntity {
	nonisolated(unsafe) static let bitmapTable = try! Graphics.BitmapTable(
		path: "entities/PlayerCursor/playerCursor")

	static let CURSOR_SPEED: Float = 1000.0

	static let SHOW_DURATION: Float = 2.8
	static let HIDE_DURATION: Float = 0.2

	var sprite: Sprite.Sprite

	private var isVisible = false

	private var isAnimating = false
	private var animTime: Float = 0
	private var animStartFrame: Float = 0
	private var animTargetFrame: Float = 0
	private var currentFrame: Int = 0
	private var animEasingFn: EasingFn = EasingFn.elastic(Ease.outElastic)
	private var animDuration: Float = 0

	override init(_ entityStore: EntityStore) {
		let sprite = Sprite.Sprite()
		sprite.image = Self.bitmapTable[0]
		sprite.moveTo(Point(x: 200.0, y: 120.0))
		sprite.addToDisplayList()
		sprite.zIndex = 200
		self.sprite = sprite

		super.init(entityStore)
	}

	override func update() {
		if isAnimating {
			animTime += Time.deltaTime

			let easedFrame = animEasingFn.ease(
				animTime, animStartFrame, animTargetFrame - animStartFrame, animDuration, 0.3, 0.7)

			currentFrame = Int(fmaxf(0, easedFrame).rounded())
			sprite.image = Self.bitmapTable[currentFrame]

			if animTime > animDuration {
				currentFrame = Int(animTargetFrame)
				isAnimating = false
			}
		}
	}

	func moveTo(point: Point) {
		self.sprite.moveTo(point)
	}

	func moveToward(dest: Point) {
		let cur = self.sprite.position

		let diffX = dest.x - cur.x
		let diffY = dest.y - cur.y

		let dist = (diffX * diffX + diffY * diffY).squareRoot()

		let dirX = diffX / dist
		let dirY = diffY / dist

		let speed = Self.CURSOR_SPEED * Time.deltaTime

		if dist < speed {
			moveTo(point: dest)
		} else {
			moveTo(
				point: Point(
					x: cur.x + dirX * speed,
					y: cur.y + dirY * speed,
				))
		}
	}

	func show() {
		if isVisible {
			return
		}
		isVisible = true

		isAnimating = true
		animDuration = Self.SHOW_DURATION
		animEasingFn = EasingFn.elastic(Ease.outElastic)
		animTime = 0
		animStartFrame = Float(currentFrame)
		animTargetFrame = 10
	}

	func hide() {
		if !isVisible {
			return
		}
		isVisible = false

		isAnimating = true
		animDuration = Self.HIDE_DURATION
		animEasingFn = EasingFn.basic(Ease.inOutQuad)
		animTime = 0
		animStartFrame = Float(currentFrame)
		animTargetFrame = 0
	}
}
