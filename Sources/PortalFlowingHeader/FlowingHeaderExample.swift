//
//  FlowingHeaderExample.swift
//  PortalFlowingHeader
//
//  Created by Aether on 12/08/2025.
//

import SwiftUI

// MARK: - Example Views

@available(iOS 18.0, *)
public struct FlowingHeaderExample: View {
    @State private var items = Array(1...50)
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Header that flows to navigation title
                    FlowingHeaderView(
                        icon: "star.fill",
                        title: "Starred Items",
                        subtitle: "Your favorite content, beautifully organized"
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Sample content
                    ForEach(items, id: \.self) { item in
                        ExampleCard(number: item)
                    }
                }
                .padding(.bottom, 100)
            }
            .flowingHeaderDestination("Starred Items")
        }
        .flowingHeader("Starred Items")
    }
}

@available(iOS 18.0, *)
public struct FlowingHeaderCustomViewExample: View {
    @State private var items = Array(1...30)
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Header with custom view that flows to navigation
                    FlowingHeaderView(
                        customView: ExampleAvatar(),
                        title: "Profile",
                        subtitle: "Manage your account and preferences"
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Profile content
                    ForEach(items, id: \.self) { item in
                        ProfileItem(title: "Setting \(item)", subtitle: "Configure option \(item)")
                    }
                }
                .padding(.bottom, 100)
            }
            .flowingHeaderDestination("Profile") {
                ExampleAvatar()
            }
        }
        .flowingHeader(
            "Profile",
            customView: ExampleAvatar()
        )
    }
}

// MARK: - Supporting Views

@available(iOS 18.0, *)
private struct ExampleCard: View {
    let number: Int
    
    var body: some View {
        HStack {
            Image(systemName: "doc.fill")
                .foregroundStyle(.blue)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Item \(number)")
                    .font(.headline)
                Text("This is a sample item with some description text")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "star.fill")
                .foregroundStyle(.yellow)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 20)
    }
}

@available(iOS 18.0, *)
private struct ProfileItem: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
                .font(.caption)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .padding(.horizontal, 20)
    }
}

@available(iOS 18.0, *)
private struct ExampleAvatar: View {
    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [.blue, .purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 80, height: 80)
            .overlay {
                Image(systemName: "person.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
            }
    }
}

// MARK: - Preview

@available(iOS 18.0, *)
#Preview("Icon Example") {
    FlowingHeaderExample()
}

@available(iOS 18.0, *)
#Preview("Custom View Example") {
    FlowingHeaderCustomViewExample()
}
