import Foundation
import Testing
@testable import RazorpayKit

private enum Widget {}

@Suite("Typed foundation")
struct FoundationTypesTests {
    @Test func idsAreTypedLiteralsAndRoundTrip() throws {
        let id: RazorpayID<Widget> = "wid_TEST000001"
        #expect(id.rawValue == "wid_TEST000001")
        let data = try JSONEncoder().encode([id])
        #expect(String(decoding: data, as: UTF8.self) == #"["wid_TEST000001"]"#)
        #expect(try JSONDecoder().decode([RazorpayID<Widget>].self, from: data) == [id])
    }

    @Test(arguments: ["", "  ", "a/b"])
    func badIDsAreRejectedBeforeSending(raw: String) {
        guard case .failure(.invalidRequest) = RazorpayID<Widget>(raw).pathComponent() else {
            Issue.record("expected invalidRequest"); return
        }
    }

    @Test func idPathComponentIsEncodedAndTrimmed() throws {
        #expect(try RazorpayID<Widget>(" pay_1 ").pathComponent().get() == "pay_1")
        #expect(try RazorpayID<Widget>("a b?").pathComponent().get() == "a%20b%3F")
    }

    @Test func currencyIsOpenAndCaseNormalised() throws {
        #expect(Currency(rawValue: "inr") == .inr)
        let unknown = try JSONDecoder().decode(Currency.self, from: Data(#""XYZ""#.utf8))
        #expect(unknown.rawValue == "XYZ" && unknown.exponent == 2 && unknown.symbol == "XYZ")
        #expect(Currency.allCases.count == 43)
        #expect(Currency.japaneseYen.exponent == 0 && Currency.kuwaitiDinar.exponent == 3)
    }

    @Test func moneyConvertsAndFormats() {
        #expect(Money.inr(rupees: 499.5).amount == 49_950)
        #expect(Money.inr(rupees: Decimal(string: "0.005")!).amount == 1, "half-up rounding")
        #expect(Money.inr(paise: 49_900).description == "₹499.00")
        #expect(Money.inr(paise: 5).description == "₹0.05")
        #expect(Money(amount: -1_050, currency: .inr).description == "-₹10.50")
        #expect(Money(amount: 1_500, currency: .japaneseYen).description == "¥1500")
        #expect(Money(amount: 1_234, currency: .kuwaitiDinar).decimalAmount == Decimal(string: "1.234"))
        #expect(Money.inr(paise: 1) < Money.inr(paise: 2))
    }

    @Test func jsonValueDecodesEverything() throws {
        let json = #"{"a":1,"b":1.5,"c":"x","d":true,"e":null,"f":[1,{"g":"h"}]}"#
        let value = try JSONDecoder().decode(JSONValue.self, from: Data(json.utf8))
        #expect(value["a"]?.intValue == 1)
        #expect(value["b"]?.doubleValue == 1.5)
        #expect(value["d"]?.boolValue == true)
        #expect(value["e"]?.isNull == true)
        #expect(value["f"]?[1]?["g"]?.stringValue == "h")
        #expect(value["f"]?[9] == nil)
        #expect(value["missing"] == nil)
        let literal: JSONValue = ["amount": 100, "notes": ["k": "v"]]
        #expect(literal["notes"]?["k"] == "v")
    }

    private struct Holder: Decodable { let notes: Notes
        enum CodingKeys: CodingKey { case notes }
        init(from decoder: any Decoder) throws { notes = try NotesCoding.decode(decoder.container(keyedBy: CodingKeys.self), .notes) }
    }

    @Test(arguments: [(#"{"notes":[]}"#, [String: String]()), (#"{}"#, [:]), (#"{"notes":null}"#, [:]),
                      (#"{"notes":{"a":"x","n":5,"z":null}}"#, ["a": "x", "n": "5"])])
    func notesAreLenient(json: String, expected: [String: String]) throws {
        #expect(try JSONDecoder().decode(Holder.self, from: Data(json.utf8)).notes == expected)
    }
}
