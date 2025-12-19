import PlaydateKit

class StatsScene: BaseScene {
	let entityStore = EntityStore()

	private var offY = 0

	private var persistentStatsDisplay: PersistentStatsDisplay?

	private var remoteScoresDisplay: RemoteScoresDisplay?

	private var currentDisplayMode: DisplayMode = .localStats

	enum DisplayMode {
		case localStats
		case remoteScores
	}

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

		if pushed.contains(.left) || pushed.contains(.right) {
			if currentDisplayMode == .localStats {
				currentDisplayMode = .remoteScores
				persistentStatsDisplay?.hide()
				remoteScoresDisplay?.show()
			} else {
				currentDisplayMode = .localStats
				remoteScoresDisplay?.hide()
				persistentStatsDisplay?.show()
			}
		}

		let current = System.buttonState.current

		if current.contains(.up) {
			offY += 4
		} else if current.contains(.down) {
			offY -= 4
		}

		offY = max(
			min(offY - Int(System.crankChange), 0),
			-(persistentStatsDisplay?.totalHeight ?? 0) + Display.height)

		Graphics.setDrawOffset(dx: 0, dy: offY)
	}

	override func enter() {
		let _ = BasicBackground(
			entityStore: self.entityStore,
			color: .black
		)

		persistentStatsDisplay = PersistentStatsDisplay(
			PersistentStatsDisplay.Config(
				entityStore: entityStore))

		remoteScoresDisplay = RemoteScoresDisplay(
			RemoteScoresDisplay.Config(
				entityStore: entityStore))
		remoteScoresDisplay?.hide()
	}
}
