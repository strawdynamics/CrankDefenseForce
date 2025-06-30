import PlaydateKit
import PDKMasterPlayer
import PDKPdfxr

class Menu {
	static let width = 120
	static let height = 120
	static let fadeDuration: Float = 0.2

	var isFadingIn = false
	var isFadingOut = false
	var fadeTime: Float = 0.0
	var fadePct: Float = 0.0
	var onFadedOut: (() -> Void)?
	
	class MenuItem {
		let key: String
		let action: () -> Void
		
		init(key: String, action: @escaping () -> Void) {
			self.key = key
			self.action = action
		}
	}
	
	let menuItems: [MenuItem]
	
	var selectedItemIndex = GameSettings.lastMainMenuSelectedItemIndex
	
	let bitmap = Graphics.Bitmap(width: Menu.width, height: Menu.height)
	
	init(menuItems: [MenuItem]) {
		self.menuItems = menuItems
		draw()
	}
	
	func next() {
		selectedItemIndex = (selectedItemIndex + 1) % menuItems.count
		GameSettings.lastMainMenuSelectedItemIndex = selectedItemIndex
		Sfx.instance.play(.menuNavigate)
		draw()
	}
	
	func prev() {
		selectedItemIndex = (selectedItemIndex - 1)
		if selectedItemIndex < 0 {
			selectedItemIndex = menuItems.count - 1
		}
		GameSettings.lastMainMenuSelectedItemIndex = selectedItemIndex
		Sfx.instance.play(.menuNavigate, offset: -2)
		draw()
	}
	
	func update() {
		if isFadingIn || isFadingOut {
			fadeTime += Time.deltaTime
			fadePct = fadeTime / Self.fadeDuration
			
			if isFadingIn {
				fadePct = 1 - fadePct
			}
			
			fadePct = fadePct.clamped(0.0, 1.0)
			
			if fadeTime > Self.fadeDuration {
				if isFadingOut {
					onFadedOut?()
				}
				
				isFadingIn = false
				isFadingOut = false
			}
			
			draw()
		}
	}
	
	func fadeIn() {
		isFadingIn = true
		isFadingOut = false
		fadeTime = 0.0
		fadePct = 0.0
	}
	
	func fadeOut(_ onFadedOut: @escaping () -> Void) {
		isFadingOut = true
		isFadingIn = false
		fadeTime = 0.0
		fadePct = 0.0
		
		self.onFadedOut = onFadedOut
	}
	
	private func draw() {
		Graphics.pushContext(bitmap)
		Graphics.clear(color: .clear)
		
		Graphics.setFont(CdfFont.Jamma8x8Mono16)
		Graphics.drawMode = .fillWhite
		
		let lineHeight = Int(Float(CdfFont.Jamma8x8Mono16.height) * 1.75)
		
		menuItems.enumerated().forEach { i, menuItem in
			let y = i * lineHeight
			let selected = selectedItemIndex == i
			
			if selected {
				Graphics.drawText(">", at: Point(x: 0, y: y))
			}
			
			Graphics.drawText(
				menuItem.key,
				at: Point(
					x: (selected
						? CdfFont.Jamma8x8Mono16.getTextWidth(for: ">", tracking: 0)
						: 0),
					y: y
				)
			)
		}
		
		if isFadingIn || isFadingOut {
			Graphics.fillRect(
				Rect(x: 0, y: 0, width: Self.width, height: Self.height),
				color: Graphics.Color.getBayer4x4FadeColor(foreground: 0, alpha: fadePct)
			)
		}
		
		Graphics.popContext()
	}
}

class MainMenuScene: BaseScene {
	static nonisolated(unsafe) let colonelBitmap = try! Graphics.Bitmap(path: "scenes/MainMenuScene/colonel")
	
	let entityStore = EntityStore()
	
	var menu: Menu?
	
	var exiting = false

	class ColonelSprite: PlaydateKit.Sprite.Sprite {
		static let startOffX: Float = -160
		static let endOffX: Float = -16
		
		var xAnimator: Animator<Float>?
		
		override init() {
			super.init()
			zIndex = 5
			image = colonelBitmap
			center = Point(x: 0, y: 0)
			moveTo(Point(x: Self.startOffX, y: 0))
			
			animateIn()
		}
		
		func animateIn() {
			self.xAnimator = Animator(Animator.Config(
				duration: 0.8,
				startValue: Self.startOffX,
				endValue: Self.endOffX,
				easingFn: EasingFn.overshoot(Ease.outBack),
			))
		}
		
		func animateOut() {
			self.xAnimator = Animator(Animator.Config(
				duration: 0.25,
				startValue: Self.endOffX,
				endValue: Self.startOffX,
				easingFn: EasingFn.overshoot(Ease.inBack),
			))
		}
		
		override func update() {
			if let xAnimator = self.xAnimator {
				xAnimator.update()
				moveTo(Point(x: xAnimator.currentValue, y: position.y))
				
				if xAnimator.ended {
					self.xAnimator = nil
				}
			}
		}
	}
	
	var colonelSprite = ColonelSprite()
	
	override func update() {
		let pushed = System.buttonState.pushed

		if !exiting {
			if pushed.contains(.down) {
				menu?.next()
			} else if (pushed.contains(.up)) {
				menu?.prev()
			}

			let ticks = System.getCrankTicks(6)
			if ticks != 0 {
				if ticks == 1 {
					menu?.next()
				} else {
					menu?.prev()
				}
			}
		}
		
		menu?.update()
		
		if menu != nil {
			Graphics.drawMode = .copy
			Graphics.drawBitmap(
				menu!.bitmap,
				at: Point(x: 210, y: 60),
				degrees: 13,
				center: Point(x: 0, y: 0),
				xScale: 1.0,
				yScale: 1.0
			)
		}
		
		if !exiting && pushed.contains(.a) {
			Sfx.instance.play(.menuEnter)
			menu?.menuItems[menu!.selectedItemIndex].action()
		}
	}
	
	override func enter() {
		Graphics.setDrawOffset(dx: 0, dy: 0)
		let _ = BasicBackground(
			entityStore: entityStore,
			color: .black
		)
		
		let _ = ImageBackground(
			entityStore: entityStore,
			backgroundType: .crt
		)
		
		colonelSprite.addToDisplayList()
	}
	
	override func start() {
		Soundtrack.instance.playUnlessActive(song: .sendHelp)

		menu = Menu(menuItems: [
			Menu.MenuItem(key: "LAUNCH!", action: self.handlePlayPressed),
			Menu.MenuItem(key: "CONFIG", action: self.handleConfigPressed),
			Menu.MenuItem(key: "MANUAL", action: self.handleAboutPressed),
			Menu.MenuItem(key: "ABOUT", action: self.handleAboutPressed),
		])

		menu!.fadeIn()
	}
	
	override func exit() {
		
	}
	
	override func finish() {
		menu = nil
	}
	
	func handlePlayPressed() {
		menu!.fadeOut({
			game.scenePresenter.changeScene(
				newScene: GameplayScene(),
				transition: CrtInSceneTransition()
			)
		})
		

		Soundtrack.instance.fadeOut(duration: 0.2)

		colonelSprite.animateOut()
		exiting = true
	}
	
	func handleConfigPressed() {
		menu!.fadeOut({
			game.scenePresenter.changeScene(
				newScene: ConfigScene(),
				transition: CrtInSceneTransition()
			)
		})
		
		colonelSprite.animateOut()
		exiting = true
	}
	
	func handleAboutPressed() {
		menu!.fadeOut({
			game.scenePresenter.changeScene(
				newScene: AboutScene(),
				transition: CrtInSceneTransition()
			)
		})
		
		colonelSprite.animateOut()
		exiting = true
	}
}
