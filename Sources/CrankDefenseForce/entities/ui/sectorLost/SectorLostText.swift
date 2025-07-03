import PlaydateKit

class SectorLostText: BaseEntity {
	// MARK: Lifecycle

	override init(_ entityStore: EntityStore) {
		super.init(entityStore)

		sprite.image = GameSettings.timeOfDay == .day ? SectorLostText.dayBitmap : SectorLostText.nightBitmap
		sprite.zIndex = 900
		move()
		sprite.addToDisplayList()
	}

	// MARK: Internal

	override func update() {
		yAnim.update()

		move()
	}

	// MARK: Private

	private static func createBitmap(text: String, timeOfDay: TimeOfDay) -> Graphics.Bitmap {
		let textBitmap = Graphics.Bitmap(
			strokedText: text,
			strokeWidth: 2,
			textColor: timeOfDay == .day ? .fillWhite : .fillBlack,
			strokeColor: timeOfDay == .day ? .fillBlack : .fillWhite,
			align: .center,
			font: CdfFont.Jamma8x8Mono16
		)
		return textBitmap
	}

	private static nonisolated(unsafe) let dayBitmap = createBitmap(text: "SECTOR LOST", timeOfDay: .day)

	private static nonisolated(unsafe) let nightBitmap = createBitmap(text: "SECTOR LOST", timeOfDay: .night)

	private static let startY: Float = -12

	private static let endY: Float = Float(Display.height / 2)

	private let sprite: Sprite.Sprite = Sprite.Sprite()

	private let yAnim: Animator<Float> = Animator(Animator.Config(
		duration: 4,
		startValue: SectorLostText.startY,
		endValue: SectorLostText.endY,
		easingFn: EasingFn.basic(Ease.outBounce),
	))

	private func move() {
		sprite.moveTo(Point(
			x: Float(Display.width / 2),
			y: yAnim.currentValue,
		))
	}
}
