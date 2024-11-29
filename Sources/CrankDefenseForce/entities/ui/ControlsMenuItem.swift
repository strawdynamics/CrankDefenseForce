
import PlaydateKit

class ControlsMenuItem: ConfigMenuItem {
	enum VolumeType {
		case music
		case sfx
	}
	
	struct Config {
		let title: String
		let offsetX: Float
		let entityStore: EntityStore
	}
	
	class TitleSprite: ConfigMenuItem.Sprite {
		override init() {
			super.init()
			zIndex = 10
			setSize(width: ConfigMenuItem.SPRITE_WIDTH, height: ConfigMenuItem.SPRITE_HEIGHT)
		}
		
		override func draw(bounds _: Rect, drawRect _: Rect) {
			Graphics.setFont(CdfFont.NicoClean16)
			Graphics.drawMode = .fillWhite
			Graphics.drawText(
				GameSettings.controlScheme.title,
				at: bounds.origin + Point(x: 16, y: 16)
			)
		}
	}
	
	class DetailsSprite: PlaydateKit.Sprite.Sprite {
		override init() {
			super.init()
			center = Point(x: 0, y: 0)
			moveTo(Point(x: 260, y: 40))
			setSize(width: 120, height: 120)
		}
		
		override func draw(bounds _: Rect, drawRect _: Rect) {
			Graphics.drawMode = .fillWhite
			Graphics.setTextLeading(10)
			Graphics.setFont(CdfFont.NicoPups16)
			Graphics.drawText(GameSettings.controlScheme.description, at: bounds.origin)
		}
	}
	
	let titleSprite = TitleSprite()
	
	let detailsSprite = DetailsSprite()
	
	var detailsSpriteAnimator: FloatAnimator?
		
	init(_ config: Config) {
		titleSprite.addToDisplayList()
		
		super.init(ConfigMenuItem.Config(
			title: config.title,
			offsetX: config.offsetX,
			entityStore: config.entityStore,
		))
	}
	
	override func update() {
		super.update()
		
		if let detailsSpriteAnimator = detailsSpriteAnimator {
			detailsSprite.addToDisplayList()
			
			detailsSpriteAnimator.update()
			
			let alpha: Float = detailsSpriteAnimator.currentValue
			var overlayPattern = Graphics.Color.getBayer4x4FadePattern(foreground: 1, alpha: alpha)
			
			overlayPattern.0.withUnsafeMutableBufferPointer { ptr in
				detailsSprite.setStencilPattern(ptr.baseAddress!)
			}
			
			if detailsSpriteAnimator.ended {
				self.detailsSpriteAnimator = nil
				
				if !isSelected {
					detailsSprite.removeFromDisplayList()
				}
			}
		}
	}
	
	override func lateUpdate() {
		titleSprite.moveTo(sprite.position)
		super.lateUpdate()
	}
	
	override func prev() {
		super.prev()
		GameSettings.controlScheme = GameSettings.controlScheme.prev
	}
	
	override func next() {
		super.next()
		GameSettings.controlScheme = GameSettings.controlScheme.next
	}
	
	override func focus() {
		super.focus()
		
		detailsSpriteAnimator = FloatAnimator(
			duration: 0.3,
			startValue: 0,
			endValue: 1,
			easingFn: EasingFn.basic(Ease.outQuad),
		)
	}
	
	override func blur() {
		super.blur()
		detailsSpriteAnimator = FloatAnimator(
			duration: 0.3,
			startValue: 1,
			endValue: 0,
			easingFn: EasingFn.basic(Ease.outQuad),
		)
	}
}
