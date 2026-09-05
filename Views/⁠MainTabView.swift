import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView().tag(0)
                Text("المفضلة").tag(1) // استبدلها بشاشة المفضلة
                SettingsView().tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // لدعم السحب يميناً ويساراً
            
            // شريط زجاجي سائل
            HStack {
                TabBarIcon(iconName: "house.fill", isSelected: selectedTab == 0) { selectedTab = 0 }
                Spacer()
                TabBarIcon(iconName: "heart.fill", isSelected: selectedTab == 1) { selectedTab = 1 }
                Spacer()
                TabBarIcon(iconName: "gearshape.fill", isSelected: selectedTab == 2) { selectedTab = 2 }
            }
            .padding()
            .background(.ultraThinMaterial) // تأثير الزجاج
            .cornerRadius(30)
            .padding(.horizontal, 40)
            .padding(.bottom, 20)
            .shadow(color: .black.opacity(0.1), radius: 10)
        }
        .preferredColorScheme(.light)
    }
}

struct TabBarIcon: View {
    let iconName: String
    let isSelected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: iconName)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(isSelected ? .black : .gray)
        }
    }
}
