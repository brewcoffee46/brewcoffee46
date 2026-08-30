import BrewCoffee46Core
import FactoryKit
import Foundation
import SwiftUI

struct RequestReviewStateView: View {
    @EnvironmentObject private var appEnvironment: AppEnvironment
    @EnvironmentObject private var viewModel: CurrentConfigViewModel

    @State private var requestReviewState = RequestReviewState(info: .none, guardInfo: .none)

    @Injected(\.requestReviewService) private var requestReviewService

    private var requestHistory: [RequestReviewItem] {
        Array((requestReviewState.info?.requestHistory ?? []).reversed())
    }

    private func formattedRequestedDate(_ date: Date) -> String {
        let timeZone = TimeZone.current
        let abbreviation = timeZone.abbreviation(for: date) ?? timeZone.identifier
        return "\(date.formattedWithSec()) \(abbreviation) (\(timeZone.identifier))"
    }

    var body: some View {
        Form {
            Section(header: Text("request review state guard")) {
                LabeledContent(
                    "request review state try count",
                    value: requestReviewState.guardInfo.map { String($0.tryCount) } ?? String(localized: "request review state no record")
                )
            }

            Section(header: Text("request review state history")) {
                if requestHistory.isEmpty {
                    Text("request review state no record")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(Array(requestHistory.enumerated()), id: \.offset) { _, item in
                        VStack(alignment: .leading) {
                            LabeledContent("request review state build version", value: item.appVersion)
                            LabeledContent("request review state requested date", value: formattedRequestedDate(item.requestedDate))
                        }
                        .font(.footnote)
                    }
                }
            }
        }
        .navigation(
            path: $appEnvironment.configPath,
            title: "navigation title request review state"
        )
        .onAppear {
            let result = requestReviewService.loadState()
            result.forEach { requestReviewState = $0 }
            result.recoverWithErrorLog(&viewModel.errors)
        }
    }
}

#if DEBUG
    final class MockRequestReviewServiceImpl: RequestReviewService {
        func check() -> ResultNea<Bool, CoffeeError> {
            .success(false)
        }

        func loadState() -> ResultNea<RequestReviewState, CoffeeError> {
            .success(
                RequestReviewState(
                    info: RequestReviewInfo(
                        requestHistory: (0..<15).map { index in
                            RequestReviewItem(
                                appVersion: String(20_260_801_000_000 + index),
                                requestedDate: Date(timeIntervalSince1970: 1_754_000_000 + Double(index * 86_400))
                            )
                        }
                    ),
                    guardInfo: RequestReviewGuard(tryCount: 8)
                )
            )
        }
    }

    struct RequestReviewStateView_Previews: PreviewProvider {
        static var previews: some View {
            Container.shared.requestReviewService.preview {
                MockRequestReviewServiceImpl()
            }

            RequestReviewStateView()
                .environmentObject(CurrentConfigViewModel.init())
                .environmentObject(AppEnvironment.init())
                .previewDisplayName("Request review state")
        }
    }
#endif
