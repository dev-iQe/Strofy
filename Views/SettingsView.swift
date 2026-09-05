import SwiftUI

struct SettingsView: View {
    @State private var notificationsEnabled = true
    @State private var language = "العربية"
    
    var body: some View {
        NavigationView {
            ZStack {
                // الخلفية بالثيم الأخضر الداكن الخاص بك
                Color(red: 0.05, green: 0.18, blue: 0.14)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // قسم الإعدادات (زجاجي متناسق مع الثيم)
                        VStack(alignment: .trailing, spacing: 15) {
                            Text("الإعدادات")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                            
                            Toggle("تفعيل الإشعارات", isOn: $notificationsEnabled)
                                .foregroundColor(.white)
                            
                            Button(action: {}) {
                                Text("حذف المكتبة المحفوظة")
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red.opacity(0.8))
                                    .cornerRadius(10)
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                        
                        // قسم المطور
                        VStack(spacing: 15) {
                            Text("المطور")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                            
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundColor(Color(red: 0.2, green: 0.85, blue: 0.5)) // أخضر مضيء
                            
                            Text("أنور العزاوي")
                                .font(.title)
                                .bold()
                                .foregroundColor(.white)
                            
                            Text("مطور تطبيقات ومواقع ويب")
                                .foregroundColor(.white.opacity(0.7))
                            
                            HStack(spacing: 25) {
                                SocialButton(icon: "camera.fill", user: "eng_azawy", color: .purple) // تم تصحيح اسم أيقونة انستغرام المتوافقة مع SF Symbols
                                SocialButton(icon: "video.fill", user: "eng_azawy", color: .yellow)
                                SocialButton(icon: "paperplane.fill", user: "bavarite", color: .blue) // تليجرام
                                SocialButton(icon: "globe", user: "eng_azawy", color: .white)
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true) // لإخفاء شريط العنوان الافتراضي ليبقى التصميم نظيفاً
        }
    }
}

struct SocialButton: View {
    let icon: String
    let user: String
    let color: Color
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text("@\(user)")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.8))
        }
    }
}
