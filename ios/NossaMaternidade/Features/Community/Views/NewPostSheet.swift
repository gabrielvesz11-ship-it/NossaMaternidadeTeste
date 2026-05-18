import SwiftUI

struct NewPostSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var content = ""
    @State private var selectedTag: CommunityTag = .support
    @State private var isAnonymous = false
    @State private var isPosting = false
    @State private var errorMessage: String?
    let onPosted: (PostDTO) -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 20) {
                            TextEditor(text: $content)
                                .font(.system(size: 17))
                                .frame(minHeight: 120)
                                .padding(12)
                                .background(AppColors.backgroundElevated)
                                .clipShape(.rect(cornerRadius: 16))
                                .overlay(
                                    Group {
                                        if content.isEmpty {
                                            Text("Compartilhe o que está sentindo... Estamos juntas.")
                                                .font(.system(size: 17))
                                                .foregroundStyle(AppColors.textTertiary)
                                                .padding(20)
                                                .allowsHitTesting(false)
                                        }
                                    },
                                    alignment: .topLeading
                                )
                                .accessibilityLabel("Texto da publicação")
                            
                            tagPicker
                            anonymityToggle
                        }
                        .padding(16)
                    }
                    
                    postButton
                }
            }
            .navigationTitle("Nova publicação")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") {
                        AppHaptics.light()
                        dismiss()
                    }
                    .foregroundStyle(AppColors.textSecondary)
                }
            }
        }
    }
    
    private var tagPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tag")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AppColors.textSecondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(CommunityTag.allCases.filter { $0 != .all }, id: \.self) { tag in
                        Button(action: {
                            AppHaptics.selection()
                            selectedTag = tag
                        }) {
                            Text(tag.displayName)
                                .font(.system(size: 14, weight: .medium))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .foregroundStyle(selectedTag == tag ? .white : AppColors.textSecondary)
                                .background(selectedTag == tag ? AppColors.primary : AppColors.backgroundSecondary)
                                .clipShape(.rect(cornerRadius: 20))
                        }
                    }
                }
            }
        }
    }
    
    private var anonymityToggle: some View {
        Toggle(isOn: $isAnonymous) {
            HStack(spacing: 12) {
                Image(systemName: "eye.slash.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(AppColors.primary)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Publicar anonimamente")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)
                    Text("Ninguém saberá que foi você")
                        .font(.system(size: 13))
                        .foregroundStyle(AppColors.textTertiary)
                }
            }
        }
        .tint(AppColors.primary)
        .padding(.vertical, 4)
    }
    
    private var postButton: some View {
        Button(action: {
            Task { await submitPost() }
        }) {
            if isPosting {
                ProgressView()
                    .tint(.white)
            } else {
                Text("Publicar")
                    .font(.system(size: 17, weight: .semibold))
            }
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(content.isEmpty ? AppColors.textTertiary : AppColors.primary)
        .clipShape(.rect(cornerRadius: 16))
        .padding(16)
        .disabled(content.isEmpty || isPosting)
        .accessibilityLabel("Botão publicar")
    }
    
    private func submitPost() async {
        guard !content.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        isPosting = true
        let service = MockCommunityService()
        
        do {
            let post = try await service.createPost(
                content: content,
                tag: selectedTag.rawValue,
                isAnonymous: isAnonymous
            )
            AppHaptics.success()
            onPosted(post)
            dismiss()
        } catch {
            AppHaptics.error()
            errorMessage = "Não foi possível publicar. Tente novamente."
            isPosting = false
        }
    }
}
