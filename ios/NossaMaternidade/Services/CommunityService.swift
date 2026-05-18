import Foundation
import Combine

protocol CommunityServiceProtocol {
    func fetchPosts(tag: String?) async throws -> [PostDTO]
    func createPost(content: String, tag: String, isAnonymous: Bool) async throws -> PostDTO
    func fetchReplies(postID: String) async throws -> [ReplyDTO]
    func createReply(postID: String, content: String, isAnonymous: Bool) async throws -> ReplyDTO
    func likePost(postID: String) async throws
}

@Observable
final class MockCommunityService: CommunityServiceProtocol {
    private var posts: [PostDTO] = []
    private var replies: [String: [ReplyDTO]] = [:]
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        seedData()
    }
    
    func fetchPosts(tag: String?) async throws -> [PostDTO] {
        try await Task.sleep(for: .seconds(0.5))
        
        if let tag = tag, tag != "todos" {
            return posts.filter { $0.tags.contains(tag) }
        }
        return posts.sorted { $0.createdAt > $1.createdAt }
    }
    
    func createPost(content: String, tag: String, isAnonymous: Bool) async throws -> PostDTO {
        try await Task.sleep(for: .seconds(0.3))
        
        let post = PostDTO(
            id: UUID().uuidString,
            authorID: "current_user",
            authorName: isAnonymous ? "Anônima" : "Você",
            authorStage: "recem_nascido",
            content: content,
            createdAt: Date(),
            likes: 0,
            replyCount: 0,
            tags: [tag],
            isAnonymous: isAnonymous
        )
        posts.insert(post, at: 0)
        return post
    }
    
    func fetchReplies(postID: String) async throws -> [ReplyDTO] {
        try await Task.sleep(for: .seconds(0.3))
        return replies[postID] ?? []
    }
    
    func createReply(postID: String, content: String, isAnonymous: Bool) async throws -> ReplyDTO {
        try await Task.sleep(for: .seconds(0.2))
        
        let reply = ReplyDTO(
            id: UUID().uuidString,
            authorID: "current_user",
            authorName: isAnonymous ? "Anônima" : "Você",
            content: content,
            createdAt: Date(),
            isAnonymous: isAnonymous
        )
        
        if replies[postID] == nil {
            replies[postID] = []
        }
        replies[postID]?.append(reply)
        
        if let index = posts.firstIndex(where: { $0.id == postID }) {
            let updated = PostDTO(
                id: posts[index].id,
                authorID: posts[index].authorID,
                authorName: posts[index].authorName,
                authorStage: posts[index].authorStage,
                content: posts[index].content,
                createdAt: posts[index].createdAt,
                likes: posts[index].likes,
                replyCount: (posts[index].replyCount) + 1,
                tags: posts[index].tags,
                isAnonymous: posts[index].isAnonymous
            )
            posts[index] = updated
        }
        
        return reply
    }
    
    func likePost(postID: String) async throws {
        try await Task.sleep(for: .seconds(0.1))
        if let index = posts.firstIndex(where: { $0.id == postID }) {
            let updated = PostDTO(
                id: posts[index].id,
                authorID: posts[index].authorID,
                authorName: posts[index].authorName,
                authorStage: posts[index].authorStage,
                content: posts[index].content,
                createdAt: posts[index].createdAt,
                likes: posts[index].likes + 1,
                replyCount: posts[index].replyCount,
                tags: posts[index].tags,
                isAnonymous: posts[index].isAnonymous
            )
            posts[index] = updated
        }
    }
    
    private func seedData() {
        posts = [
            PostDTO(
                id: "1",
                authorID: "user1",
                authorName: "Mariana",
                authorStage: "recem_nascido",
                content: "3 da manhã e o bebê não para de chorar. Sinto que estou falhando em tudo. Alguém mais passa por isso?",
                createdAt: Date().addingTimeInterval(-3600),
                likes: 24,
                replyCount: 8,
                tags: ["desabafo", "apoio"],
                isAnonymous: false
            ),
            PostDTO(
                id: "2",
                authorID: "user2",
                authorName: "Anônima",
                authorStage: "gravida",
                content: "Descobri que estou grávida hoje! Ansiosa e feliz ao mesmo tempo. Quando foi que vocês contaram pra família?",
                createdAt: Date().addingTimeInterval(-7200),
                likes: 56,
                replyCount: 15,
                tags: ["duvida"],
                isAnonymous: true
            ),
            PostDTO(
                id: "3",
                authorID: "user3",
                authorName: "Carla",
                authorStage: "bebe",
                content: "Meu bebê deu o primeiro sorriso hoje! Chorei tanto. Esses momentos valem cada noite sem dormir.",
                createdAt: Date().addingTimeInterval(-18000),
                likes: 112,
                replyCount: 22,
                tags: ["marco"],
                isAnonymous: false
            ),
            PostDTO(
                id: "4",
                authorID: "user4",
                authorName: "Fernanda",
                authorStage: "crianca",
                content: "Dica de mãe: misturar abobrinha ralada no macarrão é a única forma que encontrei de fazer meu filho comer legumes.",
                createdAt: Date().addingTimeInterval(-86400),
                likes: 89,
                replyCount: 31,
                tags: ["dica"],
                isAnonymous: false
            ),
            PostDTO(
                id: "5",
                authorID: "user5",
                authorName: "Anônima",
                authorStage: "tentando",
                content: "Mais um ciclo negativo. Estou desanimada mas não desistindo. Para quem também está tentando: força!",
                createdAt: Date().addingTimeInterval(-172800),
                likes: 45,
                replyCount: 12,
                tags: ["desabafo", "apoio"],
                isAnonymous: true
            )
        ]
        
        replies = [
            "1": [
                ReplyDTO(
                    id: "r1",
                    authorID: "user6",
                    authorName: "Julia",
                    content: "Você não está falhando! Cólicas são normais. Tenta fazer o exercício de contato pele a pele, ajudou muito com meu bebê.",
                    createdAt: Date().addingTimeInterval(-3300),
                    isAnonymous: false
                ),
                ReplyDTO(
                    id: "r2",
                    authorID: "user7",
                    authorName: "Anônima",
                    content: "Já passamos por isso. Passa, prometo. O botão de pânico do app salvou minha sanidade mental.",
                    createdAt: Date().addingTimeInterval(-3000),
                    isAnonymous: true
                )
            ]
        ]
    }
}
