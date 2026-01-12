import TipKit

struct UniversalLinksIssueTip: Tip {
    var image: Image? {
        Image(systemName: "sharedwithyou.circle")
    }
    var title: Text {
        Text("tips universal links issue")
    }
    var message: Text? {
        Text("tips universal links issue detail")
    }
}

struct UniversalLinksSaveTip: Tip {
    var title: Text {
        Text("tips universal links config save")
    }
    var message: Text? {
        Text("tips universal links config save detail")
    }
}
