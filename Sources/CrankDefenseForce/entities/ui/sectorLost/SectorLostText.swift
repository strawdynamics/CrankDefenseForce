import PlaydateKit

class SectorLostText: BaseEntity {
	// MARK: Lifecycle

	override init(_ entityStore: EntityStore) {
		bitmap = GameSettings.timeOfDay == .day ? SectorLostText.dayBitmap : SectorLostText.nightBitmap
		let (w, _, _) = bitmap.getData(mask: nil, data: nil)
		bitmapWidth = w

		super.init(entityStore)

		draw()
	}

	// MARK: Internal

	override func update() {

	}

	override func lateUpdate() {
		yAnim.update()
		draw()
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

	private static nonisolated(unsafe) let dayBitmap = createBitmap(
		text: "SECTOR LOST", timeOfDay: .day)

	private static nonisolated(unsafe) let nightBitmap = createBitmap(
		text: "SECTOR LOST", timeOfDay: .night)

	private static let startY: Float = -12

	private static let endY: Float = Float(Display.height) * 0.875

	private let bitmap: Graphics.Bitmap

	private let bitmapWidth: Int

	private let yAnim: Animator<Float> = Animator(
		Animator.Config(
			duration: 3,
			startValue: SectorLostText.startY,
			endValue: SectorLostText.endY,
			easingFn: EasingFn.basic(Ease.outBounce),
		))

	private func draw() {
		Graphics.drawMode = .copy
		Graphics.drawBitmap(
			bitmap,
			at: Point(
				x: Float((Display.width - bitmapWidth) / 2),
				y: yAnim.currentValue,
			))
	}
}
