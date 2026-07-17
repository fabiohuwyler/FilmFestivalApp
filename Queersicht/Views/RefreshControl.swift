import SwiftUI

struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct RefreshControl: View {
    let onRefresh: () async -> Void
    
    @State private var isRefreshing = false
    
    var body: some View {
        ProgressView()
            .opacity(isRefreshing ? 1 : 0)
            .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { offset in
                if offset > 50 && !isRefreshing {
                    isRefreshing = true
                    Task {
                        await onRefresh()
                        isRefreshing = false
                    }
                }
            }
    }
}
