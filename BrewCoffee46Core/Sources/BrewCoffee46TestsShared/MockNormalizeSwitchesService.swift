import BrewCoffee46Core

public final class MockNormalizeSwitchesService: NormalizeSwitchesService {
    let switches: [Switch]
    let count: Int

    public init(switches: [Switch], count: Int) {
        self.switches = switches
        self.count = count
    }

    public func normalize(_ coffeeConfig: CoffeeConfig) -> [Switch] {
        switches
    }

    public func expectedSwitchCount(_ coffeeConfig: CoffeeConfig) -> Int {
        count
    }
}
