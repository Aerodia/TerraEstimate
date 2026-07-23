//
//  HistoryView.swift
//  LandValueEstimator
//

import SwiftData
import SwiftUI

struct HistoryView: View {
    @Query(sort: \SavedEstimate.date, order: .reverse) private var estimates: [SavedEstimate]
    @Environment(\.modelContext) private var modelContext

    // State to trigger the confirmation dialog
    @State private var showClearAllAlert = false

    var body: some View {
        NavigationStack {
            Group {
                if estimates.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(estimates) { estimate in
                            HistoryRow(estimate: estimate)
                        }
                        .onDelete(perform: delete)
                    }
                }
            }
            .navigationTitle("History")
            .toolbar {
                if !estimates.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(role: .destructive) {
                            showClearAllAlert = true
                        } label: {
                            Label("Clear All", systemImage: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            // MARK: - Deletion Confirmation Alert
            .alert("Clear All History?", isPresented: $showClearAllAlert) {
                Button("Clear All", role: .destructive, action: deleteAll)
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete all saved estimates? This action cannot be undone.")
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "No Estimates Yet",
            systemImage: "clock.arrow.circlepath",
            description: Text("Estimates you save will show up here.")
        )
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(estimates[index])
        }
        try? modelContext.save()
    }

    private func deleteAll() {
        withAnimation {
            for estimate in estimates {
                modelContext.delete(estimate)
            }
            try? modelContext.save()
        }
    }
}

private struct HistoryRow: View {
    let estimate: SavedEstimate

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(estimate.result.formattedEstimate)
                .font(.headline)

            Text(estimate.summaryLine)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(Self.dateFormatter.string(from: estimate.date))
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: SavedEstimate.self, inMemory: true)
}
