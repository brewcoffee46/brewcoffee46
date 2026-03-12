import BrewCoffee46Core

public let epochTimeMillis: UInt64 = 1_723_792_539_843

@MainActor
public let waterAmountDefaultValue = WaterAmount.defaultValue()

@MainActor
public let dripInfoDefaultValue = DripInfo.defaultValue()

@MainActor
public let waterAmountFirstIs100Percent = WaterAmount(
    fortyPercent: (180.0, 0),
    sixtyPercent: NonEmptyArray(90.0, [90.0, 90.0])
)

@MainActor
public let dripInfoFirstIs100Percent = DripInfo(
    dripTimings: [
        DripTiming(waterAmount: 180.0, dripAt: 0.0),
        DripTiming(waterAmount: 270.0, dripAt: 45.0),
        DripTiming(waterAmount: 360.0, dripAt: 100.0),
        DripTiming(waterAmount: 450.0, dripAt: 155.0),
    ],
    waterAmount: waterAmountFirstIs100Percent,
    totalTimeSec: CoffeeConfig.defaultValue().totalTimeSec
)

@MainActor
public let waterAmountFirstIs100PercentSixtyIs1 = WaterAmount(
    fortyPercent: (180.0, 0),
    sixtyPercent: NonEmptyArray(270.0, [])
)

@MainActor
public let dripInfoFirstIs100PercentSixtyIs1 = DripInfo(
    dripTimings: [
        DripTiming(waterAmount: 180.0, dripAt: 0.0),
        DripTiming(waterAmount: 450.0, dripAt: 45.0),
    ],
    waterAmount: waterAmountFirstIs100PercentSixtyIs1,
    totalTimeSec: CoffeeConfig.defaultValue().totalTimeSec
)
