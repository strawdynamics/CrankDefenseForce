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
		
		Graphics.drawText("somanyents \(self.entityStore.entities.count)", at: Point.zero)
		
		let pushed = System.buttonState.pushed
		
		if pushed.contains(.down) {
			game.scenePresenter.changeScene(
				newScene: MainMenuScene(),
				transition: FirstInLineSceneTransition(),
			)
		}
		
		if pushed.contains(.a) {
			let rocket = Rocket(Rocket.Config(
				position: Point(
					x: Float.random(in: 0.0..<400.0),
					y: Float.random(in: 0.0..<240.0)
				),
				angle: Float.random(in: 0.0..<360.0),
				thrust: 2.0,
				entityStore: self.entityStore
			))
			self.entityStore.add(rocket)
		}
	}
	
	override func enter() {
		Rocket.testoEmitter.on { payload in
			print("HEY GOT THE EVENT!!!")
		}
		
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
		Rocket.testoEmitter.reset()
	}
	
	override func finish() {
		self.entityStore.destroy()
	}
}
