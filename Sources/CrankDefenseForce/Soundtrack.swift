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

	private var currentSong: SongDef?

	public func play(song: SongName) {
		stop()

		if let newSong = Self.songs[song] {
			currentSong = newSong
			newSong.player.play(
				fromStep: newSong.playFromStep,
				loopStartStep: newSong.loopStartStep,
				loopEndStep: newSong.loopEndStep,
			)
		}
	}

	public func playUnlessActive(song: SongName) {
		if song == currentSong?.name {
			return
		}

		play(song: song)
	}

	public func stop() {
		if let def = currentSong {
			def.player.stop()
		}
	}

	public func fadeOut() {
		// TODO: !!!
	}
}
