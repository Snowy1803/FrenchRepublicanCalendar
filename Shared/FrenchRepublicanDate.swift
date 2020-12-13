//
//  FrenchRepublicanCalendarCalculator.swift
//  FrenchRepublicanCalendar Shared
//
//  Created by Emil on 06/03/2020.
//  Copyright © 2020 Snowy_1803. All rights reserved.
//

import Foundation

struct FrenchRepublicanDate: CustomDebugStringConvertible {
    /// The origin of the Republican Calendar, 1er Vendémiaire An 1 or 1792-09-22
    static let origin = Date(timeIntervalSince1970: -5594191200)
    /// The maximum safe date to convert, currently 15300-12-31
    static let maxSafeDate = Date(timeIntervalSinceReferenceDate: 419707389600) // 15300-12-31
    /// The safe range that is guaranteed to convert properly
    static let safeRange = origin...maxSafeDate
    
    static let allMonthNames = ["Vendémiaire", "Brumaire", "Frimaire", "Nivôse", "Pluviôse", "Ventôse", "Germinal", "Floréal", "Prairial", "Messidor", "Thermidor", "Fructidor", "Sansculottide"]
    static let sansculottidesDayNames = ["Jour de la vertu", "Jour du génie", "Jour du travail", "Jour de l'opinion", "Jour des récompenses", "Jour de la révolution"]

    static let shortMonthNames = ["Vend.r", "Brum.r", "Frim.r", "Niv.ô", "Pluv.ô", "Vent.ô", "Germ.l", "Flo.l", "Prai.l", "Mes.or", "Ther.or", "Fru.or", "Ss.cu"]
    static let sansculottidesShortNames = ["Jr vertu", "Jr génie", "Jr travail", "Jr opinion", "Jr récompenses", "Jr révolution"]
    
    static let allWeekdays = ["Primidi", "Duodi", "Tridi", "Quartidi", "Quintidi", "Sextidi", "Septidi", "Octidi", "Nonidi", "Décadi"]
    
    static let allDayNames = ["Raisin", "Safran", "Châtaigne", "Colchique", "Cheval", "Balsamine", "Carotte", "Amaranthe", "Panais", "Cuve", "Pomme de terre", "Immortelle", "Potiron", "Réséda", "Ane", "Belle de nuit", "Citrouille", "Sarrasin", "Tournesol", "Pressoir", "Chanvre", "Pêche", "Navet", "Amaryllis", "Bœuf", "Aubergine", "Piment", "Tomate", "Orge", "Tonneau", "Pomme", "Céleri", "Poire", "Betterave", "Oie", "Héliotrope", "Figue", "Scorsonère", "Alisier", "Charrue", "Salsifis", "Macre", "Topinambour", "Endive", "Dindon", "Chervis", "Cresson", "Dentelaire", "Grenade", "Herse", "Bacchante", "Azerole", "Garance", "Orange", "Faisan", "Pistache", "Macjonc", "Coing", "Cormier", "Rouleau", "Raiponce", "Turneps", "Chicorée", "Nèfle", "Cochon", "Mâche", "Chou-fleur", "Miel", "Genièvre", "Pioche", "Cire", "Raifort", "Cèdre", "Sapin", "Chevreuil", "Ajonc", "Cyprès", "Lierre", "Sabine", "Hoyau", "Erable sucré", "Bruyère", "Roseau", "Oseille", "Grillon", "Pignon", "Liège", "Truffe", "Olive", "Pelle", "Tourbe", "Houille", "Bitume", "Soufre", "Chien", "Lave", "Terre végétale", "Fumier", "Salpêtre", "Fléau", "Granit", "Argile", "Ardoise", "Grès", "Lapin", "Silex", "Marne", "Pierre à chaux", "Marbre", "Van", "Pierre à Plâtre", "Sel", "Fer", "Cuivre", "Chat", "Étain", "Plomb", "Zinc", "Mercure", "Crible", "Lauréole", "Mousse", "Fragon", "Perce Neige", "Taureau", "Laurier thym", "Amadouvier", "Mézéréon", "Peuplier", "Cognée", "Ellébore", "Brocoli", "Laurier", "Avelinier", "Vache", "Buis", "Lichen", "If", "Pulmonaire", "Serpette", "Thlaspi", "Thimèle", "Chiendent", "Trainasse", "Lièvre", "Guède", "Noisetier", "Cyclamen", "Chélidoine", "Traineau", "Tussilage", "Cornouiller", "Violier", "Troëne", "Bouc", "Asaret", "Alaterne", "Violette", "Marceau", "Bêche", "Narcisse", "Orme", "Fumeterre", "Vélar", "Chèvre", "Épinard", "Doronic", "Mouron", "Cerfeuil", "Cordeau", "Mandragore", "Persil", "Cochléaire", "Pâquerette", "Thon", "Pissenlit", "Sylve", "Capillaire", "Frêne", "Plantoir", "Primevère", "Platane", "Asperge", "Tulipe", "Poule", "Blette", "Bouleau", "Jonquille", "Aulne", "Couvoir", "Pervenche", "Charme", "Morille", "Hêtre", "Abeille", "Laitue", "Mélèze", "Cigüe", "Radis", "Ruche", "Gainier", "Romaine", "Marronnier", "Roquette", "Pigeon", "Lilas", "Anémone", "Pensée", "Myrtille", "Greffoir", "Rose", "Chêne", "Fougère", "Aubépine", "Rossignol", "Ancolie", "Muguet", "Champignon", "Hyacinthe", "Râteau", "Rhubarbe", "Sainfoin", "Bâton d'or", "Chamerops", "Ver à soie", "Consoude", "Pimprenelle", "Corbeille d'or", "Arroche", "Sarcloir", "Statice", "Fritillaire", "Bourache", "Valériane", "Carpe", "Fusain", "Civette", "Buglosse", "Sénevé", "Houlette", "Luzerne", "Hémérocalle", "Trèfle", "Angélique", "Canard", "Mélisse", "Fromental", "Martagon", "Serpolet", "Faux", "Fraise", "Bétoine", "Pois", "Acacia", "Caille", "Œillet", "Sureau", "Pavot", "Tilleul", "Fourche", "Barbeau", "Camomille", "Chèvre-feuille", "Caille-lait", "Tanche", "Jasmin", "Verveine", "Thym", "Pivoine", "Chariot", "Seigle", "Avoine", "Oignon", "Véronique", "Mulet", "Romarin", "Concombre", "Échalotte", "Absinthe", "Faucille", "Coriandre", "Artichaut", "Girofle", "Lavande", "Chamois", "Tabac", "Groseille", "Gesse", "Cerise", "Parc", "Menthe", "Cumin", "Haricot", "Orcanète", "Pintade", "Sauge", "Ail", "Vesce", "Blé", "Chalémie", "Épeautre", "Bouillon blanc", "Melon", "Ivraie", "Bélier", "Prêle", "Armoise", "Carthame", "Mûre", "Arrosoir", "Panis", "Salicorne", "Abricot", "Basilic", "Brebis", "Guimauve", "Lin", "Amande", "Gentiane", "Écluse", "Carline", "Câprier", "Lentille", "Aunée", "Loutre", "Myrte", "Colza", "Lupin", "Coton", "Moulin", "Prune", "Millet", "Lycoperdon", "Escourgeon", "Saumon", "Tubéreuse", "Sucrion", "Apocyn", "Réglisse", "Échelle", "Pastèque", "Fenouil", "Épine vinette", "Noix", "Truite", "Citron", "Cardère", "Nerprun", "Tagette", "Hotte", "Églantier", "Noisette", "Houblon", "Sorgho", "Écrevisse", "Bigarade", "Verge d'or", "Maïs", "Marron", "Panier", "Vertu", "Génie", "Travail", "Opinion", "Récompenses", "Révolution"]
    
    static let allQuarters = ["Automne", "Hiver", "Printemps", "Été", "Sansculottides"]
    
    /// the system Date value for this Republican Date
    var date: Date
    
    /// `year`: The year, starting at 1 for 1792-09-22,
    ///
    /// month: The month, 1-13 (13 being the additional days, called SANSCULOTTIDES),
    ///
    /// day: The day in the month 1-30 (1-5 or 1-6 for the 13th month, depending on .isYearSextil),
    ///
    /// hour, minute, second, nanosecond: The same as in the gregorian calendar,
    ///
    /// weekday: The weekday 1-10,
    ///
    /// quarter: The season, 1-5 (1=winter, 2=spring, 3=summer, 4=autumn, 5=SANSCULOTTIDES),
    ///
    /// weekOfMonth: The week within the month (a week being 10 days),
    ///
    /// weekOfYear: The week within the year (a week being 10 days)
    var components: DateComponents!
    
    /// The day in year date component, 1-indexed
    var dayInYear: Int {
        return (components.month! - 1) * 30 + components.day!
    }
    
    /// true if the current Republican year is sextil, false otherwise
    var isYearSextil: Bool {
        return components.year!.isSextil
    }
    
    /// Creates a Republican Date from the given Gregorian Date
    /// - Parameter date: the Gregorian Date
    init(date: Date) {
        self.date = date
        dateToFrenchRepublican()
    }
    
    /// Creates a Republican Date from Republican Date component. The `date` property will contain the Gregorian value, so this converts from Republican to Gregorian
    /// - Parameters:
    ///   - dayInYear: Day in Year, 1-indexed
    ///   - year: The republican Year
    ///   - hour: Hour
    ///   - minute: Minutes
    ///   - second: Seconds
    ///   - nanosecond: Nanoseconds
    init(dayInYear: Int, year: Int, hour: Int? = nil, minute: Int? = nil, second: Int? = nil, nanosecond: Int? = nil) {
        self.date = Date(dayInYear: dayInYear, year: year, hour: hour, minute: minute, second: second, nanosecond: nanosecond)
        initComponents(dayOfYear: dayInYear - 1, year: year, hour: hour, minute: minute, second: second, nanosecond: nanosecond)
    }
    
    /// Logic that converts the `date` value to republican date components. Called by the Gregorian > Republican constructor
    private mutating func dateToFrenchRepublican() {
        let gregorian = Calendar.gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: date)
        let gYear = gregorian.year!
        
        var year = gYear - 1791
        var dayOfYear = Calendar.gregorian.ordinality(of: .day, in: .year, for: date)!
        dayOfYear.increment(by: -265 - (gYear.isBissextil ? 1 : 0), year: &year, daysInYear: \.daysInRepublicanYear)
        
        let remdays = (gYear / 100 - 15) * 3 / 4 - 1
        dayOfYear.increment(by: -remdays, year: &year, daysInYear: \.daysInRepublicanYear)
        
        initComponents(dayOfYear: dayOfYear, year: year, hour: gregorian.hour, minute: gregorian.minute, second: gregorian.second, nanosecond: gregorian.nanosecond)
    }
    
    /// Initializes the `components` property with the given values
    /// - Parameters:
    ///   - dayOfYear: Days of year, 0-indexed
    ///   - year: Year
    ///   - hour: Hour
    ///   - minute: Minutes
    ///   - second: Seconds
    ///   - nanosecond: Nanoseconds
    private mutating func initComponents(dayOfYear: Int, year: Int, hour: Int? = nil, minute: Int? = nil, second: Int? = nil, nanosecond: Int? = nil) {
        self.components = DateComponents(year: year, month: dayOfYear / 30 + 1, day: dayOfYear % 30 + 1, hour: hour, minute: minute, second: second, nanosecond: nanosecond, weekday: dayOfYear % 10 + 1, quarter: dayOfYear / 90 + 1, weekOfMonth: dayOfYear % 30 / 10 + 1, weekOfYear: dayOfYear / 10 + 1, yearForWeekOfYear: year)
    }
    
    /// Increments the Republican year for this Date. The Gregorian `date` will be recomputed.
    mutating func nextYear() {
        components.year! += 1
        components.yearForWeekOfYear! += 1
        date = Date(dayInYear: dayInYear, year: components.year!, hour: components.hour, minute: components.minute, second: components.second, nanosecond: components.nanosecond)
    }

    /// Returns string as EEEE d MMMM "An" yyyy
    func toVeryLongString() -> String {
        if components.month == 13 {
            return toLongString()
        }
        return "\(weekdayName) \(toLongString())"
    }
    
    /// Returns string as d MMMM "An" yyyy
    func toLongString() -> String {
        return "\(toLongStringNoYear()) An \(components.year!)"
    }
    
    /// Returns string as d MMMM
    func toLongStringNoYear() -> String {
        if components.month == 13 {
            return "\(FrenchRepublicanDate.sansculottidesDayNames[components.day! - 1])"
        }
        return "\(components.day!) \(monthName)"
    }
    
    /// Returns string as d MMM
    func toShortString() -> String {
        if components.month == 13 {
            return "\(FrenchRepublicanDate.sansculottidesShortNames[components.day! - 1])"
        }
        return "\(components.day!) \(shortMonthName)"
    }
    
    /// Returns string as dd/MM/yyy
    func toShortenedString() -> String {
        return "\(components.day! >= 10 ? "" : "0")\(components.day!)/\(components.month! >= 10 ? "" : "0")\(components.month!)/\(components.year!)"
    }
    
    /// Localized month name
    var monthName: String {
        FrenchRepublicanDate.allMonthNames[components.month! - 1]
    }
    
    /// Localized shortened month name
    var shortMonthName: String {
        FrenchRepublicanDate.shortMonthNames[components.month! - 1]
    }
    
    /// the day of the week's name
    var weekdayName: String {
        FrenchRepublicanDate.allWeekdays[components.weekday! - 1]
    }
    
    /// the name given to the day
    var dayName: String {
        FrenchRepublicanDate.allDayNames[dayInYear - 1]
    }
    
    /// the name of the quarter, or season
    var quarter: String {
        FrenchRepublicanDate.allQuarters[components.quarter! - 1]
    }
    
    /// the debug description of this value
    var debugDescription: String {
        return "\(toVeryLongString()), quarter \(components.quarter!), decade \(components.weekOfMonth!) of month, decade \(components.weekOfYear!) of year, day \(dayInYear) of year"
    }
    
    /// Returns the wiktionary or wikipedia page link associated with the day name.
    var descriptionURL: URL? {
        let wikipediaOverrides = [
            "Belle de nuit": "Mirabilis_jalapa",
            "Amaryllis": "Amaryllis_(plante)",
            "Erable sucré": "%C3%89rable_%C3%A0_sucre",
            "Perce Neige": "Perce-neige",
            "Laurier thym": "Viorne_tin",
            "Thimèle": "Daphn%C3%A9_garou",
            "Bâton d'or": "Girofl%C3%A9e_des_murailles",
            "Chamerops": "Chamaerops_humilis",
            "Épine vinette": "%C3%89pine-vinette",
            "Verge d'or": "Solidago"
        ]
        if let override = wikipediaOverrides[dayName] {
            return URL(string: "https://fr.wikipedia.org/wiki/\(override)")
        }
        guard let sanitizedName = dayName.lowercased().addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            return nil
        }
        return URL(string: "https://fr.wiktionary.org/wiki/\(sanitizedName)")
    }
}

fileprivate extension Int {
    /// If self represents a republican year, this returns true if it is sextil
    var isSextil: Bool {
        return self % 4 == 0
    }
    
    /// If self represents a gregorian year, this returns true if it is bissextil
    var isBissextil: Bool {
        return ((self % 100 != 0) && (self % 4 == 0)) || self % 400 == 0
    }
    
    /// If self represents a republican year, this returns the number of days in it
    var daysInRepublicanYear: Int {
        isSextil ? 366 : 365
    }
    
    /// If self represents a gregorian year, this returns the number of days in it
    var daysInGregorianYear: Int {
        isBissextil ? 366 : 365
    }
    
    /// Increments the day component, and if it overflows, updates the year value
    /// - Parameters:
    ///   - add: The number of days to add (or remove if negative) to/from ourself
    ///   - year: The inout year, updated if necessary
    ///   - daysInYear: A keypath in Int returning an Int: "\.daysInRepublicanYear" or "\.daysInGregorianYear"
    mutating func increment(by add: Int, year: inout Int, daysInYear: KeyPath<Int, Int>) {
        let division = (self + add).quotientAndRemainder(dividingBy: year[keyPath: daysInYear])
        self = division.remainder
        year += division.quotient
        if self < 0 {
            year -= 1
            self += year[keyPath: daysInYear]
        }
    }
}

extension Calendar {
    static let gregorian = Calendar(identifier: .gregorian)
}

extension Date {
    /// Creates a Date from the given Republican date components
    /// - Parameters:
    ///   - dayInYear: Republican Day in Year, 1-indexed
    ///   - year: Republican Year
    ///   - hour: Hour, will directly be copied over
    ///   - minute: Minute, will directly be copied over
    ///   - second: Second, will directly be copied over
    ///   - nanosecond: Nanosecond, will directly be copied over
    init(dayInYear: Int, year: Int, hour: Int? = nil, minute: Int? = nil, second: Int? = nil, nanosecond: Int? = nil) {
        self = Calendar.gregorian.date(from: Date.dateToGregorian(dayInYear: dayInYear, year: year, hour: hour, minute: minute, second: second, nanosecond: nanosecond))!
    }
}

fileprivate extension Date {
    /// Converts a date from Republican to Gregorian date components.
    /// - Parameters:
    ///   - rDayInYear: Republican Day in Year, 1-indexed
    ///   - rYear: Republican Year
    ///   - hour: Hour, will directly be copied over
    ///   - minute: Minute, will directly be copied over
    ///   - second: Second, will directly be copied over
    ///   - nanosecond: Nanosecond, will directly be copied over
    /// - Returns: A DateComponents object containing the gregorian year and day of year, with the additional time components copied over.
    static func dateToGregorian(dayInYear rDayInYear: Int, year rYear: Int, hour: Int? = nil, minute: Int? = nil, second: Int? = nil, nanosecond: Int? = nil) -> DateComponents {
        var gYear = rYear + 1792
        var gDayOfYear = rDayInYear
        gDayOfYear.increment(by: -102, year: &gYear, daysInYear: \.daysInGregorianYear)
        
        var yt = 0
        var diff: Int
        repeat {
            diff = (gYear / 100 - 15) * 3 / 4 - 1 - yt
            gDayOfYear.increment(by: diff, year: &gYear, daysInYear: \.daysInGregorianYear)
            yt += diff
        } while diff != 0
        
        if rYear.isSextil && !gYear.isBissextil && rDayInYear > 101 - yt && (rDayInYear - 101 + yt) <= 366 {
            gDayOfYear.increment(by: -1, year: &gYear, daysInYear: \.daysInGregorianYear)
        }
        
        return DateComponents(calendar: Calendar.gregorian, year: gYear, day: gDayOfYear + 1, hour: hour, minute: minute, second: second, nanosecond: nanosecond)
    }
}
