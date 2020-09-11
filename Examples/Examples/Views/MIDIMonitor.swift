import AudioKit
import CoreMIDI
import Foundation
import SwiftUI

// struct represeting last data received of each type

struct MIDIMonitorData {
    var noteOn = 0
    var velocity = 0
    var noteOff = 0
    var channel = 0
    var afterTouch = 0
    var afterTouchNoteNumber = 0
    var programChange = 0
    var pitchWheelValue = 0
    var controllerNumber = 0
    var controllerValue = 0

}

class MIDIMonitorConductor: ObservableObject, AKMIDIListener {

    let midi = AKMIDI()
    @Published var data = MIDIMonitorData()

    init() {}

    func start() {
        midi.openInput(name: "Bluetooth")
        midi.openInput()
        midi.addListener(self)
    }

    func stop() {
        midi.closeAllInputs()
    }

    func receivedMIDINoteOn(noteNumber: MIDINoteNumber,
                            velocity: MIDIVelocity,
                            channel: MIDIChannel,
                            portID: MIDIUniqueID? = nil,
                            offset: MIDITimeStamp = 0) {
        print("note On \(noteNumber)")
        data.noteOn = Int(noteNumber)
        data.velocity = Int(velocity)
        data.channel = Int(channel)
    }

    func receivedMIDINoteOff(noteNumber: MIDINoteNumber,
                             velocity: MIDIVelocity,
                             channel: MIDIChannel,
                             portID: MIDIUniqueID? = nil,
                             offset: MIDITimeStamp = 0) {
        print("note Off \(noteNumber)")
        data.noteOff = Int(noteNumber)
        data.channel = Int(channel)
    }

    func receivedMIDIController(_ controller: MIDIByte,
                                value: MIDIByte,
                                channel: MIDIChannel,
                                portID: MIDIUniqueID? = nil,
                                offset: MIDITimeStamp = 0) {
        print("controller \(controller) \(value)")
        data.controllerNumber = Int(controller)
        data.controllerValue = Int(value)
        data.channel = Int(channel)
    }

    func receivedMIDIAftertouch(_ pressure: MIDIByte,
                                channel: MIDIChannel,
                                portID: MIDIUniqueID? = nil,
                                offset: MIDITimeStamp = 0) {
        print("received after touch")
        data.afterTouch = Int(pressure)
        data.channel = Int(channel)
    }

    func receivedMIDIAftertouch(noteNumber: MIDINoteNumber,
                                pressure: MIDIByte,
                                channel: MIDIChannel,
                                portID: MIDIUniqueID? = nil,
                                offset: MIDITimeStamp = 0) {
        print("recv'd after touch \(noteNumber)")
        data.afterTouchNoteNumber = Int(noteNumber)
        data.afterTouch = Int(pressure)
        data.channel = Int(channel)
    }

    func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord,
                                channel: MIDIChannel,
                                portID: MIDIUniqueID? = nil,
                                offset: MIDITimeStamp = 0) {
        print("midi wheel \(pitchWheelValue)")
        data.pitchWheelValue = Int(pitchWheelValue)
        data.channel = Int(channel)
    }

    func receivedMIDIProgramChange(_ program: MIDIByte,
                                   channel: MIDIChannel,
                                   portID: MIDIUniqueID? = nil,
                                   offset: MIDITimeStamp = 0) {
        print("PC")
        data.programChange = Int(program)
        data.channel = Int(channel)
    }

    func receivedMIDISystemCommand(_ data: [MIDIByte],
                                   portID: MIDIUniqueID? = nil,
                                   offset: MIDITimeStamp = 0) {
//        print("sysex")
    }

    func receivedMIDISetupChange() {
        // Do nothing
    }

    func receivedMIDIPropertyChange(propertyChangeInfo: MIDIObjectPropertyChangeNotification) {
        // Do nothing
    }

    func receivedMIDINotification(notification: MIDINotification) {
        // Do nothing
    }
}

struct MIDIMonitorView: View {
    @ObservedObject var conductor = MIDIMonitorConductor()

    var body: some View {
        HStack {
            VStack {
                HStack {
                    Text("Note On: \(conductor.data.noteOn == 0 ? "-" : "\(conductor.data.noteOn)")")
                    Text("Velocity: \(conductor.data.velocity)")
                }
                HStack {
                    Text("Note Off: \(conductor.data.noteOff == 0 ? "-" : "\(conductor.data.noteOff)")")
                    Text("Channel: \(conductor.data.channel)")
                }
                HStack {
                    Text("Controller: \(conductor.data.controllerNumber == 0 ? "-" : "\(conductor.data.controllerNumber)")")
                    Text("Value: \(conductor.data.controllerValue == 0 ? "-" : "\(conductor.data.controllerValue)")")
                }
            }
        }.navigationBarTitle(Text("MIDI Monitor"))
        .onAppear {
            self.conductor.start()
        }
        .onDisappear {
            self.conductor.stop()
        }
    }
}

struct MIDIMonitorView_Previews: PreviewProvider {
    static var previews: some View {
        MIDIMonitorView()
    }
}
