# SolidWorks Drawing Generator - Quick Reference

## Quick Start
1. **Open** your assembly in SolidWorks
2. **Save** the assembly (Ctrl+S)
3. **Run macro**: Tools > Macro > Run > Select `.swp` file
4. **Wait** for completion message

## Generated Output
- **3 drawings** automatically created
- **4 views each** (exactly as required)
- **Section views** included in each drawing
- **Auto-saved** in assembly folder

## Drawing Contents

| Drawing | View 1 | View 2 | View 3 | View 4 |
|---------|--------|--------|--------|--------|
| Drawing 1 | Front View | Top View | Right View | Section A-A |
| Drawing 2 | Isometric | Front View | Section B-B | Detail C |
| Drawing 3 | Left View | Bottom View | Section C-C | Auxiliary |

## File Locations
```
YourAssembly.sldasm
├── YourAssembly_Drawing_01.slddrw
├── YourAssembly_Drawing_02.slddrw
└── YourAssembly_Drawing_03.slddrw
```

## Prerequisites Checklist
- ✅ Assembly is open and active
- ✅ Assembly is saved
- ✅ SolidWorks 2020 or later
- ✅ Sufficient disk space

## Customization Quick Tips

### Change number of drawings:
```vba
Const NUM_DRAWINGS As Integer = 5  ' Change from 3 to 5
```

### Adjust view scales:
```vba
Const DEFAULT_SCALE As Double = 0.25  ' Make views smaller
Const SECTION_SCALE As Double = 0.75  ' Make sections larger
```

### Modify view positions:
```vba
' In DefineViewPositions function
viewPositions(1, 1) = 0.15  ' Move view 1 right
viewPositions(1, 2) = 0.25  ' Move view 1 up
```

## Troubleshooting
| Problem | Quick Fix |
|---------|-----------|
| "Open assembly first" | Make sure assembly is active window |
| "Save assembly first" | Press Ctrl+S to save |
| "Runtime Error 91" | Use `SimplifiedDrawingGenerator.swp` instead |
| "Failed to create drawing" | Check SolidWorks installation |
| Views don't appear | Check assembly complexity/geometry |

## Macro Files
- `SimplifiedDrawingGenerator.swp` - **RECOMMENDED** (most reliable, avoids runtime errors)
- `EnhancedDrawingGenerator.swp` - Advanced features (includes section views)
- `GenerateMultipleDrawings.swp` - Basic version

## Support Files
- `SOLIDWORKS_MACRO_DOCUMENTATION.md` - Complete documentation
- `QUICK_REFERENCE.md` - This file

---
*Need more help? See the full documentation file for detailed instructions and advanced customization options.*