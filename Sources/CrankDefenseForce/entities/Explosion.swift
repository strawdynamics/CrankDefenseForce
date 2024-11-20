import PlaydateKit

class Explosion: BaseEntity {
	static let STARTING_RADIUS: Float = 5
	static let DURATION: Float = 1.8
	
	struct Config {
		let position: Point
		let maxRadius: Float
		let entityStore: EntityStore
	}
	
	class ExplosionSprite: Sprite.Sprite {
		var radius: Float = 0
		
		override func draw(bounds _: Rect, drawRect _: Rect) {
			Graphics.pushContext(nil)
			
			Graphics.fillEllipse(
				in: Rect(
					x: position.x - radius,
					y: position.y - radius,
					width: radius * 2,
					height: radius * 2
				),
				startAngle: 0,
				endAngle: 360,
				// TODO: Fade
				color: Graphics.Color.getBayer4x4FadePattern(foreground: 0, alpha: 0.5),
			)
			Graphics.popContext()
		}
	}
	
	enum State {
		case expanding
		case collapsing
	}
	
	let sprite = ExplosionSprite()
	
	let maxRadius: Float
	
	var currentRadius: Float = Explosion.STARTING_RADIUS

	var sizeAnimator: FloatAnimator
	
	var state: State = .expanding
	
	init(_ config: Config) {
		self.maxRadius = config.maxRadius
		
		self.sizeAnimator = FloatAnimator(
			duration: Explosion.DURATION * 0.5,
			startValue: Explosion.STARTING_RADIUS,
			endValue: self.maxRadius,
			easingFn: EasingFn.basic(Ease.outQuad),
		)
		
		super.init(config.entityStore)
		
		let size = maxRadius * 2
		
		sprite.position = config.position
		sprite.setSize(width: maxRadius * 2, height: size)
		sprite.collideRect = Rect(x: 0, y: 0, width: size, height: size)
		sprite.addToDisplayList()
	}
	
	override func update() {
		sizeAnimator.update()
		
		sprite.radius = sizeAnimator.currentValue
		
		if sizeAnimator.ended {
			if state == .expanding {
				state = .collapsing
				
				self.sizeAnimator = FloatAnimator(
					duration: Explosion.DURATION * 0.5,
					startValue: self.maxRadius,
					endValue: 0,
					easingFn: EasingFn.basic(Ease.inQuad),
				)
			} else {
				entityStore.remove(self)
			}
		}
	}
}
