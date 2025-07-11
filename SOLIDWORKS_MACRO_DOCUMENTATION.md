# SolidWorks Assembly Drawing Generator Macro

## Overview

This collection of SolidWorks VBA macros automatically generates multiple technical drawings from an assembly file. Each drawing contains exactly 4 views, including section views that are automatically generated within the drawings.

## Files Included

1. **GenerateMultipleDrawings.swp** - Basic version of the macro
2. **EnhancedDrawingGenerator.swp** - Enhanced version with better error handling and customization

## Features

### Core Functionality
- **Automatic Multi-Drawing Generation**: Creates multiple drawing documents from a single assembly
- **4 Views Per Drawing**: Each drawing contains exactly 4 carefully positioned views
- **Section Views**: Automatically generates section views within the drawings
- **Multiple Drawing Sets**: Each drawing has a different combination of views
- **Optimized Layout**: Views are positioned for optimal A3 landscape layout

### Drawing Sets

#### Drawing Set 1 (Traditional Orthographic + Section)
- Front View (Top-left position)
- Top View (Top-right position)  
- Right View (Bottom-left position)
- Section View A-A (Bottom-right position)

#### Drawing Set 2 (Mixed Views + Detail)
- Isometric View (Top-left position)
- Front View (Top-right position)
- Section View B-B (Bottom-left position)
- Detail View C (Bottom-right position)

#### Drawing Set 3 (Alternative Orthographic + Auxiliary)
- Left View (Top-left position)
- Bottom View (Top-right position)
- Section View C-C (Bottom-left position)
- Auxiliary Wireframe View (Bottom-right position)

## Prerequisites

### Software Requirements
- SolidWorks 2020 or later
- Active assembly document
- Assembly must be saved before running the macro

### Setup Requirements
1. Open your assembly in SolidWorks
2. Save the assembly (macro requires a saved file)
3. Load the macro file (.swp) into SolidWorks

## Installation and Usage

### Step 1: Load the Macro
1. In SolidWorks, go to **Tools > Macro > Run**
2. Browse to select either macro file:
   - `GenerateMultipleDrawings.swp` (basic version)
   - `EnhancedDrawingGenerator.swp` (recommended)
3. Click **Open**

### Step 2: Run the Macro
1. Ensure your assembly is the active document
2. Run the macro by clicking **OK** in the macro dialog
3. The macro will automatically:
   - Validate prerequisites
   - Create new drawing documents
   - Generate 4 views per drawing
   - Save drawings in the same folder as the assembly

### Step 3: Review Generated Drawings
The macro creates drawings with the following naming convention:
- `[AssemblyName]_Drawing_01.slddrw`
- `[AssemblyName]_Drawing_02.slddrw`
- `[AssemblyName]_Drawing_03.slddrw`

## Customization Options

### Modifying Number of Drawings
In the enhanced version, change the constant:
```vba
Const NUM_DRAWINGS As Integer = 3  ' Change to desired number
```

### Adjusting View Scales
Modify these constants for different scales:
```vba
Const DEFAULT_SCALE As Double = 0.5    ' Orthographic views
Const SECTION_SCALE As Double = 0.5    ' Section views
Const DETAIL_SCALE As Double = 2#      ' Detail views
```

### Customizing View Positions
Edit the `DefineViewPositions` subroutine to change view placement:
```vba
' Example position modification (values in meters)
viewPositions(1, 1) = 0.12  ' X position for view 1
viewPositions(1, 2) = 0.20  ' Y position for view 1
```

### Adding New Drawing Sets
Create additional view combinations by adding new functions:
```vba
Function CreateDrawingViews_Set4(assemblyPath As String, viewPositions As Variant) As Integer
    ' Your custom view combination here
End Function
```

## Technical Specifications

### Drawing Template
- Default: A3 Landscape format
- Sheet size: 420mm x 297mm
- Scale: 1:2 sheet scale with individual view scales

### View Types Supported
- **Orthographic Views**: Front, Top, Right, Left, Bottom, Back
- **Isometric Views**: Standard isometric projection
- **Section Views**: Automatically generated with proper labeling
- **Detail Views**: Circular detail callouts with 2x magnification
- **Auxiliary Views**: Custom projections and wireframe displays

### File Output
- Format: SolidWorks Drawing (.slddrw)
- Location: Same directory as source assembly
- Naming: Assembly name + Drawing number suffix

## Error Handling and Troubleshooting

### Common Issues and Solutions

#### "Please open an assembly document first"
- **Cause**: No active document or wrong document type
- **Solution**: Open and activate an assembly file

#### "Please save the assembly before running this macro"
- **Cause**: Assembly hasn't been saved
- **Solution**: Save your assembly file (Ctrl+S)

#### "Failed to create drawing document"
- **Cause**: Drawing template not found or corrupted
- **Solution**: Verify SolidWorks installation and template files

#### Section views not creating properly
- **Cause**: Parent view selection issues
- **Solution**: Ensure assembly has sufficient geometry for section views

### Advanced Troubleshooting

#### Template Path Issues
If the default template path fails, the macro automatically tries alternative paths:
```vba
' Primary path (modify for your SolidWorks version)
"C:\ProgramData\SOLIDWORKS\SOLIDWORKS 2023\lang\english\sheetformat\a3 - landscape.slddrt"

' Fallback: Default drawing template
swDocumentTypes_e.swDocDRAWING
```

#### Performance Optimization
For large assemblies:
1. Use **Simplified Configurations** before running the macro
2. Consider using **Lightweight mode** for referenced components
3. Close unnecessary applications to free system memory

## Limitations

### Current Limitations
- Fixed at 4 views per drawing (by design requirement)
- Section views depend on assembly geometry
- Template path may need adjustment for different SolidWorks versions
- Macro requires manual intervention for complex section line placement

### Assembly Complexity
- Works best with moderate complexity assemblies (50-200 components)
- Very large assemblies may require performance adjustments
- Assemblies with many mates may slow processing

## Advanced Features (Enhanced Version)

### Validation System
- Comprehensive prerequisite checking
- Error recovery mechanisms
- Detailed progress reporting

### Flexible Configuration
- Constants for easy customization
- Modular function structure
- Extensible drawing set system

### Professional Output
- Proper view naming conventions
- Optimized line weights
- Hidden line display options
- Consistent scaling throughout

## Support and Modification

### Extending the Macro
The modular design allows easy extension:

1. **Add new view types** by creating additional view generation functions
2. **Modify layouts** by adjusting position arrays
3. **Change templates** by updating template paths
4. **Add annotations** by extending the SetViewOptions function

### Best Practices
- Always test with a backup copy of your assembly
- Review generated drawings before finalizing
- Adjust scales based on assembly complexity
- Consider creating custom drawing templates for consistency

## Version History

### Basic Version (GenerateMultipleDrawings.swp)
- Core functionality
- 3 predefined drawing sets
- Basic error handling

### Enhanced Version (EnhancedDrawingGenerator.swp)
- Improved error handling and validation
- Flexible configuration options
- Better performance and reliability
- Professional view formatting
- Comprehensive documentation

For technical support or custom modifications, refer to the SolidWorks API documentation or consult with a SolidWorks automation specialist.