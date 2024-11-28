import PlaydateKit

class ConfigScene: BaseScene {
	let entityStore = EntityStore()
	
	var configMenu: ConfigMenu?
	
	override func update() {
		entityStore.update()
		
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
		
		entityStore.lateUpdate()
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
		
		configMenu = ConfigMenu(ConfigMenu.Config(
			entityStore: entityStore,
		))
		
//		print("Hello from ConfigScene");
//		let reader = PdxinfoReader(path: "pdxinfo")
//		let pdxinfo = try! reader.read();
//		print("vers \(pdxinfo[Utf8Key("version")] ?? "oh no")")
	}
}
