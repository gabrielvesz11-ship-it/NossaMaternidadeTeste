import SwiftUI
import SwiftData

struct JournalView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JournalEntry.createdAt, order: .reverse) private var entries: [JournalEntry]
    @State private var showEditor = false
    @State private var editingEntry: JournalEntry?
    @State private var selectedMood: MoodRating?
    @State private var searchText = ""
    
    var filteredEntries: [JournalEntry] {
        let moodFiltered = selectedMood == nil ? entries : entries.filter { $0.mood == selectedMood }
        guard !searchText.isEmpty else { return moodFiltered }
        return moodFiltered.filter {
            $0.title.localizedStandardContains(searchText) ||
            $0.body.localizedStandardContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    moodFilterBar
                    
                    if entries.isEmpty {
                        emptyState
                    } else {
                        journalList
                    }
                }
            }
            .navigationTitle("Diário")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Buscar entradas...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        AppHaptics.medium()
                        editingEntry = nil
                        showEditor = true
                    }) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 20))
                            .foregroundStyle(AppColors.primary)
                    }
                    .accessibilityLabel("Nova entrada no diário")
                }
            }
        }
        .sheet(isPresented: $showEditor) {
            JournalEditorSheet(entry: editingEntry) { entry in
                if let existing = editingEntry {
                    existing.title = entry.title
                    existing.body = entry.body
                    existing.mood = entry.mood
                    existing.updatedAt = Date()
                } else {
                    modelContext.insert(entry)
                }
            }
        }
    }
    
    private var moodFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                Button(action: {
                    AppHaptics.selection()
                    selectedMood = nil
                }) {
                    Text("Todas")
                        .font(.system(size: 14, weight: .medium))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .foregroundStyle(selectedMood == nil ? .white : AppColors.textSecondary)
                        .background(selectedMood == nil ? AppColors.primary : AppColors.backgroundSecondary)
                        .clipShape(.rect(cornerRadius: 20))
                }
                
                ForEach(MoodRating.allCases, id: \.self) { mood in
                    Button(action: {
                        AppHaptics.selection()
                        selectedMood = (selectedMood == mood) ? nil : mood
                    }) {
                        HStack(spacing: 4) {
                            Text(mood.emoji)
                                .font(.system(size: 16))
                            Text(mood.label)
                                .font(.system(size: 13, weight: .medium))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .foregroundStyle(selectedMood == mood ? .white : AppColors.textSecondary)
                        .background(selectedMood == mood ? mood.color : AppColors.backgroundSecondary)
                        .clipShape(.rect(cornerRadius: 20))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
    
    private var journalList: some View {
        List {
            ForEach(filteredEntries) { entry in
                JournalEntryRow(entry: entry)
                    .listRowBackground(AppColors.backgroundElevated)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .onTapGesture {
                        AppHaptics.light()
                        editingEntry = entry
                        showEditor = true
                    }
            }
            .onDelete(perform: deleteEntries)
        }
        .listStyle(.plain)
        .background(AppColors.background)
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "book.closed")
                .font(.system(size: 48))
                .foregroundStyle(AppColors.textTertiary.opacity(0.5))
            Text("Seu diário está vazio")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppColors.textSecondary)
            Text("Registre seus pensamentos, mesmo os difíceis.")
                .font(.system(size: 15))
                .foregroundStyle(AppColors.textTertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
    }
    
    private func deleteEntries(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredEntries[index])
        }
        AppHaptics.medium()
    }
}

struct JournalEntryRow: View {
    let entry: JournalEntry
    
    var body: some View {
        HStack(spacing: 14) {
            Text(entry.mood.emoji)
                .font(.system(size: 32))
                .frame(width: 44)
            
            VStack(alignment: .leading, spacing: 4) {
                if !entry.title.isEmpty {
                    Text(entry.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(1)
                }
                
                Text(entry.body)
                    .font(.system(size: 14))
                    .foregroundStyle(AppColors.textSecondary)
                    .lineLimit(2)
                    .lineSpacing(2)
                
                Text(entry.createdAt, format: Date.FormatStyle(date: .abbreviated, time: .shortened))
                    .font(.system(size: 12))
                    .foregroundStyle(AppColors.textTertiary)
            }
            
            Spacer()
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(AppColors.backgroundElevated)
        .clipShape(.rect(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
    }
}
