import AudioKit
import AVFoundation
import SwiftUI

struct CombFilterReverbData {
    var reverbDuration: AUValue = 1.0
    var loopDuration: AUValue = 0.1
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class CombFilterReverbConductor: ObservableObject, ProcessesPlayerInput {

    let engine = AKEngine()
    let player = AKPlayer()
    let filter: AKCombFilterReverb
    let dryWetMixer: AKDryWetMixer
    let playerPlot: AKNodeOutputPlot
    let filterPlot: AKNodeOutputPlot
    let mixPlot: AKNodeOutputPlot
    let buffer: AVAudioPCMBuffer

    init() {
        let url = Bundle.main.resourceURL?.appendingPathComponent("Samples/beat.aiff")
        let file = try! AVAudioFile(forReading: url!)
        buffer = try! AVAudioPCMBuffer(file: file)!

        filter = AKCombFilterReverb(player)
        dryWetMixer = AKDryWetMixer(player, filter)
        playerPlot = AKNodeOutputPlot(player)
        filterPlot = AKNodeOutputPlot(filter)
        mixPlot = AKNodeOutputPlot(dryWetMixer)
        engine.output = dryWetMixer

        playerPlot.plotType = .rolling
        playerPlot.shouldFill = true
        playerPlot.shouldMirror = true
        playerPlot.setRollingHistoryLength(128)
        filterPlot.plotType = .rolling
        filterPlot.color = .blue
        filterPlot.shouldFill = true
        filterPlot.shouldMirror = true
        filterPlot.setRollingHistoryLength(128)
        mixPlot.color = .purple
        mixPlot.shouldFill = true
        mixPlot.shouldMirror = true
        mixPlot.plotType = .rolling
        mixPlot.setRollingHistoryLength(128)
    }

    @Published var data = CombFilterReverbData() {
        didSet {
            filter.$reverbDuration.ramp(to: data.reverbDuration, duration: data.rampDuration)
//            filter.$loopDuration.ramp(to: data.loopDuration, duration: data.rampDuration)
            dryWetMixer.balance = data.balance
        }
    }

    func start() {
        playerPlot.start()
        filterPlot.start()
        mixPlot.start()

        do {
            try engine.start()
            // player stuff has to be done after start
            player.scheduleBuffer(buffer, at: nil, options: .loops)
        } catch let err {
            AKLog(err)
        }
    }

    func stop() {
        engine.stop()
    }
}

struct CombFilterReverbView: View {
    @ObservedObject var conductor = CombFilterReverbConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Reverb Duration (Seconds)",
                            parameter: self.$conductor.data.reverbDuration,
                            range: 0.0...10.0,
                            units: "Seconds")
            ParameterSlider(text: "Loop Duration (Seconds)",
                            parameter: self.$conductor.data.loopDuration,
                            range: 0.0...1.0,
                            units: "Seconds")
            ParameterSlider(text: "Balance",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixPlotsView(dry: conductor.playerPlot, wet: conductor.filterPlot, mix: conductor.mixPlot)
        }
        .padding()
        .navigationBarTitle(Text("Comb Filter Reverb"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct CombFilterReverb_Previews: PreviewProvider {
    static var previews: some View {
        CombFilterReverbView()
    }
}