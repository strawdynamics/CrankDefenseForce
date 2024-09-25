//
//  MainMenuScene.swift
//
//
//  Created by Paul Straw on 8/25/24.
//

import PlaydateKit

class MainMenuScene: BaseScene {
	let entityStore = EntityStore()
	
	let testEaseDuration: Float = 5.0
	var testEaseTime: Float = 0.0
	
	override func update() {
		testEaseTime = fmodf(testEaseTime + Time.deltaTime, testEaseDuration)
		
//		let eased = EasingFn.basic(Ease.linear).ez(testEaseTime, 50.0, 300.0, testEaseDuration)
//		Graphics.fillEllipse(in: Rect(x: eased, y: 120.0, width: 12.0, height: 12.0), color: .white)
//		
//		let eased2 = EasingFn.elastic(Ease.inOutElastic).ez(testEaseTime, 50.0, 300.0, testEaseDuration)
//		Graphics.fillEllipse(in: Rect(x: eased2, y: 140.0, width: 12.0, height: 12.0), color: .white)
//		
//		let eased3 = EasingFn.overshoot(Ease.outInBack).ez(testEaseTime, 50.0, 300.0, testEaseDuration)
//		Graphics.fillEllipse(in: Rect(x: eased3, y: 160.0, width: 12.0, height: 12.0), color: .white)
		
		let pushed = System.buttonState.pushed
		
		if pushed.contains(.a) {
			game.scenePresenter.changeScene(
				newScene: GameplayScene(),
				transition: CrtInSceneTransition()
			)
		}
		
		if pushed.contains(.b) {
			game.scenePresenter.changeScene(
				newScene: PdkTestScene(),
				transition: CrtInSceneTransition()
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
			backgroundType: .crt
		)
	}
	
	override func start() {
		//
	}
	
	override func exit() {
		//
	}
	
	override func finish() {
	
	}
}
