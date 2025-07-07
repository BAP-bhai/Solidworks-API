# SolidWorks VBA Macro: Export Solid Bodies as DXF Files

## Overview
This macro automatically exports each solid body from a SolidWorks part file as a separate DXF file.

## Prerequisites
- SolidWorks installed with VBA support
- A part file (.sldprt) containing multiple solid bodies
- The part file must be saved before running the macro

## How to Use

### 1. Setup the Macro
1. Open SolidWorks
2. Go to `Tools > Macro > New`
3. Save the macro file (e.g., `ExportBodiesAsDXF.swp`)
4. Copy and paste the VBA code from `ExportBodiesAsDXF.vba`
5. Save the macro

### 2. Prepare Your Part File
- Open your part file containing multiple solid bodies
- Ensure the file is saved (the macro needs the file path)
- Make sure you have solid bodies (not just surface bodies)

### 3. Run the Macro
1. Go to `Tools > Macro > Run`
2. Select your macro file
3. Choose `ExportBodiesAsDXF` from the procedure list
4. Click `Run`

## What the Macro Does

1. **Validates Environment**: Checks if a part file is open and saved
2. **Finds Solid Bodies**: Locates all solid bodies in the current part
3. **Creates Individual Parts**: For each body, creates a temporary new part
4. **Copies Bodies**: Copies each solid body to its own temporary part
5. **Exports as DXF**: Saves each temporary part as a DXF file
6. **Cleans Up**: Closes temporary parts and provides status updates

## Output Files
- DXF files are saved in the same directory as your original part file
- Naming convention: `[OriginalPartName]_[BodyName].dxf`
- Example: If your part is "Housing.sldprt" and has bodies named "Body1", "Body2", you'll get:
  - `Housing_Body1.dxf`
  - `Housing_Body2.dxf`

## Troubleshooting

### Common Issues:
1. **"No solid bodies found"**: Your part may only have surface bodies or sketches
2. **"Please save the part file"**: The part must be saved before running the macro
3. **DXF export fails**: Some complex geometries may not export properly to DXF

### Solutions:
- Ensure your extruded features create solid bodies, not surfaces
- Try simplifying complex geometries
- Check SolidWorks DXF export settings in `Tools > Options > Export > DXF/DWG`

## Advanced Options

### Custom Output Directory
Use `ExportBodiesAsDXFWithOptions()` instead of the main function to specify a different output directory.

### Body Selection
The macro processes ALL solid bodies. To export specific bodies:
1. Modify the code to check body names
2. Add conditional logic in the main loop

## Technical Notes

- The macro uses `GetBodies2()` with `swSolidBody` type
- Two methods are attempted for copying bodies:
  1. `CreateFeatureFromBody3()` (preferred)
  2. `InsertMoveCopyBody2()` (fallback)
- Error handling is included for robustness
- File names are cleaned to remove invalid characters

## Code Structure

- `ExportBodiesAsDXF()`: Main function
- `CopyBodyToNewPart()`: Handles body copying with fallback methods
- `SaveAsDXF()`: Exports part as DXF with error handling
- `CleanFileName()`: Sanitizes body names for file naming
- `ExportBodiesAsDXFWithOptions()`: Alternative with user input

## Performance Considerations

- Large numbers of bodies will take longer to process
- Complex geometries may slow down the DXF export
- Each body creates a temporary part document (memory usage)

---

**Note**: Always test the macro on a copy of your part file first to ensure it works as expected with your specific geometry.