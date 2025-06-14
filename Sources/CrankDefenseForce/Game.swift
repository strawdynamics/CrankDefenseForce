import PlaydateKit

final class Game: PlaydateGame {
	let scenePresenter: ScenePresenter

	let debugOverlay: DebugOverlay

	init() {
		Display.refreshRate = 40.0
		Sprite.setAlwaysRedraw(true)
		self.scenePresenter = ScenePresenter(firstScene: MainMenuScene())
		self.debugOverlay = DebugOverlay()
	}
	
	func update() -> Bool {
		Time.updateDeltaTime()
		
		Soundtrack.instance.update()

		Sprite.updateAndDrawDisplayListSprites()
		
		self.scenePresenter.update()

		debugOverlay.update()

		return true
	}

	func gameWillPause() {
		print("Paused!")
	}
}

