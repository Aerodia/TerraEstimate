//
//  LandingView.swift
//  LandValueEstimator
//
//  Created by Aryan on 23/07/26.
//

import SwiftUI

struct LandingView: View {
    var onGetStarted: () -> Void
    
    // Animation triggers
    @State private var showHero = false
    @State private var showFeatures = false
    @State private var showCTA = false
    @State private var pulseGlow = false

    var body: some View {
        ZStack {
            // Dark gradient background
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()
            
            // Ambient background glow
            Circle()
                .fill(LinearGradient(colors: [.blue.opacity(0.3), .indigo.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .offset(y: -150)
                .scaleEffect(pulseGlow ? 1.2 : 0.9)
                .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: pulseGlow)

            VStack(spacing: 32) {
                Spacer()

                // MARK: - Animated Hero Section
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.blue, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 90, height: 90)
                            .shadow(color: .blue.opacity(0.5), radius: 20, x: 0, y: 10)

                        Image(systemName: "sparkles")
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(showHero ? 1.0 : 0.4)
                    .opacity(showHero ? 1.0 : 0.0)

                    VStack(spacing: 8) {
                        Text("TerraEstimate")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)

                        Text("Instant, AI-powered land and property valuations at your fingertips.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .offset(y: showHero ? 0 : 20)
                    .opacity(showHero ? 1.0 : 0.0)
                }

                // MARK: - Animated Feature Cards
                VStack(spacing: 16) {
                    featureRow(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Smart Valuation",
                        subtitle: "Calculates real-time estimates using property inputs."
                    )
                    
                    featureRow(
                        icon: "checkmark.shield.fill",
                        title: "Confidence Ranges",
                        subtitle: "Understand bounds based on historical error margins."
                    )
                    
                    featureRow(
                        icon: "chart.bar.fill",
                        title: "Key Market Drivers",
                        subtitle: "See exact factors influencing final property price."
                    )
                }
                .padding(.horizontal, 24)
                .offset(y: showFeatures ? 0 : 30)
                .opacity(showFeatures ? 1.0 : 0.0)

                Spacer()

                // MARK: - Animated CTA Button
                Button(action: onGetStarted) {
                    HStack(spacing: 8) {
                        Text("Get Started")
                            .font(.headline.bold())
                        Image(systemName: "arrow.right")
                            .font(.subheadline.bold())
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(LinearGradient(colors: [.blue, .indigo], startPoint: .leading, endPoint: .trailing))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(color: .blue.opacity(0.4), radius: 12, x: 0, y: 6)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                .scaleEffect(showCTA ? 1.0 : 0.9)
                .opacity(showCTA ? 1.0 : 0.0)
            }
        }
        .onAppear {
            pulseGlow = true

            // Staggered sequence animation
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                showHero = true
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                showFeatures = true
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.4)) {
                showCTA = true
            }
        }
    }

    @ViewBuilder
    private func featureRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 44, height: 44)
                .background(Color.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundColor(.primary)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(14)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }
}

#Preview {
    LandingView(onGetStarted: {})
}
