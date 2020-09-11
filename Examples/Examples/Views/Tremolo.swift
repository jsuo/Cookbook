import AudioKit
import AVFoundation
import SwiftUI

struct TremoloData {
    var frequency: AUValue = 10.0
    var depth: AUValue = 1.0
    var rampDuration: AUValue = 0.02
    var balance: AUValue = 0.5
}

class TremoloConductor: ObservableObject, ProcessesPlayerInput {

    let engine = AKEngine()
    let player = AKPlayer()
    let tremolo: AKTremolo
    let dryWetMixer: AKDryWetMixer
    let playerPlot: AKNodeOutputPlot
    let tremoloPlot: AKNodeOutputPlot
    let mixPlot: AKNodeOutputPlot
    let buffer: AVAudioPCMBuffer

    init() {
        let url = Bundle.main.resourceURL?.appendingPathComponent("Samples/beat.aiff")
        let file = try! AVAudioFile(forReading: url!)
        buffer = try! AVAudioPCMBuffer(file: file)!

        tremolo = AKTremolo(player)
        dryWetMixer = AKDryWetMixer(player, tremolo)
        playerPlot = AKNodeOutputPlot(player)
        tremoloPlot = AKNodeOutputPlot(tremolo)
        mixPlot = AKNodeOutputPlot(dryWetMixer)
        engine.output = dryWetMixer

        playerPlot.plotType = .rolling
        playerPlot.shouldFill = true
        playerPlot.shouldMirror = true
        playerPlot.setRollingHistoryLength(128)
        tremoloPlot.plotType = .rolling
        tremoloPlot.color = .blue
        tremoloPlot.shouldFill = true
        tremoloPlot.shouldMirror = true
        tremoloPlot.setRollingHistoryLength(128)
        mixPlot.color = .purple
        mixPlot.shouldFill = true
        mixPlot.shouldMirror = true
        mixPlot.plotType = .rolling
        mixPlot.setRollingHistoryLength(128)
    }

    @Published var data = TremoloData() {
        didSet {
            tremolo.$frequency.ramp(to: data.frequency, duration: data.rampDuration)
            tremolo.$depth.ramp(to: data.depth, duration: data.rampDuration)
            dryWetMixer.balance = data.balance
        }
    }

    func start() {
        playerPlot.start()
        tremoloPlot.start()
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

struct TremoloView: View {
    @ObservedObject var conductor = TremoloConductor()

    var body: some View {
        ScrollView {
            PlayerControls(conductor: conductor)
            ParameterSlider(text: "Frequency (Hz)",
                            parameter: self.$conductor.data.frequency,
                            range: 0.0...100.0,
                            units: "Hertz")
            ParameterSlider(text: "Depth",
                            parameter: self.$conductor.data.depth,
                            range: 0.0...1.0,
                            units: "Generic")
            ParameterSlider(text: "Balance",
                            parameter: self.$conductor.data.balance,
                            range: 0...1,
                            units: "%")
            DryWetMixPlotsView(dry: conductor.playerPlot, wet: conductor.tremoloPlot, mix: conductor.mixPlot)
        }
        .padding()
        .navigationBarTitle(Text("Tremolo"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct Tremolo_Previews: PreviewProvider {
    static var previews: some View {
        TremoloView()
    }
}
