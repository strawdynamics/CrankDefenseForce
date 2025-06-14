import PDKMasterPlayer

class Soundtrack {
	public enum SongName {
		case sendHelp
	}

	private struct SongDef {
		let name: SongName
		let player: MasterPlayer
		let playFromStep: Int
		let loopStartStep: Int
		let loopEndStep: Int?
	}

	public nonisolated(unsafe) static let instance: Soundtrack = Soundtrack()

	private nonisolated(unsafe) static let songs: [SongName: SongDef] = [
		.sendHelp: SongDef(
			name: .sendHelp,
			player: MasterPlayer(songPath: "songs/sendHelp.mid"),
			playFromStep: 0,
			loopStartStep: 470,
			loopEndStep: -175,
		)
	]

	public var volume: Float? {
		get {
			return currentSong?.player.volume
		}

		set {
			if let newValue {
				currentSong?.player.volume = newValue
			}
		}
	}

	private var currentSong: SongDef?

	private var fadeOutTimer: TimedCallback?

	public func update() {
		updateFadeOut()
	}

	private func updateFadeOut() {
		guard var fadeOutTimer = fadeOutTimer else { return }

		volume = GameSettings.musicVolumePercent * (1 - fadeOutTimer.animator.currentPercent)

		let ended = fadeOutTimer.update()
		if ended {
			self.fadeOutTimer = nil
			stop()
		}
	}

	public func play(song: SongName) {
		stop()

		if let newSong = Self.songs[song] {
			currentSong = newSong

			volume = GameSettings.musicVolumePercent
			
			newSong.player.play(
				fromStep: newSong.playFromStep,
				loopStartStep: newSong.loopStartStep,
				loopEndStep: newSong.loopEndStep,
			)
		}
	}

	public func playUnlessActive(song: SongName) {
		guard let currentSong = currentSong else {
			play(song: song)
			return
		}

		if song == currentSong.name && currentSong.player.isPlaying {
			return
		}

		play(song: song)
	}

	public func stop() {
		if let def = currentSong {
			def.player.stop()
		}
	}

	public func fadeOut(duration: Float) {
		if fadeOutTimer != nil {
			return
		}

		fadeOutTimer = TimedCallback(duration: 0.3) {}
	}
}
