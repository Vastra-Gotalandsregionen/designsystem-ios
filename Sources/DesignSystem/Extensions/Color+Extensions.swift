import SwiftUI

public extension Color {
    //MARK: - PRIMARY
    struct Primary {
        public static let action = Color("action", bundle: .module)
        public static let actionFixed = Color("actionFixed", bundle: .module)
        public static let actionInverted = Color("actioninverted", bundle: .module)
        public static let actionInvertedFixed = Color("actioninvertedfixed", bundle: .module)
        public static let actionVariant = Color("actionvariant", bundle: .module)
        public static let base = Color("base", bundle: .module)
        public static let baseGraphic = Color("basegraphic", bundle: .module)
        public static let baseSurface = Color("basesurface", bundle: .module)
        public static let baseSurfaceBold = Color("basesurfacebold", bundle: .module)
        public static let baseSurfaceFocus = Color("basesurfacefocus", bundle: .module)
        public static let baseSurfaceMinimal = Color("basesurfaceminimal", bundle: .module)
        public static let blue = Color("blue", bundle: .module)
        public static let blueGraphic = Color("bluegraphic", bundle: .module)
        public static let blueSurface = Color("bluesurface", bundle: .module)
        public static let blueSurfaceBold = Color("bluesurfacebold", bundle: .module)
        public static let blueSurfaceFocus = Color("bluesurfacefocus", bundle: .module)
        public static let blueSurfaceMinimal = Color("bluesurfaceminimal", bundle: .module)
    }
    
    //MARK: - ELEVATION
    struct Elevation {
        public static let background = Color("background", bundle: .module)
        public static let elevation1 = Color("elevation1", bundle: .module)
        public static let elevation2 = Color("elevation2", bundle: .module)
        public static let elevation3 = Color("elevation3", bundle: .module)
        public static let elevation4 = Color("elevation4", bundle: .module)
        public static let elevation5 = Color("elevation5", bundle: .module)
    }
    
    //MARK: - ACCENT
    struct Accent {
        public static let brown = Color("brown", bundle: .module)
        public static let brownGraphic = Color("browngraphic", bundle: .module)
        public static let brownSurface = Color("brownsurface", bundle: .module)
        public static let brownSurfaceBold = Color("brownsurfacebold", bundle: .module)
        public static let brownSurfaceMinimal = Color("brownsurfaceminimal", bundle: .module)
        
        public static let cyan = Color("cyan", bundle: .module)
        public static let cyanGraphic = Color("cyangraphic", bundle: .module)
        public static let cyanSurface = Color("cyansurface", bundle: .module)
        public static let cyanSurfaceBold = Color("cyansurfacebold", bundle: .module)
        public static let cyanSurfaceMinimal = Color("cyansurfaceminimal", bundle: .module)
        
        public static let green = Color("green", bundle: .module)
        public static let greenGraphic = Color("greengraphic", bundle: .module)
        public static let greenSurface = Color("greensurface", bundle: .module)
        public static let greenSurfaceBold = Color("greensurfacebold", bundle: .module)
        public static let greenSurfaceMinimal = Color("greensurfaceminimal", bundle: .module)
        
        public static let lime = Color("lime", bundle: .module)
        public static let limeGraphic = Color("limegraphic", bundle: .module)
        public static let limeSurface = Color("limesurface", bundle: .module)
        public static let limeSurfaceBold = Color("limesurfacebold", bundle: .module)
        public static let limeSurfaceMinimal = Color("limesurfaceminimal", bundle: .module)
        
        public static let orange = Color("orange", bundle: .module)
        public static let orangeGraphic = Color("orangegraphic", bundle: .module)
        public static let orangeSurface = Color("orangesurface", bundle: .module)
        public static let orangeSurfaceBold = Color("orangesurfacebold", bundle: .module)
        public static let orangeSurfaceMinimal = Color("orangesurfaceminimal", bundle: .module)
        
        public static let pink = Color("pink", bundle: .module)
        public static let pinkGraphic = Color("pinkgraphic", bundle: .module)
        public static let pinkGraphicFixed = Color("pinkgraphicfixed", bundle: .module)
        public static let pinkSurface = Color("pinksurface", bundle: .module)
        public static let pinkSurfaceBold = Color("pinksurfacebold", bundle: .module)
        public static let pinkSurfaceMinimal = Color("pinksurfaceminimal", bundle: .module)
        
        public static let purple = Color("purple", bundle: .module)
        public static let purpleGraphic = Color("purplegraphic", bundle: .module)
        public static let purpleSurface = Color("purplesurface", bundle: .module)
        public static let purpleSurfaceBold = Color("purplesurfacebold", bundle: .module)
        public static let purpleSurfaceMinimal = Color("purplesurfaceminimal", bundle: .module)
        
        public static let red = Color("red", bundle: .module)
        public static let redGraphic = Color("redgraphic", bundle: .module)
        public static let redSurface = Color("redsurface", bundle: .module)
        public static let redSurfaceBold = Color("redsurfacebold", bundle: .module)
        public static let redSurfaceMinimal = Color("redsurfaceminimal", bundle: .module)
        
        public static let yellow = Color("yellow", bundle: .module)
        public static let yellowGraphic = Color("yellowgraphic", bundle: .module)
        public static let yellowSurface = Color("yellowsurface", bundle: .module)
        public static let yellowSurfaceBold = Color("yellowsurfacebold", bundle: .module)
        public static let yellowSurfaceMinimal = Color("yellowsurfaceminimal", bundle: .module)
    }
    
    //MARK: - NEUTRAL
    struct Neutral {
        public static let border = Color("border", bundle: .module)
        public static let borderDisabled = Color("borderdisabled", bundle: .module)
        public static let disabled = Color("disabled", bundle: .module)
        public static let divider = Color("divider", bundle: .module)
        public static let dividerVariant = Color("dividervariant", bundle: .module)
        public static let surfaceDisabled = Color("surfacedisabled", bundle: .module)
        public static let text = Color("text", bundle: .module)
        public static let textDisabled = Color("textdisabled", bundle: .module)
        public static let textFixed = Color("textfixed", bundle: .module)
        public static let textInverted = Color("textinverted", bundle: .module)
        public static let textInvertedFixed = Color("textinvertedfixed", bundle: .module)
        public static let textVariant = Color("textvariant", bundle: .module)
    }
    
    //MARK: - STATUS
    struct Status {
        public static let errorSurface = Color("errorsurface", bundle: .module)
        public static let errorText = Color("errortext", bundle: .module)
        public static let informationSurface = Color("informationsurface", bundle: .module)
        public static let informationText = Color("informationtext", bundle: .module)
        public static let successText = Color("successtext", bundle: .module)
        public static let successSurface = Color("successurface", bundle: .module)
        public static let warningSurface = Color("warningsurface", bundle: .module)
        public static let warningText = Color("warningtext", bundle: .module)
    }

    //MARK: - CUSTOM
    struct Custom {
        public static let healthcare20 = Color("healthcare20", bundle: .module)
    }

    //MARK: - COMPONENTS
    struct Components {
        //MARK: - CALENDAR
        struct Calendar {
            public static let dayBackground = Color("daybackground" )
        }
    }
}
