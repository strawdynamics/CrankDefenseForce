import PlaydateKit
import PDKPdfxr

class SmallUfoSfx {
	static let maxUfos = 2

	let instances: [Pdfxr]

	private var activeUfosCount = 0

	init() {
		instances = (0..<Self.maxUfos).map { _ in
			try! Pdfxr(effectPath: "sfx/smallUfoMove")
		}
	}

	func incActiveUfos() {
		activeUfosCount += 1
		updateInstances()
	}

	func decActiveUfos() {
		activeUfosCount -= 1
		if activeUfosCount < 0 {
			activeUfosCount = 0
		}

		updateInstances()
	}

	private func updateInstances() {
		for (i, fx) in instances.enumerated() {
			if i + 1 <= activeUfosCount {
				fx.start(note: fx.note, volume: GameSettings.sfxVolumePercent * fx.volume)
			} else {
				fx.stop()
			}
		}
	}
}
