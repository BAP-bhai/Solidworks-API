Option Explicit

' SolidWorks Assembly Section Drawing Macro
' This macro finds the origin coordinates of a selected part in an assembly,
' creates a new A3 drawing with top view and section view, then saves it

Sub CreateAssemblySectionDrawing()
    
    Dim swApp As SldWorks.SldWorks
    Dim swModel As SldWorks.ModelDoc2
    Dim swAssy As SldWorks.AssemblyDoc
    Dim swSelMgr As SldWorks.SelectionMgr
    Dim swComp As SldWorks.Component2
    Dim swXform As SldWorks.MathTransform
    Dim swMathUtil As SldWorks.MathUtility
    Dim swMathPt As SldWorks.MathPoint
    Dim swDrawing As SldWorks.DrawingDoc
    Dim swSheet As SldWorks.Sheet
    Dim swView As SldWorks.View
    Dim swSectionView As SldWorks.View
    Dim swSketch As SldWorks.SketchManager
    
    Dim vOriginCoords As Variant
    Dim dOriginArray(2) As Double
    Dim vTransformedCoords As Variant
    Dim dPartOriginX As Double
    Dim dPartOriginY As Double
    Dim dPartOriginZ As Double
    Dim bRet As Boolean
    Dim sDrawingTemplate As String
    Dim sDrawingPath As String
    
    ' Initialize SolidWorks application
    Set swApp = Application.SldWorks
    
    ' Get active document (should be an assembly)
    Set swModel = swApp.ActiveDoc
    If swModel Is Nothing Then
        MsgBox "Please open an assembly document first."
        Exit Sub
    End If
    
    If swModel.GetType <> swDocASSEMBLY Then
        MsgBox "Active document must be an assembly."
        Exit Sub
    End If
    
    Set swAssy = swModel
    Set swSelMgr = swModel.SelectionManager
    
    ' Check if a component is selected
    If swSelMgr.GetSelectedObjectCount2(-1) = 0 Then
        MsgBox "Please select a component in the assembly."
        Exit Sub
    End If
    
    ' Get the selected component
    Set swComp = swSelMgr.GetSelectedObject6(1, -1)
    If swComp Is Nothing Then
        MsgBox "Please select a valid component."
        Exit Sub
    End If
    
    ' Get the transformation matrix of the component
    Set swXform = swComp.Transform2
    If swXform Is Nothing Then
        MsgBox "Unable to get component transformation."
        Exit Sub
    End If
    
    ' Get math utility
    Set swMathUtil = swApp.GetMathUtility
    
    ' Define origin point (0, 0, 0) of the part
    dOriginArray(0) = 0#
    dOriginArray(1) = 0#
    dOriginArray(2) = 0#
    vOriginCoords = dOriginArray
    
    ' Create math point for origin
    Set swMathPt = swMathUtil.CreatePoint(vOriginCoords)
    
    ' Transform the origin point to assembly coordinates
    Set swMathPt = swMathPt.MultiplyTransform(swXform)
    vTransformedCoords = swMathPt.ArrayData
    
    ' Extract coordinates
    dPartOriginX = vTransformedCoords(0)
    dPartOriginY = vTransformedCoords(1)
    dPartOriginZ = vTransformedCoords(2)
    
    MsgBox "Part Origin in Assembly Coordinates:" & vbCrLf & _
           "X: " & Format(dPartOriginX * 1000, "0.000") & " mm" & vbCrLf & _
           "Y: " & Format(dPartOriginY * 1000, "0.000") & " mm" & vbCrLf & _
           "Z: " & Format(dPartOriginZ * 1000, "0.000") & " mm"
    
    ' Create new drawing document
    ' Note: You may need to adjust the template path based on your SolidWorks installation
    sDrawingTemplate = swApp.GetUserPreferenceStringValue(swUserPreferenceStringValue_e.swDefaultTemplateDrawing)
    
    Set swDrawing = swApp.NewDocument(sDrawingTemplate, swDwgPaperSizes_e.swDwgPaperA3size, 0, 0)
    Set swModel = swDrawing
    
    If swDrawing Is Nothing Then
        MsgBox "Failed to create drawing document."
        Exit Sub
    End If
    
    ' Get the active sheet
    Set swSheet = swDrawing.GetCurrentSheet
    
    ' Set sheet format to A3
    bRet = swDrawing.SetupSheet5(swSheet.GetName, swDwgPaperSizes_e.swDwgPaperA3size, _
                                swDwgTemplates_e.swDwgTemplateAsize, 1, 1, True, "", 0.42, 0.297, "Default", False)
    
    ' Insert top view of the assembly
    ' Method 1: Try using CreateDrawViewFromModelDoc with proper parameters
    swModel.ClearSelection2 True
    Set swView = swDrawing.CreateDrawViewFromModelDoc(swAssy.GetPathName, 0.21, 0.21, 0)
    
    If Not swView Is Nothing Then
        ' Set the view to top orientation
        swView.SetOrientation2 swStandardViews_e.swTopView, True
    Else
        ' Method 2: Alternative approach using CreateDrawViewFromModelDoc2
        Set swView = swDrawing.CreateDrawViewFromModelDoc2(swAssy.GetPathName, 0.21, 0.21)
        
        If Not swView Is Nothing Then
            ' Set view orientation to top
            swView.SetOrientation2 swStandardViews_e.swTopView, True
        Else
            ' Method 3: Try the most basic approach - create view at position
            swModel.ClearSelection2 True
            ' Create a basic orthographic view
            swApp.SendMsgToUser2 "Attempting to create view manually. Please wait...", swMessageBoxIcon_e.swMbInformation, swMessageBoxBtn_e.swMbOk
            
            ' Try using the NewDrawingView approach
            Set swView = swDrawing.CreateDrawViewFromModelDoc(swAssy.GetPathName, 0.21, 0.21, 0)
            If Not swView Is Nothing Then
                swView.SetOrientation2 swStandardViews_e.swTopView, True
            End If
        End If
    End If
    
    If swView Is Nothing Then
        MsgBox "Failed to create top view. Please ensure the assembly is saved."
        Exit Sub
    End If
    
    ' Set view scale (adjust as needed)
    swView.ScaleRatio = Array(1, 2) ' 1:2 scale
    
    ' Start sketch for section line
    swModel.ClearSelection2 True
    bRet = swModel.Extension.SelectByID2(swView.Name, "DRAWINGVIEW", 0, 0, 0, False, 0, Nothing, 0)
    
    Set swSketch = swModel.SketchManager
    swSketch.InsertSketch True
    
    ' Transform the Y coordinate from 3D assembly space to 2D drawing space
    ' This is a simplified transformation - you may need to adjust based on view orientation
    Dim dDrawingY As Double
    Dim vViewMatrix As Variant
    Dim swMathTransform As SldWorks.MathTransform
    
    ' Get view transformation
    Set swMathTransform = swView.ModelToViewTransform
    
    ' Create a point at the part origin in assembly coordinates
    dOriginArray(0) = dPartOriginX
    dOriginArray(1) = dPartOriginY
    dOriginArray(2) = dPartOriginZ
    vOriginCoords = dOriginArray
    Set swMathPt = swMathUtil.CreatePoint(vOriginCoords)
    
    ' Transform to view coordinates
    Set swMathPt = swMathPt.MultiplyTransform(swMathTransform)
    vTransformedCoords = swMathPt.ArrayData
    
    ' Get the Y coordinate in drawing space
    dDrawingY = vTransformedCoords(1)
    
    ' Create section line (horizontal line at the transformed Y coordinate)
    Dim dLineStartX As Double
    Dim dLineEndX As Double
    dLineStartX = -0.1 ' Start point X (adjust based on your model size)
    dLineEndX = 0.1    ' End point X (adjust based on your model size)
    
    ' Draw the section line
    swSketch.CreateLine dLineStartX, dDrawingY, 0, dLineEndX, dDrawingY, 0
    
    ' Exit sketch
    swSketch.InsertSketch True
    
    ' Create section view
    ' First, select the sketch line
    swModel.ClearSelection2 True
    bRet = swModel.Extension.SelectByID2("Line1", "SKETCHSEGMENT", 0, 0, 0, False, 0, Nothing, 0)
    
    If Not bRet Then
        ' Try selecting with different approach
        bRet = swModel.Extension.SelectByID2("Line1@Sketch1", "SKETCHSEGMENT", 0, 0, 0, False, 0, Nothing, 0)
    End If
    
    ' Create section view using different methods
    If bRet Then
        ' Method 1: Try CreateSectionViewAt5
        Set swSectionView = swDrawing.CreateSectionViewAt5(0.21, 0.1, 0, "A", _
                                                          swCreateSectionViewAtOptions_e.swCreateSectionView_OffsetSection, _
                                                          Nothing, 0.01)
        
        ' Method 2: If that fails, try CreateSectionViewAt4
        If swSectionView Is Nothing Then
            Set swSectionView = swDrawing.CreateSectionViewAt4(0.21, 0.1, 0, "A", _
                                                              swCreateSectionViewAtOptions_e.swCreateSectionView_OffsetSection, _
                                                              Nothing)
        End If
        
        ' Method 3: If that fails, try basic CreateSectionViewAt
        If swSectionView Is Nothing Then
            Set swSectionView = swDrawing.CreateSectionViewAt(0.21, 0.1, "A")
        End If
    End If
    
    If swSectionView Is Nothing Then
        MsgBox "Failed to create section view. Please check if the section line is properly selected."
    Else
        ' Set section view scale
        swSectionView.ScaleRatio = Array(1, 1) ' 1:1 scale
        MsgBox "Section view created successfully!"
    End If
    
    ' Save the drawing
    sDrawingPath = swAssy.GetPathName
    If sDrawingPath <> "" Then
        ' Remove extension and add drawing extension
        sDrawingPath = Left(sDrawingPath, InStrRev(sDrawingPath, ".") - 1) & "_SectionDrawing.SLDDRW"
    Else
        sDrawingPath = "C:\Temp\Assembly_SectionDrawing.SLDDRW"
    End If
    
    bRet = swModel.SaveAs3(sDrawingPath, swSaveAsVersion_e.swSaveAsCurrentVersion, swSaveAsOptions_e.swSaveAsOptions_Silent)
    
    If bRet Then
        MsgBox "Drawing saved successfully at: " & sDrawingPath
    Else
        MsgBox "Failed to save drawing. Please save manually."
    End If
    
End Sub

' Helper function to get sheet properties
Function GetSheetProperties(swSheet As SldWorks.Sheet) As String
    Dim sProps As String
    sProps = "Sheet Name: " & swSheet.GetName & vbCrLf
    sProps = sProps & "Sheet Scale: " & swSheet.GetScale(0) & ":" & swSheet.GetScale(1) & vbCrLf
    GetSheetProperties = sProps
End Function

' Alternative method for more precise ModelToViewTransform usage
Sub AlternativeCreateSectionView()
    ' This is an alternative approach that might work better for complex assemblies
    ' You can use this if the main function doesn't work as expected
    
    Dim swApp As SldWorks.SldWorks
    Dim swModel As SldWorks.ModelDoc2
    Dim swDrawing As SldWorks.DrawingDoc
    Dim swView As SldWorks.View
    Dim swMathUtil As SldWorks.MathUtility
    Dim swMathPt As SldWorks.MathPoint
    Dim swMathTransform As SldWorks.MathTransform
    
    Set swApp = Application.SldWorks
    Set swModel = swApp.ActiveDoc
    
    If swModel Is Nothing Then
        MsgBox "No active document found."
        Exit Sub
    End If
    
    If swModel.GetType <> swDocDRAWING Then
        MsgBox "Active document must be a drawing. Please run the main macro first."
        Exit Sub
    End If
    
    Set swDrawing = swModel
    
    ' Get the first view (should be the top view)
    Dim swFirstView As SldWorks.View
    Set swFirstView = swDrawing.GetFirstView
    
    If swFirstView Is Nothing Then
        MsgBox "No views found in the drawing."
        Exit Sub
    End If
    
    ' Get the next view (the actual drawing view, as GetFirstView returns the sheet)
    Set swView = swFirstView.GetNextView
    
    If swView Is Nothing Then
        MsgBox "No drawing view found in the drawing."
        Exit Sub
    End If
    
    ' Get the ModelToViewTransform
    Set swMathTransform = swView.ModelToViewTransform
    
    ' Example usage of the transform
    Set swMathUtil = swApp.GetMathUtility
    
    ' Transform a point from model space to view space
    Dim dModelCoords(2) As Double
    dModelCoords(0) = 0.05 ' Example X coordinate in model space (meters)
    dModelCoords(1) = 0.03 ' Example Y coordinate in model space (meters)
    dModelCoords(2) = 0.01 ' Example Z coordinate in model space (meters)
    
    Set swMathPt = swMathUtil.CreatePoint(dModelCoords)
    Set swMathPt = swMathPt.MultiplyTransform(swMathTransform)
    
    Dim vViewCoords As Variant
    vViewCoords = swMathPt.ArrayData
    
    MsgBox "Model coordinates (" & dModelCoords(0) & ", " & dModelCoords(1) & ", " & dModelCoords(2) & ")" & vbCrLf & _
           "View coordinates (" & vViewCoords(0) & ", " & vViewCoords(1) & ")"
    
End Sub