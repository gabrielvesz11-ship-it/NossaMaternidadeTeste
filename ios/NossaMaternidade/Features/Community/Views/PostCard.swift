import SwiftUI

struct PostCard: View {
    let post: PostDTO
    let service: MockCommunityService
    @State private var isLiked = false
    @State private var likes: Int
    
    init(post: PostDTO, service: MockCommunityService) {
        self.post = post
        self.service = service
        self._likes = State(initialValue: post.likes)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                avatar
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.authorName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)
                    
                    Text(post.formattedDate)
                        .font(.system(size: 13))
                        .foregroundStyle(AppColors.textTertiary)
                }
                
                Spacer()
                
                if post.isAnonymous {
                    Text("Anônimo")
                        .font(.system(size: 11, weight: .medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .foregroundStyle(AppColors.textTertiary)
                        .background(AppColors.backgroundSecondary)
                        .clipShape(.rect(cornerRadius: 8))
                }
            }
            
            Text(post.content)
                .font(.system(size: 15))
                .foregroundStyle(AppColors.textPrimary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
            
            tagChips
            
            Divider()
                .background(AppColors.backgroundSecondary)
            
            actionBar
        }
        .padding(16)
        .background(AppColors.backgroundElevated)
        .clipShape(.rect(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Publicação de \(post.authorName)")
    }
    
    private var avatar: some View {
        ZStack {
            Circle()
                .fill(AppColors.primaryLight.opacity(0.4))
                .frame(width: 40, height: 40)
            
            Text(String(post.authorName.prefix(1)))
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColors.primary)
        }
    }
    
    private var tagChips: some View {
        HStack(spacing: 6) {
            ForEach(post.tags, id: \.self) { tag in
                Text(tag.uppercased())
                    .font(.system(size: 10, weight: .semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .foregroundStyle(AppColors.primary)
                    .background(AppColors.primaryLight.opacity(0.2))
                    .clipShape(.rect(cornerRadius: 6))
            }
        }
    }
    
    private var actionBar: some View {
        HStack(spacing: 24) {
            Button(action: {
                AppHaptics.light()
                isLiked.toggle()
                likes += isLiked ? 1 : -1
                Task {
                    if let id = post.id {
                        try? await service.likePost(postID: id)
                    }
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 16))
                        .foregroundStyle(isLiked ? AppColors.danger : AppColors.textTertiary)
                    Text("\(likes)")
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.textTertiary)
                }
            }
            .accessibilityLabel("\(likes) curtidas")
            
            HStack(spacing: 4) {
                Image(systemName: "bubble.right")
                    .font(.system(size: 16))
                    .foregroundStyle(AppColors.textTertiary)
                Text("\(post.replyCount)")
                    .font(.system(size: 14))
                    .foregroundStyle(AppColors.textTertiary)
            }
            .accessibilityLabel("\(post.replyCount) respostas")
            
            Spacer()
        }
        .frame(minHeight: 44)
    }
}
