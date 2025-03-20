import PlaydateKit

class SkyBackground: BaseEntity {
	class SkySprite: Sprite.Sprite {
		var alpha: Float = 0
		
		override func draw(bounds _: Rect, drawRect _: Rect) {
			Graphics.fillRect(
				Rect(
					x: 0,
					y: 0,
					width: 400,
					height: 240
				),
				color: Graphics.Color.getBayer4x4FadeColor(foreground: 0, alpha: alpha),
			)
		}
	}
	
	let sprite: SkySprite
	
	var lastTimeOfDay: TimeOfDay
	
	var timeOfDayAnimator: FloatAnimator?
	
	init(entityStore: EntityStore) {
		lastTimeOfDay = GameSettings.timeOfDay
		
		let sprite = SkySprite()
		sprite.setSize(width: 400, height: 240)
		sprite.center = Point.zero
		sprite.moveTo(Point.zero)
		sprite.zIndex = -32768
		sprite.setIgnoresDrawOffset(true)
		sprite.updatesEnabled = false
		sprite.addToDisplayList()
		sprite.alpha = lastTimeOfDay == .day ? 0 : 1
		self.sprite = sprite
		
		super.init(entityStore)
	}
	
	override func update() {
		let newTimeOfDay = GameSettings.timeOfDay
		
		if newTimeOfDay != lastTimeOfDay {
			updateTimeOfDay(newTimeOfDay)
		}
		
		if let anim = timeOfDayAnimator {
			anim.update()
			
			sprite.alpha = anim.currentValue
			if anim.ended {
				timeOfDayAnimator = nil
			}
		}
	}
	
	private func updateTimeOfDay(_ newTimeOfDay: TimeOfDay) {
		timeOfDayAnimator = FloatAnimator(FloatAnimator.Config(
			duration: 0.3,
			startValue: sprite.alpha,
			endValue: newTimeOfDay == .day ? 0 : 1,
			easingFn: EasingFn.basic(Ease.inOutQuad),
		))
		
		lastTimeOfDay = newTimeOfDay
	}
}

