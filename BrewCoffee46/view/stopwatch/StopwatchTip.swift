import TipKit

struct StopwatchTip: Tip {
    var image: Image? {
        Image(systemName: "oilcan.fill")
    }
    var title: Text {
        Text("tips stopwatch start")
    }
    var message: Text? {
        Text("tips stopwatch start detail")
    }
}
