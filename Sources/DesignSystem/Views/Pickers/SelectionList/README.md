# SelectionList

`SelectionList` innehåller färdigpaketerade listkomponenter för att välja ett eller flera objekt ur en uppsättning alternativ. Komponenterna bygger på `Lists`-stacken (`VGRContainer`, `VGRSection`, `VGRList`) och använder `VGRSelectRow` respektive `VGRCheckRow` för att rendera raderna.

Två varianter finns — en för enval (radio-beteende) och en för flerval (kryssruta-beteende) — och varje variant levereras både som en ren lista och som en färdig skärm med navigationstitel.

```
VGRSingleSelectionListScreen   VGRMultiSelectionListScreen
          │                               │
          └──> VGRSingleSelectionList     └──> VGRMultiSelectionList
                     │                               │
                     └──> VGRSelectRow               └──> VGRCheckRow
```

---

## 🧱 Komponenter

### `VGRSelectionListItem`
En enkel datamodell för enskilda val i listan. Innehåller ett stabilt `id` (`String`) och en `name` för visning. Två initialiserare finns:

- `init(id: String, name: String)` — när anroparen vill styra id:et (t.ex. en domännyckel).
- `init(name: String)` — genererar ett UUID som id automatiskt, bra för snabba exempel eller engångsvärden.

Komponenterna är generiska, så det går lika bra att använda en egen domänmodell så länge den uppfyller `Identifiable` (enval) eller `Identifiable & Hashable` (flerval).

### `VGRSingleSelectionList`
Lista där användaren kan välja **exakt ett** alternativ. Listan äger bara urvalstillståndet — radens innehåll byggs av en `row`-closure som tar `(item, isSelected)` och kan returnera vilken vy som helst (ex. `VGRSelectRow`). Som standard går det inte att avmarkera ett redan valt objekt — klassiskt radio-beteende — men detta kan slås på via `allowsDeselection: true`.

| Parameter            | Typ                          | Default | Beskrivning                                               |
|----------------------|------------------------------|---------|-----------------------------------------------------------|
| `header`             | `String?`                    | `nil`   | Rubrik för omslutande `VGRSection`                         |
| `items`              | `[Item]`                     | –       | Alternativen som visas i listan                           |
| `selection`          | `Binding<Item?>`             | –       | Det aktuella valet, eller `nil`                           |
| `allowsDeselection`  | `Bool`                       | `false` | Tillåt att tömma valet genom att klicka på markerad rad   |
| `warnIfNotSelected`  | `Bool`                       | `false` | Visar en varningsram runt listan när inget är valt        |
| `row`                | `(Item, Bool) -> some View`  | –       | Bygger radens vy givet aktuell `isSelected`-status         |

### `VGRMultiSelectionList`
Lista där användaren kan välja **noll eller fler** alternativ. Listan äger bara urvalstillståndet — radens innehåll byggs av en `row`-closure som tar `(item, isSelected)` och kan returnera vilken vy som helst (ex. `VGRCheckRow`). Valet exponeras som ett `Set` av objekt — samma struktur används för att förvälja rader när vyn visas.

| Parameter            | Typ                          | Default | Beskrivning                                                |
|----------------------|------------------------------|---------|------------------------------------------------------------|
| `header`             | `String?`                    | `nil`   | Rubrik för omslutande `VGRSection`                          |
| `items`              | `[Item]`                     | –       | Alternativen som visas i listan                            |
| `selection`          | `Binding<Set<Item>>`         | –       | Aktuellt urval. Seed:a för att förvälja rader              |
| `warnIfNotSelected`  | `Bool`                       | `false` | Visar en varningsram runt listan när urvalet är tomt       |
| `row`                | `(Item, Bool) -> some View`  | –       | Bygger radens vy givet aktuell `isSelected`-status          |

### `VGRSingleSelectionListScreen` / `VGRMultiSelectionListScreen`
Kompletta skärmar som paketerar respektive lista med standardramverk: navigationstitel, valfri beskrivande rubrik och en `VGRContainer` runt listan. Använd dessa när du behöver det vanliga "välj från en lista"-flödet utan att upprepa layouten i varje anropare. För mer kontroll — komponera listan direkt i din egen vy.

Skärmarna lägger inte till en egen `NavigationStack`; presentera dem i en befintlig navigationskontext så att titeln visas korrekt.

---

## 🧪 Användning

**Enval, som en listkomponent:**
```swift
@State private var selection: VGRSelectionListItem? = nil

let items = [
    VGRSelectionListItem(id: "low",  name: "Låg"),
    VGRSelectionListItem(id: "mid",  name: "Medel"),
    VGRSelectionListItem(id: "high", name: "Hög"),
]

VGRContainer {
    VGRSingleSelectionList(
        header: "Välj en nivå",
        items: items,
        selection: $selection
    ) { item, isSelected in
        VGRSelectRow(title: item.name, isSelected: isSelected)
    }
}
```

**Flerval, som en listkomponent:**
```swift
@State private var selection: Set<VGRSelectionListItem> = []

VGRContainer {
    VGRMultiSelectionList(
        header: "Välj en eller flera faktorer",
        items: items,
        selection: $selection,
        warnIfNotSelected: true
    ) { item, isSelected in
        VGRCheckRow(title: item.name, isSelected: isSelected)
    }
}
```

**Färdig skärm:**
```swift
NavigationStack {
    VGRSingleSelectionListScreen(
        title: "Välj en faktor",
        description: "Vad påverkade händelsen mest?",
        items: items,
        selection: $selection,
        allowsDeselection: true
    ) { item, isSelected in
        VGRSelectRow(title: item.name, isSelected: isSelected)
    }
}
```

---

## 🎯 Designprinciper

- **Två nivåer av färdighet** — listkomponenten (`…List`) ger ren komposition, skärmen (`…ListScreen`) ger nyckelfärdig UX.
- **Generisk över typen** — listorna tar vilken `Identifiable`/`Identifiable & Hashable` som helst. Använd `VGRSelectionListItem` för enkla fall, eller din egen modell när du redan har data på plats.
- **Markeringen ägs av anroparen** — listorna muterar bindningen men håller inget internt tillstånd. Det gör det enkelt att synka valet mot andra delar av skärmen.
- **Radio- vs. checkbox-semantik är explicit** — `VGRSingleSelectionList` kräver `allowsDeselection: true` för att tillåta tom markering, så standardbeteendet är förutsägbart.

---

## 📁 Filer i mappen

| Fil                                     | Roll                                              |
|-----------------------------------------|---------------------------------------------------|
| `VGRSelectionListItem.swift`            | Gemensam datamodell för listvärden                |
| `VGRSingleSelectionList.swift`          | Lista för enval (radio)                           |
| `VGRMultiSelectionList.swift`           | Lista för flerval (checkbox)                      |
| `VGRSingleSelectionListScreen.swift`    | Färdig skärm för enval                            |
| `VGRMultiSelectionListScreen.swift`     | Färdig skärm för flerval                          |
