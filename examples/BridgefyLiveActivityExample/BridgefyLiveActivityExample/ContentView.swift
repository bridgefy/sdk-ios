import SwiftUI
import Playgrounds

struct ContentView: View {
    @StateObject private var vm = BridgefyViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SDK: \(vm.status)").font(.headline)
            Text("Live Activity: \(vm.liveActivityStatus)")
            Text("Peers conectados: \(vm.peers.count)")

            HStack {
                Button("Start") { vm.start() }
                Button("Stop") { vm.stop() }
            }.buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding()
    }
}
