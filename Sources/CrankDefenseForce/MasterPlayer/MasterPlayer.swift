import PlaydateKit

public class MasterPlayer {
	enum Instrument: CustomStringConvertible {
		case wave(SoundWaveform)
		case sample(String)
		
		var description: String {
			switch self {
			case .sample(let name):
				return "sample(\(name))"
			case .wave(let waveform):
				return "wave(\(waveform))"
			}
		}
	}
	
	private class InstrumentData {
		var idInt: Int?
		var idStr: String?
		var name: String?
	}
	
	class SynthInstrument {
		static nonisolated(unsafe) var instruments: [String.UTF8View: SynthInstrument] = [:]
		
		struct NoteProps {
			let path: String
			var noteStart: MIDINote?
			var noteEnd: MIDINote?
			var noteRoot: MIDINote?
		}
		
		let id: String
		
		let notes: [MIDINote: NoteProps]
		
		private init(id: String, notes: [MIDINote: NoteProps]) {
			self.id = id
			self.notes = notes
		}
		
		@discardableResult static func add(id: String, notes: [MIDINote: NoteProps]) -> SynthInstrument {
			let inst = SynthInstrument(id: id, notes: notes)
			
			Self.instruments[id.utf8] = inst
			
			return inst
		}
	}
	
	public class TrackProps {
		var attack: Float = 0
		var decay: Float = 0
		var instrument: Instrument = .wave(.sine)
		var isMuted: Bool = false
		var isSolo: Bool = false
		var notes: [MIDINote] = []
		var polyphony: Int = 0
		var release: Float = 0
		var sustain: Float = 0
		var volume: Float = 0
		
		private class Context {
			var tracks = [TrackProps]()
			var currentTrack: TrackProps?
			var isDecodingInstrument = false
			var isDecodingNotes = false
			var currentInstrument = InstrumentData()
		}
		
		static func load(songPath: String) -> [TrackProps] {
			let jsonSongPath = "\(songPath).json"
			guard let stat = try? File.stat(path: jsonSongPath) else {
				System.error("[TrackProps] Missing file")
				return []
			}
			
			let file = try! File.open(path: jsonSongPath, mode: File.Options.read)
			
			let fileBuffer = UnsafeMutableRawPointer.allocate(byteCount: Int(stat.size), alignment: 1)
			
			let bytesRead = try! file.read(buffer: fileBuffer, length: stat.size)
			
			let uint8Buffer = UnsafeBufferPointer<UInt8>(start: fileBuffer.assumingMemoryBound(to: UInt8.self), count: bytesRead)
			let jsonString = String(decoding: uint8Buffer, as: Unicode.UTF8.self)
			
			var decoder = JSON.Decoder()
			let ctx = Context()
			decoder.userdata = Unmanaged.passRetained(ctx).toOpaque()
			decoder.decodeError = decodeError
			decoder.shouldDecodeArrayValueAtIndex = shouldDecodeArrayValue
			decoder.willDecodeSublist = willDecodeSublist
			decoder.didDecodeTableValue = didDecodeTableValue
			decoder.didDecodeArrayValue = didDecodeArrayValue
			decoder.didDecodeSublist = didDecodeSublist
			
			var value = JSON.Value()
			
			_ = JSON.decodeString(using: &decoder, jsonString: jsonString, value: &value)
			
			Unmanaged<Context>.fromOpaque(decoder.userdata!).release()
			fileBuffer.deallocate()
			
			return ctx.tracks
		}
		
		static nonisolated(unsafe) var decodeError: @convention(c)
		(UnsafeMutablePointer<json_decoder>?, UnsafePointer<CChar>?, Int32) -> Void
		= { _, err, line in
			if let e = err.map({ String(cString: $0) }) {
				print("JSON error at \(line): \(e)")
			}
		}

		static nonisolated(unsafe) var shouldDecodeArrayValue: @convention(c)
		(UnsafeMutablePointer<json_decoder>?, Int32) -> Int32
		= { ptr, _ in
			guard let dptr = ptr,
				  let ctxPtr = dptr.pointee.userdata
			else { return 0 }
			let ctx = Unmanaged<Context>.fromOpaque(ctxPtr).takeUnretainedValue()
			
			if !ctx.isDecodingNotes {
				let t = TrackProps()
				ctx.tracks.append(t)
				ctx.currentTrack = t
			}
			
			return 1
		}

		static nonisolated(unsafe) var willDecodeSublist: @convention(c)
		(UnsafeMutablePointer<json_decoder>?, UnsafePointer<CChar>?, json_value_type) -> Void
		= { ptr, keyC, type in
			guard
				let dptr = ptr,
				let ctx = dptr.pointee.userdata
					.flatMap({ Unmanaged<Context>.fromOpaque($0).takeUnretainedValue() }),
				let key = keyC.map(String.init(cString:))?.utf8
			else { return }
			
			switch (key, type) {
			case ("instrument".utf8, .table):
				ctx.isDecodingInstrument = true
				ctx.currentInstrument = InstrumentData()
				
			case ("notes".utf8, .array):
				ctx.isDecodingNotes = true
				
			default:
				break
			}
		}

		static nonisolated(unsafe) var didDecodeTableValue: @convention(c)
		(UnsafeMutablePointer<json_decoder>?, UnsafePointer<CChar>?, json_value) -> Void
		= { ptr, keyC, val in
			guard
				let dptr = ptr,
				let keyC = keyC,
				let ctxPtr = dptr.pointee.userdata
			else { return }
			
			let key = String(cString: keyC).utf8
			
			let ctx = Unmanaged<Context>
				.fromOpaque(ctxPtr)
				.takeUnretainedValue()
			
			if ctx.isDecodingInstrument {
				let instr = ctx.currentInstrument
				
				if key == "id".utf8 {
					switch JsonValueType(rawValue: val.type) {
					case .integer:
						instr.idInt = Int(val.data.intval)
					case .string:
						instr.idStr = String(cString: val.data.stringval)
					default:
						break
					}
					
				} else if key == "name".utf8 {
					instr.name = String(cString: val.data.stringval)
				}
				
			} else if let track = ctx.currentTrack {
				switch (key) {
				case "attack".utf8:
					track.attack = val.data.floatval
					
				case "decay".utf8:
					track.decay = val.data.floatval
					
				case "isMuted".utf8:
					track.isMuted = (JsonValueType(rawValue: val.type)! == .trueValue)
					
				case "isSolo".utf8:
					track.isSolo = (JsonValueType(rawValue: val.type)! == .trueValue)
					
				case "polyphony".utf8:
					track.polyphony = Int(val.data.intval)
					
				case "release".utf8:
					track.release = val.data.floatval
					
				case "sustain".utf8:
					track.sustain = val.data.floatval
					
				case "volume".utf8:
					track.volume = val.data.floatval
					
				// “notes” is handled in didDecodeArrayValue
				default:
					break
				}
			}
		}

		static nonisolated(unsafe) var didDecodeArrayValue: @convention(c)
		(UnsafeMutablePointer<json_decoder>?, Int32, json_value) -> Void
		= { ptr, _, val in
			guard let dptr = ptr else { return }
			let ctx = Unmanaged<Context>
				.fromOpaque(dptr.pointee.userdata!)
				.takeUnretainedValue()
			guard let track = ctx.currentTrack else { return }
			if let cPath = dptr.pointee.path {
				let path = String(cString: cPath).utf8
				if path.hasSuffix(".notes") {
					track.notes.append(MIDINote(val.data.intval))
				}
			}
		}

		static nonisolated(unsafe) var didDecodeSublist: @convention(c)
		(UnsafeMutablePointer<json_decoder>?, UnsafePointer<CChar>?, json_value_type)
		-> UnsafeMutableRawPointer?
		= { ptr, _, type in
			guard let dptr = ptr,
				  let ctxPtr = dptr.pointee.userdata
			else { return nil }
			
			let ctx = Unmanaged<Context>
				.fromOpaque(ctxPtr)
				.takeUnretainedValue()
			
			switch type {
			case .table where ctx.isDecodingInstrument:
				if let track = ctx.currentTrack {
					let instr = ctx.currentInstrument
					if let idInt = instr.idInt {
						track.instrument = .wave(SoundWaveform(rawValue: SoundWaveform.RawValue(idInt))!)
					} else if let idStr = instr.idStr {
						track.instrument = .sample(idStr)
					}
				}
				ctx.isDecodingInstrument = false
				
			case .array where ctx.isDecodingNotes:
				ctx.isDecodingNotes = false
				
			default:
				break
			}
			
			return ctxPtr
		}
	}
	
	public enum SampleCache {
		private static nonisolated(unsafe) var cache: [String.UTF8View: Sound.Sample] = [:]
		
		static func getOrLoad(_ samplePath: String) -> Sound.Sample {
			if cache[samplePath.utf8] != nil {
				return cache[samplePath.utf8]!
			}
			
			let sample = Sound.Sample(path: samplePath)!
			cache[samplePath.utf8] = sample
			
			return sample
		}
	}
	
	public enum Midi {
		static func loadMidi(songPath: String, trackPropsCount: Int) -> Sound.Sequence {
			let seq = Sound.Sequence()
			let loaded = seq.loadMIDIFile(path: songPath)
			
			if !loaded {
				System.error("[Midi] Load error")
			}
			
			let seqTrackCount = seq.trackCount
			
			print("[Midi] Loaded \(seqTrackCount) tracks from \(songPath)")
			
			if seqTrackCount == 0 {
				do {
					_ = try File.stat(path: songPath)
					
					System.error("[Midi] No tracks")
				} catch {
					System.error("[Midi] File missing")
				}
			}
			
			if seqTrackCount != trackPropsCount {
				System.error("[Midi] Incorrect track count")
			}
			
			return seq
		}
		
		private static func createWaveInstrument(_ trackProps: TrackProps) -> Sound.Instrument {
			let inst = Sound.Instrument()
			guard case let .wave(waveform) = trackProps.instrument else {
				System.error("[Midi] Invalid instrument")
				return inst
			}
			
			for _ in 0..<trackProps.polyphony {
				let synth = Sound.Synth()
				synth.setWaveform(waveform)
				synth.volume = (trackProps.volume, trackProps.volume)
				synth.setAttackTime(trackProps.attack)
				synth.setDecayTime(trackProps.decay)
				synth.setSustainLevel(trackProps.sustain)
				synth.setReleaseTime(trackProps.release)
				
				_ = inst.addVoice(synth: synth, rangeStart: MIDINote(trackProps.notes.first!), rangeEnd: MIDINote(trackProps.notes.last!))
			}
			
			return inst
		}
		
		private static func createSampleSynth(samplePath: String, trackProps: TrackProps) -> Sound.Synth {
			let synth = Sound.Synth()
			let sample = SampleCache.getOrLoad(samplePath)
			
			synth.setSample(sample)
			synth.volume = (trackProps.volume, trackProps.volume)
			synth.setAttackTime(trackProps.attack)
			synth.setDecayTime(trackProps.decay)
			synth.setSustainLevel(trackProps.sustain)
			synth.setReleaseTime(trackProps.release)
			
			return synth
		}
		
		private static func createSampleInstrument(_ trackProps: TrackProps) -> Sound.Instrument {
			let inst = Sound.Instrument()
			guard case let .sample(instrumentId) = trackProps.instrument else {
				System.error("[Midi] Invalid instrument")
				return inst
			}
			
			guard let synthInst = SynthInstrument.instruments[instrumentId.utf8] else {
				System.error("[Midi] Synth instrument \(instrumentId) not registered. Call `MasterPlayer.SynthInstrument.add`")
				return inst
			}
			
			trackProps.notes.forEach { note in
				guard let noteProps = synthInst.notes[note] else {
					System.error("[Midi] Note \(note) not found in instrument \(instrumentId)")
					return
				}
				
				let noteStart = noteProps.noteStart ?? note
				let noteEnd = noteProps.noteEnd ?? noteStart
				let noteRoot = noteProps.noteRoot ?? noteStart
				let offset = noteRoot - noteStart
				let transpose = Float(NOTE_C4) - noteStart - offset
				
				let synth = Self.createSampleSynth(samplePath: noteProps.path, trackProps: trackProps)
				
				_ = inst.addVoice(synth: synth, rangeStart: noteStart, rangeEnd: noteEnd, transpose: transpose)
			}
			
			return inst
		}
		
		static func createInstrument(_ trackProps: TrackProps) -> Sound.Instrument {
			let inst: Sound.Instrument
			switch trackProps.instrument {
			case .wave:
				inst = createWaveInstrument(trackProps)
			case .sample:
				inst = createSampleInstrument(trackProps)
			}
			
			// https://discord.com/channels/675983554655551509/1217244550666518589/1377598500400922686
			_ = Sound.defaultChannel.addSource(inst)
			
			return inst
		}
	}
	
	let songPath: String
	
	let trackProps: [TrackProps]
	
	let sequence: Sound.Sequence
	
	var volume: Float = 1.0 {
		didSet {
			zip(trackProps, sequence.tracks).forEach { props, track in
				let effectiveVolume = volume * props.volume
				track.instrument!.volume = (effectiveVolume, effectiveVolume)
			}
		}
	}
	
	public init(songPath: String) {
		self.songPath = songPath
		
		trackProps = TrackProps.load(songPath: songPath)
		sequence = Midi.loadMidi(songPath: songPath, trackPropsCount: trackProps.count)

		var i = 0
		for trackProps in self.trackProps {
			let instrument = Midi.createInstrument(trackProps)
			sequence.tracks[i].instrument = instrument
			
			i += 1
		}
	}
	
	public func play() {
		sequence.setLoops(startStep: 0, endStep: sequence.length)
		sequence.play()
	}
	
	public func stop() {
		sequence.stop()
	}
}
