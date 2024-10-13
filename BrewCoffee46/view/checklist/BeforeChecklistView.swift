import BrewCoffee46Core
import SwiftUI

struct BeforeChecklistView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    @EnvironmentObject var viewModel: CurrentConfigViewModel

    // We cannot get the number of `viewModel.currentConfig.beforeChecklist` on the initialization
    // so `checks` is initialized `checklistSizeLimit` false values for now.
    @State private var checks: [Bool] = (0..<Config.maxCheckListSize).map { _ in false }

    @State private var editingIndex: Int? = .none

    @State private var mode: EditMode = .inactive

    @State private var willMoveToStopwatch: Bool = false

    var body: some View {
        Form {
            Section(
                header: HStack {
                    Group {
                        if isAllChecked() {
                            Button(action: {
                                checks = checks.prefix(viewModel.currentConfig.beforeChecklist.count).map({ _ in false })
                            }) {
                                Text("before check list reset")
                            }
                        } else {
                            Button(action: {
                                checks = checks.prefix(viewModel.currentConfig.beforeChecklist.count).map({ _ in true })
                            }) {
                                Text("before check list check all")
                            }
                        }
                    }
                    .disabled(mode.isEditing)
                    Spacer()
                    // Maybe it's not necessary that the `disabled` constraint when the timer has been started...
                    EditButton()
                        .disabled(appEnvironment.isTimerStarted)
                }
            ) {
                ForEach(Array(viewModel.currentConfig.beforeChecklist.enumerated()), id: \.element) { i, item in
                    Group {
                        if !mode.isEditing {
                            Toggle(isOn: $checks[i]) {
                                Text("\(i + 1). \(item)")
                            }
                            .onChange(of: checks[i]) {
                                willMoveToStopwatch = isAllChecked()
                            }
                        } else {
                            HStack {
                                Text("\(i + 1).")
                                TextField(item, text: $viewModel.currentConfig.beforeChecklist[i])
                            }
                        }
                    }
                    .deleteDisabled(appEnvironment.isTimerStarted)
                    .moveDisabled(appEnvironment.isTimerStarted)
                }
                .onDelete(perform: { indexSet in
                    viewModel.currentConfig.beforeChecklist.remove(atOffsets: indexSet)
                    checks.remove(atOffsets: indexSet)
                    checks.append(false)
                })
                .onMove(perform: { src, dest in
                    viewModel.currentConfig.beforeChecklist.move(fromOffsets: src, toOffset: dest)
                    checks.move(fromOffsets: src, toOffset: dest)
                })
                HStack {
                    Spacer()
                    Button(action: {
                        if viewModel.currentConfig.beforeChecklist.count < Config.maxCheckListSize {
                            editingIndex = .some(viewModel.currentConfig.beforeChecklist.count)
                            viewModel.currentConfig.beforeChecklist.append("")
                        }
                    }) {
                        Image(systemName: "plus.circle")
                    }
                    .disabled(!mode.isEditing || viewModel.currentConfig.beforeChecklist.count >= Config.maxCheckListSize)
                    Spacer()
                }
            }
        }
        .onChange(of: appEnvironment.isTimerStarted) { oldValue, newValue in
            // The checklist will be reset when the timer is reset.
            if oldValue == true && newValue == false {
                checks = (0..<Config.maxCheckListSize).map { _ in false }
            }
        }
        .environment(\.editMode, $mode)
        .navigationTitle("navigation title before checklist")
        .navigation(path: $appEnvironment.beforeChecklistPath)
        .sheet(isPresented: $willMoveToStopwatch) {
            Button(action: {
                willMoveToStopwatch = false
                appEnvironment.selectedTab = Route.stopwatch
            }) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.green)
                    Text("before check list go to stopwatch")
                        .font(.system(size: 30))
                }
            }
            .presentationDetents([
                .medium,
                .fraction(0.3),
            ])
        }
    }

    private func isAllChecked() -> Bool {
        checks.prefix(viewModel.currentConfig.beforeChecklist.count).allSatisfy({ $0 })
    }
}

#if DEBUG
    let epochTimeMillis: UInt64 = 1_723_792_539_843

    struct BeforeChecklistView_Previews: PreviewProvider {
        @State static var currentConfig = CurrentConfigViewModel.init(
            Config.init(
                coffeeBeansWeight: 20,
                partitionsCountOf6: 3,
                waterToCoffeeBeansWeightRatio: 16,
                firstWaterPercent: 0.5,
                totalTimeSec: 210,
                steamingTimeSec: 45,
                note: "note",
                beforeChecklist: ["aaaa", "bbb"],
                editedAtMilliSec: epochTimeMillis
            )
        )

        static var previews: some View {
            BeforeChecklistView()
                .environmentObject(AppEnvironment.init())
                .environmentObject(currentConfig)
        }
    }
#endif
