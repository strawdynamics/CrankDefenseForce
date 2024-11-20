import PlaydateKit

class PdkTestScene: BaseScene {	
	let entityStore = EntityStore()
	
	override func update() {
		self.entityStore.update()
		
		let pushed = System.buttonState.pushed
		
		if pushed.contains(.b) {
			game.scenePresenter.changeScene(
				newScene: MainMenuScene(),
				transition: CrtOutSceneTransition()
			)
		}
	}
	
	override func enter() {
		let _ = BasicBackground(
			entityStore: self.entityStore,
//			color: Graphics.Color.pattern((0xE7, 0xDB, 0xDB, 0xDB, 0xDB, 0xBD, 0x7E, 0xFF))
			color: Graphics.Color.black
		)
	}
	
	override func start() {
		//
	}
	
	override func exit() {
		//
	}
	
	override func finish() {
	
	}
}



class PdkLogo: Sprite.Sprite {
	// MARK: Lifecycle
	
	override init() {
		super.init()
		image = try! Graphics.Bitmap(path: "pdklogo.png")
		bounds = .init(x: 0, y: 0, width: 400, height: 240)
	}
	
	// MARK: Internal
	
	override func update() {
		moveBy(dx: 0, dy: sinf(System.elapsedTime * 4))
	}
}
