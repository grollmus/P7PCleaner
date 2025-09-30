# PCS 7 Project Cleaner

**Version:** 0.0.1  
Ein PowerShell-basiertes Tool mit grafischer Oberfläche zur gezielten Bereinigung von PCS 7 Projektverzeichnissen. Es ermöglicht die Auswahl von Operator Stations und löscht automatisch bestimmte Dateien in definierten Unterverzeichnissen, um Speicherplatz freizugeben.

## 🧰 Funktionen

- Auswahl eines PCS 7 Projektverzeichnisses über eine GUI
- Automatische Erkennung von Operator Stations im Unterverzeichnis `wincproj`
- Checkbox-Auswahl für einzelne Operator Stations
- Löschen von Dateien in folgenden Unterverzeichnissen:
  - `ArchiveManager/TagLoggingFast`
  - `ArchiveManager/TagLoggingSlow`
  - `ArchiveManager/AlarmLogging`
  - `protocols`
  - `GraCS` (nur `.sav`-Dateien)
- Fortschrittsanzeige während des Löschvorgangs
- Zusammenfassung der gelöschten Dateien und des freigegebenen Speicherplatzes
- Anzeige von Fehlern beim Löschen direkt in der GUI

## 🖥️ Bedienung

1. **Starte das Skript** mit PowerShell:
   ```powershell
   powershell.exe -ExecutionPolicy Bypass -File .\PCS7ProjectCleaner.ps1
   ```
2. Wähle das Hauptverzeichnis deines PCS 7 Projekts über die Schaltfläche „Durchsuchen“.
Das Tool erkennt automatisch alle Operator Stations im Unterverzeichnis wincproj und zeigt sie als Checkboxen an.
3. Wähle die gewünschten Operator Stations aus, deren Daten gelöscht werden sollen.
4. Klicke auf „Dateien löschen“, um den Vorgang zu starten.
Die Progressbar zeigt den Fortschritt, und am Ende erscheint eine Zusammenfassung:
- Anzahl der gelöschten Dateien
- Freigegebener Speicherplatz in MB
- Etwaige Fehler beim Löschen

## ⚙️ Technische Details
Verwendet System.Windows.Forms für die GUI

Löscht alle Dateien in bestimmten Unterverzeichnissen sowie .sav-Dateien in GraCS

Fehler beim Löschen werden abgefangen und im Textfeld angezeigt

## 📦 Voraussetzungen
- Windows mit PowerShell (Version 5 oder höher empfohlen)
- Keine zusätzlichen Module erforderlich

## 📄 Lizenz
Dieses Projekt steht unter der MIT-Lizenz. Siehe LICENSE für weitere Informationen.
