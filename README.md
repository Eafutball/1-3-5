# Sistema de Productividad 1-3-5

Organizador diario por consola basado en el método de productividad **1-3-5**:

- **1** objetivo grande
- **3** objetivos medianos
- **5** tareas pequeñas

Escrito en PowerShell puro. No requiere módulos externos.

## Requisitos

- Windows PowerShell 5.1+ o PowerShell 7+
- Windows 10/11 (por el uso de `chcp` y colores de consola)

## Cómo usar

### Opción rápida (Windows)

Doble clic en `Ejecutar.bat`:

```bat
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "1-3-5.ps1"
```

### Manual

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\1-3-5.ps1
```

## Menú

1. Crear nueva lista diaria
2. Ver lista de hoy
3. Marcar tarea completada
4. Ver histórico (últimos 7 días)
5. Salir

## Almacenamiento de datos

Cada lista se guarda como un archivo JSON en la carpeta:

```
%USERPROFILE%\1-3-5-Lists\YYYY-MM-DD.json
```

No se conecta a ningún servicio externo; todos los datos quedan en tu equipo.

## Funciones

| Opción | Descripción |
| ------ | ----------- |
| Crear lista | Crea la lista del día (1 grande, 3 medianas, 5 pequeñas) y sobrescribe la existente si se confirma. |
| Ver lista | Muestra la lista de hoy con colores según el tipo y el progreso. |
| Completar | Marca una tarea como completada mediante su ID. |
| Histórico | Muestra los últimos 7 días guardados. |
