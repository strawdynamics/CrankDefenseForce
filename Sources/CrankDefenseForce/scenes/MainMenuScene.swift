//
//  MainMenuScene.swift
//
//
//  Created by Paul Straw on 8/25/24.
//

import PlaydateKit

class MainMenuScene: BaseScene {
	let entityStore = EntityStore()
	
	override func update() {
		Graphics.pushContext(nil)
		Graphics.drawMode = .fillWhite
		Graphics.drawText("CDF SWIFT *salute*", at: Point(x: 50.0, y: 50.0))
		// FIXME: crashes on device?
//		Graphics.drawText("oi buddy \(Time.deltaTime.description)", at: Point(x: 50.0, y: 68.0))
		Graphics.popContext()
		
		let pushed = System.buttonState.pushed
		
		if pushed.contains(.a) {
			game.scenePresenter.changeScene(
				newScene: GameplayScene(),
				transition: FirstInLineSceneTransition()
			)
		}
	}
	
	override func enter() {
		let _ = BasicBackground(
			entityStore: self.entityStore,
			color: .black
		)
	}
	
	override func start() {
		//
	}
	
	override func exit() {
		//
	}
	
	override func finish() {
		self.entityStore.destroy()
	}
}
