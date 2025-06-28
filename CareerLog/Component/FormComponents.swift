//
//  FormComponents.swift
//  CareerLog
//
//  Created by 伊藤真依 on 2025/06/27.
//

import SwiftUI

// MARK: - FormLabel
struct FormLabel: View {
    let text: String
    let isRequired: Bool
    
    init(text: String, isRequired: Bool = false) {
        self.text = text
        self.isRequired = isRequired
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.careerLogPrimaryText)
            
            if isRequired {
                Text("*")
                    .font(.subheadline)
                    .foregroundColor(.careerLogError)
            }
            
            Spacer()
        }
    }
}

// MARK: - Text Field Styles
struct CareerLogTextFieldStyle: TextFieldStyle {
    let isFocused: Bool
    
    init(isFocused: Bool = false) {
        self.isFocused = isFocused
    }
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.careerLogCardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isFocused ? Color.careerLogPrimary : Color.careerLogBorder,
                        lineWidth: isFocused ? 2 : 1
                    )
            )
    }
}

// MARK: - Picker Button Style
struct PickerButtonView: View {
    let title: String
    let placeholder: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(isSelected ? title : placeholder)
                    .foregroundColor(isSelected ? .careerLogPrimaryText : .careerLogSecondaryText)
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .foregroundColor(.careerLogSecondaryText)
                    .font(.caption)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.careerLogCardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.careerLogBorder, lineWidth: 1)
            )
        }
    }
}

// MARK: - Navigation Picker Button (with chevron.right)
struct NavigationPickerButtonView: View {
    let title: String
    let placeholder: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(isSelected ? title : placeholder)
                    .foregroundColor(isSelected ? .careerLogPrimaryText : .careerLogSecondaryText)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.careerLogSecondaryText)
                    .font(.caption)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.careerLogCardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.careerLogBorder, lineWidth: 1)
            )
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        FormLabel(text: "案件名", isRequired: true)
        FormLabel(text: "業界")
        
        TextField("案件名を入力", text: .constant(""))
            .textFieldStyle(CareerLogTextFieldStyle())
        
        PickerButtonView(
            title: "Web・EC",
            placeholder: "業界を選択",
            isSelected: true,
            action: {}
        )
        
        NavigationPickerButtonView(
            title: "3個の技術を選択済み",
            placeholder: "技術を選択",
            isSelected: true,
            action: {}
        )
    }
    .padding()
    .background(Color.careerLogBackground)
}
