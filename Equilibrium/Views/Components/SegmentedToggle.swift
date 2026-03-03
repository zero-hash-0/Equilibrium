import SwiftUI

struct SegmentedToggle: View {
    @Binding var selection: Int
    let options: [(label: String, value: Int)]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(options, id: \.value) { opt in
                Button {
                    withAnimation(.spring(response: 0.3)) { selection = opt.value }
                } label: {
                    Text(opt.label)
                        .font(.system(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(
                            selection == opt.value
                                ? Theme.accentMint
                                : Color.clear
                        )
                        .foregroundStyle(selection == opt.value ? .black : Theme.textSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
        }
        .padding(4)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .stroke(Theme.strokeOverlay, lineWidth: 1)
        )
    }
}
