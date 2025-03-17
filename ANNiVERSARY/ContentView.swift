import SwiftUI

struct ContentView: View {
    @AppStorage("anniversaryDate") private var storedAnniversaryDate: Double = Date().timeIntervalSince1970

    private var anniversaryDate: Date {
        get { Date(timeIntervalSince1970: storedAnniversaryDate) }
        set { storedAnniversaryDate = newValue.timeIntervalSince1970 }
    }

    @State private var showingEditSheet = false
    @State private var showingDeveloperConsole = false

    private let lightModeGradients: [Gradient] = [
        Gradient(colors: [Color.red, Color.orange]),
        Gradient(colors: [Color.blue, Color.purple]),
        Gradient(colors: [Color.green, Color.yellow]),
        Gradient(colors: [Color.pink, Color.teal]),
        Gradient(colors: [Color.indigo, Color.cyan])
    ]
    private let darkModeGradients: [Gradient] = [
        Gradient(colors: [Color.black, Color.gray]),
        Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
        Gradient(colors: [Color.green.opacity(0.6), Color.teal.opacity(0.6)]),
        Gradient(colors: [Color.orange.opacity(0.6), Color.red.opacity(0.6)]),
        Gradient(colors: [Color.indigo.opacity(0.6), Color.black])
    ]

    @Environment(\.colorScheme) var colorScheme
    @State private var selectedGradient: Gradient

    init() {
        let isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
        let gradients = isDarkMode ? darkModeGradients : lightModeGradients
        _selectedGradient = State(initialValue: gradients.randomElement() ?? Gradient(colors: [Color.white, Color.gray]))
    }

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: selectedGradient,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Anniversary")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .padding()

                Text("Ihr seid seit:")
                    .font(.headline)
                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.8))
                
                let result = daysSince(anniversaryDate)
                
                Text("\(result.days)")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .padding(.vertical, 10)
                
                Text(result.isInFuture ? "Tage bis zu diesem Datum" : "\(result.days == 1 ? "Tag" : "Tagen") ein Paar")
                    .font(.headline)
                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.8))

                Spacer()

                Button(action: {
                    showingEditSheet = true
                }) {
                    Text("Jahrestag bearbeiten")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(colorScheme == .dark ? Color.white.opacity(0.2) : Color.black.opacity(0.1))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }

                if isDateFarInTheFuture(anniversaryDate) {
                    Button(action: {
                        showingDeveloperConsole.toggle()
                    }) {
                        Text("🛠 Entwicklerkonsole öffnen")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.2))
                            .foregroundColor(.red)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                }
            }
            .padding()
        }
        .sheet(isPresented: $showingEditSheet) {
            EditDateView(selectedDate: anniversaryDate) { newDate in
                storedAnniversaryDate = newDate.timeIntervalSince1970
                selectedGradient = colorScheme == .dark
                    ? darkModeGradients.randomElement() ?? Gradient(colors: [Color.black, Color.gray])
                    : lightModeGradients.randomElement() ?? Gradient(colors: [Color.white, Color.gray])
            }
        }
        .sheet(isPresented: $showingDeveloperConsole) {
            DeveloperConsoleView(selectedDate: anniversaryDate) { newDate in
                storedAnniversaryDate = newDate.timeIntervalSince1970
            }
        }
    }

    // Updated function to handle past and future dates
    func daysSince(_ date: Date) -> (days: Int, isInFuture: Bool) {
        let components = Calendar.current.dateComponents([.day], from: Date(), to: date)
        let days = components.day ?? 0
        return (abs(days), days > 0)
    }

    // Checks if the date is more than 30 years into the future
    func isDateFarInTheFuture(_ date: Date) -> Bool {
        let today = Date()
        let futureLimit = Calendar.current.date(byAdding: .year, value: 30, to: today)!
        return date > futureLimit
    }
}

// DeveloperConsoleView and EditDateView remain unchanged
struct DeveloperConsoleView: View {
    @State var selectedDate: Date
    var onSave: (Date) -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("🛠 Entwicklerkonsole")
                    .font(.title)
                    .padding()

                Text("Aktueller Jahrestag: \(formattedDate(selectedDate))")
                    .font(.headline)
                    .padding()

                Button("Jahrestag zurücksetzen") {
                    selectedDate = Date()
                }
                .foregroundColor(.red)
                .padding()

                Spacer()

                Button("Schließen") {
                    onSave(selectedDate)
                    dismiss()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding()
        }
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}

struct EditDateView: View {
    @State var selectedDate: Date
    var onSave: (Date) -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            DatePicker("Wähle ein Datum", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()

            Button("Speichern") {
                onSave(selectedDate)
                dismiss()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)

            Button("Abbrechen") {
                dismiss()
            }
            .padding()
        }
        .padding()
    }
}
