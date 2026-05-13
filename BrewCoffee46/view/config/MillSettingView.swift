import SwiftUI
import TipKit

@MainActor
struct MillSettingView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    @EnvironmentObject var viewModel: CurrentConfigViewModel

    @Binding private var mills: [RawMill]
    @Binding private var showMillEditSheet: Bool

    @State private var millEditMode: EditMode = .inactive

    // If we don't use `tmpMills`, `TextField` will edit `mills` directory.
    // It causes to re-render `TextField` so the editing will be suspended.
    @State private var tmpMills: [RawMill]

    init(
        mills: Binding<[RawMill]>,
        showMillEditSheet: Binding<Bool>
    ) {
        self._mills = mills
        self._showMillEditSheet = showMillEditSheet
        self.tmpMills = mills.wrappedValue
    }

    var body: some View {
        VStack {
            Spacer()
            Spacer()
            HStack {
                Spacer()
                Text("config mill settings sheet title")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            List {
                HStack {
                    Spacer()
                    // In List view, Button's touch area is whole of HStack
                    // so when push EditButton also push Button simultaneously.
                    // To avoid that these button is set .buttonStyle(.bordered).
                    TipView(MillEditTip(), arrowEdge: .trailing)
                    EditButton()
                        .buttonStyle(.bordered)
                        .disabled(appEnvironment.isTimerStarted)
                }
                .listRowSeparator(.hidden)

                TipView(MillItemTip(), arrowEdge: .bottom)
                ForEach($tmpMills) { item in
                    EditableMillItem(item: item, mode: $millEditMode)
                        .deleteDisabled(disableMoveAndDelete())
                        .moveDisabled(disableMoveAndDelete())
                }
                .onDelete(perform: { indexSet in
                    tmpMills.remove(atOffsets: indexSet)
                })
                .onMove(perform: { src, dest in
                    tmpMills.move(fromOffsets: src, toOffset: dest)
                })

                HStack {
                    Spacer()
                    Button(action: {
                        tmpMills.append(RawMill.defaultValue())
                    }) {
                        Image(systemName: "plus.circle")
                    }
                    .buttonStyle(.bordered)
                    .disabled(!millEditMode.isEditing)
                    Spacer()
                }
            }
            .environment(\.editMode, $millEditMode)
            .onChange(of: millEditMode) { _, newValue in
                if newValue.isEditing {
                    tmpMills = mills
                } else {
                    mills = tmpMills
                }
            }

            Button(action: {
                showMillEditSheet.toggle()
            }) {
                Text("Close")
            }
            .buttonStyle(.borderless)
            .disabled(millEditMode.isEditing)
        }
        .interactiveDismissDisabled(millEditMode.isEditing)
    }

    func disableMoveAndDelete() -> Bool {
        return appEnvironment.isTimerStarted || !millEditMode.isEditing
    }
}

#if DEBUG
    struct MillSettingView_Previews: PreviewProvider {
        @State static var showMillEditSheet: Bool = false
        @State static var mills: [RawMill] = [RawMill.defaultValue()]

        static var previews: some View {
            Text("Background")
                .sheet(isPresented: .constant(true)) {
                    MillSettingView(mills: $mills, showMillEditSheet: $showMillEditSheet)
                        .environment(\.locale, .init(identifier: "ja"))
                        .environmentObject(CurrentConfigViewModel.init())
                        .environmentObject(AppEnvironment.init())
                }
        }
    }
#endif
