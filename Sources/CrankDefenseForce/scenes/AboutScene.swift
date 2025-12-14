import PlaydateKit

class AboutScene: BaseScene {
	let entityStore = EntityStore()

	override func update() {
		self.entityStore.update()

		let pushed = System.buttonState.pushed

		if pushed.contains(.b) {
			Sfx.instance.play(.menuExit)
			game.scenePresenter.changeScene(
				newScene: MainMenuScene(),
				transition: CrtOutSceneTransition()
			)
		}
	}

	override func enter() {
		let _ = BasicBackground(
			entityStore: self.entityStore,
			color: Graphics.Color.pattern((0x80, 0x49, 0x94, 0x8, 0x20, 0x52, 0x25, 0x2))
		)
	}
}
