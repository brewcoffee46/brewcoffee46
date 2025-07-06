import TipKit

struct RootTip: Tip {
    var image: Image? {
        Image(systemName: "slider.horizontal.3")
    }
    var title: Text {
        Text("tips first configuration")
    }
    var message: Text? {
        Text("tips first configuration detail")
    }
}
