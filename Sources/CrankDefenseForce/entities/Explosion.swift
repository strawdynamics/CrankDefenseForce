import PlaydateKit

class Explosion: BaseEntity {
	static let STARTING_RADIUS: Float = 8
	
	struct Config {
		let position: Point
		let maxRadius: Float
		let duration: Float = 1.8
		let entityStore: EntityStore
	}
	
	class ExplosionSprite: Sprite.Sprite {
		var radius: Float = 0
		var alpha: Float = 0
		
		override func draw(bounds _: Rect, drawRect _: Rect) {
			Graphics.fillEllipse(
				in: Rect(
					x: position.x - radius,
					y: position.y - radius,
					width: radius * 2,
					height: radius * 2
				),
				startAngle: 0,
				endAngle: 360,
				color: Graphics.Color.getBayer4x4FadeColor(
					foreground: GameSettings.timeOfDay == .day ? 0 : 1,
					alpha: alpha
				),
			)
		}
	}
	
	enum State {
		case expanding
		case collapsing
	}
	
	let sprite = ExplosionSprite()
	
	let maxRadius: Float
	
	let duration: Float
	
	var currentRadius: Float = Explosion.STARTING_RADIUS

	var sizeAnimator: Animator<Float>
	
	var alphaAnimator: Animator<Float>
	
	var state: State = .expanding
	
	init(_ config: Config) {
		self.maxRadius = config.maxRadius
		self.duration = config.duration
		
		self.sizeAnimator = Animator(Animator.Config(
			duration: self.duration * 0.5,
			startValue: Explosion.STARTING_RADIUS,
			endValue: self.maxRadius,
			easingFn: EasingFn.basic(Ease.outQuad),
		))
		
		self.alphaAnimator = Animator(Animator.Config(
			duration: self.duration * 0.5,
			startValue: 0.7,
			endValue: 0.4,
			easingFn: EasingFn.basic(Ease.inBounce),
		))
		
		super.init(config.entityStore)
		
		let size = maxRadius * 2
		
		sprite.position = config.position
		sprite.setSize(width: maxRadius * 2, height: size)
		sprite.collideRect = Rect(x: 0, y: 0, width: size, height: size)
		sprite.addToDisplayList()
	}
	
	override func update() {
		sizeAnimator.update()
		alphaAnimator.update()
		
		sprite.radius = sizeAnimator.currentValue
		sprite.alpha = alphaAnimator.currentValue
		
		if sizeAnimator.ended {
			if state == .expanding {
				state = .collapsing
				
				self.sizeAnimator = Animator(Animator.Config(
					duration: self.duration * 0.5,
					startValue: self.maxRadius,
					endValue: 0,
					easingFn: EasingFn.basic(Ease.inQuad),
				))
				
				self.alphaAnimator = Animator(Animator.Config(
					duration: self.duration * 0.5,
					startValue: 0.4,
					endValue: 0,
					easingFn: EasingFn.basic(Ease.inOutQuad),
				))
			} else {
				entityStore.remove(self)
			}
		}
	}
}
