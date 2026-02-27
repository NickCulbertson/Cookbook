import Foundation
import MIDIKit
import Tablature

class MIDIController: ObservableObject {
    let midiManager = MIDIManager(
        clientName: "TablatureDemoMIDIManager",
        model: "TablatureDemo",
        manufacturer: "AudioKit"
    )

    enum ChannelMapPreset: String, CaseIterable, Identifiable {
        case channels1to6 = "Ch 1–6"
        case channels11to16 = "Ch 11–16"

        var id: String { rawValue }

        var mapping: [UInt4: Int] {
            switch self {
            case .channels1to6:
                return [0: 5, 1: 4, 2: 3, 3: 2, 4: 1, 5: 0]
            case .channels11to16:
                return [10: 5, 11: 4, 12: 3, 13: 2, 14: 1, 15: 0]
            }
        }
    }

    @Published var channelMapPreset: ChannelMapPreset = .channels1to6 {
        didSet { channelMap = channelMapPreset.mapping }
    }

    @Published var channelMap: [UInt4: Int]

    @Published var instrument: StringInstrument = .guitar

    /// Called on the main thread with (string, fret, articulation) after fret lookup.
    var noteHandler: ((Int, Int, Articulation?) -> Void)?

    /// Tracks the last note-on MIDI note per string for pitch bend context.
    private var lastMIDINote: [Int: UInt8] = [:]

    init() {
        channelMap = ChannelMapPreset.channels1to6.mapping

        do {
            setMIDINetworkSession(policy: .anyone)
            try midiManager.start()
            try midiManager.addInputConnection(
                to: .allOutputs,
                tag: "inputConnections",
                receiver: .events { [weak self] events, _, _ in
                    DispatchQueue.main.async { [weak self] in
                        self?.handleEvents(events)
                    }
                }
            )
        } catch {
            print("MIDI did not start. Error: \(error)")
        }
    }

    private func handleEvents(_ events: [MIDIEvent]) {
        for event in events {
            switch event {
            case .noteOn(let payload):
                guard payload.velocity.midi1Value > 0 else { continue }
                guard let stringIndex = channelMap[payload.channel] else { continue }
                let midiNote = payload.note.number.uInt8Value
                lastMIDINote[stringIndex] = midiNote
                if let fret = instrument.fret(for: midiNote, onString: stringIndex) {
                    noteHandler?(stringIndex, fret, nil)
                }

            case .pitchBend(let payload):
                guard let stringIndex = channelMap[payload.channel] else { continue }
                let centered = Int(payload.value.midi1Value) - 8192
                let semitones = Double(centered) / 8192.0 * 2.0
                if abs(semitones) > 1.0 {
                    guard let lastNote = lastMIDINote[stringIndex],
                          let fret = instrument.fret(for: lastNote, onString: stringIndex)
                    else { continue }
                    noteHandler?(stringIndex, fret, .pitchBendArrow)
                }

            default:
                break
            }
        }
    }
}
