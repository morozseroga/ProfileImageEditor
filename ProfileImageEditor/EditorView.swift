//
//  EditorView.swift
//  ProfileImageEditor
//
//  Created by Сергій on 04.04.2025.
//

import SwiftUI
import PhotosUI

struct EditorView: View {
    let selectedImage: UIImage?
    
    @Binding var scale: CGFloat
    @State private var lastScale: CGFloat = 1.0
    @Binding var offset: CGSize
    @State private var lastOffset: CGSize = .zero
    @State private var showImagePicker: Bool = true
    
    @Binding var profileImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    let circleDiameter: CGFloat = 300
    
    init(
        _ profileImage: Binding<UIImage?>,
        selectedImage: UIImage?,
        scale: Binding<CGFloat>,
        offset: Binding<CGSize>
    ) {
        self.selectedImage = selectedImage
        _profileImage = profileImage
        _scale = scale
        _offset = offset
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .overlay {
                    Circle()
                        .frame(width: circleDiameter, height: circleDiameter)
                        .blendMode(.destinationOut)
                }
                .compositingGroup()
                .background{
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFill()
                            .scaleEffect(scale)
                            .offset(offset)
                    }
                }
                .clipped()
            HStack{
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .bold()
                        .foregroundStyle(.white)
                }
                Spacer()
                Button {
                    saveCroppedImage()
                } label: {
                    Text("Continue")
                        .bold()
                        .foregroundStyle(.black)
                        .frame(width: 120, height: 55)
                        .background(.white, in: .capsule)
                }
            }
            .padding()
            .padding(.bottom, 24)
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .ignoresSafeArea()
        .gesture (
            SimultaneousGesture(
                DragGesture()
                    .onChanged{ value in
                        let newOffset = CGSize(
                            width: lastOffset.width + value.translation.width,
                            height: lastOffset.height + value.translation.height
                        )
                        offset = clampedOffsetWithScreen(for: newOffset)
                    }
                    .onEnded { _ in
                        lastOffset = offset
                    },
                MagnificationGesture()
                    .onChanged{ value in
                        scale = lastScale * value
                    }
                    .onEnded{ _ in
                        lastScale = scale
                        offset = clampedOffsetWithScreen(for: offset)
                        lastOffset = offset
                    }
            )
        )
        .onAppear {
            scale = 1
            lastScale = 1
            offset = .zero
            lastOffset = .zero
        }
    }
    
    private func clampedOffsetWithScreen(for proposedOffset: CGSize) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let maxX = screenWidth / 2
        let maxY = screenHeight / 2
        
        return CGSize(
            width: min(max(proposedOffset.width, -maxX), maxX),
            height: min(max(proposedOffset.height, -maxY), maxY)
        )
    }
    
    private func saveCroppedImage() {
        guard selectedImage != nil else { return }
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let window = windowScene.windows.first else {
            return
        }
        
        let cropRect = CGRect(
            x: (UIScreen.main.bounds.width - circleDiameter) / 2,
            y: (UIScreen.main.bounds.height - circleDiameter) / 2,
            width: circleDiameter,
            height: circleDiameter
        )
        
        let renderer = UIGraphicsImageRenderer(bounds: cropRect)
        
        profileImage = renderer.image { _ in
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }
        
        dismiss()
    }
}

extension PhotosPickerItem {
    func loadUIImage() async -> UIImage? {
        if let data = try? await loadTransferable(type: Data.self),
           let image = UIImage(data: data) {
            return image
        } else {
            return nil
        }
    }
}

#Preview {
    Text("Test")
        .fullScreenCover(isPresented: .constant(true)) {
            EditorView(
                .constant(nil),
                selectedImage: UIImage(named: "14"),
                scale: .constant(1),
                offset: .constant(.zero)
            )
        }
}

