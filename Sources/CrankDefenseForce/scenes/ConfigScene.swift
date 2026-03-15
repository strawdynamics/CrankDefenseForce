import PlaydateKit
import UTF8ViewExtensions

class ConfigScene: BaseScene {
	class VersionSprite: Sprite.Sprite {
		let version: String

		init(version: String) {
			self.version = version
			super.init()
			center = Point(x: 1, y: 1)
			setSize(width: 50, height: 16)
			moveTo(Point(x: Display.width, y: Display.height))
			zIndex = 10
		}

		override func draw(bounds _: Rect, drawRect _: Rect) {
			Graphics.setFont(CdfFont.NicoPups16)
			Graphics.drawMode = .fillWhite
			let textWidth = CdfFont.NicoPups16.getTextWidth(for: version, tracking: 0)
			Graphics.drawText(
				version,
				at: bounds.origin
					+ Point(
						x: bounds.width - (Float(textWidth) + 2),
						y: 2
					))
		}
	}

	let entityStore = EntityStore()

	var configMenu: ConfigMenu?

	let versionSprite: VersionSprite

	override init() {
		let reader = PdxinfoReader(path: "pdxinfo")
		let pdxinfo = try! reader.read()
		versionSprite = VersionSprite(version: pdxinfo["version".utf8]!)
	}

	override func update() {
		entityStore.update()

		updateInput()

		entityStore.lateUpdate()
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

		if pushed.contains(.up) {
			configMenu?.selectPrev()
		} else if pushed.contains(.down) {
			configMenu?.selectNext()
		}

		let ticks = System.getCrankTicks(6)
		if ticks != 0 {
			if ticks == 1 {
				configMenu?.selectNext()
			} else {
				configMenu?.selectPrev()
			}
		}
	}

	override func enter() {
		let _ = SkyBackground(
			entityStore: entityStore
		)

		let _ = ImageBackground(
			entityStore: entityStore,
			backgroundType: .configCity
		)

		versionSprite.addToDisplayList()

		configMenu = ConfigMenu(
			ConfigMenu.Config(
				entityStore: entityStore,
			))
	}

	override func exit() {
		GameSettings.writeToDisk()
	}
}
