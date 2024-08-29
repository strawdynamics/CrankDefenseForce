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
		
		let eased = EasingFn.basic(Ease.linear).ez(testEaseTime, 50.0, 300.0, testEaseDuration)
		Graphics.fillEllipse(in: Rect(x: eased, y: 120.0, width: 12.0, height: 12.0), color: .white)
		
		let eased2 = EasingFn.elastic(Ease.inOutElastic).ez(testEaseTime, 50.0, 300.0, testEaseDuration)
		Graphics.fillEllipse(in: Rect(x: eased2, y: 140.0, width: 12.0, height: 12.0), color: .white)
		
		let eased3 = EasingFn.overshoot(Ease.outInBack).ez(testEaseTime, 50.0, 300.0, testEaseDuration)
		Graphics.fillEllipse(in: Rect(x: eased3, y: 160.0, width: 12.0, height: 12.0), color: .white)
		
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
