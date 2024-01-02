import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect

public struct RingSlider: View {

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

  public init(
    value: Binding<Double>,
    stride: Double = 1,
    valueRange: ClosedRange<Double> = (-Double.greatestFiniteMagnitude...Double.greatestFiniteMagnitude)
  ) {
    self.stride = stride
    self.valueRange = valueRange
    self._value = value
  }

  public var body: some View {

    let content = HStack(spacing: 0) {
      ShortBar()
        .foregroundStyle(Color.accentColor)
      Group {
        Spacer(minLength: 0)
        ShortBar()
        Spacer(minLength: 0)
        ShortBar()
        Spacer(minLength: 0)
        ShortBar()
        Spacer(minLength: 0)
        ShortBar()
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

  // MARK: - nested types

  struct Bar: View {
    var body: some View {
      RoundedRectangle(cornerRadius: 8)
        .frame(width: 3, height: 30)
    }
  }

  struct ShortBar: View {
    var body: some View {
      RoundedRectangle(cornerRadius: 8)
        .frame(width: 3, height: 20)
    }
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

#Preview {
  Demo()
}

#Preview {
  HStack(spacing: 0) {
    ForEach(0..<6) { i in
      HStack(spacing: 0) {
        //                    Spacer(minLength: 0)

        RingSlider.Bar()
          .foregroundColor(.red)
        Spacer(minLength: 0)
        RingSlider.ShortBar()
        Spacer(minLength: 0)
        RingSlider.ShortBar()
        Spacer(minLength: 0)
        RingSlider.ShortBar()
        Spacer(minLength: 0)
        RingSlider.ShortBar()
        Spacer(minLength: 0)
      }
    }
  }
  .background(Color.blue)
}
#endif
