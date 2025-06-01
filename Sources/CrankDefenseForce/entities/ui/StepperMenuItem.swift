import PlaydateKit

// abstract
class StepperMenuItem: ConfigMenuItem {
	static nonisolated(unsafe) let arrowsBitmapTable = try! Graphics.BitmapTable(path: "entities/ui/StepperMenuItem/arrows")
	
	let leftSprite = PlaydateKit.Sprite.Sprite()
	
	var leftSpriteYAnimator: Animator<Float>?
	
	let rightSprite = PlaydateKit.Sprite.Sprite()
	
	var rightSpriteYAnimator: Animator<Float>?
	
	var arrowFocusAnimator: Animator<Float>?
	
	override init(_ config: ConfigMenuItem.Config) {
		super.init(config)
		
		leftSprite.image = Self.arrowsBitmapTable[0]
		leftSprite.isVisible = false
		leftSprite.addToDisplayList()
		
		rightSprite.image = Self.arrowsBitmapTable[1]
		rightSprite.isVisible = false
		rightSprite.addToDisplayList()
	}
	
	override func update() {
		super.update()
		
		updateInput()
		
		updateArrowFocusAnimator()
		
		updateLeftSpriteYAnimator()
		
		updateRightSpriteYAnimator()
	}
	
	func updateInput() {
		if isFocused {
			let pushed = System.buttonState.pushed
			
			if pushed.contains(.left) {
				prev()
			} else if pushed.contains(.right) {
				next()
			}
		}
	}
	
	func updateArrowFocusAnimator() {
		if let arrowFocusAnimator = arrowFocusAnimator {
			arrowFocusAnimator.update()
			
			let alpha: Float = isFocused ? arrowFocusAnimator.currentPercent : 1 - arrowFocusAnimator.currentPercent
			var overlayPattern = Graphics.Color.getBayer4x4FadePattern(foreground: 1, alpha: alpha)
	
			overlayPattern.0.withUnsafeMutableBufferPointer { ptr in
				rightSprite.setStencilPattern(ptr.baseAddress!)
				leftSprite.setStencilPattern(ptr.baseAddress!)
			}
	
			leftSprite.moveTo(Point(x: arrowFocusAnimator.currentValue - 12, y: leftSprite.position.y))
			rightSprite.moveTo(Point(x: arrowFocusAnimator.currentValue + 205, y: rightSprite.position.y))
			
			if arrowFocusAnimator.ended {
				self.arrowFocusAnimator = nil
				
				if !isFocused {
					leftSprite.isVisible = false
					rightSprite.isVisible = false
				}
			}
		}
	}
	
	func updateLeftSpriteYAnimator() {
		if let leftSpriteYAnimator = leftSpriteYAnimator {
			leftSpriteYAnimator.update()
			leftSprite.moveTo(Point(
				x: leftSprite.position.x,
				y: sprite.position.y + leftSpriteYAnimator.currentValue,
			))
			
			if leftSpriteYAnimator.ended {
				self.leftSpriteYAnimator = nil
			}
		}
	}
	
	func updateRightSpriteYAnimator() {
		if let rightSpriteYAnimator = rightSpriteYAnimator {
			rightSpriteYAnimator.update()
			rightSprite.moveTo(Point(
				x: rightSprite.position.x,
				y: sprite.position.y + rightSpriteYAnimator.currentValue,
			))
			
			if rightSpriteYAnimator.ended {
				self.rightSpriteYAnimator = nil
			}
		}
	}
	
	override func moveTo(y: Float) {
		super.moveTo(y: y)
		leftSprite.moveTo(Point(x: leftSprite.position.x, y: y))
		rightSprite.moveTo(Point(x: rightSprite.position.x, y: y))
	}
	
	override func focus() {
		if isFocused {
			return
		}
		
		arrowFocusAnimator = Animator(Animator.Config(
			duration: 0.2,
			startValue: offsetX,
			endValue: offsetX + ConfigMenuItem.SELECTED_OFFSET_X,
			easingFn: EasingFn.basic(Ease.outQuad),
		))
		
		super.focus()
		
		leftSprite.isVisible = true
		rightSprite.isVisible = true
	}
	
	override func blur() {
		if !isFocused {
			return
		}
		
		arrowFocusAnimator = Animator(Animator.Config(
			duration: 0.5,
			startValue: offsetX + ConfigMenuItem.SELECTED_OFFSET_X,
			endValue: offsetX,
			easingFn: EasingFn.basic(Ease.outQuad),
		))
		
		super.blur()
	}
	
	func prev() {
		leftSpriteYAnimator = Animator(Animator.Config(
			duration: 0.1,
			startValue: 5,
			endValue: 0,
			easingFn: EasingFn.basic(Ease.outQuad),
		))
	}
	
	func next() {
		rightSpriteYAnimator = Animator(Animator.Config(
			duration: 0.1,
			startValue: 5,
			endValue: 0,
			easingFn: EasingFn.basic(Ease.outQuad),
		))
	}
}
