import SwiftUI
import StratilesCore

struct TopActivitiesCard: View {
    let insights: ActivityInsights

    @State private var sortMetric: SortMetric = .distance

    private enum SortMetric: String, CaseIterable {
        case distance = "Distance"
        case elevation = "Elevation"
        case kudos = "Kudos"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Top Activities")
                    .font(.headline)

                Spacer()

                Menu {
                    Picker("Sort by", selection: $sortMetric) {
                        ForEach(SortMetric.allCases, id: \.self) { metric in
                            Text(metric.rawValue).tag(metric)
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(sortMetric.rawValue)
                            .font(.subheadline.weight(.medium))
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption2)
                    }
                    .foregroundStyle(Theme.stravaOrange)
                }
            }

            if insights.peakActivities.isEmpty {
                Text("Top activities will appear after a full activity refresh.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(sortedActivities.enumerated()), id: \.element.id) { index, activity in
                        row(index: index, activity: activity)
                    }
                }
            }
        }
        .padding(14)
        .background(Theme.cardBackground, in: .rect(cornerRadius: 14, style: .continuous))
    }

    private var sortedActivities: [PeakActivity] {
        switch sortMetric {
        case .distance:
            insights.peakActivities.sorted { $0.miles > $1.miles }
        case .elevation:
            insights.peakActivities.sorted { $0.elevationGainMeters > $1.elevationGainMeters }
        case .kudos:
            insights.peakActivities.sorted { $0.kudosCount > $1.kudosCount }
        }
    }

    private func row(index: Int, activity: PeakActivity) -> some View {
        Link(destination: URL(string: "https://www.strava.com/activities/\(activity.id)")!) {
            HStack(alignment: .center, spacing: 10) {
                Text("#\(index + 1)")
                    .font(.caption.monospacedDigit().weight(.semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 26, alignment: .leading)

                Image(systemName: activity.activityType?.category.icon ?? "sportscourt")
                    .font(.body)
                    .foregroundStyle(Theme.stravaOrange)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(activity.name)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)

                    Text(activity.date, format: .dateTime.month(.abbreviated).day().year())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 8)

                VStack(alignment: .trailing, spacing: 2) {
                    primaryMetric(for: activity)
                    secondaryMetric(for: activity)
                }

                Image(systemName: "arrow.up.right")
                    .font(.caption2)
                    .foregroundStyle(Theme.stravaOrange)
            }
        }
        .tint(.primary)
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background(index.isMultiple(of: 2) ? Theme.subtleOrange : Color.clear, in: .rect(cornerRadius: 10, style: .continuous))
    }

    private func primaryMetric(for activity: PeakActivity) -> some View {
        Group {
            switch sortMetric {
            case .distance:
                Text("\(activity.miles.formatted(.number.precision(.fractionLength(1)))) mi")
            case .elevation:
                Text("\(activity.elevationGainMeters.formatted(.number.precision(.fractionLength(0)))) ft")
            case .kudos:
                Text("\(activity.kudosCount) kudos")
            }
        }
        .font(.subheadline.monospacedDigit().weight(.semibold))
    }

    private func secondaryMetric(for activity: PeakActivity) -> some View {
        Group {
            switch sortMetric {
            case .distance:
                Text("\(activity.elevationGainMeters.formatted(.number.precision(.fractionLength(0)))) ft gain")
            case .elevation:
                Text("\(activity.miles.formatted(.number.precision(.fractionLength(1)))) mi")
            case .kudos:
                Text("\(activity.miles.formatted(.number.precision(.fractionLength(1)))) mi")
            }
        }
        .font(.caption2)
        .foregroundStyle(.secondary)
    }
}
