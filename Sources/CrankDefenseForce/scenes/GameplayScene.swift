//
//  GameplayScene.swift
//
//
//  Created by Paul Straw on 8/25/24.
//

import PlaydateKit

class GameplayScene: BaseScene {
	var gameRunner: GameRunner? = nil
	
	override func update() {
		gameRunner?.update()
	}
	
	override func enter() {
		gameRunner = GameRunner()
	}
	
	override func start() {
		System.addMenuItem(title: "Main menu") {
			game.scenePresenter.changeScene(
				newScene: MainMenuScene(),
				transition: CrtOutSceneTransition(),
			)
			
			System.removeAllMenuItems()
		}
	}
	
	override func exit() {
		gameRunner?.exit()
	}
	
	override func finish() {
		gameRunner?.finish()
	}
}
