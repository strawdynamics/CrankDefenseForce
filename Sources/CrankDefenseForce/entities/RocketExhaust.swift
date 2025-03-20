import PlaydateKit


// ./bin/spriterot --rotations=24 --columns=1 --keep-size --output=4.png ~/Downloads/rot/4.png
class RocketExhaust : BaseEntity {
	nonisolated(unsafe) static let rocketExhaustBitmapTable = try! Graphics.BitmapTable(path: "rocketExhaust.png")
	
	nonisolated(unsafe) static let engineSfx = RocketEngineSfx()
	
	static let distance: Float = 9
	
	var sprite = Sprite.Sprite()
	
	var rocketPtr: Int
	var rocket: Rocket {
		return unsafeBitCast(rocketPtr, to: Rocket.self)
	}
	
	var frameAnimator: Animator<Float>
	
	var active = false
	
	struct Config {
		var rocket: Rocket
		var entityStore: EntityStore
	}
	
	init(_ config: Config) {
		rocketPtr = unsafeBitCast(config.rocket, to: Int.self)
		
		frameAnimator = Animator(Animator.Config(
			duration: 0.4,
			startValue: 0.0,
			endValue: 4.0,
			easingFn: EasingFn.basic(Ease.linear),
			loopMode: .loop,
		))
		
		super.init(config.entityStore)
		
		sprite.image = Self.rocketExhaustBitmapTable[0]
		sprite.isVisible = false
		sprite.addToDisplayList()
	}
	
	deinit {
		deactivate()
	}
	
	override func update() {
		super.update()
		
		let rPos = rocket.position
		
		let x = rPos.x - (Self.distance * rocket.roundedCos)
		let y = rPos.y - (Self.distance * rocket.roundedSin)
		
		let roundedAngle = Int(rocket.angle.roundToNearest(15.0))
		let rotFrame = (((roundedAngle % 360) / 15 + 24) % 24) * 4
		
		let animFrame = Int(frameAnimator.currentValue.rounded().truncatingRemainder(dividingBy: 4))
				
		frameAnimator.update()
		sprite.image = Self.rocketExhaustBitmapTable[rotFrame + animFrame]
		
		sprite.moveTo(Point(x: x, y: y))
	}
	
	func activate() {
		if active {
			return
		}
		active = true
		
		Self.engineSfx.incActiveRockets()
		
		sprite.isVisible = true
	}
	
	func deactivate() {
		if !active {
			return
		}
		active = false
		
		Self.engineSfx.decActiveRockets()
		
		sprite.isVisible = false
	}
}
