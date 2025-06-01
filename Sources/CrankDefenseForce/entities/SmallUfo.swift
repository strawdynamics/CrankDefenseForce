import PlaydateKit

class SmallUfo: BaseEntity, PowerUpDropper {
	static let powerUpDropTable: [PowerUp.PowerUpType: Float] = [
		.none: 1
	]

	var position: Point {
		return sprite.position
	}

	nonisolated(unsafe) static let smallUfoBitmapTable = try! Graphics.BitmapTable(path: "entities/SmallUfo/smallUfo")

	static let moveToBuildingXPps: Float = 25


	class SmallUfoSprite: Sprite.Sprite {
		var smallUfoId: Int = -1
	}

	struct Config {
		var entityStore: EntityStore
		var position: Point
	}

	var sprite = SmallUfoSprite()

	private(set) var destroyed = false

	private var moveToBuildingXAnimator: Animator<Float>?

	private var bobYAnimator: Animator<Float>?
	init(_ config: Config) {
		let bitmap = Self.smallUfoBitmapTable[0]!
		let (bitmapWidth, bitmapHeight, _) = bitmap.getData(mask: nil, data: nil)

		sprite.image = bitmap
		sprite.moveTo(config.position)
		sprite.collideRect = Rect.init(
			x: 0,
			y: 0,
			width: bitmapWidth,
			height: bitmapHeight
		)
		sprite.zIndex = 60

		sprite.addToDisplayList()

		bobYAnimator = Animator(Animator.Config(
			duration: 0.5,
			startValue: config.position.y,
			endValue: config.position.y + 2,
			easingFn: EasingFn.basic(Ease.inOutQuad),
			loopMode: .pingPong
		))

		super.init(config.entityStore)

		sprite.smallUfoId = id
	}

	override func update() {
		updateBob()
	}

//	private func updateMoveToBuilding() {
//		guard let target = targetBuilding else {
//			pickTargetBuilding()
//			return
//		}
//
//		if target.destroyed {
//			pickTargetBuilding()
//			return
//		}
//
//		guard let xAnim = moveToBuildingXAnimator else { return }
//		xAnim.update()
//
//		sprite.moveTo(Point(
//			x: xAnim.currentValue,
//			y: sprite.position.y
//		))
//
//		if xAnim.ended {
//			currentActivity = .chargeLaser
//		}
//	}

	private func updateBob() {
		guard let yAnim = bobYAnimator else { return }
		yAnim.update()
		sprite.moveTo(Point(
			x: sprite.position.x.rounded(),
			y: yAnim.currentValue.rounded()
		))
	}
}
