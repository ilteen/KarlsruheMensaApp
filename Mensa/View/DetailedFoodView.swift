//
//  DetailedFoodView.swift
//  Mensa
//
//  Created by Philipp on 06.02.26.
//

import SwiftUI
#if os(iOS)
import PhotosUI
import UIKit
#endif

struct DetailedFoodView: View {
    @ObservedObject var food: Food
    @State private var uploadInProgress = false
    @State private var ratingInProgress = false
    @State private var feedbackMessage: String?
    @State private var showRatingSheet = false
    @State private var selectedImageIndex = 0
#if os(iOS)
    @State private var showImageSourceDialog = false
    @State private var showImagePicker = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary
#endif

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    foodHeader
                    foodImage
                        .padding(.vertical, 5)
                    ratingsSection.padding(.horizontal, 10)
                    if food.nutritionalInfo != nil {
                        sectionCard(title: NSLocalizedString("Nutritional Information", comment: "Nutrition section title")) {
                            NutritionalInfoView(food: food)
                        }
                    }
                    if !food.allergens.isEmpty {
                        sectionCard(title: NSLocalizedString("Allergens", comment: "Allergen section title")) {
                            Text(allergensLongString(allergens: food.allergens))
                                .font(.subheadline.monospaced())
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 10) {
                            ratingButton
                            photoUploadSection.disabled(true)
                        }
                        if uploadInProgress {
                            ProgressView(NSLocalizedString("Uploading...", comment: "Upload progress"))
                        }
                        if ratingInProgress {
                            ProgressView(NSLocalizedString("Saving rating...", comment: "Save rating progress"))
                        }
                        if let feedbackMessage {
                            Text(feedbackMessage)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("")
            .sheet(isPresented: $showRatingSheet) {
                RateMealSheet(
                    currentRating: food.personalRating,
                    onSave: { rating in
                        rateMeal(rating)
                    }
                )
            }
#if os(iOS)
            .confirmationDialog(NSLocalizedString("Upload photo", comment: "Upload confirmation dialog title"), isPresented: $showImageSourceDialog, titleVisibility: .visible) {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    Button(NSLocalizedString("Take Photo", comment: "Open camera button")) {
                        imagePickerSourceType = .camera
                        showImagePicker = true
                    }
                }
                Button(NSLocalizedString("Choose from Library", comment: "Open photo library button")) {
                    imagePickerSourceType = .photoLibrary
                    showImagePicker = true
                }
                Button(NSLocalizedString("Cancel", comment: "Cancel action"), role: .cancel) { }
            }
            .sheet(isPresented: photoLibraryPickerBinding) {
                imagePickerView(sourceType: .photoLibrary)
            }
            .fullScreenCover(isPresented: cameraPickerBinding) {
                imagePickerView(sourceType: .camera)
                    .ignoresSafeArea()
            }
#endif
        }
    }

    private var foodHeader: some View {
        HStack {
            foodTitleText
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var foodTitleText: Text {
        let baseText = Text(food.name)
            .font(.title2.weight(.semibold))
            .foregroundColor(.primary)

        guard food.foodClass != .nothing else {
            return baseText
        }

        let foodClassLabel = NSLocalizedString(String(describing: food.foodClass), comment: Constants.EMPTY)

        return baseText + Text("  (\(foodClassLabel))")
            .font(.subheadline)
            .italic()
            .foregroundColor(.secondary)
    }
    
    private var foodImage: some View {
        Group {
            if !foodImages.isEmpty {
                VStack(spacing: 8) {
                    TabView(selection: $selectedImageIndex) {
                        ForEach(Array(foodImages.enumerated()), id: \.element.id) { index, imageEntry in
                            CachedMealHeroImageView(url: imageEntry.url, placeholder: placeholderImage)
                                .tag(index)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 263, maxHeight: 360)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .tabViewStyle(.page(indexDisplayMode: foodImages.count > 1 ? .automatic : .never))
                }
            }
        }
        .onChange(of: foodImages.count) { newCount in
            selectedImageIndex = min(selectedImageIndex, max(0, newCount - 1))
        }
    }

    private var foodImages: [FoodImageEntry] {
        let entries = food.imageEntries
        if !entries.isEmpty {
            return entries
        }
        if let imageURL = food.imageURL {
            return [FoodImageEntry(id: imageURL.absoluteString, url: imageURL, rank: nil, personalDownvote: nil, personalUpvote: nil, downvotes: nil, upvotes: nil)]
        }
        return []
    }
    
    private var placeholderImage: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color(.secondarySystemFill))
            .frame(maxWidth: .infinity, minHeight: 220, maxHeight: 280)
            .overlay {
                Image(systemName: "photo")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundStyle(.secondary)
            }
    }
    
    private var ratingsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                if let averageRating = food.averageRating {
                    Label(String(format: "%.1f", averageRating), systemImage: "star.fill")
                        .foregroundStyle(.yellow)
                }
                if food.ratingsCount > 0 {
                    Text("\(food.ratingsCount) \(NSLocalizedString("ratings", comment: "Ratings count suffix"))")
                        .foregroundStyle(.secondary)
                } else {
                    Text(NSLocalizedString("No ratings yet", comment: "No ratings placeholder"))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if let personalRating = food.personalRating {
                    HStack(spacing: 4) {
                        Text(NSLocalizedString("Your rating:", comment: "Personal meal rating label"))
                        Image(systemName: "star.fill")
                        Text("\(personalRating)")
                    }
                    .foregroundStyle(.secondary)
                }
            }
            .font(.subheadline)
        }
    }
    
    private var ratingButton: some View {
        Button {
            showRatingSheet = true
        } label: {
            Label(NSLocalizedString("Rate meal", comment: "Rate meal button"), systemImage: "star.fill")
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .frame(maxWidth: .infinity, minHeight: 34, maxHeight: 34)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: 8))
        .tint(.orange)
        .disabled(food.apiMealID == nil || ratingInProgress)
    }
    
    @ViewBuilder
    private var photoUploadSection: some View {
        Button {
#if os(iOS)
            showImageSourceDialog = true
#endif
        } label: {
            Label(NSLocalizedString("Upload photo", comment: "Upload photo button"), systemImage: "camera")
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .frame(maxWidth: .infinity, minHeight: 34, maxHeight: 34)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: 8))
        .tint(.blue)
        .disabled(uploadInProgress || food.apiMealID == nil)
    }
    
    private func sectionCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            content()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
    
    private func rateMeal(_ rating: Int) {
        ratingInProgress = true
        Repository.shared.rateMeal(food, rating: rating) { success in
            ratingInProgress = false
            if success {
                food.personalRating = rating
                feedbackMessage = NSLocalizedString("Thanks for rating.", comment: "Rating success message")
            } else {
                feedbackMessage = NSLocalizedString("Rating failed. Please try again.", comment: "Rating failure message")
            }
        }
    }

    private func uploadImageData(_ data: Data) {
        uploadInProgress = true
        Repository.shared.uploadImage(food: food, imageData: data) { success in
            uploadInProgress = false
            feedbackMessage = success
                ? NSLocalizedString("Image uploaded.", comment: "Upload success message")
                : NSLocalizedString("Upload failed. Please try again.", comment: "Upload failure message")
        }
    }

#if os(iOS)
    private var cameraPickerBinding: Binding<Bool> {
        Binding(
            get: { showImagePicker && imagePickerSourceType == .camera },
            set: { newValue in
                if !newValue {
                    showImagePicker = false
                }
            }
        )
    }

    private var photoLibraryPickerBinding: Binding<Bool> {
        Binding(
            get: { showImagePicker && imagePickerSourceType == .photoLibrary },
            set: { newValue in
                if !newValue {
                    showImagePicker = false
                }
            }
        )
    }

    private func imagePickerView(sourceType: UIImagePickerController.SourceType) -> some View {
        ImagePicker(sourceType: sourceType) { image in
            guard let jpeg = image.jpegData(compressionQuality: 0.85) else {
                feedbackMessage = NSLocalizedString("Image could not be loaded.", comment: "Image picker failure")
                return
            }
            uploadImageData(jpeg)
        }
    }
#endif
    
}

#if os(iOS)
private struct CachedMealHeroImageView<Placeholder: View>: View {
    let url: URL
    let placeholder: Placeholder
    @StateObject private var loader: CachedMealImageLoader

    init(url: URL, placeholder: Placeholder) {
        self.url = url
        self.placeholder = placeholder
        _loader = StateObject(wrappedValue: CachedMealImageLoader(url: url))
    }
    
    var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, minHeight: 250, maxHeight: 350)
                    .clipped()
            } else {
                placeholder
            }
        }
        .onAppear {
            loader.loadIfNeeded()
        }
        .onChange(of: url) { _ in
            loader.loadIfNeeded()
        }
    }
}
#endif

private struct RateMealSheet: View {
    let currentRating: Int?
    let onSave: (Int) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedRating: Int = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text(NSLocalizedString("Select rating", comment: "Rating sheet title"))
                    .font(.headline)
                
                HStack(spacing: 12) {
                    ForEach(1...5, id: \.self) { rating in
                        Button {
                            selectedRating = rating
                        } label: {
                            Image(systemName: selectedRating >= rating ? "star.fill" : "star")
                                .font(.title2)
                                .foregroundStyle(.yellow)
                        }
                        .buttonStyle(.plain)
                    }
                }
                Spacer()
            }
            .padding()
            .navigationTitle(NSLocalizedString("Rate meal", comment: "Rate meal navigation title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("Cancel", comment: "Cancel action")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(NSLocalizedString("Save", comment: "Save action")) {
                        onSave(selectedRating)
                        dismiss()
                    }
                    .disabled(selectedRating == 0)
                }
            }
        }
        .onAppear {
            selectedRating = currentRating ?? 0
        }
    }
}

#if os(iOS)
private struct ImagePicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    let onImagePicked: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        picker.modalPresentationStyle = .fullScreen
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        private let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImagePicked(image)
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
#endif

#Preview {
    DetailedFoodView(
        food: Food(
            name: "Beispielessen mit extrem langer Beschreibung und zusätzlich sogar noch Salat",
            bio: true,
            allergens: ["ML", "SE", "WE"],
            prices: [4.60, 5.20, 4.00, 3.60],
            foodClass: .vegetarian,
            nutritionalInfo: NutritionalInfo(energy: "744", proteins: "41", carbohydrates: "94", sugar: "1", fat: "20", saturatedFat: "9", salt: "1", co2Value: "1109", co2Score: 2, waterValue: "29180", waterScore: 3, animalWelfareScore: 1, rainforestScore: 1, environmentScore: 1),
            imageURL: apiURL.appending(path: "image/81f51fb2-1fdb-42c4-8ff3-7b5d2edd8779.jpg"),
            averageRating: 3.8,
            ratingsCount: 42,
            personalRating: 4
        )
    )
}
