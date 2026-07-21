import SwiftUI

struct GlassModifier: ViewModifier {
    var cornerRadius: CGFloat = 20
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                ZStack {
                    Color.white.opacity(0.03) // Slight inner brighten
                    Rectangle().fill(.ultraThinMaterial)
                }
            )
            .cornerRadius(cornerRadius)
            .shadow(color: Color.black.opacity(0.4), radius: 20, x: 0, y: 15)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(LinearGradient(
                        gradient: Gradient(colors: [Color.white.opacity(0.5), Color.cyan.opacity(0.2), Color.white.opacity(0.05)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ), lineWidth: 1.2)
            )
    }
}

struct NeonGlowModifier: ViewModifier {
    var color: Color
    var radius: CGFloat = 10

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.8), radius: radius, x: 0, y: 0)
            .shadow(color: color.opacity(0.5), radius: radius * 2, x: 0, y: 0)
    }
}

extension View {
    func liquidGlass(cornerRadius: CGFloat = 20, padding: CGFloat = 16) -> some View {
        self.modifier(GlassModifier(cornerRadius: cornerRadius, padding: padding))
    }
}

// Кастомный стиль для полей ввода (TextField), чтобы они вписывались в прозрачный дизайн
struct GlassTextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(12)
            .background(Color.white.opacity(0.05))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .foregroundColor(.white)
    }
}

extension View {
    func glassTextField() -> some View {
        self.modifier(GlassTextFieldModifier())
    }
}
