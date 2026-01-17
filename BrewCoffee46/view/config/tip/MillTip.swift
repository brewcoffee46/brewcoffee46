import TipKit

struct MillTip: Tip {
    var image: Image? {
        Image(systemName: "cylinder.split.1x2.fill")
    }
    var title: Text {
        Text("tips mill")
    }
    var message: Text? {
        Text("tips mill detail")
    }
}

struct MillEditTip: Tip {
    var title: Text {
        Text("tips mill edit")
    }
    var message: Text? {
        Text("tips mill edit detail")
    }
}

struct MillItemTip: Tip {
    var title: Text {
        Text("tips mill item")
    }
    var message: Text? {
        Text("tips mill item detail")
    }
}
