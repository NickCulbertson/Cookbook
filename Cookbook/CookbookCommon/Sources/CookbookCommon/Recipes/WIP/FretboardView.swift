import Fretboard
import SwiftUI
import Tonic

struct FretboardView: View {
    @State var playedFrets: [Int?] = [nil, 5, 7, 7, 5, nil]
    @State var bends: [Double] = [0, 0, 0, 0, 0, 0]
    @State var bassMode = false
    @State var selectedKey: Key = .C

    var body: some View {
        VStack(spacing: 20) {
            Text("Fretboard Demo")
                .font(.largeTitle)

            Fretboard(
                playedFrets: playedFrets,
                bends: bends,
                bassMode: bassMode,
                noteKey: selectedKey
            )
            .frame(height: 150)
            .padding(.horizontal)

            Toggle("Bass Mode", isOn: $bassMode)
                .frame(width: 200)

            HStack {
                Text("Example Chords:")
                Button("Am") {
                    playedFrets = [0, 1, 2, 2, 0, nil]
                    bends = Array(repeating: 0, count: 6)
                }
                Button("C") {
                    playedFrets = [0, 1, 0, 2, 3, nil]
                    bends = Array(repeating: 0, count: 6)
                }
                Button("G") {
                    playedFrets = [3, 0, 0, 0, 2, 3]
                    bends = Array(repeating: 0, count: 6)
                }
                Button("Clear") {
                    playedFrets = Array(repeating: nil, count: 6)
                    bends = Array(repeating: 0, count: 6)
                }
            }
        }
        .padding()
        .navigationTitle("Fretboard Demo")
    }
}
