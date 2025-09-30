Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$version = "0.0.1"

# GUI erstellen

$form = New-Object System.Windows.Forms.Form
$form.Text = "PCS 7 Project Cleaner " + $version
$form.Size = New-Object System.Drawing.Size(600,500)

$label = New-Object System.Windows.Forms.Label
$label.Text = "Wähle das PCS 7 Projektverzeichnis:"
$label.Location = New-Object System.Drawing.Point(10,20)
$form.Controls.Add($label)

$folderPathBox = New-Object System.Windows.Forms.TextBox
$folderPathBox.Size = New-Object System.Drawing.Size(400,20)
$folderPathBox.Location = New-Object System.Drawing.Point(10,50)
$form.Controls.Add($folderPathBox)

$browseButton = New-Object System.Windows.Forms.Button
$browseButton.Text = "Durchsuchen"
$browseButton.Size = New-Object System.Drawing.Size(100, 20)
$browseButton.Location = New-Object System.Drawing.Point(420,50)
$form.Controls.Add($browseButton)

$subfolderLabel = New-Object System.Windows.Forms.Label
$subfolderLabel.Text = "Wähle Operator Stations aus:"
$subfolderLabel.Location = New-Object System.Drawing.Point(10,90)
$form.Controls.Add($subfolderLabel)

$subfolderPanel = New-Object System.Windows.Forms.Panel
$subfolderPanel.Location = New-Object System.Drawing.Point(10,120)
$subfolderPanel.Size = New-Object System.Drawing.Size(560,150)
$subfolderPanel.AutoScroll = $true
$form.Controls.Add($subfolderPanel)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(10,280)
$progressBar.Size = New-Object System.Drawing.Size(560,20)
$form.Controls.Add($progressBar)

$summaryBox = New-Object System.Windows.Forms.TextBox
$summaryBox.Multiline = $true
$summaryBox.ScrollBars = "Vertical"
$summaryBox.Location = New-Object System.Drawing.Point(10,310)
$summaryBox.Size = New-Object System.Drawing.Size(560,100)
$form.Controls.Add($summaryBox)

$deleteButton = New-Object System.Windows.Forms.Button
$deleteButton.Text = "Dateien löschen"
$deleteButton.Location = New-Object System.Drawing.Point(10,420)
$deleteButton.Size = New-Object System.Drawing.Size(100, 20)
$form.Controls.Add($deleteButton)


# Checkbox-Liste dynamisch erstellen
function Populate-SubfolderCheckboxes {
    param($basePath)

    $subfolderPanel.Controls.Clear()
    $ossPath = Join-Path $basePath "wincproj"

    if (Test-Path $ossPath) {
        $subfolders = Get-ChildItem -Path $ossPath -Directory
        $y = 0
        foreach ($sub in $subfolders) {
            $checkbox = New-Object System.Windows.Forms.CheckBox
            $checkbox.Text = $sub.Name
            $checkbox.Tag = $sub.FullName
            $checkbox.Location = New-Object System.Drawing.Point(5, $y)
            $checkbox.Width = 500
            $checkbox.Checked = $true
            $subfolderPanel.Controls.Add($checkbox)
            $y += 25
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show("Kein 'wincproj'-Unterverzeichnis gefunden.")
    }
}

# Ordnerauswahl
$browseButton.Add_Click({
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($folderBrowser.ShowDialog() -eq "OK") {
        $folderPathBox.Text = $folderBrowser.SelectedPath
        Populate-SubfolderCheckboxes -basePath $folderBrowser.SelectedPath
    }
})


# Löschlogik
$deleteButton.Add_Click({
    $ossSubDirs = @()

    foreach ($control in $subfolderPanel.Controls) {
        if ($control.Checked) {
            $ossSubDirs += $control.Tag
        }
    }

    if ($ossSubDirs.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Bitte wähle mindestens einen Unterordner aus.")
        return
    }

    $targetExtension = ".*"  # Alle Dateien in den Verzeichnissen
    $subDirs = @("protocols")

    foreach ($ossSub in $ossSubDirs) {
        if (Test-Path $ossSub) {
            $subDirs += $ossSub + "/ArchiveManager/TagLoggingFast"
            $subDirs += $ossSub + "/ArchiveManager/TagLoggingSlow"
            $subDirs += $ossSub + "/ArchiveManager/AlarmLogging"
        }
    }

    $deletedFiles = 0
    $freedSpace = 0
    $allFiles = @()
    $errors = @()

    foreach ($sub in $subDirs) {
        if (Test-Path $sub) {
            $files = Get-ChildItem -Path $sub -Recurse -Filter "*$targetExtension" -File
            $allFiles += $files
        }
    }


    $targetExtension = ".sav"  # Nur *.sav Dateien in GraCS Ordnern
    $subDirs = @()
    foreach ($ossSub in $ossSubDirs) {
        if (Test-Path $ossSub) {
            $subDirs += $ossSub + "/GraCS"
        }
    }

    foreach ($sub in $subDirs) {
        if (Test-Path $sub) {
            $files = Get-ChildItem -Path $sub -Recurse -Filter "*$targetExtension" -File
            $allFiles += $files
        }
    }

    $progressBar.Maximum = $allFiles.Count
    $progressBar.Value = 0

    foreach ($file in $allFiles) {
        try {
            $size = $file.Length
            Remove-Item $file.FullName -Force -ErrorAction Stop
            $deletedFiles++
            $freedSpace += $size
            $progressBar.Value++
            Start-Sleep -Milliseconds 50
        } catch {
            $errors += "Fehler beim Löschen: $($file.FullName) - $($_.Exception.Message)"
        }
    }

    $freedMB = [math]::Round($freedSpace / 1MB, 2)
    $summaryText = "Gelöschte Dateien: $deletedFiles`r`nFreigegebener Speicherplatz: $freedMB MB"

    
    if ($errors.Count -gt 0) {
        $summaryText += "`r`n`r`nFehlgeschlagene Löschvorgänge:`r`n" + ($errors -join "`r`n")
    }

    $summaryBox.Text = $summaryText

})


# GUI anzeigen
$form.Topmost = $true
$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()
