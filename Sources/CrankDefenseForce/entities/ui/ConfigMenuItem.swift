import PlaydateKit

class ConfigMenuItem: BaseEntity {
	static nonisolated(unsafe) let bgBitmapTable = try! Graphics.BitmapTable(path: "configMenuItemBg.png")
	
	static nonisolated(unsafe) let arrowsBitmapTable = try! Graphics.BitmapTable(path: "configMenuItemArrows.png")
	
	static let SELECTED_OFFSET_X: Float = 24
	
	struct Config {
		let title: String
		let offsetX: Float
		let entityStore: EntityStore
	}
	
	class Sprite: PlaydateKit.Sprite.Sprite {
		var isSelected = false
		
		override init() {
			super.init()
			center = Point(x: 0, y: 0.5)
			setSize(width: 192, height: 44)
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
	
	class LineSprite: PlaydateKit.Sprite.Sprite {
		override init() {
			super.init()
			center = Point(x: 0, y: 0.5)
			setSize(width: 40, height: 3)
		}
		
		override func draw(bounds _: Rect, drawRect _: Rect) {
			Graphics.pushContext(nil)
			Graphics.drawLine(Line(
				start: Point(x: bounds.origin.x, y: bounds.origin.y + 1),
				end: Point(x: bounds.origin.x + bounds.width, y: bounds.origin.y + 1),
			), lineWidth: 3, color: Graphics.Color.white)
			
			Graphics.drawLine(Line(
				start: Point(x: bounds.origin.x, y: bounds.origin.y + 1),
				end: Point(x: bounds.origin.x + bounds.width, y: bounds.origin.y + 1),
			), lineWidth: 1, color: Graphics.Color.black)
			
			Graphics.popContext()
		}
	}
	
	let offsetX: Float
	
	let title: String
	
	let sprite = Sprite()
	
	let lineSprite = LineSprite()
	
	let leftSprite = PlaydateKit.Sprite.Sprite()
	
	let rightSprite = PlaydateKit.Sprite.Sprite()
	
	private var isSelected = false
	
	var xAnimator: FloatAnimator?
	
	init(_ config: Config) {
		title = config.title
		offsetX = config.offsetX
		
		super.init(config.entityStore)
		
		sprite.moveTo(Point(x: offsetX, y: 0))
		lineSprite.moveTo(Point(x: 0, y: 0))
	
		lineSprite.addToDisplayList()
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
			
			let alpha: Float = isSelected ? xAnimator.currentPercent : 1 - xAnimator.currentPercent
			var overlayPattern = Graphics.Color.getBayer4x4FadePattern(foreground: 1, alpha: alpha)
			
			sprite.moveTo(Point(x: xAnimator.currentValue, y: sprite.position.y))
			lineSprite.moveTo(Point(x: 0, y: lineSprite.position.y))
			
			overlayPattern.0.withUnsafeMutableBufferPointer { ptr in
				rightSprite.setStencilPattern(ptr.baseAddress!)
				leftSprite.setStencilPattern(ptr.baseAddress!)
			}
			
			leftSprite.moveTo(Point(x: xAnimator.currentValue - 12, y: leftSprite.position.y))
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
		lineSprite.moveTo(Point(x: 0, y: y))
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

