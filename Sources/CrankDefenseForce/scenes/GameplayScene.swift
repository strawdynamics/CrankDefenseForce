//
//  GameplayScene.swift
//
//
//  Created by Paul Straw on 8/25/24.
//

import PlaydateKit

class GameplayScene: BaseScene {
	let entityStore = EntityStore()
	
	let playerController: PlayerController
	
	override init() {
		self.playerController = PlayerController(entityStore)
		entityStore.add(playerController)
	}
	
	override func update() {
		self.entityStore.update()
		
		Graphics.drawText("somanyents \(self.entityStore.entityCount)", at: Point.zero)
		
		let pushed = System.buttonState.pushed
		
		if pushed.contains(.a) {
			let rocket = Rocket(Rocket.Config(
				position: Point(
					x: Float.random(in: 0.0..<400.0),
					y: Float.random(in: 0.0..<240.0)
				),
				angle: Float.random(in: 0.0..<360.0),
				thrust: 20.0,
				entityStore: self.entityStore
			))
			self.entityStore.add(rocket)
		}
	}
	
	override func enter() {
		let _ = Rocket.removeEmitter.on { payload in
			self.entityStore.remove(payload.rocket)
		}
		
		let bgEntity = ImageBackground(
			entityStore: self.entityStore,
			backgroundType: .city
		)
		
		self.entityStore.add(bgEntity)
	}
	
	override func start() {
		System.addMenuItem(title: "Main menu") {
			game.scenePresenter.changeScene(
				newScene: MainMenuScene(),
				transition: FirstInLineSceneTransition(),
			)
			
			System.removeAllMenuItems()
		}
	}
	
	override func exit() {
		Rocket.removeEmitter.reset()
	}
	
	override func finish() {
		self.entityStore.destroy()
	}
}
