import SwiftUI

struct Theme: Codable, Identifiable, Equatable {
    static func == (lhs: Theme, rhs: Theme) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: String
    let name: String
    let colors: [Color]
    let preview: [Color]
    
    enum CodingKeys: String, CodingKey {
        case id, name
    }
    
    init(id: String, name: String, colors: [Color], preview: [Color]) {
        self.id = id
        self.name = name
        self.colors = colors
        self.preview = preview
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        colors = []
        preview = []
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
    }
    
    static let defaultThemes: [Theme] = [
        Theme(
            id: "queersicht",
            name: "Queersicht 1",
            colors: [
                Color(hex: "4F694F"),
                Color(hex: "715540 "),
                Color(hex: "AF9869"),
                Color(hex: "3E3928")
            ],
            preview: [Color(hex: "90A282"), Color(hex: "C2B186")]
        ),
        Theme(
            id: "queersicht2",
            name: "Queersicht 2",
            colors: [
                Color(hex: "271A0E"),
                Color(hex: "A1946E "),
                Color(hex: "444835"),
                Color(hex: "B0A37B")
            ],
            preview: [Color(hex: "757961"), Color(hex: "BDA073")]
        ),
        Theme(
            id: "queersicht3",
            name: "Queersicht 3",
            colors: [
                Color(hex: "141825"),
                Color(hex: "31425E "),
                Color(hex: "61849D"),
                Color(hex: "3C4F6D")
            ],
            preview: [Color(hex: "263887"), Color(hex: "7998C0")]
        ),
        Theme(
            id: "queersicht4",
            name: "Queersicht 4",
            colors: [
                Color(hex: "925A3F"),
                Color(hex: "897E8A "),
                Color(hex: "503C58"),
                Color(hex: "CF8858")
            ],
            preview: [Color(hex: "263887"), Color(hex: "7998C0")]
        ),
        Theme(
            id: "queersicht5",
            name: "Queersicht 5",
            colors: [
                Color(hex: "B18532"),
                Color(hex: "706434 "),
                Color(hex: "845730"),
                Color(hex: "403243")
            ],
            preview: [Color(hex: "263887"), Color(hex: "7998C0")]
        ),
        Theme(
            id: "queersicht6",
            name: "Black (Mono)",
            colors: [
                Color(hex: "000000"),
                Color(hex: "000000 "),
                Color(hex: "000000"),
                Color(hex: "000000")
            ],
            preview: [Color(hex: "000000"), Color(hex: "000000")]
        ),
        Theme(
            id: "queersicht7",
            name: "Red (Mono)",
            colors: [
                Color(hex: "B60909"),
                Color(hex: "B60909 "),
                Color(hex: "B60909"),
                Color(hex: "B60909")
            ],
            preview: [Color(hex: "B60909"), Color(hex: "B60909")]
        ),
        Theme(
            id: "queersicht8",
            name: "Green (Mono))",
            colors: [
                Color(hex: "2C8B07"),
                Color(hex: "2C8B07 "),
                Color(hex: "2C8B07"),
                Color(hex: "2C8B07")
            ],
            preview: [Color(hex: "2C8B07"), Color(hex: "2C8B07")]
        ),
        Theme(
            id: "queersicht9",
            name: "Orange (Mono)",
            colors: [
                Color(hex: "F46D25"),
                Color(hex: "F46D25 "),
                Color(hex: "F46D25"),
                Color(hex: "F46D25")
            ],
            preview: [Color(hex: "F46D25"), Color(hex: "F46D25")]
        ),
        Theme(
            id: "queersicht10",
            name: "Blue (Mono)",
            colors: [
                Color(hex: "1B09B9"),
                Color(hex: "1B09B9 "),
                Color(hex: "1B09B9"),
                Color(hex: "1B09B9")
            ],
            preview: [Color(hex: "1B09B9"), Color(hex: "1B09B9")]
        )
    ]
}
