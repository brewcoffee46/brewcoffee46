import Foundation
import SwiftUI

final class WatchKitAppEnvironment: ObservableObject {
    @Published var rootPath: [Route] = []
    @Published var isTimerStarted: Bool = false
}
