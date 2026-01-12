import SwiftUI

public struct MillListView: View {
    @Binding private var items: [Mill]

    public init(items: Binding<[Mill]>) {
        self._items = items
    }

    public var body: some View {
        if items.isEmpty {
            HStack {
                Spacer()
                Text("config mill setting empty")
            }
        } else {
            ScrollView {
                VStack {
                    ForEach(items, id: \.self) { item in
                        MillItem(item: item)
                    }
                }
            }
        }
    }
}

struct MillItem: View {
    let item: Mill
    @State private var isExpanded = false

    public var body: some View {
        VStack(alignment: .leading) {
            Button(action: {
                isExpanded.toggle()
            }) {
                HStack {
                    Text(item.name).foregroundColor(.primary)

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
                Text(item.value)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 10)
                    .transition(.opacity)
            }
        }
        .millItemModifier()
    }
}
