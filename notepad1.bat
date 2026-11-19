<# : launcher
@ECHO OFF
start "" powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -Command "$raw = Get-Content -Path \"%~f0\" -Encoding UTF8 -Raw;$com = $raw.Replace(\"#argumentData#\", \"%1\");Invoke-Expression \"$com\";"
EXIT /B %errorlevel%
: end launcher #>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$currentFile = $null
$argumentData = "#argumentData#"

# Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Notepad1 Text Editor"
$form.Size = New-Object System.Drawing.Size(900,600)
$form.StartPosition = "CenterScreen"

# Text Area
$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Multiline = $true
$textBox.AcceptsTab = $true
$textBox.AcceptsReturn = $true
$textBox.ScrollBars = "Both"
$textBox.WordWrap = $true
$textBox.Dock = "Fill"
$textBox.Font = New-Object System.Drawing.Font("Consolas",11)

$form.Controls.Add($textBox)

# Status Bar
$statusStrip = New-Object System.Windows.Forms.StatusStrip
$statusStrip.Dock = "Bottom"
$statusLabel = New-Object System.Windows.Forms.ToolStripStatusLabel
$statusLabel.Text = "Ready"

$statusStrip.Items.Add($statusLabel)
$form.Controls.Add($statusStrip)

# Menu Strip
$menuStrip = New-Object System.Windows.Forms.MenuStrip
$menuStrip.Dock = "Top"

# File Menu
$fileMenu = New-Object System.Windows.Forms.ToolStripMenuItem("File")
$newMenu = New-Object System.Windows.Forms.ToolStripMenuItem("New")
$openMenu = New-Object System.Windows.Forms.ToolStripMenuItem("Open")
$saveMenu = New-Object System.Windows.Forms.ToolStripMenuItem("Save")
$saveAsMenu = New-Object System.Windows.Forms.ToolStripMenuItem("Save As")
$exitMenu = New-Object System.Windows.Forms.ToolStripMenuItem("Exit")

$fileMenu.DropDownItems.AddRange(@(
    $newMenu,
    $openMenu,
    $saveMenu,
    $saveAsMenu,
    $exitMenu
))

# Edit Menu
$editMenu = New-Object System.Windows.Forms.ToolStripMenuItem("Edit")
$cutMenu = New-Object System.Windows.Forms.ToolStripMenuItem("Cut")
$copyMenu = New-Object System.Windows.Forms.ToolStripMenuItem("Copy")
$pasteMenu = New-Object System.Windows.Forms.ToolStripMenuItem("Paste")

$editMenu.DropDownItems.AddRange(@(
    $cutMenu,
    $copyMenu,
    $pasteMenu
))

# Format Menu
$formatMenu = New-Object System.Windows.Forms.ToolStripMenuItem("Format")
$wordWrapMenu = New-Object System.Windows.Forms.ToolStripMenuItem("Word Wrap")
$wordWrapMenu.CheckOnClick = $true
$wordWrapMenu.Checked = $true

$fontMenu = New-Object System.Windows.Forms.ToolStripMenuItem("Font")

$formatMenu.DropDownItems.AddRange(@(
    $wordWrapMenu,
    $fontMenu
))

# Help Menu
$helpMenu = New-Object System.Windows.Forms.ToolStripMenuItem("Help")
$aboutMenu = New-Object System.Windows.Forms.ToolStripMenuItem("About")

$helpMenu.DropDownItems.AddRange(@(
    $aboutMenu
))

$menuStrip.Items.AddRange(@(
    $fileMenu,
    $editMenu,
    $formatMenu,
    $helpMenu
))

$form.Controls.Add($menuStrip)
$form.MainMenuStrip = $menuStrip

function Update-Title {
    if ($currentFile) {
        $form.Text = "$(Split-Path $currentFile -Leaf) - Notepad1 Text Editor"
    }
    else {
        $form.Text = "Untitled - Notepad1 Text Editor"
    }
}

function Save-CurrentFile {

    if (-not $currentFile) {
        $saveDialog = New-Object System.Windows.Forms.SaveFileDialog
        $saveDialog.Filter = "Text Files (*.txt)|*.txt|All Files (*.*)|*.*"

        if ($saveDialog.ShowDialog() -eq "OK") {
            $script:currentFile = $saveDialog.FileName
        }
        else {
            return
        }
    }

    Set-Content -Path $currentFile -Value $textBox.Text -Encoding UTF8
    $statusLabel.Text = "Saved : $currentFile"
    Update-Title
}

function Open-ArgumentData {
    if (($argumentData -ne "") -and (Test-Path $argumentData)) {
        $textBox.Text = Get-Content $argumentData -Raw -Encoding UTF8
        $script:currentFile = $argumentData
        $statusLabel.Text = "Opened : $currentFile"
        Update-Title
    }
}

# New
$newMenu.Add_Click({
    $textBox.Clear()
    $script:currentFile = $null
    Update-Title
})

# Open
$openMenu.Add_Click({
    $openDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openDialog.Filter = "Text Files (*.txt)|*.txt|All Files (*.*)|*.*"

    if ($openDialog.ShowDialog() -eq "OK") {
        $textBox.Text = Get-Content $openDialog.FileName -Raw -Encoding UTF8
        $script:currentFile = $openDialog.FileName
        $statusLabel.Text = "Opened : $currentFile"
        Update-Title
    }
})

# Save
$saveMenu.Add_Click({
    Save-CurrentFile
})

# Save As
$saveAsMenu.Add_Click({
    $saveDialog = New-Object System.Windows.Forms.SaveFileDialog
    $saveDialog.Filter = "Text Files (*.txt)|*.txt|All Files (*.*)|*.*"

    if ($saveDialog.ShowDialog() -eq "OK") {
        $script:currentFile = $saveDialog.FileName
        Save-CurrentFile
    }
})

# Exit
$exitMenu.Add_Click({
    $form.Close()
})

# Cut
$cutMenu.Add_Click({
    $textBox.Cut()
})

# Copy
$copyMenu.Add_Click({
    $textBox.Copy()
})

# Paste
$pasteMenu.Add_Click({
    $textBox.Paste()
})

# Word Wrap
$wordWrapMenu.Add_Click({
    $textBox.WordWrap = $wordWrapMenu.Checked
})

# Font Dialog
$fontMenu.Add_Click({

    $fontDialog = New-Object System.Windows.Forms.FontDialog

    if ($fontDialog.ShowDialog() -eq "OK") {
        $textBox.Font = $fontDialog.Font
    }
})

# About
$aboutMenu.Add_Click({
    [System.Windows.Forms.MessageBox]::Show('Notepad1 v0.0.1 '+"`r`n"+'Copyright (c) 2026 Nuzulul Zulkarnain'+"`r`n"+'https://nuzulul.github.io/notepad1/'+"`r`n"+'MIT License','About')
})

# Update Status Bar
$textBox.Add_TextChanged({
    $statusLabel.Text = "Characters: $($textBox.Text.Length)"
})

Update-Title
Open-ArgumentData

[void]$form.ShowDialog()