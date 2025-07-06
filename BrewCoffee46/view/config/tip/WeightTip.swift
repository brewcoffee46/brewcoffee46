import TipKit

struct WeightTip: Tip {
    var image: Image? {
        Image(systemName: "powermeter")
    }

    var title: Text {
        Text("tips weight")
    }
    var message: Text? {
        Text("tips weight detail")
    }
}
