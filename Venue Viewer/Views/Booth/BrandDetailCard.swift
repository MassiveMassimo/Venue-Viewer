//
//  BrandDetailCard.swift
//  Venue Viewer
//
//  Created by Mirabella on 27/07/25.
//

import SwiftUI

struct BrandDetailCard: View {
    let booth: Booth
    @Binding var isExpanded: Bool
    @Binding var selectedDest: Landmark
    let landmarks: [Landmark]
    
    @State private var flashSaleText: String = ""
    @State private var timer: Timer?
    
    @Environment(\.dismiss) private var dismiss
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(booth.boothName)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("Peak hours")
                    .font(.caption)
                    .foregroundColor(Color.red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
            }
            
            Text(booth.categories.first ?? "")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 12)
            
            Divider()
            HStack(spacing: 31) {
                HStack {
                    Image(systemName: "figure.walk")
                        .foregroundColor(.pink)
                    Text("300 m")
                }
                
                Rectangle()
                    .frame(width: 1, height: 20)
                    .foregroundColor(.gray.opacity(0.4))
                
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.pink)
                    Text("1 min")
                }
                
                Rectangle()
                    .frame(width: 1, height:20)
                    .foregroundColor(.gray.opacity(0.4))
                
                Text("Hall \(booth.hall)")
            }
            .font(.subheadline)
            .padding(.top, 4)
            .padding(.bottom, 4)
            
            Divider()
            
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.purple)
                Text("Next Flash Sale in")
                Text(flashSaleText)
                    .fontWeight(.semibold)
                
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .font(.subheadline)
            .padding(.top, 12)
            .padding(.bottom, 12)
            
            Button(action: {
                if let matchedLandmark = landmarks.first(where: { $0.name == booth.locName }) {
                    selectedDest = matchedLandmark
                }
                isExpanded = false
                dismiss()
            }) {
                Text("Navigate")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 0.835, green: 0.169, blue: 0.31)) // #D52B4F
                    .cornerRadius(12)
            }
            .padding(.top, 4)
        }
        .onAppear {
            updateFlashSaleText()
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                updateFlashSaleText()
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .padding()
    }
    
    private func format(_ interval: TimeInterval) -> String {
        let totalSeconds = Int(interval)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d : %02d : %02d", hours, minutes, seconds)
    }
    
    private func updateFlashSaleText() {
        let now = Date()
        if let current = booth.flashSaleSchedule?.first(where: { $0.interval.contains(now) }) {
            let remaining = current.interval.end.timeIntervalSince(now)
            flashSaleText = "Now"
        } else if let upcoming = booth.flashSaleSchedule?
            .filter({ $0.interval.start > now })
            .sorted(by: { $0.interval.start < $1.interval.start })
            .first {
            let untilStart = upcoming.interval.start.timeIntervalSince(now)
            flashSaleText = "\(format(untilStart))"
        } else {
            flashSaleText = "None"
        }
        
    }
    
}

//#Preview {
//    BrandDetailCard()
//}
