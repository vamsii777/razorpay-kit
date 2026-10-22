import Foundation

/// An ISO 4217 currency code. Open: codes this SDK does not list still decode and round-trip.
///
/// ```swift
/// let price = Money(amount: 49_900, currency: .inr)  // ₹499.00
/// ```
/// See https://razorpay.com/docs/payments/international-payments/#supported-currencies.
public struct Currency: RazorpayStringEnum {
    public let rawValue: String

    /// Creates a currency from its ISO code. The code is upper-cased.
    public init(rawValue: String) { self.rawValue = rawValue.uppercased() }

    /// Indian Rupee (₹)
    public static let indianRupee = Self(rawValue: "INR")
    /// United States Dollar ($)
    public static let usDollar = Self(rawValue: "USD")
    /// Euro (€)
    public static let euro = Self(rawValue: "EUR")
    /// British Pound Sterling (£)
    public static let britishPound = Self(rawValue: "GBP")
    /// Japanese Yen (¥)
    public static let japaneseYen = Self(rawValue: "JPY")
    /// Canadian Dollar (C$)
    public static let canadianDollar = Self(rawValue: "CAD")
    /// Australian Dollar (A$)
    public static let australianDollar = Self(rawValue: "AUD")
    /// New Zealand Dollar (NZ$)
    public static let newZealandDollar = Self(rawValue: "NZD")
    /// Singapore Dollar (S$)
    public static let singaporeDollar = Self(rawValue: "SGD")
    /// Hong Kong Dollar (HK$)
    public static let hongKongDollar = Self(rawValue: "HKD")
    /// Malaysian Ringgit (RM)
    public static let malaysianRinggit = Self(rawValue: "MYR")
    /// United Arab Emirates Dirham (د.إ)
    public static let uaeDirham = Self(rawValue: "AED")
    /// Swiss Franc (Fr)
    public static let swissFranc = Self(rawValue: "CHF")
    /// Chinese Yuan (¥)
    public static let chineseYuan = Self(rawValue: "CNY")
    /// South African Rand (R)
    public static let southAfricanRand = Self(rawValue: "ZAR")
    /// Sri Lankan Rupee (Rs)
    public static let sriLankanRupee = Self(rawValue: "LKR")
    /// Swedish Krona (kr)
    public static let swedishKrona = Self(rawValue: "SEK")
    /// Saudi Riyal (﷼)
    public static let saudiRiyal = Self(rawValue: "SAR")
    /// Thai Baht (฿)
    public static let thaiBaht = Self(rawValue: "THB")
    /// Russian Ruble (₽)
    public static let russianRuble = Self(rawValue: "RUB")
    /// Turkish Lira (₺)
    public static let turkishLira = Self(rawValue: "TRY")
    /// Israeli New Shekel (₪)
    public static let israeliNewShekel = Self(rawValue: "ILS")
    /// Danish Krone (kr)
    public static let danishKrone = Self(rawValue: "DKK")
    /// Polish Złoty (zł)
    public static let polishZloty = Self(rawValue: "PLN")
    /// Norwegian Krone (kr)
    public static let norwegianKrone = Self(rawValue: "NOK")
    /// Hungarian Forint (Ft)
    public static let hungarianForint = Self(rawValue: "HUF")
    /// Czech Koruna (Kč)
    public static let czechKoruna = Self(rawValue: "CZK")
    /// Qatari Riyal (﷼)
    public static let qatariRiyal = Self(rawValue: "QAR")
    /// Kuwaiti Dinar (د.ك)
    public static let kuwaitiDinar = Self(rawValue: "KWD")
    /// Bahraini Dinar (.د.ب)
    public static let bahrainiDinar = Self(rawValue: "BHD")
    /// Omani Rial (﷼)
    public static let omaniRial = Self(rawValue: "OMR")
    /// Mexican Peso ($)
    public static let mexicanPeso = Self(rawValue: "MXN")
    /// Taiwan New Dollar (NT$)
    public static let taiwanDollar = Self(rawValue: "TWD")
    /// South Korean Won (₩)
    public static let southKoreanWon = Self(rawValue: "KRW")
    /// Indonesian Rupiah (Rp)
    public static let indonesianRupiah = Self(rawValue: "IDR")
    /// Philippine Peso (₱)
    public static let philippinePeso = Self(rawValue: "PHP")
    /// Vietnamese Dong (₫)
    public static let vietnameseDong = Self(rawValue: "VND")
    /// Bangladeshi Taka (৳)
    public static let bangladeshiTaka = Self(rawValue: "BDT")
    /// Brazilian Real (R$)
    public static let brazilianReal = Self(rawValue: "BRL")
    /// Egyptian Pound (£)
    public static let egyptianPound = Self(rawValue: "EGP")
    /// Nigerian Naira (₦)
    public static let nigerianNaira = Self(rawValue: "NGN")
    /// Ghanaian Cedi (₵)
    public static let ghanaianCedi = Self(rawValue: "GHS")
    /// Kenyan Shilling (KSh)
    public static let kenyanShilling = Self(rawValue: "KES")

    /// Shorthand for ``indianRupee``.
    public static let inr = indianRupee
    /// Shorthand for ``usDollar``.
    public static let usd = usDollar

    /// Every currency this SDK lists.
    public static let allCases: [Currency] = [
        .indianRupee,
        .usDollar,
        .euro,
        .britishPound,
        .japaneseYen,
        .canadianDollar,
        .australianDollar,
        .newZealandDollar,
        .singaporeDollar,
        .hongKongDollar,
        .malaysianRinggit,
        .uaeDirham,
        .swissFranc,
        .chineseYuan,
        .southAfricanRand,
        .sriLankanRupee,
        .swedishKrona,
        .saudiRiyal,
        .thaiBaht,
        .russianRuble,
        .turkishLira,
        .israeliNewShekel,
        .danishKrone,
        .polishZloty,
        .norwegianKrone,
        .hungarianForint,
        .czechKoruna,
        .qatariRiyal,
        .kuwaitiDinar,
        .bahrainiDinar,
        .omaniRial,
        .mexicanPeso,
        .taiwanDollar,
        .southKoreanWon,
        .indonesianRupiah,
        .philippinePeso,
        .vietnameseDong,
        .bangladeshiTaka,
        .brazilianReal,
        .egyptianPound,
        .nigerianNaira,
        .ghanaianCedi,
        .kenyanShilling
    ]
}

extension Currency {
    private static let zeroDecimal: Set<String> = ["JPY", "HUF", "TWD", "KRW", "IDR", "VND"]
    private static let threeDecimal: Set<String> = ["BHD", "KWD", "OMR"]
    private static let names: [String: String] = [
        "INR": "Indian Rupee (INR)",
        "USD": "US Dollar (USD)",
        "EUR": "Euro (EUR)",
        "GBP": "British Pound Sterling (GBP)",
        "JPY": "Japanese Yen (JPY)",
        "CAD": "Canadian Dollar (CAD)",
        "AUD": "Australian Dollar (AUD)",
        "NZD": "New Zealand Dollar (NZD)",
        "SGD": "Singapore Dollar (SGD)",
        "HKD": "Hong Kong Dollar (HKD)",
        "MYR": "Malaysian Ringgit (MYR)",
        "AED": "UAE Dirham (AED)",
        "CHF": "Swiss Franc (CHF)",
        "CNY": "Chinese Yuan (CNY)",
        "ZAR": "South African Rand (ZAR)",
        "LKR": "Sri Lankan Rupee (LKR)",
        "SEK": "Swedish Krona (SEK)",
        "SAR": "Saudi Riyal (SAR)",
        "THB": "Thai Baht (THB)",
        "RUB": "Russian Ruble (RUB)",
        "TRY": "Turkish Lira (TRY)",
        "ILS": "Israeli New Shekel (ILS)",
        "DKK": "Danish Krone (DKK)",
        "PLN": "Polish Złoty (PLN)",
        "NOK": "Norwegian Krone (NOK)",
        "HUF": "Hungarian Forint (HUF)",
        "CZK": "Czech Koruna (CZK)",
        "QAR": "Qatari Riyal (QAR)",
        "KWD": "Kuwaiti Dinar (KWD)",
        "BHD": "Bahraini Dinar (BHD)",
        "OMR": "Omani Rial (OMR)",
        "MXN": "Mexican Peso (MXN)",
        "TWD": "Taiwan New Dollar (TWD)",
        "KRW": "South Korean Won (KRW)",
        "IDR": "Indonesian Rupiah (IDR)",
        "PHP": "Philippine Peso (PHP)",
        "VND": "Vietnamese Dong (VND)",
        "BDT": "Bangladeshi Taka (BDT)",
        "BRL": "Brazilian Real (BRL)",
        "EGP": "Egyptian Pound (EGP)",
        "NGN": "Nigerian Naira (NGN)",
        "GHS": "Ghanaian Cedi (GHS)",
        "KES": "Kenyan Shilling (KES)"
    ]
    private static let symbols: [String: String] = [
        "INR": "₹",
        "USD": "$",
        "MXN": "$",
        "EUR": "€",
        "GBP": "£",
        "EGP": "£",
        "JPY": "¥",
        "CNY": "¥",
        "MYR": "RM",
        "AED": "د.إ",
        "CHF": "Fr",
        "ZAR": "R",
        "LKR": "Rs",
        "SEK": "kr",
        "NOK": "kr",
        "DKK": "kr",
        "SAR": "﷼",
        "QAR": "﷼",
        "OMR": "﷼",
        "THB": "฿",
        "RUB": "₽",
        "TRY": "₺",
        "ILS": "₪",
        "PLN": "zł",
        "HUF": "Ft",
        "CZK": "Kč",
        "KWD": "د.ك",
        "BHD": ".د.ب",
        "TWD": "NT$",
        "KRW": "₩",
        "IDR": "Rp",
        "PHP": "₱",
        "VND": "₫",
        "BDT": "৳",
        "BRL": "R$",
        "NGN": "₦",
        "GHS": "₵",
        "KES": "KSh"
    ]

    /// A readable name such as `Indian Rupee (INR)`. Unknown codes return the code.
    public var displayName: String { Self.names[rawValue] ?? rawValue }

    /// The symbol, for example `₹`. Unknown codes return the code.
    public var symbol: String { Self.symbols[rawValue] ?? rawValue }

    /// Decimal places in the minor unit: 2 for INR (paise), 0 for JPY, 3 for KWD.
    public var exponent: Int {
        if Self.zeroDecimal.contains(rawValue) { return 0 }
        if Self.threeDecimal.contains(rawValue) { return 3 }
        return 2
    }

    /// Converts a major-unit amount to minor units, rounding half-up. `10.5` INR → `1050`.
    public func convertToSmallestUnit(_ amount: Decimal) -> Int {
        var scaled = amount * pow(Decimal(10), exponent)
        var rounded = Decimal()
        NSDecimalRound(&rounded, &scaled, 0, .plain)
        return NSDecimalNumber(decimal: rounded).intValue
    }

    /// Converts minor units to a major-unit amount. `1050` INR → `10.5`.
    public func convertFromSmallestUnit(_ amount: Int) -> Decimal {
        Decimal(amount) / pow(Decimal(10), exponent)
    }
}
