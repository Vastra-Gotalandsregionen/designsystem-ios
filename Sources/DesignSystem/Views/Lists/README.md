# Lists

`Lists` innehåller designsystemets byggstenar för vertikalt staplade vyer — från själva skärmbehållaren ner till enskilda raders innehåll. Komponenterna är avsedda att komponeras tillsammans enligt en tydlig hierarki:

```
VGRContainer
└── VGRSection
    └── VGRList
        ├── VGRListRow
        ├── VGRLabelRow
        ├── VGRNavRow
        ├── VGRCheckRow
        ├── VGRSelectRow
        ├── VGRToggleRow
        └── VGRMenuRow
```

Varje nivå har ett tydligt ansvar. Detta gör att vyer kan staplas flexibelt utan att varje lista behöver hantera egen scroll, bakgrund eller rubrik.

---

## 🧱 Hierarkin

### `VGRContainer`
Skärmnivåns behållare. Äger en `ScrollView`, designsystemets bakgrund (`Color.Elevation.background`) och vertikal rytm mellan sektionerna. Applicerar ingen horisontell padding — det ansvaret ligger på sektionerna.

### `VGRSection`
Gruppering med valfri rubrik och sidfot. Innehållet är godtyckligt: vanligtvis en `VGRList`, men kan vara diagram, banners, tomma tillstånd eller egna kort. Rubrik och sidfot kan vara antingen en sträng (renderas med designsystemets typografi) eller en egen vy via `@ViewBuilder`. Horisontell indragning av innehållet styrs via flaggan `inset`.

### `VGRList`
Det rundade kortet med `elevation1`-bakgrund och automatiska `VGRDivider` mellan rader. Stöder en valfri varningsram via `showWarning`. Listan hanterar inte rubrik, sidfot eller horisontell padding — den är enbart själva kortet.

---

## 🧩 Rad-komponenter

| Komponent        | Beskrivning                                                              |
|------------------|--------------------------------------------------------------------------|
| `VGRListRow`     | Standardrad med titel, valfri undertitel, ikon och accessory             |
| `VGRLabelRow`    | Rad med titel/undertitel och ett värde på höger sida (nyckel/värde-par)  |
| `VGRNavRow`      | Rad som navigerar till en destinationsvy via `NavigationLink`            |
| `VGRCheckRow`    | Rad för flerval — rund indikator som växlar mellan markerad/omarkerad    |
| `VGRSelectRow`   | Rad för enval — bockmarkering endast på den valda raden                  |
| `VGRToggleRow`   | Rad med en `Toggle`-kontroll — exponerar tillståndet via `Binding<Bool>` |
| `VGRMenuRow`     | Rad med en `Menu` — visar valt värde + upp/ned-chevron på höger sida     |

Alla rader kan användas fritt inuti en `VGRList`, men i praktiken är `VGRCheckRow` och `VGRSelectRow` avsedda att omslutas av en `Button` så att anroparen styr markeringstillståndet. `VGRToggleRow` och `VGRMenuRow` hanterar sin egen interaktion via de inbyggda kontrollerna.

---

## 🧪 Användning

```swift
VGRContainer {
    VGRSection(header: "Idag") {
        VGRList {
            VGRListRow(title: "Morgon", subtitle: "08:00")
            VGRListRow(title: "Kväll", subtitle: "20:00")
        }
    }

    VGRSection(header: "Profil",
               footer: "Dessa uppgifter visas endast för dig.") {
        VGRList {
            VGRLabelRow("Namn", value: "Anna Svensson")
            VGRLabelRow("Vikt", value: "72 kg")
            VGRNavRow(title: "Kontaktuppgifter") {
                ContactDetailsView()
            }
        }
    }

    VGRSection(header: "Statistik", inset: false) {
        ChartView()
    }
}
```

---

## 🎯 Designprinciper

- **Skärmens struktur beskrivs deklarativt** — `VGRContainer` → `VGRSection` → `VGRList` gör skärmens hierarki synlig direkt i vyn.
- **En komponent, ett ansvar** — scroll ligger i `VGRContainer`, gruppering i `VGRSection`, kort-chrome i `VGRList`.
- **Rubrik och sidfot hör till sektionen, inte till listan** — så samma lista kan återanvändas i olika sammanhang utan att dra med sig sin egen rubrik.
- **Flexibelt innehåll i sektioner** — `VGRSection` är inte låst till listor; den kan omsluta vilken vy som helst och styra horisontell indragning via `inset`.

---

## 📁 Filer i mappen

| Fil                       | Roll                                    |
|---------------------------|-----------------------------------------|
| `VGRContainer.swift`      | Scrollande skärmbehållare               |
| `VGRSection.swift`        | Gruppering med rubrik/sidfot            |
| `VGRList.swift`           | Rundat kort med rader och avdelare      |
| `VGRListRow.swift`        | Standardrad                             |
| `VGRLabelRow.swift`       | Nyckel/värde-rad                        |
| `VGRNavRow.swift`         | Navigationsrad                          |
| `VGRCheckRow.swift`       | Flervalsrad                             |
| `VGRSelectRow.swift`      | Envalsrad                               |
| `VGRToggleRow.swift`      | Rad med `Toggle`-kontroll               |
| `VGRMenuRow.swift`        | Rad med `Menu`-kontroll                 |
