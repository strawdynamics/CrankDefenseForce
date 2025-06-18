import PlaydateKit
import PDKPdfxr

class Sfx {
	enum EffectName {
		case menuEnter
		case menuExit
		case menuNavigate
		case stepperNext
		case stepperNo
		case stepperPrev
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
		.menuEnter: Effect(.menuEnter, path: "sfx/menuEnter"),
		.menuExit: Effect(.menuExit, path: "sfx/menuExit"),
		.menuNavigate: Effect(.menuNavigate, path: "sfx/menuNavigate"),
		.stepperNext: Effect(.stepperNext, path: "sfx/stepperNext"),
		.stepperNo: Effect(.stepperNo, path: "sfx/stepperNo"),
		.stepperPrev: Effect(.stepperPrev, path: "sfx/stepperPrev"),
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
