import PlaydateKit

class ConfigMenuItem: BaseEntity {
	static nonisolated(unsafe) let bgBitmapTable = try! Graphics.BitmapTable(path: "configMenuItemBg.png")
	
	static nonisolated(unsafe) let arrowsBitmapTable = try! Graphics.BitmapTable(path: "configMenuItemArrows.png")
	
	static let SELECTED_OFFSET_X: Float = 24
	
	struct Config {
		let offsetX: Float
		let entityStore: EntityStore
	}
	
	class Sprite: PlaydateKit.Sprite.Sprite {
		var isSelected = false
		
		override init() {
			super.init()
			self.center = Point(x: 0, y: 0.5)
			self.setSize(width: 192, height: 44)
		}
		
		override func draw(bounds _: Rect, drawRect _: Rect) {
			Graphics.pushContext(nil)
			
			Graphics.drawBitmap(
				ConfigMenuItem.bgBitmapTable[isSelected ? 1 : 0]!,
				at: bounds.origin
			)
			
			Graphics.drawMode = .fillWhite
			
			Graphics.popContext()
		}
	}
	
	let offsetX: Float
	
	private var isSelected = false
	
	var sprite = Sprite()
	
	var leftSprite = PlaydateKit.Sprite.Sprite()
	
	var rightSprite = PlaydateKit.Sprite.Sprite()
	
	var xAnimator: FloatAnimator?
	
	init(_ config: Config) {
		offsetX = config.offsetX
		
		super.init(config.entityStore)
	
		sprite.addToDisplayList()
		
		leftSprite.image = ConfigMenuItem.arrowsBitmapTable[0]
		leftSprite.isVisible = false
		leftSprite.addToDisplayList()
		
		rightSprite.image = ConfigMenuItem.arrowsBitmapTable[1]
		rightSprite.isVisible = false
		rightSprite.addToDisplayList()
	}
	
	override func update() {
		if let xAnimator = xAnimator {
			xAnimator.update()
			
			let alpha: Float = isSelected ? 1 - xAnimator.currentPercent : xAnimator.currentPercent
			let overlayColor = Graphics.Color.getBayer4x4FadePattern(foreground: 0, alpha: alpha)
			
			sprite.moveTo(Point(x: xAnimator.currentValue, y: sprite.position.y))
			
			let leftImg = Graphics.Bitmap(width: 17, height: 18)
			Graphics.pushContext(leftImg)
			Graphics.drawBitmap(ConfigMenuItem.self.arrowsBitmapTable[0]!, at: Point(x: 0, y: 0))
			Graphics.fillRect(Rect(x: 0, y: 0, width: 17, height: 18), color: overlayColor)
			Graphics.popContext()
			leftSprite.image = leftImg
			leftSprite.moveTo(Point(x: xAnimator.currentValue - 12, y: leftSprite.position.y))
			
			let rightImg = Graphics.Bitmap(width: 17, height: 18)
			Graphics.pushContext(rightImg)
			Graphics.drawBitmap(ConfigMenuItem.self.arrowsBitmapTable[1]!, at: Point(x: 0, y: 0))
			Graphics.fillRect(Rect(x: 0, y: 0, width: 17, height: 18), color: overlayColor)
			Graphics.popContext()
			rightSprite.image = rightImg
			rightSprite.moveTo(Point(x: xAnimator.currentValue + 205, y: rightSprite.position.y))
			
			if xAnimator.ended {
				self.xAnimator = nil
				
				if !isSelected {
					leftSprite.isVisible = false
					rightSprite.isVisible = false
				}
			}
		}
	}
	
	func moveTo(y: Float) {
		sprite.moveTo(Point(x: sprite.position.x, y: y))
		leftSprite.moveTo(Point(x: leftSprite.position.x, y: y))
		rightSprite.moveTo(Point(x: rightSprite.position.x, y: y))
	}
	
	func select() {
		if isSelected {
			return
		}
		isSelected = true
		sprite.isSelected = true
		
		leftSprite.isVisible = true
		rightSprite.isVisible = true
		
		xAnimator = FloatAnimator(
			duration: 0.2,
			startValue: offsetX,
			endValue: offsetX + ConfigMenuItem.SELECTED_OFFSET_X,
			easingFn: EasingFn.basic(Ease.outQuad),
		)
	}
	
	func deselect() {
		if !isSelected {
			return
		}
		isSelected = false
		sprite.isSelected = false
		
		xAnimator = FloatAnimator(
			duration: 0.5,
			startValue: offsetX + ConfigMenuItem.SELECTED_OFFSET_X,
			endValue: offsetX,
			easingFn: EasingFn.basic(Ease.outQuad),
		)
	}
}

