import SwiftUI

// MARK: - Animation Modifiers that respect settings
struct AnimatableSmoothAppear: ViewModifier {
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

struct AnimatableLiquidGlassEffect: ViewModifier {
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
                                guard settingsManager.enableAnimations else { return }
                                
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

struct AnimatableFloatingAnimation: ViewModifier {
    @EnvironmentObject var settingsManager: SettingsManager
    @State private var isFloating = false
    let duration: Double
    let verticalOffset: CGFloat
    
    func body(content: Content) -> some View {
        content
            .offset(y: isFloating ? -verticalOffset : verticalOffset)
            .onAppear {
                guard settingsManager.enableAnimations else { return }
                
                let adjustedDuration = duration / settingsManager.animationSpeed
                withAnimation(
                    Animation.easeInOut(duration: adjustedDuration)
                        .repeatForever(autoreverses: true)
                ) {
                    isFloating.toggle()
                }
            }
    }
}

struct AnimatablePulseAnimation: ViewModifier {
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

struct AnimatableShimmerEffect: ViewModifier {
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

// Extension methods
extension View {
    func animatableSmoothAppear(delay: Double = 0) -> some View {
        self.modifier(AnimatableSmoothAppear(delay: delay))
    }
    
    func animatableLiquidGlassEffect(intensity: CGFloat = 1.0) -> some View {
        self.modifier(AnimatableLiquidGlassEffect(intensity: intensity))
    }
    
    func animatableFloatingAnimation(duration: Double = 2.0, verticalOffset: CGFloat = 5) -> some View {
        self.modifier(AnimatableFloatingAnimation(duration: duration, verticalOffset: verticalOffset))
    }
    
    func animatablePulseAnimation() -> some View {
        self.modifier(AnimatablePulseAnimation())
    }
    
    func animatableShimmerEffect() -> some View {
        self.modifier(AnimatableShimmerEffect())
    }
}
