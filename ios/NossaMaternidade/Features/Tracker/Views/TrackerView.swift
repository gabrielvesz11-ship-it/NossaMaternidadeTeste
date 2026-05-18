import SwiftUI
import SwiftData

struct TrackerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TrackerLog.createdAt, order: .reverse) private var logs: [TrackerLog]
    @State private var selectedCategory: TrackerCategory = .feeding
    @State private var showLogSheet = false
    @State private var isNightMode = false
    
    var filteredLogs: [TrackerLog] {
        logs.filter { $0.category == selectedCategory }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                isNightMode ? AppColors.nightBackground : AppColors.background
                
                VStack(spacing: 0) {
                    categorySelector
                    
                    if filteredLogs.isEmpty {
                        emptyState
                    } else {
                        logList
                    }
                }
                .ignoresSafeArea(.container, edges: .bottom)
            }
            .navigationTitle("Registros")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        AppHaptics.medium()
                        showLogSheet = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(AppColors.primary)
                    }
                    .accessibilityLabel("Novo registro")
                }
            }
            .sheet(isPresented: $showLogSheet) {
                NewLogSheet(category: selectedCategory) { log in
                    modelContext.insert(log)
                }
            }
        }
        .onAppear {
            checkNightMode()
        }
    }
    
    private func checkNightMode() {
        let hour = Calendar.current.component(.hour, from: Date())
        isNightMode = hour >= 22 || hour < 6
    }
    
    private var categorySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TrackerCategory.allCases, id: \.self) { category in
                    Button(action: {
                        AppHaptics.selection()
                        selectedCategory = category
                    }) {
                        VStack(spacing: 6) {
                            Image(systemName: category.icon)
                                .font(.system(size: 20))
                            Text(category.displayName)
                                .font(.system(size: 11, weight: .medium))
                        }
                        .foregroundStyle(selectedCategory == category ? .white : (isNightMode ? AppColors.nightText : AppColors.textSecondary))
                        .frame(width: 72, height: 64)
                        .background(selectedCategory == category ? AppColors.primary : (isNightMode ? AppColors.nightSurface : AppColors.backgroundElevated))
                        .clipShape(.rect(cornerRadius: 16))
                        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                    }
                    .accessibilityLabel("Categoria \(category.displayName)")
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
    
    private var logList: some View {
        List {
            ForEach(filteredLogs) { log in
                LogRow(log: log)
                    .listRowBackground(isNightMode ? AppColors.nightSurface : AppColors.backgroundElevated)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
            }
            .onDelete(perform: deleteLogs)
        }
        .listStyle(.plain)
        .background(isNightMode ? AppColors.nightBackground : AppColors.background)
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: selectedCategory.icon)
                .font(.system(size: 48))
                .foregroundStyle(AppColors.textTertiary.opacity(0.5))
            Text("Nenhum registro de \(selectedCategory.displayName)")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(isNightMode ? AppColors.nightText.opacity(0.6) : AppColors.textSecondary)
            Text("Toque em + para adicionar o primeiro")
                .font(.system(size: 15))
                .foregroundStyle(AppColors.textTertiary)
            Spacer()
        }
    }
    
    private func deleteLogs(offsets: IndexSet) {
        for index in offsets {
            let log = filteredLogs[index]
            modelContext.delete(log)
        }
        AppHaptics.medium()
    }
}

struct LogRow: View {
    let log: TrackerLog
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(log.category.color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: log.category.icon)
                    .font(.system(size: 18))
                    .foregroundStyle(log.category.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(log.category.displayName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)
                
                if !log.notes.isEmpty {
                    Text(log.notes)
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                if log.value > 0 {
                    Text("\(Int(log.value))\(log.unit)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(AppColors.primary)
                }
                
                Text(log.createdAt, format: Date.FormatStyle(date: .omitted, time: .shortened))
                    .font(.system(size: 12))
                    .foregroundStyle(AppColors.textTertiary)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(AppColors.backgroundElevated)
        .clipShape(.rect(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 2)
    }
}

extension TrackerCategory {
    var color: Color {
        switch self {
        case .feeding: return Color(hex: "C2705A")
        case .sleep: return Color(hex: "7B8FA6")
        case .diaper: return Color(hex: "A68F8F")
        case .pumping: return Color(hex: "8FA68E")
        case .medication: return Color(hex: "A68FA6")
        case .temperature: return Color(hex: "D4A656")
        case .weight: return Color(hex: "6B9E75")
        case .mood: return Color(hex: "D9A08B")
        case .milestone: return Color(hex: "D4A656")
        }
    }
}
