import PlaydateKit

class BigUfoEyes : BaseEntity, Movable, Toggleable {
	nonisolated(unsafe) static let eyesBitmapTable = try! Graphics.BitmapTable(path: "entities/BigUfoEyes/eyes")

	var sprite = Sprite.Sprite()

	var frameAnimator: Animator<Float>

	struct Config {
		var entityStore: EntityStore
	}

	init(_ config: Config) {
		frameAnimator = Animator(Animator.Config(
			duration: 5,
			startValue: 0,
			endValue: 1,
			easingFn: EasingFn.basic(Ease.linear),
			loopMode: .loop,
		))

		super.init(config.entityStore)

		sprite.image = Self.eyesBitmapTable[0]
		sprite.addToDisplayList()
	}

	override func update() {
		super.update()

		frameAnimator.update()
		sprite.image = frameAnimator.currentValue > 0.8 ? Self.eyesBitmapTable[1] : Self.eyesBitmapTable[0]
	}

	func moveTo(position: PlaydateKit.Point) {
		sprite.moveTo(position)
	}

	func show() {
		sprite.addToDisplayList()
	}

	func hide() {
		sprite.removeFromDisplayList()
	}
}
