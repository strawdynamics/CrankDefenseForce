//
//  GameplayScene.swift
//
//
//  Created by Paul Straw on 8/25/24.
//

import PlaydateKit

class GameplayScene: BaseScene {
	let entityStore = EntityStore()
	
	override func update() {
		self.entityStore.update()
		
		let pushed = System.buttonState.pushed
		
		if pushed.contains(.a) {
			game.scenePresenter.changeScene(
				newScene: MainMenuScene(),
				transition: FirstInLineSceneTransition(),
			)
		}
	}
	
	override func enter() {
		let bgEntity = ImageBackground(
			entityStore: self.entityStore,
			backgroundType: .city
		)
		
		self.entityStore.add(bgEntity)
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
