import SwiftUI

struct SettingsView: View {
    @State private var notificationsEnabled = true
    @State private var language = "العربية"
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.95, green: 0.95, blue: 0.95).edgesIgnoringSafeArea(.all) // أبيض غامق
                
                ScrollView {
                    VStack(spacing: 20) {
                        // قسم الإعدادات (زجاجي)
                        VStack(alignment: .trailing, spacing: 15) {
                            Text("الإعدادات").font(.title2).bold()
                            
                            Toggle("تفعيل الإشعارات", isOn: $notificationsEnabled)
                            
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
                        
                        // قسم المطور
                        VStack(spacing: 15) {
                            Text("المطور").font(.title2).bold()
                            
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                            
                            Text("أنور العزاوي").font(.title).bold()
                            Text("مطور تطبيقات ومواقع ويب").foregroundColor(.gray)
                            
                            HStack(spacing: 25) {
                                SocialButton(icon: "instagram", user: "eng_azawy", color: .purple)
                                SocialButton(icon: "snapchat", user: "eng_azawy", color: .yellow)
                                SocialButton(icon: "paperplane.fill", user: "bavarite", color: .blue) // تليجرام
                                SocialButton(icon: "tiktok", user: "eng_azawy", color: .black)
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(20)
                    }
                    .padding()
                }
            }
        }
    }
}

struct SocialButton: View {
    let icon: String
    let user: String
    let color: Color
    var body: some View {
        VStack {
            Image(systemName: icon) // يفضل استخدام صور حقيقية في assets
                .font(.title)
                .foregroundColor(color)
            Text("@\(user)")
                .font(.caption2)
        }
    }
}
