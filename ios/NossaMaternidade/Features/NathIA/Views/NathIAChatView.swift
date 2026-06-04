import SwiftData
import SwiftUI

struct NathIAChatView: View {
    @Environment(AppServices.self) private var services
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ChatMessage.createdAt) private var allMessages: [ChatMessage]
    @Query private var allUsage: [DailyUsage]
    let profile: UserProfile?
    let isPremium: Bool
    let requestPaywall: () -> Void
    @State private var draft = ""
    @State private var isResponding = false
    @State private var errorMessage: String?

    private var userID: String {
        profile?.id ?? "local"
    }

    private var messages: [ChatMessage] {
        allMessages.filter { $0.userID == userID }
    }

    private var todayUsage: DailyUsage? {
        allUsage.first { $0.userID == userID && $0.dayKey == DateFormatter.localDayKey.string(from: Date()) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                NathIAHeader(isPremium: isPremium)

                Divider()
                    .overlay(AppTheme.ColorToken.borderSubtle)

                MessageScrollView(messages: messages, isResponding: isResponding)

                if let errorMessage {
                    InlineErrorBanner(message: errorMessage)
                        .padding(.horizontal, AppTheme.Space.x4)
                        .padding(.bottom, AppTheme.Space.x2)
                }

                ChatInputBar(text: $draft, isSending: isResponding, send: sendMessage)
                    .padding(.horizontal, AppTheme.Space.x4)
                    .padding(.bottom, AppTheme.Space.x3)
                    .background(AppTheme.ColorToken.backgroundPrimary)
            }
            .premiumScreenBackground()
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            triggerPaywallIfNeeded()
            syncPendingMessages()
        }
    }

    private func sendMessage() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isResponding else { return }
        guard canSendFreeMessage else {
            requestPaywall()
            return
        }

        AppHaptics.light()
        draft = ""
        errorMessage = nil
        let userMessage = ChatMessage(userID: userID, role: .user, content: text)
        modelContext.insert(userMessage)
        let usage = incrementUsage()
        try? modelContext.save()
        sync(message: userMessage, usage: usage)

        Task {
            await askNathIA(with: userMessage)
        }
    }

    private var canSendFreeMessage: Bool {
        if isPremium { return true }
        if shouldTriggerDayThreePaywall { return false }
        return (todayUsage?.nathiaMessageCount ?? 0) < 3
    }

    private var shouldTriggerDayThreePaywall: Bool {
        guard let createdAt = profile?.createdAt else { return false }
        let days = Calendar.current.dateComponents([.day], from: createdAt, to: Date()).day ?? 0
        return days >= 3
    }

    private func incrementUsage() -> DailyUsage {
        let usage = todayUsage ?? DailyUsage(userID: userID)
        usage.nathiaMessageCount += 1
        usage.updatedAt = Date()
        usage.syncStatus = .pending

        if todayUsage == nil {
            modelContext.insert(usage)
        }

        return usage
    }

    private func askNathIA(with userMessage: ChatMessage) async {
        await MainActor.run { isResponding = true }

        do {
            _ = try? await services.supabase.ensureAnonymousSession()
            let response = try await services.nathIA.send(messages: messages)
            await MainActor.run {
                saveAssistantResponse(response)
                isResponding = false
                triggerPaywallAfterThirdMessage()
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isResponding = false
                triggerPaywallAfterThirdMessage()
            }
        }
    }

    private func saveAssistantResponse(_ response: String) {
        let assistantMessage = ChatMessage(userID: userID, role: .assistant, content: response)
        modelContext.insert(assistantMessage)
        try? modelContext.save()
        sync(message: assistantMessage, usage: nil)
    }

    private func sync(message: ChatMessage, usage: DailyUsage?) {
        Task {
            do {
                try await services.supabase.insertChatMessage(message)
                if let usage {
                    try await services.supabase.upsertDailyUsage(usage)
                }
                await MainActor.run {
                    message.syncStatus = .synced
                    usage?.syncStatus = .synced
                    try? modelContext.save()
                }
            } catch {
                await MainActor.run {
                    message.syncStatus = .pending
                    usage?.syncStatus = .pending
                    try? modelContext.save()
                }
            }
        }
    }

    private func syncPendingMessages() {
        for message in messages where message.syncStatus == .pending {
            sync(message: message, usage: nil)
        }

        for usage in allUsage where usage.userID == userID && usage.syncStatus == .pending {
            Task {
                do {
                    try await services.supabase.upsertDailyUsage(usage)
                    await MainActor.run {
                        usage.syncStatus = .synced
                        try? modelContext.save()
                    }
                } catch { }
            }
        }
    }

    private func triggerPaywallIfNeeded() {
        guard !isPremium, shouldTriggerDayThreePaywall else { return }
        requestPaywall()
    }

    private func triggerPaywallAfterThirdMessage() {
        guard !isPremium, (todayUsage?.nathiaMessageCount ?? 0) >= 3 else { return }
        requestPaywall()
    }
}

private struct NathIAHeader: View {
    let isPremium: Bool

    var body: some View {
        HStack(spacing: AppTheme.Space.x3) {
            ZStack {
                Circle()
                    .fill(AppTheme.ColorToken.accentPrimary.opacity(0.14))
                Image(systemName: "sparkles")
                    .foregroundStyle(AppTheme.ColorToken.accentPrimary)
            }
            .frame(width: 44, height: 44)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: AppTheme.Space.x1) {
                Text("NathIA")
                    .font(AppTheme.FontToken.section)
                    .foregroundStyle(AppTheme.ColorToken.textPrimary)

                Text(isPremium ? "Sem limites hoje" : "3 mensagens grátis por dia")
                    .font(AppTheme.FontToken.caption)
                    .foregroundStyle(AppTheme.ColorToken.textSecondary)
            }

            Spacer()
        }
        .padding(AppTheme.Space.x4)
        .accessibilityElement(children: .combine)
    }
}

private struct MessageScrollView: View {
    let messages: [ChatMessage]
    let isResponding: Bool

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: AppTheme.Space.x3) {
                    if messages.isEmpty {
                        ChatBubble(
                            role: .assistant,
                            text: "Respira. Uma coisa de cada vez. Me conta o que você está sentindo agora — no corpo e no coração."
                        )
                        .id("starter")
                    }

                    ForEach(messages) { message in
                        ChatBubble(role: message.role, text: message.content)
                            .id(message.id)
                    }

                    if isResponding {
                        TypingBubble()
                            .id("typing")
                    }
                }
                .padding(AppTheme.Space.x4)
            }
            .onChange(of: messages.count) { _, _ in scrollToBottom(proxy) }
            .onChange(of: isResponding) { _, _ in scrollToBottom(proxy) }
        }
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        let target = isResponding ? "typing" : (messages.last?.id ?? "starter")
        withAnimation(.spring(response: 0.34, dampingFraction: 0.9)) {
            proxy.scrollTo(target, anchor: .bottom)
        }
    }
}

private struct ChatBubble: View {
    let role: ChatRole
    let text: String

    private var isUser: Bool {
        role == .user
    }

    var body: some View {
        HStack {
            if isUser { Spacer(minLength: AppTheme.Space.x12) }

            Text(LocalizedStringKey(text))
                .font(AppTheme.FontToken.body)
                .foregroundStyle(isUser ? .white : AppTheme.ColorToken.textPrimary)
                .padding(.horizontal, AppTheme.Space.x4)
                .padding(.vertical, AppTheme.Space.x3)
                .background(isUser ? AppTheme.ColorToken.accentPrimary : AppTheme.ColorToken.backgroundElevated)
                .clipShape(.rect(cornerRadius: 18))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(isUser ? Color.clear : AppTheme.ColorToken.borderSubtle)
                )
                .fixedSize(horizontal: false, vertical: true)

            if !isUser { Spacer(minLength: AppTheme.Space.x12) }
        }
        .accessibilityLabel(isUser ? "Você: \(text)" : "NathIA: \(text)")
    }
}

private struct TypingBubble: View {
    @State private var pulse = false

    var body: some View {
        HStack {
            HStack(spacing: AppTheme.Space.x1) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(AppTheme.ColorToken.accentPrimary.opacity(0.7))
                        .frame(width: 7, height: 7)
                        .scaleEffect(pulse ? 1.0 : 0.68)
                        .animation(
                            .easeInOut(duration: 0.62)
                            .repeatForever()
                            .delay(Double(index) * 0.12),
                            value: pulse
                        )
                }
            }
            .padding(.horizontal, AppTheme.Space.x4)
            .padding(.vertical, AppTheme.Space.x3)
            .background(AppTheme.ColorToken.backgroundElevated)
            .clipShape(.rect(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(AppTheme.ColorToken.borderSubtle)
            )

            Spacer(minLength: AppTheme.Space.x12)
        }
        .onAppear { pulse = true }
        .accessibilityLabel("NathIA está respondendo")
    }
}

private struct ChatInputBar: View {
    @Binding var text: String
    let isSending: Bool
    let send: () -> Void

    var body: some View {
        HStack(alignment: .bottom, spacing: AppTheme.Space.x3) {
            TextField("Escreve pra NathIA", text: $text, axis: .vertical)
                .font(AppTheme.FontToken.body)
                .lineLimit(1...4)
                .padding(.horizontal, AppTheme.Space.x4)
                .padding(.vertical, AppTheme.Space.x3)
                .background(AppTheme.ColorToken.backgroundElevated)
                .clipShape(.rect(cornerRadius: 24))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(AppTheme.ColorToken.borderSubtle)
                )
                .accessibilityLabel("Mensagem para NathIA")

            Button(action: send) {
                Image(systemName: isSending ? "hourglass" : "arrow.up")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(
                        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? AppTheme.ColorToken.textPrimary.opacity(0.25)
                            : AppTheme.ColorToken.accentPrimary
                    )
                    .clipShape(.circle)
            }
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSending)
            .accessibilityLabel("Enviar mensagem")
        }
    }
}

#Preview {
    if let container = try? ModelContainer(
        for: ChatMessage.self, DailyUsage.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    ) {
        NathIAChatView(
            profile: UserProfile(name: "Ana", hasCompletedOnboarding: true),
            isPremium: false,
            requestPaywall: {}
        )
        .environment(AppServices())
        .modelContainer(container)
        .environment(\.locale, Locale(identifier: "pt_BR"))
    } else {
        Text("Preview indisponível")
    }
}
