//
//  GameRunner.swift
//
//
//  Created by Paul Straw on 8/26/24.
//

import PlaydateKit

nonisolated(unsafe) let groundBitmap = try! Graphics.Bitmap(path: "ground.png")

struct GameRunner {
	let entityStore = EntityStore()
	
	let playerController: PlayerController
	
	let siloB: RocketSilo
	
	let siloA: RocketSilo
	
	let testEaseDuration: Float = 5.0
	var testEaseTime: Float = 0.0
	
	init() {
		playerController = PlayerController(entityStore)
		
		siloB = RocketSilo(RocketSilo.Config(
			siloType: .b, entityStore: entityStore
		))
		
		siloA = RocketSilo(RocketSilo.Config(
			siloType: .a, entityStore: entityStore
		))
		
		let _ = Rocket.removeEmitter.on(handleRocketRemove)
		
		let _ = ImageBackground(
			entityStore: entityStore,
			backgroundType: .city
		)
		
		let ground = StaticCollider(StaticCollider.Config(
			bitmap: groundBitmap,
			entityStore: entityStore,
		))
		
		ground.sprite.center = Point(x: 0.0, y: 1.0)
		ground.sprite.moveTo(Point(x: 0.0, y: 240.0))
	}
	
	func handleRocketRemove(payload: Rocket.RemoveEventPayload) {
		entityStore.remove(payload.rocket)
	}
	
	mutating func update() {
		testEaseTime += Time.deltaTime
		testEaseTime = fmodf(testEaseTime, testEaseDuration)
		
		let eased = EasingFn.basic(outQuad).ease(testEaseTime, 50.0, 300.0, testEaseDuration)
		Graphics.fillEllipse(in: Rect(x: eased, y: 120.0, width: 12.0, height: 12.0))
		
		entityStore.update()
		
		updateInputs()
		
		entityStore.lateUpdate()
		
		Graphics.drawText("somanyents \(entityStore.entityCount)", at: Point.zero)
	}
	
	func exit() {
		Rocket.removeEmitter.reset()
		RocketSilo.launchEmitter.reset()
	}

	func finish() {
		entityStore.destroy()
	}
	
	private func updateInputs() {
		let inputs = playerController.inputs
		
		for input in inputs {
			switch input {
			case .launchSiloB:
				let _ = siloB.attemptLaunch()
			case .launchSiloA:
				let _ = siloA.attemptLaunch()
			case .selectNextRocket:
				playerController.selectNextRocket()
			case .selectPreviousRocket:
				playerController.selectPreviousRocket()
			case .turnRocket(let degrees):
				playerController.turn(degrees: degrees)
			}
		}
	}
}
