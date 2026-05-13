import BrewCoffee46Core
import SwiftUI

struct EditableMillItem: View {
    @Binding private var item: RawMill
    @Binding private var mode: EditMode

    @State private var isExpanded = true

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
                    TextField(item.name, text: $item.name, axis: .vertical)
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
                TextField(item.value, text: $item.value, axis: .vertical)
                    .disabled(!mode.isEditing)
                    .lineLimit(1...3)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 10)
                    .transition(.opacity)
            }
        }
        .millItemModifier()
    }
}
