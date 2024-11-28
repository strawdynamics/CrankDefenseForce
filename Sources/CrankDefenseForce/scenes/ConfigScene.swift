import PlaydateKit

class ConfigScene: BaseScene {
	class VersionSprite: Sprite.Sprite {
		let version: String
		
		init(version: String) {
			self.version = version
			super.init()
			center = Point(x: 1, y: 1)
			setSize(width: 40, height: 10)
			moveTo(Point(x: 400, y: 240))
			zIndex = 10
		}
		
		override func draw(bounds _: Rect, drawRect _: Rect) {
			Graphics.pushContext(nil)
			
			Graphics.setFont(CdfFont.Nybble4)
			Graphics.drawMode = .fillWhite
			let textWidth = CdfFont.Nybble4.getTextWidth(for: version, tracking: 0)
			Graphics.drawText(version, at: bounds.origin + Point(
				x: bounds.width - (Float(textWidth) + 4),
				y: 2
			))
			
			Graphics.popContext()
		}
	}
	
	let entityStore = EntityStore()
	
	var configMenu: ConfigMenu?
	
	let versionSprite: VersionSprite
	
	override init() {
				print("Hello from ConfigScene");
//				let reader = PdxinfoReader(path: "pdxinfo")
//				let pdxinfo = try! reader.read();
//				print("vers \(pdxinfo[Utf8Key("version")] ?? "oh no")")
		versionSprite = VersionSprite(version: "v TODO")
	}
	
	override func update() {
		entityStore.update()
		
		updateInput()
		
		entityStore.lateUpdate()
	}
	
	private func updateInput() {
		let pushed = System.buttonState.pushed
		
		if pushed.contains(.b) {
			game.scenePresenter.changeScene(
				newScene: MainMenuScene(),
				transition: CrtOutSceneTransition()
			)
		}
		
		if pushed.contains(.up) {
			configMenu?.selectPrev()
		} else if pushed.contains(.down) {
			configMenu?.selectNext()
		}
	}
	
	override func enter() {
		let _ = BasicBackground(
			entityStore: entityStore,
			color: .black
		)
		
		let _ = ImageBackground(
			entityStore: entityStore,
			backgroundType: .configCity
		)
		
		versionSprite.addToDisplayList()
		
		configMenu = ConfigMenu(ConfigMenu.Config(
			entityStore: entityStore,
		))
	}
}
