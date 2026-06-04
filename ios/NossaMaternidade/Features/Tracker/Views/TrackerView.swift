import PhotosUI
import SwiftData
import SwiftUI
import UIKit

struct TrackerView: View {
    @Environment(AppServices.self) private var services
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WeeklyJournalEntry.updatedAt, order: .reverse) private var entries: [WeeklyJournalEntry]
    let profile: UserProfile?
    let isPremium: Bool
    @State private var selectedMood: JournalMood = .onda
    @State private var selectedSymptoms: Set<String> = []
    @State private var note = ""
    @State private var showAllSymptoms = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var localPhotoURI: String?
    @State private var isSaving = false
    @State private var errorMessage: String?

    private let symptoms = [
        "enjoo", "sono", "azia", "dor nas costas", "ansiedade",
        "inchaço", "fome", "cólicas leves", "cansaço", "sensibilidade"
    ]

    private var userID: String {
        profile?.id ?? "local"
    }

    private var currentWeek: Int {
        PregnancyCalculator.currentWeek(dueDate: profile?.dueDate) ?? 1
    }

    private var currentEntry: WeeklyJournalEntry? {
        entries.first { $0.userID == userID && $0.pregnancyWeek == currentWeek }
    }

    private var visibleSymptoms: [String] {
        showAllSymptoms ? symptoms : Array(symptoms.prefix(5))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Space.x6) {
                    TrackerHeader(week: currentWeek)

                    MoodSection(selectedMood: $selectedMood)

                    SymptomsSection(
                        symptoms: visibleSymptoms,
                        selectedSymptoms: $selectedSymptoms,
                        showAllSymptoms: $showAllSymptoms,
                        canExpand: !showAllSymptoms
                    )

                    NoteSection(note: $note)

                    PhotoSection(selectedPhoto: $selectedPhoto, localPhotoURI: localPhotoURI)

                    if let errorMessage {
                        InlineErrorBanner(message: errorMessage)
                    }

                    PrimaryButton(isSaving ? "Guardando..." : "Guardar minha semana", isLoading: isSaving, action: saveWeek)
                }
                .padding(.horizontal, AppTheme.Space.x6)
                .padding(.vertical, AppTheme.Space.x8)
            }
            .premiumScreenBackground()
            .navigationTitle("Diário")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            hydrateFromExistingEntry()
            await syncPendingEntries()
        }
        .onChange(of: selectedPhoto) { _, item in
            guard let item else { return }
            Task { await storePhoto(item) }
        }
    }

    private func hydrateFromExistingEntry() {
        guard let entry = currentEntry else { return }
        selectedMood = JournalMood(rawValue: entry.mood) ?? .onda
        selectedSymptoms = Set(entry.symptoms)
        note = entry.note
        localPhotoURI = entry.localPhotoURI
    }

    private func storePhoto(_ item: PhotosPickerItem) async {
        do {
            guard let data = try await item.loadTransferable(type: Data.self) else { return }
            let entryID = currentEntry?.id ?? UUID().uuidString
            let localURL = try LocalPhotoStore.saveJPEGData(data, entryID: entryID)
            await MainActor.run {
                localPhotoURI = localURL.absoluteString
            }
        } catch {
            await MainActor.run {
                errorMessage = "Não consegui guardar essa foto agora."
            }
        }
    }

    private func saveWeek() {
        isSaving = true
        errorMessage = nil
        let entry = currentEntry ?? WeeklyJournalEntry(
            userID: userID,
            pregnancyWeek: currentWeek,
            mood: selectedMood.rawValue
        )

        entry.mood = selectedMood.rawValue
        entry.symptoms = Array(selectedSymptoms).sorted()
        entry.note = note.trimmingCharacters(in: .whitespacesAndNewlines)
        entry.localPhotoURI = localPhotoURI
        entry.updatedAt = Date()
        entry.syncStatus = .pending

        if currentEntry == nil {
            modelContext.insert(entry)
        }

        try? modelContext.save()
        AppHaptics.success()

        Task {
            await sync(entry, showStatus: true)
        }
    }

    private func syncPendingEntries() async {
        let pending = entries.filter { $0.userID == userID && $0.syncStatus == .pending }
        for entry in pending {
            await sync(entry, showStatus: false)
        }
    }

    private func sync(_ entry: WeeklyJournalEntry, showStatus: Bool) async {
        do {
            if let uri = entry.localPhotoURI,
               entry.remotePhotoURL == nil,
               let url = LocalPhotoStore.url(from: uri) {
                let remoteURL = try await services.supabase.uploadJournalPhoto(
                    localURL: url,
                    userID: profile?.anonymousUserID ?? userID,
                    entryID: entry.id
                )
                await MainActor.run {
                    entry.remotePhotoURL = remoteURL
                }
            }

            try await services.supabase.upsertJournalEntry(entry)
            await MainActor.run {
                entry.syncStatus = .synced
                if showStatus {
                    isSaving = false
                }
                try? modelContext.save()
            }
        } catch {
            await MainActor.run {
                entry.syncStatus = .pending
                if showStatus {
                    isSaving = false
                    errorMessage = "Semana guardada no aparelho. Vou sincronizar quando der."
                }
                try? modelContext.save()
            }
        }
    }
}

private struct TrackerHeader: View {
    let week: Int

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Space.x3) {
            Text("Diário semanal")
                .font(AppTheme.FontToken.caption)
                .foregroundStyle(AppTheme.ColorToken.accentPrimary)
                .textCase(.uppercase)

            Text("Como foi a semana \(week)?")
                .font(AppTheme.FontToken.display)
                .foregroundStyle(AppTheme.ColorToken.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Text("Guarda só o que fizer sentido. Sem pressão.")
                .font(AppTheme.FontToken.body)
                .foregroundStyle(AppTheme.ColorToken.textSecondary)
        }
    }
}

private struct MoodSection: View {
    @Binding var selectedMood: JournalMood

    var body: some View {
        PremiumCard {
            VStack(alignment: .leading, spacing: AppTheme.Space.x4) {
                Text("Seu clima de hoje")
                    .font(AppTheme.FontToken.bodyStrong)
                    .foregroundStyle(AppTheme.ColorToken.textPrimary)

                HStack(spacing: AppTheme.Space.x2) {
                    ForEach(JournalMood.allCases) { mood in
                        MoodButton(mood: mood, isSelected: selectedMood == mood) {
                            AppHaptics.selection()
                            selectedMood = mood
                        }
                    }
                }
            }
        }
    }
}

private struct MoodButton: View {
    let mood: JournalMood
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: AppTheme.Space.x1) {
                Image(systemName: mood.symbolName)
                    .font(.system(size: 20, weight: .semibold))
                Text(mood.label)
                    .font(AppTheme.FontToken.caption)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
            .foregroundStyle(isSelected ? .white : AppTheme.ColorToken.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .background(isSelected ? AppTheme.ColorToken.accentPrimary : AppTheme.ColorToken.backgroundPrimary)
            .clipShape(.rect(cornerRadius: AppTheme.Radius.card))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                    .stroke(AppTheme.ColorToken.borderSubtle)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Humor \(mood.label)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private struct SymptomsSection: View {
    let symptoms: [String]
    @Binding var selectedSymptoms: Set<String>
    @Binding var showAllSymptoms: Bool
    let canExpand: Bool

    var body: some View {
        PremiumCard {
            VStack(alignment: .leading, spacing: AppTheme.Space.x4) {
                Text("O que apareceu no corpo?")
                    .font(AppTheme.FontToken.bodyStrong)
                    .foregroundStyle(AppTheme.ColorToken.textPrimary)

                FlowLayout(spacing: AppTheme.Space.x2) {
                    ForEach(symptoms, id: \.self) { symptom in
                        SecondaryPill(title: symptom, isSelected: selectedSymptoms.contains(symptom)) {
                            toggle(symptom)
                        }
                    }

                    if canExpand {
                        SecondaryPill(title: "ver mais", isSelected: false) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.88)) {
                                showAllSymptoms = true
                            }
                        }
                    }
                }
            }
        }
    }

    private func toggle(_ symptom: String) {
        AppHaptics.selection()
        if selectedSymptoms.contains(symptom) {
            selectedSymptoms.remove(symptom)
        } else {
            selectedSymptoms.insert(symptom)
        }
    }
}

private struct NoteSection: View {
    @Binding var note: String

    var body: some View {
        PremiumCard {
            VStack(alignment: .leading, spacing: AppTheme.Space.x3) {
                Text("Quer guardar algo sobre essa semana?")
                    .font(AppTheme.FontToken.bodyStrong)
                    .foregroundStyle(AppTheme.ColorToken.textPrimary)

                TextField("Escreve aqui, se quiser", text: $note, axis: .vertical)
                    .font(AppTheme.FontToken.body)
                    .lineLimit(3...6)
                    .padding(AppTheme.Space.x3)
                    .background(AppTheme.ColorToken.backgroundPrimary)
                    .clipShape(.rect(cornerRadius: AppTheme.Radius.card))
                    .accessibilityLabel("Nota opcional da semana")
            }
        }
    }
}

private struct PhotoSection: View {
    @Binding var selectedPhoto: PhotosPickerItem?
    let localPhotoURI: String?

    var body: some View {
        PremiumCard {
            VStack(alignment: .leading, spacing: AppTheme.Space.x3) {
                HStack {
                    VStack(alignment: .leading, spacing: AppTheme.Space.x1) {
                        Text("Foto da barriga")
                            .font(AppTheme.FontToken.bodyStrong)
                            .foregroundStyle(AppTheme.ColorToken.textPrimary)

                        Text("Uma por semana, do seu jeito.")
                            .font(AppTheme.FontToken.caption)
                            .foregroundStyle(AppTheme.ColorToken.textSecondary)
                    }

                    Spacer()

                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(AppTheme.ColorToken.accentPrimary)
                            .clipShape(.circle)
                    }
                    .accessibilityLabel("Adicionar foto da barriga")
                }

                if let image = localImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 180)
                        .frame(maxWidth: .infinity)
                        .clipShape(.rect(cornerRadius: AppTheme.Radius.card))
                        .clipped()
                        .accessibilityLabel("Foto da barriga selecionada")
                }
            }
        }
    }

    private var localImage: UIImage? {
        guard let url = LocalPhotoStore.url(from: localPhotoURI) else { return nil }
        return UIImage(contentsOfFile: url.path)
    }
}

private struct FlowLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var size = CGSize.zero
        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let subviewSize = subview.sizeThatFits(.unspecified)
            if lineWidth + subviewSize.width > width, lineWidth > 0 {
                size.height += lineHeight + spacing
                size.width = max(size.width, lineWidth - spacing)
                lineWidth = 0
                lineHeight = 0
            }
            lineWidth += subviewSize.width + spacing
            lineHeight = max(lineHeight, subviewSize.height)
        }

        size.height += lineHeight
        size.width = max(size.width, lineWidth - spacing)
        return size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var origin = bounds.origin
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let subviewSize = subview.sizeThatFits(.unspecified)
            if origin.x + subviewSize.width > bounds.maxX, origin.x > bounds.minX {
                origin.x = bounds.minX
                origin.y += lineHeight + spacing
                lineHeight = 0
            }

            subview.place(at: origin, proposal: ProposedViewSize(subviewSize))
            origin.x += subviewSize.width + spacing
            lineHeight = max(lineHeight, subviewSize.height)
        }
    }
}

#Preview {
    if let container = try? ModelContainer(
        for: WeeklyJournalEntry.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    ) {
        TrackerView(
            profile: UserProfile(
                name: "Ana",
                dueDate: Calendar.current.date(byAdding: .weekOfYear, value: 14, to: Date()),
                hasCompletedOnboarding: true
            ),
            isPremium: false
        )
        .environment(AppServices())
        .modelContainer(container)
        .environment(\.locale, Locale(identifier: "pt_BR"))
    } else {
        Text("Preview indisponível")
    }
}
