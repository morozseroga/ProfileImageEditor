//
//  ProfileView.swift
//  ProfileImageEditor
//
//  Created by Сергій on 04.04.2025.
//

import SwiftUI
import PhotosUI


struct ProfileView: View {
    @State var pushNotification = false
    @State var faceID = false
    @State var profileImage: UIImage? = nil
    @State var selectedImage: UIImage? = nil
    @State var selectedPickerItem: PhotosPickerItem? = nil
    
    @State var isEditorPresented = false
    @State var isPhotoPickerPresenter = false
    @State var isConfirmationDialogPresented = false
    
    @State var editorOffset: CGSize = .zero
    @State var editorScale: CGFloat = 1
    
    var body: some View {
        NavigationView{
            VStack(spacing: 34) {
                VStack(spacing: 8) {
                    
                    if let profileImage = profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(.circle)
                            .onTapGesture {
                                isConfirmationDialogPresented = true
                            }
                            .overlay(alignment: .bottomTrailing) {
                                ZStack{
                                    Circle().foregroundStyle(.gray)
                                        .frame(width: 25, height: 25)
                                    Image(systemName: "pencil")
                                }
                                .offset(x: -5, y: -10)
                            }
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 120, height: 120)
                            .overlay {
                                Text("Tap to Add")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            .onTapGesture {
                                isPhotoPickerPresenter = true
                            }
                    }
                    
                    userInfo
                        .padding(.top)
                    section
                }
            }
            .padding(.horizontal)
            .navigationBarTitleDisplayMode(.inline)
            .photosPicker(
                isPresented: $isPhotoPickerPresenter,
                selection: $selectedPickerItem
            )
            .confirmationDialog("Avatar",
                                isPresented: $isConfirmationDialogPresented) {
                Button {
                    isEditorPresented = true
                } label: {
                    Text("Edit photo")
                }
                
                Button {
                    editorScale = 1
                    editorOffset = .zero
                    selectedPickerItem = nil
                    isPhotoPickerPresenter = true
                } label: {
                    Text("Chose new photo")
                }
            } message: {
                Text("Edit avatar")
            }
            .onChange(of: selectedPickerItem) { _, newValue in
                Task{
                    if let newImage = await newValue?.loadUIImage() {
                        selectedImage = newImage
                    }
                }
            }
            .onChange(of: selectedImage) { oldValue, newValue in
                guard newValue != nil else { return }
                isEditorPresented = true
            }
            .fullScreenCover(isPresented: $isEditorPresented) {
                EditorView($profileImage,
                           selectedImage: selectedImage,
                           scale: $editorScale,
                           offset: $editorOffset)
            }
        }
    }
    
    var section: some View {
        Group{
            SectionView(title: "Inventories") {
                ProfileRow(icon: "building.2", title: "My stories", badgeCount: 2)
                ProfileRow(icon: "questionmark.circle", title: "Support")
            }
            
            SectionView(title: "Preferences") {
                ToggleRow(icon: "bell", title: "Push notification", isOn: $pushNotification)
                ToggleRow(icon: "faceid", title: "Face ID", isOn: $faceID)
                NavigationLinkRow(icon: "key", title: "PIN Code")
                NavigationLinkRow(icon: "arrowshape.turn.up.left", title: "Logout")
            }
        }
    }
    
    var userInfo: some View {
        VStack(spacing: 4) {
            Text("SUCODEE")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("user.name@example")
                .foregroundColor(.gray)
            
            Button("Edit profile") {
                
            }
            .font(.subheadline.bold())
            .foregroundColor(.black)
            .padding(.vertical, 8)
            .padding(.horizontal, 28)
            .background(.white, in: Capsule())
            .padding(.top)
        }
    }
}

struct SectionView<Content: View>: View {
    let title: String
    let content: Content
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.gray)
            VStack(spacing: 0) {
                content
            }
            .background(.gray.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct ProfileRow: View {
    let icon: String
    let title: String
    var badgeCount: Int? = nil
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)
            Text(title)
            Spacer()
            if let count = badgeCount {
                Text("\(count)")
                    .font(.caption)
                    .padding(10)
                    .background(Circle().fill(Color.gray.opacity(0.2)))
            }
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
    }
}

struct ToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)
            Text(title)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding()
    }
}

struct NavigationLinkRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)
            Text(title)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
    }
}

#Preview {
    ProfileView()
}
