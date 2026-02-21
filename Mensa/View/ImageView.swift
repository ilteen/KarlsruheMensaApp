//
//  ImageView.swift
//  Mensa
//
//  Created by Philipp on 06.02.26.
//

import SwiftUI

struct ImageView: View {
    let name: String
    let imageURL: URL
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                
                Text(self.name).bold().font(.headline)
                
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: 300)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                    case .failure(_):
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 160, height: 160)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ImageView(name: "test", imageURL: apiURL.appending(path: "image/81f51fb2-1fdb-42c4-8ff3-7b5d2edd8779.jpg"))
}
