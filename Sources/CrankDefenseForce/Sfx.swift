import PlaydateKit
import PDKPdfxr

class Sfx {
	enum EffectName {
		case weird
		case up
		case boppp
		case fazer
	}

	class Effect {
		let name: EffectName
		let path: String
		let polyphony: Int

		let instances: [Pdfxr]

		var nextInstanceIndex = 0

		init(_ name: EffectName, path: String, polyphony: Int = 1) {
			self.name = name
			self.path = path
			self.polyphony = max(1, polyphony)

			let pdfxr = try! Pdfxr(effectPath: path)

			var instances = [pdfxr]

			if polyphony > 1 {
				for _ in 2...polyphony {
					instances.append(pdfxr.copy())
				}
			}

			self.instances = instances
		}

		func play() {
			play(offset: 0)
		}

		func play(offset: MIDINote) {
			let fx = instances[nextInstanceIndex]
			fx.play(note: fx.note + offset, volume: GameSettings.sfxVolumePercent * fx.volume)
			nextInstanceIndex = (nextInstanceIndex + 1) % instances.count
		}
	}

	static nonisolated(unsafe) let instance = Sfx(effects: [
		.weird: Effect(.weird, path: "sfx/weird", polyphony: 1),
		.up: Effect(.up, path: "sfx/up", polyphony: 2),
		.boppp: Effect(.boppp, path: "sfx/boppp", polyphony: 2),
		.fazer: Effect(.fazer, path: "sfx/fazer", polyphony: 3),
	])

	let effects: [EffectName: Effect]

	private init(effects: [EffectName: Effect]) {
		self.effects = effects
	}

	public func play(_ effectName: EffectName) {
		play(effectName, offset: 0)
	}

	public func play(_ effectName: EffectName, offset: MIDINote) {
		if let effect = effects[effectName] {
			effect.play(offset: offset)
		} else {
			print("Tried to play unknown effect \(effectName)")
		}
	}

	public func playWithRandomOffset(_ effectName: EffectName) {
		play(effectName, offset: MIDINote.random(in: -3...3))
	}
}
