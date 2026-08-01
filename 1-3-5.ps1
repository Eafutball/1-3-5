<#
.SYNOPSIS
    Organizador diario usando el sistema 1-3-5

.DESCRIPTION
    Sistema:
        - 1 objetivo grande
        - 3 objetivos medianos
        - 5 tareas pequeñas

    Compatible con:
        Windows PowerShell 5.1+
        PowerShell 7+

    No requiere módulos externos.
#>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 > $null

$ErrorActionPreference = "Stop"

#==========================================================
# Configuración
#==========================================================

$DataFolder = Join-Path $HOME "1-3-5-Lists"

if (!(Test-Path $DataFolder)) {
    New-Item -ItemType Directory -Path $DataFolder | Out-Null
}

function Get-TodayFile {
    $date = Get-Date -Format "yyyy-MM-dd"
    Join-Path $DataFolder "$date.json"
}

#==========================================================
# Utilidades
#==========================================================

function Pause-Script {
    Write-Host ""
    Read-Host "Presione ENTER para continuar"
}

function Get-TaskColor {
    param($Task)

    if ($Task.Completed) {
        return "DarkGray"
    }

    switch ($Task.Type) {
        "Grande" { return "Red" }
        "Mediana" { return "Yellow" }
        "Pequena" { return "Green" }
        default { return "White" }
    }
}

function Save-List {
    param($Data)

    $file = Get-TodayFile

    $Data | ConvertTo-Json -Depth 10 | Set-Content $file -Encoding UTF8
}

function Load-Today {
    $file = Get-TodayFile

    if (!(Test-Path $file)) {
        return $null
    }

    Get-Content $file -Raw | ConvertFrom-Json
}

function Show-Header {
    Clear-Host

    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host "           SISTEMA DE PRODUCTIVIDAD 1-3-5"
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host ""
}

#==========================================================
# Crear Lista
#==========================================================

function New-DayList {

    Show-Header

    $existing = Load-Today

    if ($existing) {

        $ans = Read-Host "Ya existe una lista para hoy. ¿Sobrescribir? (S/N)"

        if ($ans.ToUpper() -ne "S") {
            return
        }
    }

    $tasks = @()

    Write-Host ""
    Write-Host "OBJETIVO GRANDE" -ForegroundColor Red

    do {
        $text = Read-Host "Ingrese el objetivo grande"
    } until ($text.Trim() -ne "")

    $tasks += [PSCustomObject]@{
        Id = 1
        Type = "Grande"
        Text = $text
        Completed = $false
    }

    Write-Host ""

    for ($i = 1; $i -le 3; $i++) {

        do {
            $text = Read-Host "Objetivo mediano $i"
        } until ($text.Trim() -ne "")

        $tasks += [PSCustomObject]@{
            Id = $tasks.Count + 1
            Type = "Mediana"
            Text = $text
            Completed = $false
        }
    }

    Write-Host ""

    for ($i = 1; $i -le 5; $i++) {

        do {
            $text = Read-Host "Tarea pequeña $i"
        } until ($text.Trim() -ne "")

        $tasks += [PSCustomObject]@{
            Id = $tasks.Count + 1
            Type = "Pequena"
            Text = $text
            Completed = $false
        }
    }

    $data = [PSCustomObject]@{
        Date = Get-Date -Format "yyyy-MM-dd"
        Tasks = $tasks
    }

    Save-List $data

    Write-Host ""
    Write-Host "Lista creada correctamente." -ForegroundColor Green

    Pause-Script
}

#==========================================================
# Mostrar Lista
#==========================================================

function Show-DayList {

    Show-Header

    $data = Load-Today

    if (!$data) {

        Write-Host "No existe una lista para hoy." -ForegroundColor Yellow
        Pause-Script
        return
    }

    Write-Host "Fecha: $($data.Date)"
    Write-Host ""

    Write-Host "===== OBJETIVO GRANDE =====" -ForegroundColor Red

    foreach ($task in $data.Tasks | Where-Object Type -eq "Grande") {

        $status = if ($task.Completed) { "[X]" } else { "[ ]" }

        Write-Host "$status [$($task.Id)] $($task.Text)" -ForegroundColor (Get-TaskColor $task)
    }

    Write-Host ""
    Write-Host "===== OBJETIVOS MEDIANOS =====" -ForegroundColor Yellow

    foreach ($task in $data.Tasks | Where-Object Type -eq "Mediana") {

        $status = if ($task.Completed) { "[X]" } else { "[ ]" }

        Write-Host "$status [$($task.Id)] $($task.Text)" -ForegroundColor (Get-TaskColor $task)
    }

    Write-Host ""
    Write-Host "===== TAREAS PEQUEÑAS =====" -ForegroundColor Green

    foreach ($task in $data.Tasks | Where-Object Type -eq "Pequena") {

        $status = if ($task.Completed) { "[X]" } else { "[ ]" }

        Write-Host "$status [$($task.Id)] $($task.Text)" -ForegroundColor (Get-TaskColor $task)
    }

    Write-Host ""

    $completed = ($data.Tasks | Where-Object Completed).Count
    $total = $data.Tasks.Count

    Write-Host "Progreso: $completed / $total completadas" -ForegroundColor Cyan

    Pause-Script
}

#==========================================================
# Marcar completada
#==========================================================

function Complete-Task {

    Show-Header

    $data = Load-Today

    if (!$data) {

        Write-Host "No existe una lista para hoy." -ForegroundColor Yellow
        Pause-Script
        return
    }

    foreach ($task in $data.Tasks) {

        $status = if ($task.Completed) { "[X]" } else { "[ ]" }

        Write-Host "$status [$($task.Id)] $($task.Text)" -ForegroundColor (Get-TaskColor $task)
    }

    Write-Host ""

    do {

        $inputId = Read-Host "Ingrese el ID de la tarea"

        $valid = $inputId -match '^\d+$'

        if (!$valid) {
            Write-Host "Debe ingresar un número." -ForegroundColor Red
        }

    } until ($valid)

    # Forzar conversión a entero y asegurar búsqueda exacta
    $searchId = [int]$inputId.Trim()
    $task = $data.Tasks | Where-Object { $_.Id -eq $searchId }

    if (!$task) {

        Write-Host "ID no encontrado." -ForegroundColor Red
        Pause-Script
        return
    }

    $task.Completed = $true

    Save-List $data

    Write-Host ""
    Write-Host "Tarea marcada como completada." -ForegroundColor Green

    Pause-Script
}

#==========================================================
# Histórico
#==========================================================

function Show-History {

    Show-Header

    $files = Get-ChildItem $DataFolder -Filter *.json |
        Sort-Object Name -Descending |
        Select-Object -First 7

    if ($files.Count -eq 0) {

        Write-Host "No hay historial." -ForegroundColor Yellow
        Pause-Script
        return
    }

    foreach ($file in $files) {

        $data = Get-Content $file.FullName -Raw | ConvertFrom-Json

        Write-Host ""
        Write-Host "==========================================" -ForegroundColor Cyan
        Write-Host $data.Date -ForegroundColor White
        Write-Host "==========================================" -ForegroundColor Cyan

        foreach ($task in $data.Tasks) {

            $status = if ($task.Completed) { "[X]" } else { "[ ]" }

            Write-Host "$status [$($task.Id)] $($task.Text)" -ForegroundColor (Get-TaskColor $task)
        }

        $completed = ($data.Tasks | Where-Object Completed).Count

        Write-Host ""
        Write-Host "Completadas: $completed / $($data.Tasks.Count)" -ForegroundColor Cyan
    }

    Pause-Script
}

#==========================================================
# Menú
#==========================================================

function Main-Menu {

    do {

        Show-Header

        Write-Host "1. Crear nueva lista diaria"
        Write-Host "2. Ver lista de hoy"
        Write-Host "3. Marcar tarea completada"
        Write-Host "4. Ver histórico (últimos 7 días)"
        Write-Host "5. Salir"

        Write-Host ""

        $option = Read-Host "Seleccione una opción"

        switch ($option) {

            "1" { New-DayList }

            "2" { Show-DayList }

            "3" { Complete-Task }

            "4" { Show-History }

            "5" {
                Write-Host ""
                Write-Host "¡Hasta luego!" -ForegroundColor Green
            }

            default {

                Write-Host ""
                Write-Host "Opción inválida." -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }

    } until ($option -eq "5")
}

#==========================================================
# Inicio
#==========================================================

Main-Menu