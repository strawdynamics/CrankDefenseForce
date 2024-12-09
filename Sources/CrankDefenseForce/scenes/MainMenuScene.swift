import PlaydateKit

class Menu {
	static let width = 140
	static let height = 130
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
		draw()
	}
	
	func prev() {
		selectedItemIndex = (selectedItemIndex - 1)
		if selectedItemIndex < 0 {
			selectedItemIndex = menuItems.count - 1
		}
		GameSettings.lastMainMenuSelectedItemIndex = selectedItemIndex
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
			let y = 20 + i * lineHeight
			let selected = selectedItemIndex == i
			
			if selected {
				Graphics.drawText(">", at: Point(x: 12, y: y))
			}
			
			Graphics.drawText(
				menuItem.key,
				at: Point(x: (selected ? CdfFont.Jamma8x8Mono16.getTextWidth(for: ">", tracking: 0) : 0) + 12, y: y)
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
	let entityStore = EntityStore()
	
	var menu: Menu?
	
	var exiting = false
	
	override func update() {
		let pushed = System.buttonState.pushed
		
		if !exiting {
			if pushed.contains(.down) {
				menu?.next()
			} else if (pushed.contains(.up)) {
				menu?.prev()
			}
		}
		
		menu?.update()
		
		if menu != nil {
			Graphics.drawMode = .copy
			Graphics.drawBitmap(
				menu!.bitmap,
				at: Point(x: 200, y: 45),
				degrees: 12,
				center: Point(x: 0, y: 0),
				xScale: 1.0,
				yScale: 1.0
			)
		}
		
		
		if !exiting && pushed.contains(.a) {
			menu?.menuItems[menu!.selectedItemIndex].action()
		}
	}
	
	override func enter() {
		let _ = BasicBackground(
			entityStore: entityStore,
			color: .black
		)
		
		let _ = ImageBackground(
			entityStore: entityStore,
			backgroundType: .crt
		)
	}
	
	override func start() {
		menu = Menu(menuItems: [
			Menu.MenuItem(key: "LAUNCH!", action: self.handlePlayPressed),
			Menu.MenuItem(key: "CONFIG", action: self.handleConfigPressed),
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
		
		exiting = true
	}
	
	func handleConfigPressed() {
		menu!.fadeOut({
			game.scenePresenter.changeScene(
				newScene: ConfigScene(),
				transition: CrtInSceneTransition()
			)
		})
		
		exiting = true
	}
	
	func handleAboutPressed() {
		menu!.fadeOut({
			game.scenePresenter.changeScene(
				newScene: AboutScene(),
				transition: CrtInSceneTransition()
			)
		})
		
		exiting = true
	}
}
