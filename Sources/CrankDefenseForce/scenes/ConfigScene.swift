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
			entityStore: entityStore,
			color: .black
		)
		
		let _ = ImageBackground(
			entityStore: entityStore,
			backgroundType: .configCity
		)
		
		print("Hello from ConfigScene");
//		let reader = PdxinfoReader(path: "pdxinfo")
//		let pdxinfo = try! reader.read();
//		print("vers \(pdxinfo[Utf8Key("version")] ?? "oh no")")
	}
}
