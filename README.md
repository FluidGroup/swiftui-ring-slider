# RingSlider

A SwiftUI component that provides an infinite circular slider for precise value adjustments, inspired by the rotation dial commonly found in professional editing applications.

![CleanShot 2024-01-02 at 4  46 41](https://github.com/FluidGroup/swiftui-ring-slider/assets/1888355/fd50dba5-a786-4561-906f-1fd5850c4f82)

## Features

- 🔄 **Infinite scrolling** - Smoothly scroll in either direction without limits
- 🎯 **Precise control** - Fine-grained value adjustments with customizable stride
- 📳 **Haptic feedback** - Built-in sensory feedback on value changes
- 🎨 **Native SwiftUI** - Seamlessly integrates with your SwiftUI views
- ⚡ **Fast deceleration** - Natural feeling momentum scrolling

## Requirements

- iOS 17.0+
- Swift 5.9+
- Xcode 15.0+

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/FluidGroup/swiftui-ring-slider", from: "1.0.0")
]
```

Or add it directly in Xcode:

1. Go to **File > Add Package Dependencies...**
2. Enter the repository URL: `https://github.com/FluidGroup/swiftui-ring-slider`
3. Select your desired version rules
4. Click **Add Package**

## Usage

### Basic Usage

```swift
import SwiftUIRingSlider

struct ContentView: View {
    @State private var value: Double = 0
    
    var body: some View {
        VStack {
            Text("Value: \(String(format: "%.2f", value))")
            RingSlider(value: $value)
        }
    }
}
```

### Custom Stride

Control the increment/decrement step size using the `stride` parameter:

```swift
RingSlider(value: $value, stride: 0.5)
```

### Value Range Constraints

Limit the slider to a specific range using `valueRange`:

```swift
RingSlider(
    value: $value,
    stride: 1,
    valueRange: 0...100
)
```

## API Reference

### RingSlider

```swift
public init(
    value: Binding<Double>,
    stride: Double = 1,
    valueRange: ClosedRange<Double> = (-Double.greatestFiniteMagnitude...Double.greatestFiniteMagnitude)
)
```

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `value` | `Binding<Double>` | Required | A binding to the current value of the slider |
| `stride` | `Double` | `1` | The amount to increment/decrement the value per scroll unit |
| `valueRange` | `ClosedRange<Double>` | `-∞...∞` | The range of allowable values for the slider |

## Dependencies

This package uses [SwiftUIIntrospect](https://github.com/siteline/swiftui-introspect) to enable infinite scrolling functionality.

## License

MIT License. See [LICENSE](LICENSE) for details.

## Author

[FluidGroup](https://github.com/FluidGroup)
