import SwiftUI
import Combine

// MARK: - Animation Manager
class AnimationManager: ObservableObject {
    @Published var enabled = true
    @Published var speed: Double = 1.0
    
    func animationDuration(_ baseDuration: Double) -> Double {
        return enabled ? (baseDuration / speed) : 0
    }
    
    func animation(withBaseDuration baseDuration: Double) -> Animation {
        return enabled ? Animation.easeInOut(duration: baseDuration / speed) : Animation.default
    }
    
    func springAnimation(response: Double = 0.6, dampingFraction: Double = 0.8) -> Animation {
        return enabled ? .spring(response: response / speed, dampingFraction: dampingFraction) : Animation.default
    }
}

// MARK: - Modified Smooth Appear Animation with Settings
struct SettingsAwareSmoothAppear: ViewModifier {
    let delay: Double
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .onAppear {
                guard settingsManager.enableAnimations else {
                    isVisible = true
                    return
                }
                
                isVisible = false
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.spring(response: 0.6 / settingsManager.animationSpeed, dampingFraction: 0.8)) {
                        isVisible = true
                    }
                }
            }
            .onDisappear {
                isVisible = false
            }
    }
}

// MARK: - Modified Liquid Glass Effect
struct SettingsAwareLiquidGlassEffect: ViewModifier {
    let intensity: CGFloat
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if settingsManager.enableAnimations {
                        GeometryReader { geometry in
                            ZStack {
                                // Animated gradient overlay
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.2),
                                        .white.opacity(0.1),
                                        .white.opacity(0.05),
                                        .clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .mask(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    .white.opacity(0.8),
                                                    .white.opacity(0.4),
                                                    .white.opacity(0.1),
                                                    .clear
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                        .blur(radius: 2)
                                )
                                
                                // Animated blobs
                                ForEach(0..<3) { i in
                                    Circle()
                                        .fill(
                                            RadialGradient(
                                                gradient: Gradient(colors: [
                                                    .white.opacity(0.3),
                                                    .white.opacity(0.1),
                                                    .clear
                                                ]),
                                                center: .center,
                                                startRadius: 0,
                                                endRadius: 50
                                            )
                                        )
                                        .frame(width: 100, height: 100)
                                        .offset(
                                            x: sin(phase + CGFloat(i) * 2) * 30,
                                            y: cos(phase + CGFloat(i) * 2) * 30
                                        )
                                        .blur(radius: 20)
                                        .opacity(0.3)
                                }
                            }
                            .onAppear {
                                let duration = 8.0 / settingsManager.animationSpeed
                                withAnimation(
                                    Animation.easeInOut(duration: duration)
                                        .repeatForever(autoreverses: true)
                                ) {
                                    phase = .pi * 2
                                }
                            }
                        }
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Modified Floating Animation
struct SettingsAwareFloatingAnimation: ViewModifier {
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var isFloating = false
    let duration: Double
    let verticalOffset: CGFloat
    
    func body(content: Content) -> some View {
        content
            .offset(y: isFloating ? -verticalOffset : verticalOffset)
            .onAppear {
                guard settingsManager.enableAnimations else { return }
                
                let duration = self.duration / settingsManager.animationSpeed
                withAnimation(
                    Animation.easeInOut(duration: duration)
                        .repeatForever(autoreverses: true)
                ) {
                    isFloating.toggle()
                }
            }
    }
}

// MARK: - Modified Pulse Animation
struct SettingsAwarePulseAnimation: ViewModifier {
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.05 : 1.0)
            .onAppear {
                guard settingsManager.enableAnimations else { return }
                
                isPulsing = true
            }
            .animation(
                settingsManager.enableAnimations ?
                    Animation.easeInOut(duration: 1.5 / settingsManager.animationSpeed)
                        .repeatForever(autoreverses: true) : nil,
                value: isPulsing
            )
    }
}

// MARK: - Modified Shimmer Effect
struct SettingsAwareShimmerEffect: ViewModifier {
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if settingsManager.enableAnimations {
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .clear,
                                .white.opacity(0.3),
                                .clear
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .mask(content)
                        .offset(x: phase * 200)
                        .onAppear {
                            let duration = 1.5 / settingsManager.animationSpeed
                            withAnimation(
                                Animation.linear(duration: duration)
                                    .repeatForever(autoreverses: false)
                            ) {
                                phase = 1
                            }
                        }
                    }
                }
            )
    }
}

// MARK: - Original animation modifiers (kept for backward compatibility)

struct LiquidGlassEffect: ViewModifier {
    let intensity: CGFloat
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    ZStack {
                        // Animated gradient overlay
                        LinearGradient(
                            colors: [
                                .white.opacity(0.2),
                                .white.opacity(0.1),
                                .white.opacity(0.05),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .mask(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            .white.opacity(0.8),
                                            .white.opacity(0.4),
                                            .white.opacity(0.1),
                                            .clear
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                                .blur(radius: 2)
                        )
                        
                        // Animated blobs
                        ForEach(0..<3) { i in
                            Circle()
                                .fill(
                                    RadialGradient(
                                        gradient: Gradient(colors: [
                                            .white.opacity(0.3),
                                            .white.opacity(0.1),
                                            .clear
                                        ]),
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 50
                                    )
                                )
                                .frame(width: 100, height: 100)
                                .offset(
                                    x: sin(phase + CGFloat(i) * 2) * 30,
                                    y: cos(phase + CGFloat(i) * 2) * 30
                                )
                                .blur(radius: 20)
                                .opacity(0.3)
                        }
                    }
                    .onAppear {
                        withAnimation(
                            Animation.easeInOut(duration: 8)
                                .repeatForever(autoreverses: true)
                        ) {
                            phase = .pi * 2
                        }
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct FloatingAnimation: ViewModifier {
    @State private var isFloating = false
    let duration: Double
    let verticalOffset: CGFloat
    
    func body(content: Content) -> some View {
        content
            .offset(y: isFloating ? -verticalOffset : verticalOffset)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: duration)
                        .repeatForever(autoreverses: true)
                ) {
                    isFloating.toggle()
                }
            }
    }
}

struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        .clear,
                        .white.opacity(0.3),
                        .clear
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .mask(content)
                .offset(x: phase * 200)
                .onAppear {
                    withAnimation(
                        Animation.linear(duration: 1.5)
                            .repeatForever(autoreverses: false)
                    ) {
                        phase = 1
                    }
                }
            )
    }
}

struct PulseAnimation: ViewModifier {
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.05 : 1.0)
            .animation(
                Animation.easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

struct SmoothAppear: ViewModifier {
    let delay: Double
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .onAppear {
                // Reset animation when view appears
                isVisible = false
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        isVisible = true
                    }
                }
            }
            .onDisappear {
                // Reset when view disappears
                isVisible = false
            }
    }
}

struct GlassCard: ViewModifier {
    let cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                .white.opacity(0.5),
                                .clear,
                                .white.opacity(0.2)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

// Extension methods
extension View {
    func liquidGlassEffect(intensity: CGFloat = 1.0) -> some View {
        self.modifier(LiquidGlassEffect(intensity: intensity))
    }
    
    func floatingAnimation(duration: Double = 2.0, verticalOffset: CGFloat = 5) -> some View {
        self.modifier(FloatingAnimation(duration: duration, verticalOffset: verticalOffset))
    }
    
    func shimmerEffect() -> some View {
        self.modifier(ShimmerEffect())
    }
    
    func pulseAnimation() -> some View {
        self.modifier(PulseAnimation())
    }
    
    func smoothAppear(delay: Double = 0) -> some View {
        self.modifier(SmoothAppear(delay: delay))
    }
    
    func glassCard(cornerRadius: CGFloat = 16) -> some View {
        self.modifier(GlassCard(cornerRadius: cornerRadius))
    }
    
    // Settings-aware methods
    func settingsAwareSmoothAppear(delay: Double = 0) -> some View {
        self.modifier(SettingsAwareSmoothAppear(delay: delay))
    }
    
    func settingsAwareLiquidGlassEffect(intensity: CGFloat = 1.0) -> some View {
        self.modifier(SettingsAwareLiquidGlassEffect(intensity: intensity))
    }
    
    func settingsAwareFloatingAnimation(duration: Double = 2.0, verticalOffset: CGFloat = 5) -> some View {
        self.modifier(SettingsAwareFloatingAnimation(duration: duration, verticalOffset: verticalOffset))
    }
    
    func settingsAwarePulseAnimation() -> some View {
        self.modifier(SettingsAwarePulseAnimation())
    }
    
    func settingsAwareShimmerEffect() -> some View {
        self.modifier(SettingsAwareShimmerEffect())
    }
}
