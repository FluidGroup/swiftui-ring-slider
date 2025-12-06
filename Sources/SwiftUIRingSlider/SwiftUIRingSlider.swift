import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect

/// A SwiftUI view that provides an infinite circular slider for precise value adjustments.
///
/// `RingSlider` creates a horizontal scrolling interface that allows users to adjust a numeric value
/// by scrolling left or right. The slider supports infinite scrolling in both directions and provides
/// haptic feedback on value changes.
///
/// ## Usage
///
/// Create a `RingSlider` by providing a binding to a `Double` value:
///
/// ```swift
/// @State private var value: Double = 0
///
/// var body: some View {
///     RingSlider(value: $value)
/// }
/// ```
///
/// You can customize the stride (increment step) and constrain the value range:
///
/// ```swift
/// RingSlider(
///     value: $value,
///     stride: 0.5,
///     valueRange: 0...100
/// )
/// ```
///
/// You can also customize the tick marks:
///
/// ```swift
/// RingSlider(
///     value: $value,
///     primaryTickMark: { Circle().frame(width: 4, height: 4) },
///     secondaryTickMark: { Circle().frame(width: 2, height: 2) }
/// )
/// ```
public struct RingSlider<PrimaryTickMark: View, SecondaryTickMark: View>: View {

  final class Proxy: ObservableObject {
    var value: Double = 0 {
      didSet {
        print(value, oldValue)
        let diff = value - oldValue
        self.incrementValue = diff
      }
    }

    @Published var incrementValue: Double = 0

    var contentOffsetObservation: NSKeyValueObservation?

    init() {}

    deinit {
      contentOffsetObservation?.invalidate()
    }
  }

  private let stride: Double
  @Binding var value: Double
  @State private var page: Int = 0

  @StateObject private var uiProxy: Proxy = .init()
  private let valueRange: ClosedRange<Double>

  private let primaryTickMark: PrimaryTickMark
  private let secondaryTickMark: SecondaryTickMark

  /// Creates a new ring slider with custom tick marks.
  ///
  /// - Parameters:
  ///   - value: A binding to the current value of the slider.
  ///   - stride: The amount to increment or decrement the value per scroll unit. Default is `1`.
  ///   - valueRange: The range of allowable values for the slider.
  ///     Default is from `-Double.greatestFiniteMagnitude` to `Double.greatestFiniteMagnitude`.
  ///   - primaryTickMark: A view builder that creates the primary tick mark (used for the first tick in each segment).
  ///   - secondaryTickMark: A view builder that creates the secondary tick marks.
  public init(
    value: Binding<Double>,
    stride: Double = 1,
    valueRange: ClosedRange<Double> = (-Double.greatestFiniteMagnitude...Double.greatestFiniteMagnitude),
    @ViewBuilder primaryTickMark: () -> PrimaryTickMark,
    @ViewBuilder secondaryTickMark: () -> SecondaryTickMark
  ) {
    self.stride = stride
    self.valueRange = valueRange
    self._value = value
    self.primaryTickMark = primaryTickMark()
    self.secondaryTickMark = secondaryTickMark()
  }

  public var body: some View {

    let content = HStack(spacing: 0) {
      primaryTickMark
        .foregroundStyle(Color.accentColor)
      Group {
        Spacer(minLength: 0)
        secondaryTickMark
        Spacer(minLength: 0)
        secondaryTickMark
        Spacer(minLength: 0)
        secondaryTickMark
        Spacer(minLength: 0)
        secondaryTickMark
        Spacer(minLength: 0)
      }
      .foregroundStyle(Color.accentColor.secondary)
    }
      .padding(.vertical, 10)

    // for sizing
    content
      .hidden()
      .overlay(
        GeometryReader(content: { geometry in
          ScrollViewReader(content: { proxy in
            ScrollView(.horizontal) {
              HStack(spacing: 0) {
                ForEach(0..<2) { _ in
                  HStack(spacing: 0) {
                    ForEach(0..<6) { i in
                      content
                    }
                  }
                  .frame(
                    width: geometry.size.width,
                    height: geometry.size.height,
                    alignment: .center
                  )
                }
              }
            }
            .sensoryFeedback(.selection, trigger: value)
            .scrollIndicators(.hidden)
            .introspect(.scrollView, on: .iOS(.v15...)) { (view: UIScrollView) in

              view.decelerationRate = .fast

              uiProxy.contentOffsetObservation?.invalidate()

              uiProxy.contentOffsetObservation = view.observe(\.contentOffset) { view, value in

                let v = view.contentOffset.x + Double(page) * view.bounds.width

                withTransaction(.init()) {
                  let value = (v / 20).rounded()
                  if uiProxy.value != value {
                    uiProxy.value = value
                  }
                }

                // for start
                if view.contentOffset.x < 0 {
                  page -= 1
                  view.contentOffset.x = view.contentSize.width - view.bounds.width
                  return
                }

                // for end
                if view.contentOffset.x > view.contentSize.width - view.bounds.width {
                  page += 1
                  view.contentOffset.x = 0
                  return
                }
              }
            }
          })
          .mask {
            HStack(spacing: 0) {
              LinearGradient(
                stops: [
                  .init(color: .black, location: 0),
                  .init(color: .clear, location: 1),
                ],
                startPoint: .init(x: 1, y: 0),
                endPoint: .init(x: 0, y: 0)
              )
              Color.black.frame(width: 30)
              LinearGradient(
                stops: [
                  .init(color: .black, location: 0),
                  .init(color: .clear, location: 1),
                ],
                startPoint: .init(x: 0, y: 0),
                endPoint: .init(x: 1, y: 0)
              )
            }
          }
          .onReceive(
            uiProxy.$incrementValue,
            perform: { value in
              let newValue = self.value + (value * stride)

              self.value = newValue

              if newValue > valueRange.upperBound {
                self.value = valueRange.upperBound
              }

              if newValue < valueRange.lowerBound {
                self.value = valueRange.lowerBound
              }

            }
          )
        })
      )
  }

}

/// The default primary tick mark view used by `RingSlider`.
///
/// A rounded rectangle with 3pt width, typically used for the first tick in each segment.
public struct DefaultPrimaryTickMark: View {
  public init() {}

  public var body: some View {
    RoundedRectangle(cornerRadius: 8)
      .frame(width: 3)
  }
}

/// The default secondary tick mark view used by `RingSlider`.
///
/// A rounded rectangle with 3pt width, used for secondary ticks between primary ticks.
public struct DefaultSecondaryTickMark: View {
  public init() {}

  public var body: some View {
    RoundedRectangle(cornerRadius: 8)
      .frame(width: 3)
  }
}

// MARK: - Backward Compatible Initializer

extension RingSlider {

  /// Creates a new ring slider with default tick marks.
  ///
  /// - Parameters:
  ///   - value: A binding to the current value of the slider.
  ///   - stride: The amount to increment or decrement the value per scroll unit. Default is `1`.
  ///   - valueRange: The range of allowable values for the slider.
  ///     Default is from `-Double.greatestFiniteMagnitude` to `Double.greatestFiniteMagnitude`.
  public init(
    value: Binding<Double>,
    stride: Double = 1,
    valueRange: ClosedRange<Double> = (-Double.greatestFiniteMagnitude...Double.greatestFiniteMagnitude)
  ) where PrimaryTickMark == DefaultPrimaryTickMark, SecondaryTickMark == DefaultSecondaryTickMark {
    self.init(
      value: value,
      stride: stride,
      valueRange: valueRange,
      primaryTickMark: { DefaultPrimaryTickMark() },
      secondaryTickMark: { DefaultSecondaryTickMark() }
    )
  }
}

#if DEBUG

private struct Demo: View {

  @State var value: Double = 20

  var body: some View {

    VStack {
      Text("\(String(format: "%.2f", value))")
      RingSlider(value: $value)
    }
  }

}

#Preview("Default") {
  Demo()
}

#Preview("Default Tick Marks") {
  HStack(spacing: 0) {
    ForEach(0..<6) { i in
      HStack(spacing: 0) {
        DefaultPrimaryTickMark()
          .foregroundColor(.red)
        Spacer(minLength: 0)
        DefaultSecondaryTickMark()
        Spacer(minLength: 0)
        DefaultSecondaryTickMark()
        Spacer(minLength: 0)
        DefaultSecondaryTickMark()
        Spacer(minLength: 0)
        DefaultSecondaryTickMark()
        Spacer(minLength: 0)
      }
    }
  }
  .background(Color.blue)
}

#Preview("Custom Tick Marks") {
  struct CustomDemo: View {
    @State var value: Double = 0

    var body: some View {
      VStack {
        Text("\(String(format: "%.2f", value))")
        RingSlider(
          value: $value,
          primaryTickMark: {
            Circle()
              .frame(width: 6, height: 6)
          },
          secondaryTickMark: {
            Circle()
              .frame(width: 3, height: 3)
          }
        )
      }
    }
  }
  return CustomDemo()
}

#endif
