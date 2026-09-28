# Layouts

Layouthjälpare utan eget utseende.

| Komponent                  | Användning                                                       |
|----------------------------|------------------------------------------------------------------|
| `VGRFlowLayout`            | Radbrytande layout för chips, taggar och filterpiller            |
| `VGRPortraitLandscapeView` | Visar olika innehåll beroende på om ytan är stående eller liggande |

`OrientationViewModifier/` innehåller en intern `onOrientationChange`-modifier som inte är publik.

---

## VGRFlowLayout

En `Layout` som placerar subvyer från vänster till höger och bryter rad när nästa vy inte får plats. Varje subvy mäts vid sin idealstorlek. Ny rad börjar under den högsta vyn på föregående rad, så rader med olika höjd överlappar inte.

```swift
VGRFlowLayout {
    ForEach(tags, id: \.self) { tag in
        VGRChip(tag)
    }
}

// Olika avstånd per axel
VGRFlowLayout(horizontalSpacing: 8, verticalSpacing: 12) { ... }

// Samma avstånd på båda axlarna
VGRFlowLayout(spacing: 10) { ... }
```

| Parameter           | Typ       | Default              | Beskrivning                         |
|---------------------|-----------|----------------------|-------------------------------------|
| `horizontalSpacing` | `CGFloat` | `.Margins.xtraSmall` | Avstånd mellan vyer på samma rad    |
| `verticalSpacing`   | `CGFloat` | `.Margins.small`     | Avstånd mellan rader                |
| `spacing`           | `CGFloat` | –                    | Sätter båda axlarna (egen init)     |

---

## VGRPortraitLandscapeView

Läser storleken på den yta vyn får via `GeometryReader` och väljer `portrait` när höjden är större än bredden, annars `landscape`. Orienteringen avgörs alltså av ytan, inte av enheten, vilket gör att vyn fungerar i split view och i previews med `traits:`.

```swift
VGRPortraitLandscapeView {
    VStack { chart; legend }
} landscape: {
    HStack { chart; legend }
}
```

Vyn fyller hela den yta den erbjuds.
