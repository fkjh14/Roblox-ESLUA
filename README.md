# Roblox-AntiAFK-Script

1. Grundlegende GUI-Struktur
ba (ScreenGui): Container für die gesamte GUI. Wird zu game.CoreGui hinzugefügt, sodass es auf dem Bildschirm angezeigt wird.

ca (Frame): Hauptcontainer für die GUI-Inhalte. Beinhaltet den Schatteneffekt (shadow), die Titelleiste (title), den Hauptinhalt (da) und den Schließen-Button (closeButton).

2. Schatteneffekt
shadow (Frame): Dieser Frame dient als Schatten für die GUI. Es wird so positioniert und skaliert, dass es leicht hinter der Haupt-GUI sichtbar ist und einen visuellen Schattierungseffekt erzeugt.
Eigenschaften:
BackgroundColor3: Schwarz mit Transparenz.
Position und Size: Stellen sicher, dass der Schatten den gesamten Bereich hinter der GUI abdeckt.
UICorner_shadow: Abgerundete Ecken für den Schatten.
3. Hauptcontainer (ca)
Hauptlabel (title): Zeigt den Titel der GUI an.

Eigenschaften:
BackgroundColor3: Dunkles Grau.
TextColor3: Weiß.
TextSize: 20.
UICorner_ca: Abgerundete Ecken für das Hauptcontainer (ca).
UIStroke_ca: Rahmen um das Hauptcontainer.
UIGradient_ca: Farbverlauf für den Hintergrund des Hauptcontainers.
da (Frame): Hintergrund-Frame innerhalb des Hauptcontainers, der zusätzliche GUI-Inhalte wie den Footer-Text und Status anzeigt.

Eigenschaften:
BackgroundColor3: Etwas heller als der Hauptcontainer.
UICorner_da: Abgerundete Ecken für den Hintergrund-Frame (da).
UIStroke_da: Rahmen um den Hintergrund-Frame.
UIGradient_da: Farbverlauf für den Hintergrund des Frames (da).
4. GUI-Inhalte
Footer Text (_b): Text im unteren Bereich des Hintergrund-Frames.

Eigenschaften:
BackgroundColor3: Etwas heller als der Hintergrund-Frame.
TextColor3: Hellgrau.
TextSize: 16.
Status Text (ab): Zeigt den aktuellen Status der GUI an.

Eigenschaften:
BackgroundColor3: Dunkelgrau.
TextColor3: Cyan.
TextSize: 18.
Animation: Bei AFK-Aktivierung wird die Farbe des Textes vorübergehend geändert.
Close-Button (closeButton): Ermöglicht das Schließen der GUI.

Eigenschaften:
BackgroundColor3: Rot.
TextColor3: Weiß.
TextSize: 20.
UICorner_closeButton: Abgerundete Ecken für den Close-Button.
5. Animationen
TweenService: Wird verwendet, um sanfte Übergänge für das Ein- und Ausschalten der GUI und für die Statusänderungen zu ermöglichen.

DeconstructScript Funktion: Schließt die GUI mit einer Animation.
toggleGui Funktion: Umschalten der GUI-Sichtbarkeit mit einer Animation.
6. Steuerung
Keybind für das Umschalten der GUI: LeftCtrl + G.
Verwendet UserInputService, um die Tasteneingabe zu erkennen und die GUI umzuschalten.
