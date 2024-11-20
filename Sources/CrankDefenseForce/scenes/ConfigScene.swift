import PlaydateKit

class ConfigScene: BaseScene {
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
			color: Graphics.Color.pattern((0xE7, 0xDB, 0xDB, 0xDB, 0xDB, 0xBD, 0x7E, 0xFF))
		)
	}
}
