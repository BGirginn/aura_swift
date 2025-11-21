//
//  CaptureOverlayView.swift
//  Aura
//
//  Created by Aura Team
//

import SwiftUI
import AVFoundation

struct CaptureOverlayView: View {
    
    let faceBounds: CGRect?
    let guideSize: CGSize
    
    var body: some View {
        ZStack {
            // Face detection overlay
            if let faceBounds = faceBounds {
                FaceOverlay(faceBounds: faceBounds, guideSize: guideSize)
            } else {
                // Guide frame when no face detected
                GuideFrame(size: guideSize)
            }
        }
    }
}

// MARK: - Face Overlay

struct FaceOverlay: View {
    let faceBounds: CGRect
    let guideSize: CGSize
    
    var body: some View {
        GeometryReader { geometry in
            let scaleX = geometry.size.width / guideSize.width
            let scaleY = geometry.size.height / guideSize.height
            
            let scaledBounds = CGRect(
                x: faceBounds.origin.x * scaleX,
                y: faceBounds.origin.y * scaleY,
                width: faceBounds.width * scaleX,
                height: faceBounds.height * scaleY
            )
            
            // Face detection rectangle
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.green, lineWidth: 2)
                .frame(width: scaledBounds.width, height: scaledBounds.height)
                .position(
                    x: scaledBounds.midX,
                    y: scaledBounds.midY
                )
            
            // Center indicator
            Circle()
                .fill(Color.green.opacity(0.3))
                .frame(width: 8, height: 8)
                .position(
                    x: scaledBounds.midX,
                    y: scaledBounds.midY
                )
        }
    }
}

// MARK: - Guide Frame

struct GuideFrame: View {
    let size: CGSize
    
    var body: some View {
        GeometryReader { geometry in
            let centerX = geometry.size.width / 2
            let centerY = geometry.size.height / 2
            let frameSize = min(geometry.size.width * 0.7, geometry.size.height * 0.7)
            
            // Outer guide frame
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.auraAccent.opacity(0.5), lineWidth: 2)
                .frame(width: frameSize, height: frameSize)
                .position(x: centerX, y: centerY)
            
            // Corner indicators
            let cornerLength: CGFloat = 30
            let cornerWidth: CGFloat = 3
            
            // Top-left
            Path { path in
                path.move(to: CGPoint(x: centerX - frameSize/2, y: centerY - frameSize/2))
                path.addLine(to: CGPoint(x: centerX - frameSize/2 + cornerLength, y: centerY - frameSize/2))
                path.move(to: CGPoint(x: centerX - frameSize/2, y: centerY - frameSize/2))
                path.addLine(to: CGPoint(x: centerX - frameSize/2, y: centerY - frameSize/2 + cornerLength))
            }
            .stroke(Color.auraAccent, lineWidth: cornerWidth)
            
            // Top-right
            Path { path in
                path.move(to: CGPoint(x: centerX + frameSize/2, y: centerY - frameSize/2))
                path.addLine(to: CGPoint(x: centerX + frameSize/2 - cornerLength, y: centerY - frameSize/2))
                path.move(to: CGPoint(x: centerX + frameSize/2, y: centerY - frameSize/2))
                path.addLine(to: CGPoint(x: centerX + frameSize/2, y: centerY - frameSize/2 + cornerLength))
            }
            .stroke(Color.auraAccent, lineWidth: cornerWidth)
            
            // Bottom-left
            Path { path in
                path.move(to: CGPoint(x: centerX - frameSize/2, y: centerY + frameSize/2))
                path.addLine(to: CGPoint(x: centerX - frameSize/2 + cornerLength, y: centerY + frameSize/2))
                path.move(to: CGPoint(x: centerX - frameSize/2, y: centerY + frameSize/2))
                path.addLine(to: CGPoint(x: centerX - frameSize/2, y: centerY + frameSize/2 - cornerLength))
            }
            .stroke(Color.auraAccent, lineWidth: cornerWidth)
            
            // Bottom-right
            Path { path in
                path.move(to: CGPoint(x: centerX + frameSize/2, y: centerY + frameSize/2))
                path.addLine(to: CGPoint(x: centerX + frameSize/2 - cornerLength, y: centerY + frameSize/2))
                path.move(to: CGPoint(x: centerX + frameSize/2, y: centerY + frameSize/2))
                path.addLine(to: CGPoint(x: centerX + frameSize/2, y: centerY + frameSize/2 - cornerLength))
            }
            .stroke(Color.auraAccent, lineWidth: cornerWidth)
            
            // Center crosshair
            Path { path in
                path.move(to: CGPoint(x: centerX - 20, y: centerY))
                path.addLine(to: CGPoint(x: centerX + 20, y: centerY))
                path.move(to: CGPoint(x: centerX, y: centerY - 20))
                path.addLine(to: CGPoint(x: centerX, y: centerY + 20))
            }
            .stroke(Color.auraAccent.opacity(0.5), lineWidth: 1)
        }
    }
}

