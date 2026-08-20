import SwiftUI

struct ContentView: View {
    @EnvironmentObject var locker: KeyboardLocker
    @State private var pulse = false

    private let durations: [(label: String, value: TimeInterval)] = [
        ("∞", 0), ("30s", 30), ("1m", 60), ("3m", 180), ("5m", 300)
    ]

    var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {
                header
                    .padding(.top, 44)

                Spacer()

                lockButton

                Spacer()

                if locker.hasPermission {
                    timerPicker
                        .padding(.bottom, 12)
                    statusLine
                        .padding(.bottom, 16)
                } else {
                    permissionCard
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)
                }

                colophon
                    .padding(.bottom, 14)
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.85), value: locker.isLocked)
        .animation(.easeInOut(duration: 0.25), value: locker.hasPermission)
    }

    // MARK: pieces

    private var background: some View {
        ZStack {
            Color(red: 0.07, green: 0.08, blue: 0.10)
            // Crossfade two fixed-color washes; gradient colors themselves
            // don't interpolate, opacity does.
            RadialGradient(
                colors: [Color.teal.opacity(0.16), .clear],
                center: .center, startRadius: 20, endRadius: 320
            )
            .opacity(locker.isLocked ? 0 : 1)
            RadialGradient(
                colors: [Color.orange.opacity(0.16), .clear],
                center: .center, startRadius: 20, endRadius: 320
            )
            .opacity(locker.isLocked ? 1 : 0)
        }
        .animation(.easeInOut(duration: 0.6), value: locker.isLocked)
        .ignoresSafeArea()
    }

    private var header: some View {
        VStack(spacing: 4) {
            Text("KeyLock")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
            Text(locker.isLocked ? "Keyboard is locked — wipe away" : "Clean your keyboard without chaos")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.45))
        }
    }

    private var lockButton: some View {
        Button(action: { locker.toggle() }) {
            ZStack {
                // Outer glow: crossfaded color layers so the hue blends
                ZStack {
                    Circle().fill(Color.teal)
                        .opacity(locker.isLocked ? 0 : 1)
                    Circle().fill(Color.orange)
                        .opacity(locker.isLocked ? 1 : 0)
                }
                .frame(width: 190, height: 190)
                .blur(radius: 24)
                .opacity(pulse ? 0.20 : 0.08)
                .animation(.easeInOut(duration: 0.6), value: locker.isLocked)

                // Track ring
                Circle()
                    .stroke(Color.white.opacity(0.08), lineWidth: 6)
                    .frame(width: 160, height: 160)

                // Progress / state ring: two gradient layers crossfaded
                ZStack {
                    ringLayer(colors: [.teal, .mint, .teal])
                        .opacity(locker.isLocked ? 0 : 1)
                    ringLayer(colors: [.orange, .pink, .orange])
                        .opacity(locker.isLocked ? 1 : 0)
                }
                .animation(.easeInOut(duration: 0.6), value: locker.isLocked)

                // Face
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.10), Color.white.opacity(0.03)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: 132, height: 132)
                    .overlay(Circle().stroke(Color.white.opacity(0.10), lineWidth: 1))

                VStack(spacing: 8) {
                    Image(systemName: locker.isLocked ? "lock.fill" : "keyboard")
                        .font(.system(size: 34, weight: .medium))
                        .foregroundStyle(locker.isLocked ? Color.orange : Color.teal)
                        .contentTransition(.symbolEffect(.replace))
                        .animation(.easeInOut(duration: 0.6), value: locker.isLocked)
                    Text(centerLabel)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.white.opacity(0.75))
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(!locker.hasPermission)
        .opacity(locker.hasPermission ? 1 : 0.35)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }

    private func ringLayer(colors: [Color]) -> some View {
        Circle()
            .trim(from: 0, to: ringProgress)
            .stroke(
                AngularGradient(colors: colors, center: .center),
                style: StrokeStyle(lineWidth: 6, lineCap: .round)
            )
            .frame(width: 160, height: 160)
            .rotationEffect(.degrees(-90))
    }

    private var ringProgress: CGFloat {
        guard locker.isLocked else { return 1 }
        guard locker.duration > 0 else { return 1 }
        return max(0, locker.remaining / locker.duration)
    }

    private var centerLabel: String {
        if locker.isLocked {
            if locker.duration > 0 {
                let s = Int(locker.remaining.rounded(.up))
                return String(format: "%d:%02d", s / 60, s % 60)
            }
            return "Unlock"
        }
        return "Lock"
    }

    private var timerPicker: some View {
        HStack(spacing: 6) {
            ForEach(durations, id: \.value) { item in
                Button(item.label) { locker.duration = item.value }
                    .buttonStyle(.plain)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(locker.duration == item.value ? .black : .white.opacity(0.6))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule().fill(
                            locker.duration == item.value
                                ? AnyShapeStyle(locker.isLocked ? Color.orange : Color.teal)
                                : AnyShapeStyle(Color.white.opacity(0.07))
                        )
                    )
                    .disabled(locker.isLocked)
            }
        }
        .opacity(locker.isLocked ? 0.4 : 1)
    }

    private var statusLine: some View {
        Text(locker.duration == 0 ? "Locks until you tap again" : "Auto-unlocks when time is up")
            .font(.system(size: 11, weight: .medium, design: .rounded))
            .foregroundStyle(.white.opacity(0.35))
    }

    // Stripe payment link for tips. Configure the product in Stripe with
    // "customer chooses price", suggested $5.
    private let tipURL = URL(string: "https://buy.stripe.com/6oU14nbAtfBvawR76n38406")!

    @State private var hoveringTip = false

    private var colophon: some View {
        Button {
            NSWorkspace.shared.open(tipURL)
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 10, weight: .medium))
                Text("Buy me a coffee")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
            }
            .foregroundStyle(.white.opacity(hoveringTip ? 0.75 : 0.30))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Capsule().fill(Color.white.opacity(hoveringTip ? 0.08 : 0)))
        }
        .buttonStyle(.plain)
        .onHover { hoveringTip = $0 }
        .animation(.easeInOut(duration: 0.15), value: hoveringTip)
    }

    private var permissionCard: some View {
        VStack(spacing: 10) {
            Text("Accessibility access needed")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
            Text("KeyLock blocks key presses with a system event tap, which macOS gates behind Accessibility permission.")
                .font(.system(size: 11, design: .rounded))
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)
            Button("Grant Access") { locker.requestPermission() }
                .buttonStyle(.borderedProminent)
                .tint(.teal)
                .controlSize(.small)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.05)))
    }
}
