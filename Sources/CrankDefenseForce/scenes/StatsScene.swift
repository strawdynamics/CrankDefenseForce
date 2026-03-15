import PlaydateKit

class StatsScene: BaseScene {
	let entityStore = EntityStore()

	private static let indicatorY: Float = 0

	private static let localStatsIndicatorX: Float = 4

	private static let remoteScoresIndicatorX: Float = 200

	private var offY = 0

	private var persistentStatsDisplay: PersistentStatsDisplay?

	private var remoteScoresDisplay: RemoteScoresDisplay?

	private var currentDisplayMode: DisplayMode = .localStats

	private let displayModeIndicator = Sprite.Sprite()

	private var indicatorAnimator: Animator<Float>?

	private let localStatsText = Sprite.Sprite()

	private let remoteScoresText = Sprite.Sprite()

	enum DisplayMode {
		case localStats
		case remoteScores
	}

	override func update() {
		self.entityStore.update()
		remoteScoresDisplay?.update()

		if let indicatorAnimator = indicatorAnimator {
			indicatorAnimator.update()

			displayModeIndicator.moveTo(Point(x: indicatorAnimator.currentValue, y: Self.indicatorY))

			if indicatorAnimator.ended {
				self.indicatorAnimator = nil
			}
		}

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

				Sfx.instance.play(.stepperNext)
			} else {
				currentDisplayMode = .localStats
				remoteScoresDisplay?.hide()
				persistentStatsDisplay?.show()

				Sfx.instance.play(.stepperPrev)
			}

			offY = 0
			Graphics.setDrawOffset(dx: 0, dy: 0)

			indicatorAnimator = Animator(Animator.Config(
				duration: 0.4,
				startValue: displayModeIndicator.position.x,
				endValue: currentDisplayMode == .localStats ? Self.localStatsIndicatorX : Self.remoteScoresIndicatorX,
				easingFn: EasingFn.basic(Ease.inOutQuad)
			))
		}

		let current = System.buttonState.current

		if current.contains(.up) {
			offY += 4
		} else if current.contains(.down) {
			offY -= 4
		}

		let activeHeight = currentDisplayMode == .localStats
			? (persistentStatsDisplay?.totalHeight ?? 0)
			: (remoteScoresDisplay?.totalHeight ?? 0)

		offY = max(
			min(offY - Int(System.crankChange), 0),
			-activeHeight + Display.height)

		Graphics.setDrawOffset(dx: 0, dy: offY)
	}

	override func enter() {
		displayModeIndicator.image = ConfigMenuItem.bgBitmapTable[0]
		displayModeIndicator.center = Point.zero
		displayModeIndicator.moveTo(Point(x: Self.localStatsIndicatorX, y: Self.indicatorY))
		displayModeIndicator.setIgnoresDrawOffset(true)
		displayModeIndicator.zIndex = 800
		displayModeIndicator.addToDisplayList()

		let textHeight = CdfFont.NicoClean16.height
		let textY = Self.indicatorY + 26
		let textRect = Rect(x: 0, y: 0, width: 130, height: textHeight)

		let localStatsBmp = Graphics.Bitmap(width: 150, height: textHeight)
		Graphics.pushContext(localStatsBmp)
		Graphics.setFont(CdfFont.NicoClean16)
		Graphics.drawMode = .fillWhite
		Graphics.drawTextInRect("Local stats", in: textRect, aligned: .center)
		Graphics.popContext()
		localStatsText.image = localStatsBmp
		localStatsText.moveTo(Point(x: Self.localStatsIndicatorX + 108, y: textY))
		localStatsText.setIgnoresDrawOffset(true)
		localStatsText.zIndex = 810
		localStatsText.addToDisplayList()

		let remoteScoresBmp = Graphics.Bitmap(width: 150, height: textHeight)
		Graphics.pushContext(remoteScoresBmp)
		Graphics.setFont(CdfFont.NicoClean16)
		Graphics.drawMode = .fillWhite
		Graphics.drawTextInRect("Remote scores", in: textRect, aligned: .center)
		Graphics.popContext()
		remoteScoresText.image = remoteScoresBmp
		remoteScoresText.moveTo(Point(x: Self.remoteScoresIndicatorX + 108, y: textY))
		remoteScoresText.setIgnoresDrawOffset(true)
		remoteScoresText.zIndex = 810
		remoteScoresText.addToDisplayList()

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
