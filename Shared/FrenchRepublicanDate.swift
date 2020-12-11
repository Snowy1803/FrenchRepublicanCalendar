//
//  FrenchRepublicanCalendarCalculator.swift
//  FrenchRepublicanCalendar Shared
//
//  Created by Emil on 06/03/2020.
//  Copyright © 2020 Snowy_1803. All rights reserved.
//

import Foundation

struct FrenchRepublicanDate: CustomDebugStringConvertible {
    static let origin = Date(timeIntervalSince1970: -5594191200)
    
    static let allMonthNames = ["Vendémiaire", "Brumaire", "Frimaire", "Nivôse", "Pluviôse", "Ventôse", "Germinal", "Floréal", "Prairial", "Messidor", "Thermidor", "Fructidor", "Sansculottide"]
    static let sansculottidesDayNames = ["Jour de la vertu", "Jour du génie", "Jour du travail", "Jour de l'opinion", "Jour des récompenses", "Jour de la révolution"]

    static let shortMonthNames = ["Vend.r", "Brum.r", "Frim.r", "Niv.ô", "Pluv.ô", "Vent.ô", "Germ.l", "Flo.l", "Prai.l", "Mes.or", "Ther.or", "Fru.or", "Ss.cu"]
    static let sansculottidesShortNames = ["Jr vertu", "Jr génie", "Jr travail", "Jr opinion", "Jr récompenses", "Jr révolution"]
    
    static let allWeekdays = ["Primidi", "Duodi", "Tridi", "Quartidi", "Quintidi", "Sextidi", "Septidi", "Octidi", "Nonidi", "Décadi"]
    
    static let allDayNames = ["Raisin", "Safran", "Châtaigne", "Colchique", "Cheval", "Balsamine", "Carotte", "Amaranthe", "Panais", "Cuve", "Pomme de terre", "Immortelle", "Potiron", "Réséda", "Ane", "Belle de nuit", "Citrouille", "Sarrasin", "Tournesol", "Pressoir", "Chanvre", "Pêche", "Navet", "Amaryllis", "Bœuf", "Aubergine", "Piment", "Tomate", "Orge", "Tonneau", "Pomme", "Céleri", "Poire", "Betterave", "Oie", "Héliotrope", "Figue", "Scorsonère", "Alisier", "Charrue", "Salsifis", "Macre", "Topinambour", "Endive", "Dindon", "Chervis", "Cresson", "Dentelaire", "Grenade", "Herse", "Bacchante", "Azerole", "Garance", "Orange", "Faisan", "Pistache", "Macjonc", "Coing", "Cormier", "Rouleau", "Raiponce", "Turneps", "Chicorée", "Nèfle", "Cochon", "Mâche", "Chou-fleur", "Miel", "Genièvre", "Pioche", "Cire", "Raifort", "Cèdre", "Sapin", "Chevreuil", "Ajonc", "Cyprès", "Lierre", "Sabine", "Hoyau", "Erable sucré", "Bruyère", "Roseau", "Oseille", "Grillon", "Pignon", "Liège", "Truffe", "Olive", "Pelle", "Tourbe", "Houille", "Bitume", "Soufre", "Chien", "Lave", "Terre végétale", "Fumier", "Salpêtre", "Fléau", "Granit", "Argile", "Ardoise", "Grès", "Lapin", "Silex", "Marne", "Pierre à chaux", "Marbre", "Van", "Pierre à Plâtre", "Sel", "Fer", "Cuivre", "Chat", "Étain", "Plomb", "Zinc", "Mercure", "Crible", "Lauréole", "Mousse", "Fragon", "Perce Neige", "Taureau", "Laurier thym", "Amadouvier", "Mézéréon", "Peuplier", "Cognée", "Ellébore", "Brocoli", "Laurier", "Avelinier", "Vache", "Buis", "Lichen", "If", "Pulmonaire", "Serpette", "Thlaspi", "Thimèle", "Chiendent", "Trainasse", "Lièvre", "Guède", "Noisetier", "Cyclamen", "Chélidoine", "Traineau", "Tussilage", "Cornouiller", "Violier", "Troëne", "Bouc", "Asaret", "Alaterne", "Violette", "Marceau", "Bêche", "Narcisse", "Orme", "Fumeterre", "Vélar", "Chèvre", "Épinard", "Doronic", "Mouron", "Cerfeuil", "Cordeau", "Mandragore", "Persil", "Cochléaire", "Pâquerette", "Thon", "Pissenlit", "Sylve", "Capillaire", "Frêne", "Plantoir", "Primevère", "Platane", "Asperge", "Tulipe", "Poule", "Blette", "Bouleau", "Jonquille", "Aulne", "Couvoir", "Pervenche", "Charme", "Morille", "Hêtre", "Abeille", "Laitue", "Mélèze", "Cigüe", "Radis", "Ruche", "Gainier", "Romaine", "Marronnier", "Roquette", "Pigeon", "Lilas", "Anémone", "Pensée", "Myrtille", "Greffoir", "Rose", "Chêne", "Fougère", "Aubépine", "Rossignol", "Ancolie", "Muguet", "Champignon", "Hyacinthe", "Râteau", "Rhubarbe", "Sainfoin", "Bâton d'or", "Chamerops", "Ver à soie", "Consoude", "Pimprenelle", "Corbeille d'or", "Arroche", "Sarcloir", "Statice", "Fritillaire", "Bourache", "Valériane", "Carpe", "Fusain", "Civette", "Buglosse", "Sénevé", "Houlette", "Luzerne", "Hémérocalle", "Trèfle", "Angélique", "Canard", "Mélisse", "Fromental", "Martagon", "Serpolet", "Faux", "Fraise", "Bétoine", "Pois", "Acacia", "Caille", "Œillet", "Sureau", "Pavot", "Tilleul", "Fourche", "Barbeau", "Camomille", "Chèvre-feuille", "Caille-lait", "Tanche", "Jasmin", "Verveine", "Thym", "Pivoine", "Chariot", "Seigle", "Avoine", "Oignon", "Véronique", "Mulet", "Romarin", "Concombre", "Échalotte", "Absinthe", "Faucille", "Coriandre", "Artichaut", "Girofle", "Lavande", "Chamois", "Tabac", "Groseille", "Gesse", "Cerise", "Parc", "Menthe", "Cumin", "Haricot", "Orcanète", "Pintade", "Sauge", "Ail", "Vesce", "Blé", "Chalémie", "Épeautre", "Bouillon blanc", "Melon", "Ivraie", "Bélier", "Prêle", "Armoise", "Carthame", "Mûre", "Arrosoir", "Panis", "Salicorne", "Abricot", "Basilic", "Brebis", "Guimauve", "Lin", "Amande", "Gentiane", "Écluse", "Carline", "Câprier", "Lentille", "Aunée", "Loutre", "Myrte", "Colza", "Lupin", "Coton", "Moulin", "Prune", "Millet", "Lycoperdon", "Escourgeon", "Saumon", "Tubéreuse", "Sucrion", "Apocyn", "Réglisse", "Échelle", "Pastèque", "Fenouil", "Épine vinette", "Noix", "Truite", "Citron", "Cardère", "Nerprun", "Tagette", "Hotte", "Églantier", "Noisette", "Houblon", "Sorgho", "Écrevisse", "Bigarade", "Verge d'or", "Maïs", "Marron", "Panier", "Vertu", "Génie", "Travail", "Opinion", "Récompenses", "Révolution"]
    
    static let allQuarters = ["Automne", "Hiver", "Printemps", "Été", "Sansculottides"]
    
    /// the Date this object was initialized with
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
    
    init(date: Date) {
        self.date = date
        dateToFrenchRepublican()
    }
    
    /// Notes dayInYear is 1-indexed
    init(dayInYear: Int, year: Int, hour: Int? = nil, minute: Int? = nil, second: Int? = nil, nanosecond: Int? = nil) {
        self.date = Date(dayOfYear: dayInYear, year: year, hour: hour, minute: minute, second: second, nanosecond: nanosecond)
        initComponents(dayOfYear: dayInYear - 1, year: year, hour: hour, minute: minute, second: second, nanosecond: nanosecond)
    }

    /// calculates a  0-indexed day of year out of self.date, without the correction algorithms.
    private func simpleGregToRepDate(gregorianYear year: Int) -> Int {
        var dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date)! - 265
        if year.isBissextil {
            dayOfYear -= 1
        }
        if dayOfYear < 0 {
            dayOfYear += 365
        }
        return dayOfYear
    }
    
    private func updateDay(byAdding add: Int, toDayOfYear day: inout Int, inYear year: inout Int) {
        let division = (day + add).quotientAndRemainder(dividingBy: year.daysInRepublicanYear)
        day = division.remainder
        year += division.quotient
        if day < 0 {
            year -= 1
            day += year.daysInRepublicanYear
        }
    }

    private mutating func dateToFrenchRepublican() {
        let gregorian = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second, .nanosecond], from: date)
        var year = gregorian.year! - 1792
        if gregorian.month! > 9 || (gregorian.month == 9 && gregorian.day! > 21) {
            year += 1
        }
        var dayOfYear = simpleGregToRepDate(gregorianYear: gregorian.year!)
        if year.isSextil && (gregorian.month! < 9 || (gregorian.month == 9 && gregorian.day! < 22)) {
            updateDay(byAdding: 1, toDayOfYear: &dayOfYear, inYear: &year)
        }
        let remdays = (gregorian.year! / 100 - 15) * 3 / 4 - 1
        updateDay(byAdding: -remdays, toDayOfYear: &dayOfYear, inYear: &year)
        
        initComponents(dayOfYear: dayOfYear, year: year, hour: gregorian.hour, minute: gregorian.minute, second: gregorian.second, nanosecond: gregorian.nanosecond)
    }
    
    /// Note dayOfYear is 0-indexed
    private mutating func initComponents(dayOfYear: Int, year: Int, hour: Int? = nil, minute: Int? = nil, second: Int? = nil, nanosecond: Int? = nil) {
        self.components = DateComponents(year: year, month: dayOfYear / 30 + 1, day: dayOfYear % 30 + 1, hour: hour, minute: minute, second: second, nanosecond: nanosecond, weekday: dayOfYear % 10 + 1, quarter: dayOfYear / 90 + 1, weekOfMonth: dayOfYear % 30 / 10 + 1, weekOfYear: dayOfYear / 10 + 1, yearForWeekOfYear: year)
    }
    
    mutating func nextYear() {
        components.year! += 1
        components.yearForWeekOfYear! += 1
        date = Date(dayOfYear: dayInYear, year: components.year!, hour: components.hour, minute: components.minute, second: components.second, nanosecond: components.nanosecond)
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
    
    var dayName: String {
        FrenchRepublicanDate.allDayNames[dayInYear - 1]
    }
    
    var quarter: String {
        FrenchRepublicanDate.allQuarters[components.quarter! - 1]
    }
    
    var debugDescription: String {
        return "\(toVeryLongString()), quarter \(components.quarter!), decade \(components.weekOfMonth!) of month, decade \(components.weekOfYear!) of year, day \(dayInYear) of year"
    }
    
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
    var isSextil: Bool {
        return self % 4 == 0
    }
    
    var isBissextil: Bool {
        return ((self % 100 != 0) && (self % 4 == 0)) || self % 400 == 0
    }
    
    var daysInRepublicanYear: Int {
        isSextil ? 366 : 365
    }
    
    var daysInGregorianYear: Int {
        isBissextil ? 366 : 365
    }
}

extension Date {
    init(dayOfYear: Int, year: Int, hour: Int? = nil, minute: Int? = nil, second: Int? = nil, nanosecond: Int? = nil) {
        self = Calendar.current.date(from: Date.dateToGregorian(dayOfYear: dayOfYear, year: year, hour: hour, minute: minute, second: second, nanosecond: nanosecond))!
    }
}

fileprivate extension Date {
    static func dateToGregorian(dayOfYear rDayOfYear: Int, year rYear: Int, hour: Int? = nil, minute: Int? = nil, second: Int? = nil, nanosecond: Int? = nil) -> DateComponents {
        var gYear = rYear + 1792
        if rDayOfYear < 102 {
            gYear -= 1
        }
        var gDayOfYear = rDayOfYear - 102
        if gDayOfYear < 0 {
            gDayOfYear += gYear.daysInGregorianYear
        }
        var y = 1800
        var yt = 0
        while gYear >= y {
            gDayOfYear += 1
            if gDayOfYear == gYear.daysInGregorianYear {
                gYear += 1
                gDayOfYear = 0
            }
            y += 100
            if y % 400 == 0 {
                y += 100
            }
            yt += 1
        }
        if rYear.isSextil && !gYear.isBissextil && rDayOfYear > 101 - yt {
            gDayOfYear -= 1
            if gDayOfYear == -1 {
                gYear -= 1
                gDayOfYear = gYear.daysInGregorianYear - 1
            }
        }
        return DateComponents(calendar: Calendar.current, year: gYear, day: gDayOfYear + 1, hour: hour, minute: minute, second: second, nanosecond: nanosecond)
    }
}
