import SwiftUI

struct ContentNotesListView: View {
    let contentNotes: [ContentNote]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List(contentNotes) { note in
                HStack {
                    Text(note.id)
                        .font(.customBody)
                        .foregroundColor(.accentColor)
                        .frame(width: 60, alignment: .leading)
                    Text(note.title)
                        .font(.customBody)
                }
            }
            .navigationTitle("Content Notes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
