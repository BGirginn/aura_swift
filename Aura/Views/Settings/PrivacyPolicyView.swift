//
//  PrivacyPolicyView.swift
//  Aura
//
//  Created by Aura Team
//

import SwiftUI

struct PrivacyPolicyView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy Policy")
                    .font(.title.bold())
                    .foregroundColor(.auraText)
                
                policySection(title: "1. Data Processing", content: """
                Aura analyzes your photos entirely on-device. Images never leave your device and are deleted immediately after the aura analysis completes.
                """)
                
                policySection(title: "2. Storage & History", content: """
                When you save an aura result, only the generated colors, descriptions, and optional thumbnail data are stored locally on your device via Core Data. You can delete this history at any time.
                """)
                
                policySection(title: "3. Permissions", content: """
                • Camera access is required to capture new scans.\n• Photo Library access is optional and only used when you choose an existing photo.\n• Notification permission (optional) is only used for daily reminder prompts.
                """)
                
                policySection(title: "4. Analytics", content: """
                Analytics and crash reporting integrations are currently disabled in the base app. When enabled in a future release, data will only be used to improve stability and user experience.
                """)
                
                policySection(title: "5. Contact", content: """
                For privacy questions, contact us at \(AppConstants.supportEmail).
                """)
                
                Text("Last updated: \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none))")
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
    
    private func policySection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.auraAccent)
            Text(content)
                .foregroundColor(.auraText)
        }
    }
}

struct PrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PrivacyPolicyView()
        }
    }
}


