import SwiftUI

struct NewLogSheet: View {
    @Environment(\.dismiss) private var dismiss
    let category: TrackerCategory
    let onSave: (TrackerLog) -> Void
    
    @State private var value: Double = 0
    @State private var notes = ""
    @State private var date = Date()
    @State private var unit: String
    @State private var showNumberPicker = false
    
    init(category: TrackerCategory, onSave: @escaping (TrackerLog) -> Void) {
        self.category = category
        self.onSave = onSave
        self._unit = State(initialValue: category.defaultUnit)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        categoryHeader
                        
                        if !category.quickActions.isEmpty {
                            quickActionsRow
                        }
                        
                        valueInput
                        notesInput
                        datePicker
                    }
                    .padding(20)
                }
            }
            .navigationTitle(category.displayName)
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
                        saveLog()
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(AppColors.primary)
                    .disabled(value == 0 && category != .diaper)
                }
            }
        }
    }
    
    private var categoryHeader: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(category.color.opacity(0.15))
                    .frame(width: 60, height: 60)
                
                Image(systemName: category.icon)
                    .font(.system(size: 28))
                    .foregroundStyle(category.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Novo registro")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppColors.textTertiary)
                Text(category.displayName)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
            }
            
            Spacer()
        }
    }
    
    private var quickActionsRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Registro rápido")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AppColors.textSecondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(category.quickActions) { action in
                        Button(action: {
                            AppHaptics.selection()
                            value = action.value
                            unit = action.unit
                        }) {
                            VStack(spacing: 4) {
                                Text(action.label)
                                    .font(.system(size: 15, weight: .semibold))
                                Text("\(Int(action.value))\(action.unit)")
                                    .font(.system(size: 13))
                            }
                            .foregroundStyle(AppColors.primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(AppColors.primaryLight.opacity(0.15))
                            .clipShape(.rect(cornerRadius: 14))
                        }
                        .accessibilityLabel("Registro rápido \(action.label)")
                    }
                }
            }
        }
    }
    
    private var valueInput: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Valor")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AppColors.textSecondary)
            
            HStack(spacing: 12) {
                TextField("0", value: $value, format: .number)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 16)
                    .background(AppColors.backgroundSecondary)
                    .clipShape(.rect(cornerRadius: 16))
                    .frame(maxWidth: .infinity)
                    .accessibilityLabel("Valor do registro")
                
                Text(unit)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(width: 50)
            }
            
            if category == .diaper {
                HStack(spacing: 10) {
                    ForEach(["Xixi", "Cocô", "Misto"], id: \.self) { type in
                        Button(action: {
                            AppHaptics.selection()
                            notes = type
                        }) {
                            Text(type)
                                .font(.system(size: 14, weight: .medium))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .foregroundStyle(notes == type ? .white : AppColors.textSecondary)
                                .background(notes == type ? AppColors.primary : AppColors.backgroundSecondary)
                                .clipShape(.rect(cornerRadius: 12))
                        }
                    }
                }
            }
        }
    }
    
    private var notesInput: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Observações (opcional)")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AppColors.textSecondary)
            
            TextEditor(text: $notes)
                .font(.system(size: 16))
                .frame(minHeight: 80)
                .padding(12)
                .background(AppColors.backgroundSecondary)
                .clipShape(.rect(cornerRadius: 16))
                .overlay(
                    Group {
                        if notes.isEmpty {
                            Text("Algo mais para lembrar?")
                                .font(.system(size: 16))
                                .foregroundStyle(AppColors.textTertiary)
                                .padding(16)
                                .allowsHitTesting(false)
                        }
                    },
                    alignment: .topLeading
                )
        }
    }
    
    private var datePicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quando?")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AppColors.textSecondary)
            
            DatePicker("", selection: $date)
                .datePickerStyle(.compact)
                .padding(12)
                .background(AppColors.backgroundSecondary)
                .clipShape(.rect(cornerRadius: 16))
                .accessibilityLabel("Data e hora do registro")
        }
    }
    
    private func saveLog() {
        let log = TrackerLog(
            createdAt: date,
            category: category,
            value: value,
            notes: notes,
            unit: unit
        )
        AppHaptics.success()
        onSave(log)
        dismiss()
    }
}
