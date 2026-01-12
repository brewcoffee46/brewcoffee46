import SwiftUI
import TipKit

@MainActor
struct MillSettingView: View {
    @EnvironmentObject var appEnvironment: AppEnvironment
    @EnvironmentObject var viewModel: CurrentConfigViewModel

    @Binding private var mills: [RawMill]
    @Binding private var showMillEditSheet: Bool

    @State private var millEditMode: EditMode = .inactive

    init(
        mills: Binding<[RawMill]>,
        showMillEditSheet: Binding<Bool>
    ) {
        self._mills = mills
        self._showMillEditSheet = showMillEditSheet
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

                ForEach(Array(mills.enumerated()), id: \.self.element.id) { i, item in
                    VStack {
                        if i == 0 {
                            TipView(MillItemTip(), arrowEdge: .bottom)
                        }
                        EditableMillItem(item: $mills[i], mode: $millEditMode)
                            .deleteDisabled(disableMoveAndDelete())
                            .moveDisabled(disableMoveAndDelete())
                    }
                }
                .onDelete(perform: { indexSet in
                    mills.remove(atOffsets: indexSet)
                })
                .onMove(perform: { src, dest in
                    mills.move(fromOffsets: src, toOffset: dest)
                })

                HStack {
                    Spacer()
                    Button(action: {
                        mills.append(RawMill.defaultValue)
                    }) {
                        Image(systemName: "plus.circle")
                    }
                    .buttonStyle(.bordered)
                    .disabled(!millEditMode.isEditing)
                    Spacer()
                }
            }
            .environment(\.editMode, $millEditMode)

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
        @State static var mills: [RawMill] = [RawMill.defaultValue]

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
