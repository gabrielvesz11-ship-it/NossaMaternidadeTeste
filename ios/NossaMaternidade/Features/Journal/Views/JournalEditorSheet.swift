import SwiftUI

struct JournalEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    let entry: JournalEntry?
    let onSave: (JournalEntry) -> Void
    
    @State private var title = ""
    @State private var bodyText = ""
    @State private var selectedMood: MoodRating = .neutral
    @State private var selectedTags: [String] = []
    
    private let tagOptions = ["Sono", "Amamentação", "Cólica", "Mamãe", "Trabalho", "Família", "Saúde"]
    
    init(entry: JournalEntry?, onSave: @escaping (JournalEntry) -> Void) {
        self.entry = entry
        self.onSave = onSave
        
        if let entry = entry {
            self._title = State(initialValue: entry.title)
            self._bodyText = State(initialValue: entry.body)
            self._selectedMood = State(initialValue: entry.mood)
            self._selectedTags = State(initialValue: entry.tags)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        moodSelector
                        titleField
                        bodyEditor
                        tagSelector
                    }
                    .padding(20)
                }
            }
            .navigationTitle(entry == nil ? "Nova entrada" : "Editar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") {
                        AppHaptics.light()
                        dismiss()
                    }
                    .foregroundStyle(AppColors.textSecondary)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Salvar") {
                        saveEntry()
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(!bodyText.isEmpty ? AppColors.primary : AppColors.textTertiary)
                    .disabled(bodyText.isEmpty)
                }
            }
        }
    }
    
    private var moodSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Como você está se sentindo?")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AppColors.textSecondary)
            
            HStack(spacing: 12) {
                ForEach(MoodRating.allCases, id: \.self) { mood in
                    Button(action: {
                        AppHaptics.selection()
                        selectedMood = mood
                    }) {
                        VStack(spacing: 6) {
                            Text(mood.emoji)
                                .font(.system(size: 32))
                            Text(mood.label)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(selectedMood == mood ? mood.color : AppColors.textTertiary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedMood == mood ? mood.color.opacity(0.12) : AppColors.backgroundSecondary)
                        .clipShape(.rect(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(selectedMood == mood ? mood.color : Color.clear, lineWidth: 2)
                        )
                    }
                    .accessibilityLabel("Humor \(mood.label)")
                }
            }
        }
    }
    
    private var titleField: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Título (opcional)")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AppColors.textSecondary)
            
            TextField("Ex: Primeira noite em casa", text: $title)
                .font(.system(size: 17))
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .background(AppColors.backgroundSecondary)
                .clipShape(.rect(cornerRadius: 16))
                .accessibilityLabel("Título da entrada")
        }
    }
    
    private var bodyEditor: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Escreva o que está no coração")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AppColors.textSecondary)
            
            TextEditor(text: $bodyText)
                .font(.system(size: 17))
                .frame(minHeight: 160)
                .padding(12)
                .background(AppColors.backgroundSecondary)
                .clipShape(.rect(cornerRadius: 16))
                .overlay(
                    Group {
                        if bodyText.isEmpty {
                            Text("Não precisa ser perfeito. Só honesto.")
                                .font(.system(size: 17))
                                .foregroundStyle(AppColors.textTertiary)
                                .padding(16)
                                .allowsHitTesting(false)
                        }
                    },
                    alignment: .topLeading
                )
                .accessibilityLabel("Texto do diário")
        }
    }
    
    private var tagSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tags (opcional)")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AppColors.textSecondary)
            
            FlowLayout(spacing: 8) {
                ForEach(tagOptions, id: \.self) { tag in
                    Button(action: {
                        AppHaptics.selection()
                        if selectedTags.contains(tag) {
                            selectedTags.removeAll { $0 == tag }
                        } else {
                            selectedTags.append(tag)
                        }
                    }) {
                        Text(tag)
                            .font(.system(size: 14, weight: .medium))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .foregroundStyle(selectedTags.contains(tag) ? .white : AppColors.textSecondary)
                            .background(selectedTags.contains(tag) ? AppColors.primary : AppColors.backgroundSecondary)
                            .clipShape(.rect(cornerRadius: 20))
                    }
                    .accessibilityLabel("Tag \(tag)")
                }
            }
        }
    }
    
    private func saveEntry() {
        let newEntry = JournalEntry(
            id: entry?.id ?? UUID().uuidString,
            createdAt: entry?.createdAt ?? Date(),
            updatedAt: Date(),
            mood: selectedMood,
            title: title,
            body: bodyText,
            tags: selectedTags,
            isBookmarked: entry?.isBookmarked ?? false
        )
        AppHaptics.success()
        onSave(newEntry)
        dismiss()
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: result.positions[index].x + bounds.minX,
                                      y: result.positions[index].y + bounds.minY),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}
