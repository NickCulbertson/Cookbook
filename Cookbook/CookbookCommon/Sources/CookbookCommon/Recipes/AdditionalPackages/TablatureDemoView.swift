import Tablature
import SwiftUI

struct TablatureDemoView: View {
    @StateObject private var midiController = MIDIController()
    @StateObject private var liveModel = LiveTablatureModel(instrument: .guitar)
    @State private var isPlaying = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // MARK: - Live Tablature (MIDI)
                Text("Live Tablature")
                    .font(.headline)
                LiveTablatureView(model: liveModel)
                    .frame(height: 140)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)

                MIDISettingsView(
                    midiController: midiController,
                    instrument: $midiController.instrument,
                    timeWindow: $liveModel.timeWindow,
                    onReset: {
                        isPlaying = false
                        liveModel.reset()
                    }
                )

                HStack {
                    Button(isPlaying ? "Stop Simulation" : "Simulate Input") {
                        isPlaying.toggle()
                        if isPlaying {
                            liveModel.reset()
                            startSimulatedInput()
                        }
                    }
                    Text("or connect a MIDI guitar")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }

                Divider()

                // MARK: - Static Examples
                Text("Smoke on the Water")
                    .font(.headline)
                TablatureView(sequence: .smokeOnTheWater)

                Text("C Major Scale")
                    .font(.headline)
                TablatureView(sequence: .cMajorScale)

                Text("E Minor Chord")
                    .font(.headline)
                TablatureView(sequence: .eMinorChord)

                Text("Blues Lick (Articulations)")
                    .font(.headline)
                TablatureView(sequence: .bluesLick)

                Text("Custom Styled")
                    .font(.headline)
                TablatureView(sequence: .smokeOnTheWater)
                    .tablatureStyle(TablatureStyle(
                        stringSpacing: 24,
                        measureWidth: 400,
                        lineThickness: 2,
                        fretColor: .blue,
                        lineColor: .gray
                    ))
            }
            .padding()
        }
        .onAppear {
            midiController.noteHandler = { [weak liveModel] string, fret, articulation in
                liveModel?.addNote(string: string, fret: fret, articulation: articulation)
            }
        }
        .navigationTitle("Tablature Demo")
    }

    private func startSimulatedInput() {
        let pattern: [(string: Int, fret: Int)] = [
            (0, 0), (0, 3), (1, 0), (1, 2), (2, 0), (2, 2),
            (3, 0), (3, 2), (4, 0), (4, 3), (5, 0), (5, 3),
        ]
        var index = 0

        Timer.scheduledTimer(withTimeInterval: 0.35, repeats: true) { timer in
            guard isPlaying else {
                timer.invalidate()
                return
            }
            let entry = pattern[index % pattern.count]
            liveModel.addNote(string: entry.string, fret: entry.fret)
            index += 1
        }
    }
}
