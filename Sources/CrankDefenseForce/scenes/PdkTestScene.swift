//
//  PdkTestScene.swift
//
//
//  Created by Paul Straw on 8/25/24.
//

import PlaydateKit

class PdkTestScene: BaseScene {	
	let entityStore = EntityStore()
	
	override func update() {
		self.entityStore.update()
		
		let pushed = System.buttonState.pushed
		
		if pushed.contains(.a) {
			game.scenePresenter.changeScene(newScene: MainMenuScene(), transition: FirstInLineSceneTransition())
		}
	}
	
	override func enter() {
		let bgEntity = BasicBackground(
			entityStore: self.entityStore,
			color: Graphics.Color.pattern((0x55, 0xAA, 0x55, 0xAA, 0x55, 0xAA, 0x55, 0xAA))
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



class PdkLogo: Sprite.Sprite {
	// MARK: Lifecycle
	
	override init() {
		super.init()
		image = try! Graphics.Bitmap(path: "pdklogo.png")
		bounds = .init(x: 0, y: 0, width: 400, height: 240)
	}
	
	// MARK: Internal
	
	override func update() {
		moveBy(dx: 0, dy: sinf(System.elapsedTime * 4))
	}
}
