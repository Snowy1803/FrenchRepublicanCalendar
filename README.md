#  French Republican Calendar
## (aka Calendrier Républicain Moderne)

[Version Française](LISEZMOI.md)

Swift Converter between the Gregorian Calendar and the French Republican Calendar. Fully tested and compliant with the original version.

[Download on the App Store](https://apps.apple.com/fr/app/calendrier-républicain-moderne/id1509106182)

Features:
 - iOS app for converting between the two calendars
 - watchOS companion with a complication to get the current date on the watch face
 - Widget to get it on the iOS14 Home Screen
 - Tests so you can see for yourself that only my implementation is correct 😤

Often, online converters are wrong : They either forget that 1800 and 1900 were sextils but not leap years, either forget 2000 was a leap year.  
You can often see that by youself by converting around March 1st of those years... My implementation is fully tested and doesn't have those issues.

All returned values are correct, until around the years 15.300 (in Gregorian), where the Republican to Gregorian conversion fails, because at that point, the first day of the Republican year and the first day of the Gregorian year happen at the same time.

UI is 100% SwiftUI, with the UIKit Lifecycle (for iOS 13 compatibility)
