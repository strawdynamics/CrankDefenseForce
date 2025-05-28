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
	
	public class TrackProps {
		var attack: Float = 0
		var decay: Float = 0
		var instrument: Instrument = .wave(.sine)
		var isMuted: Bool = false
		var isSolo: Bool = false
		var notes: [Int] = []
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
				let key = keyC.map(String.init(cString:))
			else { return }
			
			switch (key, type) {
			case ("instrument", .table):
				ctx.isDecodingInstrument = true
				ctx.currentInstrument = InstrumentData()
				
			case ("notes", .array):
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
			
			let key = String(cString: keyC)
			
			let ctx = Unmanaged<Context>
				.fromOpaque(ctxPtr)
				.takeUnretainedValue()
			
			if ctx.isDecodingInstrument {
				let instr = ctx.currentInstrument
				
				if key == "id" {
					switch JsonValueType(rawValue: val.type) {
					case .integer:
						instr.idInt = Int(val.data.intval)
					case .string:
						instr.idStr = String(cString: val.data.stringval)
					default:
						break
					}
					
				} else if key == "name" {
					instr.name = String(cString: val.data.stringval)
				}
				
			} else if let track = ctx.currentTrack {
				switch (key) {
				case "attack":
					track.attack = val.data.floatval
					
				case "decay":
					track.decay = val.data.floatval
					
				case "isMuted":
					track.isMuted = (JsonValueType(rawValue: val.type)! == .trueValue)
					
				case "isSolo":
					track.isSolo = (JsonValueType(rawValue: val.type)! == .trueValue)
					
				case "polyphony":
					track.polyphony = Int(val.data.intval)
					
				case "release":
					track.release = val.data.floatval
					
				case "sustain":
					track.sustain = val.data.floatval
					
				case "volume":
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
				let path = String(cString: cPath)
				if path.hasSuffix(".notes") {
					track.notes.append(Int(val.data.intval))
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
	}
	
	let songPath: String
	
	let trackProps: [TrackProps]
	
	let sequence: Sound.Sequence
	
	public init(songPath: String) {
		self.songPath = songPath
		
		trackProps = TrackProps.load(songPath: songPath)
		sequence = Midi.loadMidi(songPath: songPath, trackPropsCount: trackProps.count)
	}
}
