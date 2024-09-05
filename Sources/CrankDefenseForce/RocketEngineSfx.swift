import PlaydateKit

class RocketEngineSfx {
	static let maxVolume: Float = 0.08
	static let maxRockets = 10
	
	let engineNoise1 = Sound.Synth()
	
	let engineNoise2 = Sound.Synth()
	
	private var activeRocketsCount = 0
	
	init() {
		engineNoise1.setWaveform(.noise)
		engineNoise1.setAttackTime(0.1)
		engineNoise1.setReleaseTime(0.1)
		
		engineNoise2.setWaveform(.noise)
		engineNoise2.setAttackTime(0.1)
		engineNoise2.setReleaseTime(0.1)
		
		let _ = RocketSilo.launchEmitter.on(handleRocketLaunch)
		let _ = Rocket.removeEmitter.on(handleRocketRemove)
	}
	
	private func handleRocketLaunch(payload: RocketSilo.LaunchEventPayload) {
		activeRocketsCount += 1
		updateNoise()
	}
	
	private func handleRocketRemove(payload: Rocket.RemoveEventPayload) {
		activeRocketsCount -= 1
		updateNoise()
	}
	
	private func updateNoise() {
		// TODO: Check settings SFX vol
		let volume = RocketEngineSfx.maxVolume * fminf(1, Float(activeRocketsCount) / Float( RocketEngineSfx.maxRockets))
		
		if volume > 0 {
			engineNoise1.playNote(frequency: 120, volume: volume)
			engineNoise2.playNote(frequency: 80, volume: volume)
		} else {
			engineNoise1.noteOff()
			engineNoise2.noteOff()
		}
	}
}
