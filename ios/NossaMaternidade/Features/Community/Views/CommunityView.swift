import SwiftUI

struct CommunityView: View {
    @State private var service = MockCommunityService()
    @State private var posts: [PostDTO] = []
    @State private var selectedTag: CommunityTag = .all
    @State private var isLoading = true
    @State private var showNewPost = false
    @State private var errorMessage: String?
    @State private var selectedPost: PostDTO?
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    tagFilterBar
                    
                    if isLoading {
                        loadingState
                    } else if posts.isEmpty {
                        emptyState
                    } else {
                        postList
                    }
                }
            }
            .navigationTitle("Comunidade")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        AppHaptics.medium()
                        showNewPost = true
                    }) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 18))
                            .foregroundStyle(AppColors.primary)
                    }
                    .accessibilityLabel("Nova publicação")
                }
            }
        }
        .task {
            await loadPosts()
        }
        .sheet(isPresented: $showNewPost) {
            NewPostSheet { _ in
                Task { await loadPosts() }
            }
        }
        .sheet(item: $selectedPost) { post in
            PostDetailView(post: post, service: service)
        }
    }
    
    private var tagFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(CommunityTag.allCases, id: \.self) { tag in
                    Button(action: {
                        AppHaptics.selection()
                        selectedTag = tag
                        Task { await loadPosts() }
                    }) {
                        Text(tag.displayName)
                            .font(.system(size: 14, weight: .medium))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .foregroundStyle(selectedTag == tag ? .white : AppColors.textSecondary)
                            .background(selectedTag == tag ? AppColors.primary : AppColors.backgroundSecondary)
                            .clipShape(.rect(cornerRadius: 20))
                    }
                    .accessibilityLabel("Filtrar por \(tag.displayName)")
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
    
    private var postList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(posts) { post in
                    PostCard(post: post, service: service)
                        .onTapGesture {
                            AppHaptics.light()
                            selectedPost = post
                        }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .refreshable {
            await loadPosts()
        }
    }
    
    private var loadingState: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView()
                .scaleEffect(1.2)
                .tint(AppColors.primary)
            Text("Carregando mensagens de apoio...")
                .font(.system(size: 15))
                .foregroundStyle(AppColors.textSecondary)
            Spacer()
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "heart.text.square")
                .font(.system(size: 48))
                .foregroundStyle(AppColors.textTertiary)
            Text("Nenhuma publicação ainda")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppColors.textSecondary)
            Text("Seja a primeira a compartilhar sua jornada!")
                .font(.system(size: 15))
                .foregroundStyle(AppColors.textTertiary)
            Spacer()
        }
    }
    
    private func loadPosts() async {
        isLoading = true
        do {
            posts = try await service.fetchPosts(tag: selectedTag == .all ? nil : selectedTag.rawValue)
            errorMessage = nil
        } catch {
            errorMessage = "Não foi possível carregar as publicações. Tente novamente."
        }
        isLoading = false
    }
}
