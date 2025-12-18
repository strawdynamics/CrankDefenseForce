import PlaydateKit

class AboutScene: BaseScene {
	let entityStore = EntityStore()

	private var offY = 0

	private var creditsDisplay: CreditsDisplay?

	override func update() {
		self.entityStore.update()

		updateInput()
	}

	private func updateInput() {
		let pushed = System.buttonState.pushed

		if pushed.contains(.b) {
			Sfx.instance.play(.menuExit)
			game.scenePresenter.changeScene(
				newScene: MainMenuScene(),
				transition: CrtOutSceneTransition()
			)
		}

		let current = System.buttonState.current

		if current.contains(.up) {
			offY += 4
		} else if current.contains(.down) {
			offY -= 4
		}

		offY = max(
			min(offY - Int(System.crankChange), 0), -(creditsDisplay?.totalHeight ?? 0) + Display.height)

		Graphics.setDrawOffset(dx: 0, dy: offY)
	}

	override func enter() {
		let _ = BasicBackground(
			entityStore: self.entityStore,
			color: .black
		)

		creditsDisplay = CreditsDisplay(
			CreditsDisplay.Config(
				entityStore: entityStore))
	}
}
