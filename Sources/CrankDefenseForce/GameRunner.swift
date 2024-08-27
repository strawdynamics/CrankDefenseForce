//
//  GameRunner.swift
//
//
//  Created by Paul Straw on 8/26/24.
//

import PlaydateKit

struct GameRunner {
	let entityStore = EntityStore()
	
	let playerController: PlayerController
	
	let siloB: RocketSilo
	
	let siloA: RocketSilo
	
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
	}
	
	func handleRocketRemove(payload: Rocket.RemoveEventPayload) {
		entityStore.remove(payload.rocket)
	}
	
	func update() {
		entityStore.update()
		
		updateInputs()
		
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
				print("TODO: selectNextRocket")
			case .selectPreviousRocket:
				print("TODO: selectPreviousRocket")
			case .turnRocket(let degrees):
				playerController.turn(degrees: degrees)
			}
		}
	}
}
