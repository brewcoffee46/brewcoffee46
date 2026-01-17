import BrewCoffee46Core
import SwiftUI

struct EditableMillItem: View {
    @Binding private var item: RawMill
    @Binding private var mode: EditMode

    @State private var isExpanded = true
    // If we don't use `tmpItem`, `TextField` will edit `item` directory.
    // It causes to re-render `TextField` so the editing will be suspended.
    @State private var tmpItem: RawMill = RawMill.defaultValue

    init(
        item: Binding<RawMill>,
        mode: Binding<EditMode>
    ) {
        self._item = item
        self._mode = mode
    }

    public var body: some View {
        VStack(alignment: .leading) {
            Button(action: {
                isExpanded.toggle()
            }) {
                HStack {
                    TextField(item.name, text: $tmpItem.name, axis: .vertical)
                        .disabled(!mode.isEditing)
                        .lineLimit(1)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Spacer()

                    if isExpanded {
                        Image(systemName: "chevron.up").foregroundColor(.gray)
                    } else {
                        Image(systemName: "chevron.down").foregroundColor(.gray)
                    }
                }
                .padding(.vertical)
            }
            .border(.primary, width: 0)

            if isExpanded {
                TextField(item.value, text: $tmpItem.value, axis: .vertical)
                    .disabled(!mode.isEditing)
                    .lineLimit(1...3)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 10)
                    .transition(.opacity)
            }
        }
        .millItemModifier()
        .onChange(of: mode) { oldValue, newValue in
            if mode.isEditing {
                tmpItem = item
            } else {
                item = tmpItem
            }
        }
        .onAppear {
            if tmpItem != item {
                tmpItem = item
            }
        }
    }
}
