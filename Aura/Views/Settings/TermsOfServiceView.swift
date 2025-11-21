//
//  TermsOfServiceView.swift
//  Aura
//
//  Created by Aura Team
//

import SwiftUI

struct TermsOfServiceView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Terms of Service")
                    .font(.title.bold())
                    .foregroundColor(.auraText)
                
                termsSection(title: "1. Acceptance", content: """
                By using Aura you agree to these terms. Do not use the app if you disagree with any part.
                """)
                
                termsSection(title: "2. Personal Use", content: """
                Aura is provided for personal wellness and entertainment purposes. Aura insights are not medical advice.
                """)
                
                termsSection(title: "3. User Content", content: """
                Photos you capture or import remain entirely yours. The app processes them locally and does not transmit them to any server.
                """)
                
                termsSection(title: "4. Premium Features", content: """
                Future releases may include paid content. Pricing and renewal terms will be presented clearly before any purchase.
                """)
                
                termsSection(title: "5. Liability", content: """
                Aura is provided “as is”. We are not liable for indirect or consequential damages arising from the use of the app.
                """)
                
                termsSection(title: "6. Contact & Updates", content: """
                We may update these terms as features evolve. For questions, contact \(AppConstants.supportEmail).
                """)
                
                Text("Effective date: \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none))")
                    .font(.footnote)
                    .foregroundColor(.auraTextSecondary)
            }
            .padding()
        }
        .background(Color.auraBackground.ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") { dismiss() }
                    .foregroundColor(.auraAccent)
            }
        }
    }
    
    private func termsSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.auraAccent)
            Text(content)
                .foregroundColor(.auraText)
        }
    }
}

struct TermsOfServiceView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TermsOfServiceView()
        }
    }
}


