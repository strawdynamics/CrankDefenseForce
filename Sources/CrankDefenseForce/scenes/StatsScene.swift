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
			} else {
				currentDisplayMode = .localStats
				remoteScoresDisplay?.hide()
				persistentStatsDisplay?.show()
			}

			indicatorAnimator = Animator(Animator.Config(
				duration: 0.4,
				startValue: displayModeIndicator.position.x,
				endValue: currentDisplayMode == .localStats ? Self.localStatsIndicatorX : Self.remoteScoresIndicatorX,
				easingFn: EasingFn.basic(Ease.inOutQuad)
			))
		}

		// TODO: Scrolling for remote scores
//		let current = System.buttonState.current
//
//		if current.contains(.up) {
//			offY += 4
//		} else if current.contains(.down) {
//			offY -= 4
//		}
//
//		offY = max(
//			min(offY - Int(System.crankChange), 0),
//			-(persistentStatsDisplay?.totalHeight ?? 0) + Display.height)
//
//		Graphics.setDrawOffset(dx: 0, dy: offY)
	}

	override func enter() {
		displayModeIndicator.image = ConfigMenuItem.bgBitmapTable[0]
		displayModeIndicator.center = Point.zero
		displayModeIndicator.moveTo(Point(x: Self.localStatsIndicatorX, y: Self.indicatorY))
		displayModeIndicator.setIgnoresDrawOffset(true)
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
