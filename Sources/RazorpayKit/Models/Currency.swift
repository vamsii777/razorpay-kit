/// Represents currencies supported by Razorpay for international payments
///
/// This enum contains all the currencies that can be used for payments through Razorpay's payment gateway.
/// Each case represents a currency with its ISO 4217 currency code.
///
/// ## Usage Example
/// ```swift
/// let paymentData: [String: Any] = [
///     "amount": 1000,
///     "currency": Currency.indianRupee.rawValue
/// ]
/// ```
public enum Currency: String, CaseIterable {
    /// Indian Rupee (₹)
    case indianRupee = "INR"
    
    /// United States Dollar ($)
    case usDollar = "USD"
    
    /// Euro (€)
    case euro = "EUR"
    
    /// British Pound Sterling (£)
    case britishPound = "GBP"
    
    /// Japanese Yen (¥)
    case japaneseYen = "JPY"
    
    /// Canadian Dollar (C$)
    case canadianDollar = "CAD"
    
    /// Australian Dollar (A$)
    case australianDollar = "AUD"
    
    /// New Zealand Dollar (NZ$)
    case newZealandDollar = "NZD"
    
    /// Singapore Dollar (S$)
    case singaporeDollar = "SGD"
    
    /// Hong Kong Dollar (HK$)
    case hongKongDollar = "HKD"
    
    /// Malaysian Ringgit (RM)
    case malaysianRinggit = "MYR"
    
    /// United Arab Emirates Dirham (د.إ)
    case uaeDirham = "AED"
    
    /// Swiss Franc (Fr)
    case swissFranc = "CHF"
    
    /// Chinese Yuan (¥)
    case chineseYuan = "CNY"
    
    /// South African Rand (R)
    case southAfricanRand = "ZAR"
    
    /// Sri Lankan Rupee (Rs)
    case sriLankanRupee = "LKR"
    
    /// Swedish Krona (kr)
    case swedishKrona = "SEK"
    
    /// Saudi Riyal (﷼)
    case saudiRiyal = "SAR"
    
    /// Thai Baht (฿)
    case thaiBaht = "THB"
    
    /// Russian Ruble (₽)
    case russianRuble = "RUB"
    
    /// Turkish Lira (₺)
    case turkishLira = "TRY"
    
    /// Israeli New Shekel (₪)
    case israeliNewShekel = "ILS"
    
    /// Danish Krone (kr)
    case danishKrone = "DKK"
    
    /// Polish Złoty (zł)
    case polishZloty = "PLN"
    
    /// Norwegian Krone (kr)
    case norwegianKrone = "NOK"
    
    /// Hungarian Forint (Ft)
    case hungarianForint = "HUF"
    
    /// Czech Koruna (Kč)
    case czechKoruna = "CZK"
    
    /// Qatari Riyal (﷼)
    case qatariRiyal = "QAR"
    
    /// Kuwaiti Dinar (د.ك)
    case kuwaitiDinar = "KWD"
    
    /// Bahraini Dinar (.د.ب)
    case bahrainiDinar = "BHD"
    
    /// Omani Rial (﷼)
    case omaniRial = "OMR"
    
    /// Mexican Peso ($)
    case mexicanPeso = "MXN"
    
    /// Taiwan New Dollar (NT$)
    case taiwanDollar = "TWD"
    
    /// South Korean Won (₩)
    case southKoreanWon = "KRW"
    
    /// Indonesian Rupiah (Rp)
    case indonesianRupiah = "IDR"
    
    /// Philippine Peso (₱)
    case philippinePeso = "PHP"
    
    /// Vietnamese Dong (₫)
    case vietnameseDong = "VND"
    
    /// Bangladeshi Taka (৳)
    case bangladeshiTaka = "BDT"
    
    /// Brazilian Real (R$)
    case brazilianReal = "BRL"
    
    /// Egyptian Pound (£)
    case egyptianPound = "EGP"
    
    /// Nigerian Naira (₦)
    case nigerianNaira = "NGN"
    
    /// Ghanaian Cedi (₵)
    case ghanaianCedi = "GHS"
    
    /// Kenyan Shilling (KSh)
    case kenyanShilling = "KES"
}

extension Currency {
    /// Returns a description of the currency including its name and code
    public var description: String {
        switch self {
        case .indianRupee: return "Indian Rupee (INR)"
        case .usDollar: return "US Dollar (USD)"
        case .euro: return "Euro (EUR)"
        case .britishPound: return "British Pound Sterling (GBP)"
        case .japaneseYen: return "Japanese Yen (JPY)"
        case .canadianDollar: return "Canadian Dollar (CAD)"
        case .australianDollar: return "Australian Dollar (AUD)"
        case .newZealandDollar: return "New Zealand Dollar (NZD)"
        case .singaporeDollar: return "Singapore Dollar (SGD)"
        case .hongKongDollar: return "Hong Kong Dollar (HKD)"
        case .malaysianRinggit: return "Malaysian Ringgit (MYR)"
        case .uaeDirham: return "UAE Dirham (AED)"
        case .swissFranc: return "Swiss Franc (CHF)"
        case .chineseYuan: return "Chinese Yuan (CNY)"
        case .southAfricanRand: return "South African Rand (ZAR)"
        case .sriLankanRupee: return "Sri Lankan Rupee (LKR)"
        case .swedishKrona: return "Swedish Krona (SEK)"
        case .saudiRiyal: return "Saudi Riyal (SAR)"
        case .thaiBaht: return "Thai Baht (THB)"
        case .russianRuble: return "Russian Ruble (RUB)"
        case .turkishLira: return "Turkish Lira (TRY)"
        case .israeliNewShekel: return "Israeli New Shekel (ILS)"
        case .danishKrone: return "Danish Krone (DKK)"
        case .polishZloty: return "Polish Złoty (PLN)"
        case .norwegianKrone: return "Norwegian Krone (NOK)"
        case .hungarianForint: return "Hungarian Forint (HUF)"
        case .czechKoruna: return "Czech Koruna (CZK)"
        case .qatariRiyal: return "Qatari Riyal (QAR)"
        case .kuwaitiDinar: return "Kuwaiti Dinar (KWD)"
        case .bahrainiDinar: return "Bahraini Dinar (BHD)"
        case .omaniRial: return "Omani Rial (OMR)"
        case .mexicanPeso: return "Mexican Peso (MXN)"
        case .taiwanDollar: return "Taiwan New Dollar (TWD)"
        case .southKoreanWon: return "South Korean Won (KRW)"
        case .indonesianRupiah: return "Indonesian Rupiah (IDR)"
        case .philippinePeso: return "Philippine Peso (PHP)"
        case .vietnameseDong: return "Vietnamese Dong (VND)"
        case .bangladeshiTaka: return "Bangladeshi Taka (BDT)"
        case .brazilianReal: return "Brazilian Real (BRL)"
        case .egyptianPound: return "Egyptian Pound (EGP)"
        case .nigerianNaira: return "Nigerian Naira (NGN)"
        case .ghanaianCedi: return "Ghanaian Cedi (GHS)"
        case .kenyanShilling: return "Kenyan Shilling (KES)"
        }
    }
    
    /// The exponent for the currency, indicating the number of decimal places
    /// Used to convert currency units to their smallest denomination
    /// For example:
    /// - INR has exponent 2, so ₹1 = 100 paise
    /// - JPY has exponent 0, so ¥1 = 1 yen
    public var exponent: Int {
        switch self {
        // Zero decimal currencies
        case .japaneseYen, .hungarianForint, .taiwanDollar, .southKoreanWon, 
             .indonesianRupiah, .vietnameseDong:
            return 0
            
        // Three decimal currencies
        case .bahrainiDinar, .kuwaitiDinar, .omaniRial:
            return 3
            
        // Two decimal currencies (most common)
        default:
            return 2
        }
    }
    
    /// Converts a decimal amount to the smallest currency unit
    /// For example:
    /// - convertToSmallestUnit(10.5) for INR returns 1050 (paise)
    /// - convertToSmallestUnit(10.5) for JPY returns 10 (yen)
    /// - convertToSmallestUnit(10.5) for BHD returns 10500 (fils)
    public func convertToSmallestUnit(_ amount: Decimal) -> Int {
        let multiplier = pow(10, exponent)
        return NSDecimalNumber(decimal: amount * multiplier).intValue
    }
    
    /// Converts an amount in smallest currency unit back to decimal
    /// For example:
    /// - convertFromSmallestUnit(1050) for INR returns 10.50 (rupees)
    /// - convertFromSmallestUnit(10) for JPY returns 10.00 (yen)
    /// - convertFromSmallestUnit(10500) for BHD returns 10.500 (dinar)
    public func convertFromSmallestUnit(_ amount: Int) -> Decimal {
        let divisor = Decimal(pow(10, exponent))
        return Decimal(amount) / divisor
    }
}

// Example usage extension
extension Currency {
    /// Returns the symbol for the currency
    public var symbol: String {
        switch self {
        case .indianRupee: return "₹"
        case .usDollar, .mexicanPeso: return "$"
        case .euro: return "€"
        case .britishPound, .egyptianPound: return "£"
        case .japaneseYen, .chineseYuan: return "¥"
        case .malaysianRinggit: return "RM"
        case .uaeDirham: return "د.إ"
        case .swissFranc: return "Fr"
        case .southAfricanRand: return "R"
        case .sriLankanRupee: return "Rs"
        case .swedishKrona, .norwegianKrone, .danishKrone: return "kr"
        case .saudiRiyal, .qatariRiyal, .omaniRial: return "﷼"
        case .thaiBaht: return "฿"
        case .russianRuble: return "₽"
        case .turkishLira: return "₺"
        case .israeliNewShekel: return "₪"
        case .polishZloty: return "zł"
        case .hungarianForint: return "Ft"
        case .czechKoruna: return "Kč"
        case .kuwaitiDinar: return "د.ك"
        case .bahrainiDinar: return ".د.ب"
        case .taiwanDollar: return "NT$"
        case .southKoreanWon: return "₩"
        case .indonesianRupiah: return "Rp"
        case .philippinePeso: return "₱"
        case .vietnameseDong: return "₫"
        case .bangladeshiTaka: return "৳"
        case .brazilianReal: return "R$"
        case .nigerianNaira: return "₦"
        case .ghanaianCedi: return "₵"
        case .kenyanShilling: return "KSh"
        default: return self.rawValue
        }
    }
} 