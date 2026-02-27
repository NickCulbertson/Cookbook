import SwiftUI
import Tablature

struct MIDISettingsView: View {
    @ObservedObject var midiController: MIDIController
    @Binding var instrument: StringInstrument
    @Binding var timeWindow: Double
    var onReset: () -> Void

    private static let instruments: [StringInstrument] = [
        .guitar, .guitar7String, .guitarDropD,
        .bass, .bass5String, .ukulele, .banjo,
    ]

    var body: some View {
        HStack(spacing: 16) {
            Picker("Instrument", selection: $instrument) {
                ForEach(Self.instruments) { preset in
                    Text(preset.name).tag(preset)
                }
            }
            .frame(maxWidth: 200)

            Picker("Channels", selection: $midiController.channelMapPreset) {
                ForEach(MIDIController.ChannelMapPreset.allCases) { preset in
                    Text(preset.rawValue).tag(preset)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 200)

            HStack(spacing: 4) {
                Text("Window:")
                Slider(value: $timeWindow, in: 2...15, step: 1)
                    .frame(maxWidth: 120)
                    .accessibilityLabel("Time window")
                    .accessibilityValue("\(Int(timeWindow)) seconds")
                Text("\(Int(timeWindow))s")
                    .monospacedDigit()
                    .frame(width: 28, alignment: .trailing)
            }

            Button("Reset", action: onReset)
        }
    }
}
