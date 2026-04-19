//
//  FoodRow.swift
//  Mensa
//
//  Created by Philipp on 13.05.23.
//  Copyright © 2023 Philipp. All rights reserved.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

struct FoodRow: View {
    @ObservedObject var food: Food
    @Binding var priceGroup: Int
    var onTap: (() -> Void)? = nil

    private var isClosedFood: Bool {
        food.name.localizedCaseInsensitiveContains("geschlossen")
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
#if !os(watchOS)
            if !isClosedFood {
                CachedMealCardImageView(url: food.imageURL)
            }
#endif

            VStack(alignment: .leading, spacing: 6) {
                Text(food.name)
                    .fixedSize(horizontal: false, vertical: true)

                if !isClosedFood {
                    HStack(spacing: 8) {
                        HStack(spacing: 6) {
                            if food.ratingsCount > 0, let averageRating = food.averageRating {
                                HStack(spacing: 2) {
                                    Image(systemName: "star.fill")
                                    Text(String(format: "%.1f", averageRating))
                                }
                                .font(.system(size: 10))
                                .foregroundColor(.orange)
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: false)
                            }
                            
                            Text(NSLocalizedString(String(describing: food.foodClass), comment: Constants.EMPTY))
                                .font(.system(size: 10))
                                .italic()
                                .lineLimit(1)
                        }
                        .layoutPriority(1)

                        Spacer(minLength: 8)

                        if !food.prices.isEmpty && food.prices.indices.contains(self.priceGroup) && food.prices[self.priceGroup] != 0.0 {
                            Text(food.prices[self.priceGroup].Euro)
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: false)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
#if os(iOS)
        .contentShape(Rectangle())
        .onTapGesture {
            if !isClosedFood {
                onTap?()
            }
        }
#endif
        .transaction { transaction in
            transaction.animation = nil
        }
    }
}


struct ClosedRow: View {
    let info: String
    var body: some View {
        Text(info).font(.system(size: 12)).foregroundColor(Color.gray).frame(maxWidth: .infinity, alignment: .center)
    }
}

#if os(iOS)
private struct CachedMealCardImageView: View {
    let url: URL?
    @StateObject private var loader: CachedMealImageLoader

    init(url: URL?) {
        self.url = url
        _loader = StateObject(wrappedValue: CachedMealImageLoader(url: url))
    }

    var body: some View {
        if let url {
            Group {
                if let image = loader.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color(.secondarySystemFill))
                        .overlay {
                            ProgressView()
                        }
                }
            }
            .frame(width: 65, height: 65)
            .clipped()
            .cornerRadius(8)
            .onAppear {
                loader.loadIfNeeded()
            }
        }
    }
}

final class CachedMealImageLoader: ObservableObject {
    static let memoryCache = NSCache<NSURL, UIImage>()

    @Published var image: UIImage?

    private let url: URL?
    private var hasStartedLoading = false

    init(url: URL?) {
        self.url = url

        guard let url else {
            return
        }

        if let cachedImage = Self.memoryCache.object(forKey: url as NSURL) {
            self.image = cachedImage
            self.hasStartedLoading = true
            return
        }

        if let data = cachedImageData(for: url), let diskImage = UIImage(data: data) {
            Self.memoryCache.setObject(diskImage, forKey: url as NSURL)
            self.image = diskImage
            self.hasStartedLoading = true
        }
    }

    func loadIfNeeded() {
        guard let url, !hasStartedLoading else {
            return
        }

        hasStartedLoading = true
        var request = URLRequest(url: url)
        request.cachePolicy = .returnCacheDataElseLoad
        request.timeoutInterval = 20

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data, let image = UIImage(data: data) else { return }
            storeCachedImageData(data, for: url)
            Self.memoryCache.setObject(image, forKey: url as NSURL)
            DispatchQueue.main.async {
                self.image = image
            }
        }.resume()
    }
}
#endif

#Preview {
    FoodRow(
        food: Food(name: "Schnitzel mit extrem langen Zutaten, Salat, Soße, Zitronenscheiben, lecker mit ganz viel Zutaten und viel Soße hmm fein", bio: true, allergens: ["Sa", "So", "We", "Se", "Ei", "Ml"], prices: [3.40, 3.40, 3.40], foodClass: FoodClass.vegetarian, nutritionalInfo: NutritionalInfo(energy: "1", proteins: "1", carbohydrates: "1", sugar: "1", fat: "1", saturatedFat: "1", salt: "1", co2Value: "1", co2Score: 1, waterValue: "1", waterScore: 1, animalWelfareScore: 1, rainforestScore: 1, environmentScore: 1), imageURL: URL("url.com")!, averageRating: 4.3, ratingsCount: 3),
        priceGroup: .constant(0)
    )
}
