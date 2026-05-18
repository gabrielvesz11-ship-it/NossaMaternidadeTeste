import SwiftUI

struct PostDetailView: View {
    let post: PostDTO
    let service: MockCommunityService
    @Environment(\.dismiss) private var dismiss
    @State private var replies: [ReplyDTO] = []
    @State private var newReply = ""
    @State private var isLoading = true
    @State private var isAnonymous = false
    @State private var isSending = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 16) {
                            PostCard(post: post, service: service)
                            
                            if isLoading {
                                ProgressView()
                                    .padding(.vertical, 20)
                            } else if replies.isEmpty {
                                emptyRepliesState
                            } else {
                                repliesSection
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    
                    replyInputBar
                }
            }
            .navigationTitle("Publicação")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fechar") {
                        dismiss()
                    }
                    .foregroundStyle(AppColors.textSecondary)
                }
            }
        }
        .task {
            await loadReplies()
        }
    }
    
    private var emptyRepliesState: some View {
        VStack(spacing: 12) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 36))
                .foregroundStyle(AppColors.textTertiary)
            Text("Nenhuma resposta ainda")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(AppColors.textSecondary)
            Text("Seja a primeira a apoiar")
                .font(.system(size: 13))
                .foregroundStyle(AppColors.textTertiary)
        }
        .padding(.vertical, 32)
    }
    
    private var repliesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\(replies.count) respostas")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AppColors.textSecondary)
                .padding(.horizontal, 4)
            
            ForEach(replies) { reply in
                ReplyRow(reply: reply)
            }
        }
    }
    
    private var replyInputBar: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 12) {
                Toggle("", isOn: $isAnonymous)
                    .toggleStyle(AnonymousToggleStyle())
                
                TextField("Escreva um apoio...", text: $newReply)
                    .font(.system(size: 16))
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                    .background(AppColors.backgroundSecondary)
                    .clipShape(.rect(cornerRadius: 20))
                    .accessibilityLabel("Campo de resposta")
                
                Button(action: {
                    Task { await sendReply() }
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(newReply.isEmpty ? AppColors.textTertiary : AppColors.primary)
                }
                .disabled(newReply.isEmpty || isSending)
                .accessibilityLabel("Enviar resposta")
                .frame(minWidth: 44, minHeight: 44)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(AppColors.backgroundElevated)
        }
    }
    
    private func loadReplies() async {
        guard let id = post.id else { return }
        isLoading = true
        do {
            replies = try await service.fetchReplies(postID: id)
        } catch {
            replies = []
        }
        isLoading = false
    }
    
    private func sendReply() async {
        guard let postID = post.id,
              !newReply.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        isSending = true
        do {
            let reply = try await service.createReply(
                postID: postID,
                content: newReply,
                isAnonymous: isAnonymous
            )
            AppHaptics.success()
            replies.append(reply)
            newReply = ""
        } catch {
            AppHaptics.error()
        }
        isSending = false
    }
}

struct ReplyRow: View {
    let reply: ReplyDTO
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppColors.accentLight.opacity(0.4))
                    .frame(width: 36, height: 36)
                
                Text(String(reply.authorName.prefix(1)))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColors.accent)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(reply.authorName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Text(reply.formattedDate)
                        .font(.system(size: 12))
                        .foregroundStyle(AppColors.textTertiary)
                }
                
                Text(reply.content)
                    .font(.system(size: 15))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .background(AppColors.backgroundElevated)
        .clipShape(.rect(cornerRadius: 16))
    }
}

struct AnonymousToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }) {
            Image(systemName: configuration.isOn ? "eye.slash.fill" : "eye.fill")
                .font(.system(size: 20))
                .foregroundStyle(configuration.isOn ? AppColors.primary : AppColors.textTertiary)
        }
        .frame(minWidth: 44, minHeight: 44)
        .accessibilityLabel(configuration.isOn ? "Anônimo ativado" : "Anônimo desativado")
    }
}
