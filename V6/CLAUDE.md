# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AICAD is an AI-powered plugin for ZWCAD that lets users manipulate CAD objects (text, lines, polylines) via natural language instructions in Chinese or English. It integrates into the ZWCAD ribbon UI and provides a floating panel for input.

## Architecture

The system has four layers connected by a file-based IPC mechanism:

1. **AutoLISP extension** (`aicad_extension.lsp`) -- Runs inside ZWCAD. Captures user selection and instruction, writes a JSON request to a temp file, polls for a response file, then dispatches the parsed command against CAD entities. Defines the `AICAD`/`ASCAD` commands and all entity manipulation logic (alignment, color, text replace, move, line edit, etc.).

2. **VBScript launcher** (`aicad_launch.vbs`) -- Thin wrapper that launches the PowerShell bridge silently (window-hidden) via `wscript.exe` so ZWCAD doesn't block.

3. **PowerShell bridge** (`aicad_bridge.ps1`) -- Core routing logic. First attempts **local routing** (`Resolve-LocalRoute`) using regex/keyword matching on the user instruction to avoid an API call. If local routing returns `$null`, it sends the instruction to the OpenAI-compatible chat API. Writes a key=value response file that the LISP layer reads.

4. **C# Ribbon plugin** (`AICADRibbon/AiRibbonPlugin.cs`) -- .NET DLL loaded via `_.NETLOAD` into ZWCAD. Creates ribbon UI (prompt box + replace boxes + buttons) on the "Home" tab and a floating WinForms panel. Passes input to the LISP layer via environment variables and `SendStringToExecute`.

**Loader** (`aicad_aa_loader.lsp`) -- Bootstrap script that resolves the install directory, loads `aicad_extension.lsp`, then NETLOADs the ribbon DLL. Uses a scoring system to find the best candidate directory. It is expected to be loaded by ZWCAD Startup Suite, but it must not auto-open the replace panel; users open that panel manually via `AICADREPLACEPANEL` or `AICADREPLACEPANELSHOW`.

### Data Flow

```
User input (ribbon/floating panel/command line)
  -> aicad_extension.lsp writes JSON to %TEMP%/aicad_request_*.json
  -> aicad_launch.vbs spawns PowerShell hidden
  -> aicad_bridge.ps1 routes locally or calls OpenAI API
  -> writes response to %TEMP%/aicad_response_*.txt (key=value format)
  -> aicad_extension.lsp polls, reads, dispatches CAD operation
```

### Supported Commands (Whitelist)

| Command | Purpose |
|---------|---------|
| QW | Set text height |
| WI | Set text width factor |
| Y | Set object color (ACI index) |
| ZUO/YOU/SHANG/XIA/ZHONG | Left/Right/Top/Bottom/Center alignment |
| HEI | Arrange text top-to-bottom with uniform spacing |
| RETXT | Find-and-replace text content (supports ordered pairs) |
| MOVEOBJ | Move objects by delta vector |
| LINEEDIT | Extend/shorten LINE objects from a specified side |
| NONE | Returned when request doesn't match whitelist |

## Build

The ribbon DLL is built using the .NET Framework 4.0 C# compiler directly (no MSBuild/Visual Studio required):

```powershell
# Default: targets ZWCAD at D:\ZWCAD, outputs AICADRibbonHostV6.dll
.\build_zwcad_ribbon.ps1

# Custom ZWCAD path
.\build_zwcad_ribbon.ps1 -ZWCADDir "C:\Program Files\ZWCAD"

# Custom output name
.\build_zwcad_ribbon.ps1 -OutputName "AICADRibbonHost.dll"
```

Requires ZWCAD SDK DLLs (`ZwManaged.dll`, `ZwDatabaseMgd.dll`, `ZdWindows.dll`) at the specified ZWCAD directory. Compiles as x64.

Multiple DLL versions exist for compatibility: `AICADRibbonHostV6.dll` (latest), `AICADRibbonHostV5.dll`, `AICADRibbonHost.dll`, `AICADRibbon.dll`. The loader tries them in that priority order.

## Configuration

- **API key**: `AICAD_API_KEY` environment variable (required for non-locally-routed commands)
- **API URL**: `AICAD_API_URL` env var (defaults to `https://api.openai.com/v1/chat/completions`)
- **Model**: `AICAD_MODEL` env var, or set in LISP via `*AICAD_Model*` (defaults to `gpt-4.1-mini`)
- **Install directory**: `AICADAA_BASEDIR` env var, or hardcoded default in `*AICAD_DefaultInstallDirectory*`
- **Current fixed install directory**: `E:\366256\ZW-auto_lisp\V6`; do not restore the former Desktop path
- **Confirmation mode**: `*AICAD_RequireConfirmation*` in LISP (nil = auto-execute, T = prompt user)

## Key Conventions

- The bridge response format is flat key=value lines (not JSON), parsed by `aicad:read-kv-file` in LISP.
- Local routing in `aicad_bridge.ps1` handles Chinese text patterns (regex with Unicode escapes for CJK characters) to avoid API round-trips for simple commands.
- Entity filtering uses modes: `ALL`, `TEXT` (TEXT+MTEXT), `LINE` (LINE+LWPOLYLINE+POLYLINE), `STRAIGHTLINE` (LINE only).
- All CAD operations wrap modifications in undo marks (`vla-startundomark`/`vla-endundomark`).
- The ribbon plugin syncs text state bidirectionally between the ribbon combo boxes and the floating panel.
- Legacy "AA" toolbars/tabs are cleaned up automatically on load.
