//
//  LocationView.swift
//  Queersicht
//
//  Created by Fabio Huwyler on 13.07.2024.
//

import SwiftUI

struct LocationView: View {
    var location: Location

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let imageUrl = URL(string: location.imageURL ?? "") {
                AsyncImage(url: imageUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                } placeholder: {
                    Color.gray
                        .frame(height: 200)
                }
            } else {
                Color.gray
                    .frame(height: 200)
            }

            Text(location.name)
                .font(.h1)

            Text(location.address)
                .font(.p1)

            if let description = location.description {
                Text(description)
                    .font(.p1)
            }

            if let accessibilityInfo = location.accessibilityInfo, !accessibilityInfo.isEmpty {
                Text("Accessibility Information")
                    .font(.h3)
                Text(accessibilityInfo)
                    .font(.p1)
            }
        }
        .padding()
    }
}
