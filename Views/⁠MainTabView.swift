import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // الثيم الأخضر الداكن كخلفية أساسية لكل التطبيق
            Color(red: 0.05, green: 0.18, blue: 0.14) // درجة الأخضر الغامق الفاخر
                .ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                HomeView().tag(0)
                Text("المفضلة").tag(1) // شاشة المفضلة
                SettingsView().tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never)) // لدعم السحب يميناً ويسارا
            .ignoresSafeArea()
            
            // شريط زجاجي سائل متناسق مع الثيم الأخضر
            HStack {
                TabBarIcon(iconName: "house.fill", isSelected: selectedTab == 0) { selectedTab = 0 }
                Spacer()
                TabBarIcon(iconName: "heart.fill", isSelected: selectedTab == 1) { selectedTab = 1 }
                Spacer()
                TabBarIcon(iconName: "gearshape.fill", isSelected: selectedTab == 2) { selectedTab = 2 }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(.ultraThinMaterial) // تأثير الزجاج الفاخر
            .cornerRadius(35)
            .overlay(
                RoundedRectangle(cornerRadius: 35)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1) // إطار زجاجي خفيف
            )
            .padding(.horizontal, 40)
            .padding(.bottom, 8)
            .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 10)
        }
        .preferredColorScheme(.dark) // تثبيت الثيم الداكن والأخضر الخاص بتصميمك
    }
}

struct TabBarIcon: View {
    let iconName: String
    let isSelected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: iconName)
                .font(.system(size: 22, weight: .semibold))
                // اللون الأخضر المضيء عند التحديد، وأبيض شفاف للعناصر غير المحددة
                .foregroundColor(isSelected ? Color(red: 0.2, green: 0.85, blue: 0.5) : .white.opacity(0.5))
                .scaleEffect(isSelected ? 1.15 : 1.0) // تأثير تكبير خفيف للأيقونة المفعلة
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        }
    }
}
