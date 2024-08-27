//
//  PlayerController.swift
//
//
//  Created by Paul Straw on 8/26/24.
//

import PlaydateKit

nonisolated(unsafe) private let SCREEN_CENTER = Point(x: 200.0, y: 120.0)

private let CRANK_COEFFICIENT: Float = 0.3;

class PlayerController: BaseEntity {
	enum PlayerInput {
		case launchSiloB
		case launchSiloA
		case selectPreviousRocket
		case selectNextRocket
		case turnRocket(Float)
	}
	
	private var cursor: PlayerCursor
	
	private(set) var currentRocket: Rocket?
	
	private var rockets: [Rocket] = []
	
	private(set) var inputs: [PlayerInput] = []
	
	private var currentRocketIndex: Int = -1
	
	override init(_ entityStore: EntityStore) {
		self.cursor = PlayerCursor(entityStore)
		super.init(entityStore)
		
		let _ = RocketSilo.launchEmitter.on(handleRocketLaunch)
		let _ = Rocket.removeEmitter.on(handleRocketRemove)
	}
	
	func handleRocketLaunch(payload: RocketSilo.LaunchEventPayload) {
		currentRocket = payload.rocket
		currentRocketIndex = rockets.count
		rockets.append(payload.rocket)
	}
	
	func handleRocketRemove(payload: Rocket.RemoveEventPayload) {
		var removedCurrentRocket = payload.rocket.id == self.currentRocket?.id
		if removedCurrentRocket {
			self.currentRocket = nil
		}
		
		rockets.removeAll { rocket in
			let shouldRemove = rocket.id == payload.rocket.id
			
			return shouldRemove
		}
		
		if removedCurrentRocket && rockets.count > 0 {
			currentRocketIndex = rockets.count - 1
			currentRocket = rockets[currentRocketIndex]
		}
	}
	
	func turn(degrees: Float) {
		currentRocket?.changeAngle(delta: degrees)
	}
	
	func selectNextRocket() {
		if rockets.count == 0 {
			currentRocketIndex = -1
			return
		}
		
		if currentRocketIndex >= self.rockets.count - 1 {
			currentRocketIndex = 0
		} else {
			currentRocketIndex = currentRocketIndex + 1
		}

		currentRocket = rockets[currentRocketIndex]
	}
	
	func selectPreviousRocket() {
		if rockets.count == 0 {
			currentRocketIndex = -1
			return
		}
		
		if currentRocketIndex <= 0 {
			currentRocketIndex = rockets.count - 1
		} else {
			currentRocketIndex = currentRocketIndex - 1
		}

		currentRocket = rockets[currentRocketIndex]
	}
	
	override func update() {
		updateInputs()
	}
	
	override func lateUpdate() {
		updateCursor()
	}
	
	private func updateInputs() {
		inputs.removeAll()
		// TODO: Base this on user settings
		
		let pushed = System.buttonState.pushed
		
		if pushed.contains(.b) {
			inputs.append(.launchSiloB)
		}
		
		if pushed.contains(.a) {
			inputs.append(.launchSiloA)
		}
		
		if pushed.contains(.left) {
			inputs.append(.selectPreviousRocket)
		} else if pushed.contains(.right) {
			inputs.append(.selectNextRocket)
		}
		
		let crankChange = System.crankChange
		
		if crankChange != 0.0 {
			inputs.append(.turnRocket(crankChange * CRANK_COEFFICIENT))
		}
	}
	
	private func updateCursor() {
		if let rocket = self.currentRocket {
			self.cursor.moveToward(dest: rocket.position)
		} else {
			self.cursor.moveToward(dest: SCREEN_CENTER)
		}
	}
}
