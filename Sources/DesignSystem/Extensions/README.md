# Extensions

Små, återanvändbara Swift-extensions på vanliga typer, samt designsystemets tokens för färg, typografi och avstånd.

## Riktlinjer

- Håll varje extension fokuserad och liten.
- Namnge filen efter typen som utökas: `Color+Extensions.swift`, `String+Extensions.swift`.
- Extensions som hör till en specifik komponent ligger i komponentens mapp, inte här.

---

## Färgtokens (`Color+Extensions.swift`)

Alla färger läses från `Assets.xcassets/Colors` med ljust och mörkt läge. Namnkonvention:

| Suffix | Betydelse |
|---|---|
| *(inget)* | Förgrund: text, ikon, kant |
| `Graphic` | Förgrund för grafik och diagram, något dämpad |
| `Surface` | Bakgrundsyta |
| `SurfaceBold` | Kraftigare bakgrundsyta |
| `SurfaceMinimal` | Ljusaste bakgrundsytan |
| `SurfaceFocus` | Yta för fokuserat/valt tillstånd |
| `Fixed` | Byter inte färg i mörkt läge |
| `Inverted` | För användning på mörk/färgad yta |
| `Variant` | Sekundär variant med lägre kontrast |

### `Color.Primary`

`action`, `actionFixed`, `actionInverted`, `actionInvertedFixed`, `actionVariant`, `base`, `baseGraphic`, `baseSurface`, `baseSurfaceBold`, `baseSurfaceFocus`, `baseSurfaceMinimal`, `blue`, `blueGraphic`, `blueSurface`, `blueSurfaceBold`, `blueSurfaceFocus`, `blueSurfaceMinimal`

### `Color.Accent`

| Färg | Tokens |
|---|---|
| brown | `brown`, `brownGraphic`, `brownSurface`, `brownSurfaceBold`, `brownSurfaceMinimal`, `brownSurfaceFixed` |
| cyan | `cyan`, `cyanGraphic`, `cyanSurface`, `cyanSurfaceBold`, `cyanSurfaceMinimal` |
| green | `green`, `greenGraphic`, `greenSurface`, `greenSurfaceBold`, `greenSurfaceMinimal` |
| lime | `lime`, `limeGraphic`, `limeSurface`, `limeSurfaceBold`, `limeSurfaceMinimal` |
| orange | `orange`, `orangeGraphic`, `orangeSurface`, `orangeSurfaceBold`, `orangeSurfaceMinimal` |
| pink | `pink`, `pinkGraphic`, `pinkGraphicFixed`, `pinkSurface`, `pinkSurfaceBold`, `pinkSurfaceMinimal` |
| purple | `purple`, `purpleGraphic`, `purpleGraphicFixed`, `purpleSurface`, `purpleSurfaceBold`, `purpleSurfaceMinimal` |
| red | `red`, `redGraphic`, `redSurface`, `redSurfaceBold`, `redSurfaceMinimal` |
| yellow | `yellow`, `yellowGraphic`, `yellowSurface`, `yellowSurfaceBold`, `yellowSurfaceMinimal` |

### `Color.Neutral`

`text`, `textVariant`, `textDisabled`, `textFixed`, `textInverted`, `textInvertedFixed`, `border`, `borderDisabled`, `divider`, `dividerVariant`, `disabled`, `disabledVariant`, `surfaceDisabled`

### `Color.Status`

| Status | Yta | Text |
|---|---|---|
| information | `informationSurface` | `informationText` |
| success | `successSurface` | `successText` |
| warning | `warningSurface` | `warningText` |
| error | `errorSurface` | `errorText` |

### `Color.Elevation`

`background` (skärmbakgrund), `elevation1` … `elevation5` (upphöjda ytor, kort ligger normalt på `elevation1`)

### Övriga

`Color.Custom.healthcare20` – mörkblå specialfärg för vårdrelaterat innehåll.

---

## Typografi (`Font+Extensions.swift`)

Viktade varianter av systemstilarna. Använd dessa i stället för `.font(.body).fontWeight(.bold)` så att vikt och stil hålls ihop.

| Stil | Tokens |
|---|---|
| body | `bodyLight`, `bodyRegular`, `bodyMedium`, `bodySemibold`, `bodyBold` |
| footnote | `footnoteRegular`, `footnoteMedium`, `footnoteSemibold`, `footnoteBold` |
| headline | `headlineSemibold`, `headlineBold` |
| title | `titleSemibold`, `titleBold` |
| title2 | `title2Semibold`, `title2Bold` |
| title3 | `title3Semibold`, `title3Bold` |
| subheadline | `subheadlineSemibold`, `subheadlineBold` |
| caption | `captionSemibold`, `captionBold` |

---

## Avstånd och radier (`CGFloat+ThemeValues.swift`)

| Namnrymd | Token | Värde |
|---|---|---|
| `CGFloat.Margins` | `xtraSmall` | 8 |
| | `small` | 12 |
| | `medium` | 16 (standard för de flesta layouter) |
| | `large` | 24 |
| | `xtraLarge` | 32 |
| | `safeArea` | 16 (horisontell indragning mot skärmkant) |
| `CGFloat.Radius` | `smallSchema` | 8 |
| | `mainRadius` | 26 (kort och rundade ytor) |
| | `large38` | 38 |
| | `vgrCorner` | 40 (VGR-profilerad radie) |
| | `screen` | 62 (helskärmsbehållare) |
| `CGFloat.Letterspacing` | `small` | 0.2 |
| | `medium` | 0 |

---

## View-hjälpare (`View+Extensions.swift`)

| Modifier | Beskrivning |
|---|---|
| `.selected(_ isSelected: Bool)` | Sätter miljövärdet `\.isSelected` som rader och kort läser för att rita valt tillstånd |
| `.isVisible(_ shouldShow: Bool)` | Renderar `EmptyView` när `false`, så vyn försvinner ur layouten |
| `.maxLeading()` / `.maxCentered()` / `.maxTrailing()` | Fyller tillgänglig bredd och justerar innehållet |
| `.warningBorder(_ isVisible: Bool)` | Kant i `Color.Status.errorText`, 2 pt, med `mainRadius` |
| `.roundedBorder(_ isVisible: Bool = true, borderColor: Color = .Neutral.divider, lineWidth: CGFloat = 1)` | Rundad kant med `mainRadius` |
| `.applyFullWidth(_ isFullWidth: Bool, alignment: Alignment = .center)` | `frame(maxWidth: .infinity)` endast när `true` |
| `.dismissesKeyboardOnScroll()` | Stänger tangentbordet vid scroll |
| `.dismissesKeyboardOnEscape()` | Stänger tangentbordet på Escape från externt tangentbord |

---

## Datum och kalender

### `Date+Extensions.swift`

- Gränser: `startOfDay`, `endOfDay`, `startOfWeek`, `endOfWeek`, `startOfMonth`, `endOfMonth`, `nextMonth`, `startOfYear`, `endOfYear`
- Komponenter: `year`, `month`, `dayInMonth`, `hour`, `minute`, `week`, `weekday`
- Formatering (svensk locale): `vgrDateFormat`, `vgrMonthFormat`, `vgrShortMonthFormat`, `vgrWeekFormat`, `vgrLongWeekFormat`, `vgrTimeFormat`, `vgrShortTimeFormat`, `vgrDateTimeFormat` samt VoiceOver-varianterna `vgrTimeA11yFormat`, `vgrDateTimeA11yFormat`, `vgrRelativeDateA11yFormat`
- Jämförelser med precision: `isEqual(to:component:)`, `isLess(than:)`, `isGreater(than:)`, `isEqualOrLess(than:)`, `isEqualOrGreater(than:)`, `isWithin(_:)`, `isWithinLast14Days`
- `datesForCurrentWeek(startingFrom:)`

### `Calendar+Extensions.swift`

- Jämförelser: `isSameDay`, `lessThan`, `lessThanOrEqual`, `greaterThan`, `greaterThanOrEqual`, `areEqual`
- Intervall: `numberOfDaysBetween`, `daysBetween`, `weekdays(in:matching:)`, `datesByMonth(in:preferredDay:)`, `dateInterval(from:count:component:)`, `weekIntervalExact(containing:)`, `weeksInMonth(for:year:)`
- Konstruktion: `date(_:_:_:...)`, `addDays(_:to:)`, `dateWithSpecificDay(from:dayIndex:)`, `combinedDateTime(date:time:)`, `startOfWeek(for:)`
- Formatering: `formatDate(_:showWeekday:allDay:)`, `formatDateInterval(_:allDay:a11y:forceShowEndDate:)`

### `DateInterval+Extensions.swift`

`monthsIncluded(using:)`, `mergeWith(_:)`, `numberOfDays`

---

## Strängar och lokalisering (`String+Extensions.swift`)

| Medlem | Slår upp i | Användning |
|---|---|---|
| `"key".localized` | Appens bundle | Appens egna strängar |
| `"key".localizedFormat(arguments:)` | Appens bundle | Med formatargument |
| `"key".loc(in:)` / `.locFmt(in:arguments:)` | Valfritt bundle | När bundle ska styras explicit |
| `"key".localizedBundle` | Paketets bundle | Designsystemets egna strängar. Används internt |
| `"key".localizedBundleFormat(arguments:)` | Paketets bundle | Med formatargument |
| `LocalizedHelper.localizedAttributed(forKey:bundle:)` | Valfritt bundle | Markdown till `AttributedString` |
| `LocalizedHelper.localizedBulletList(forKey:bundle:)` | Valfritt bundle | Punktlista som `[AttributedString]` |
| `capitalizeFirstLetterRestLowercase` | – | "hEJ" → "Hej" |

---

## `Bundle+Extensions.swift`

Läser Info.plist-värden: `appName`, `displayName`, `language`, `identifier`, `copyright`, `appBuild`, `appVersionLong`.
