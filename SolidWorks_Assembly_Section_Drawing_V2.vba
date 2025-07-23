Option Explicit

' SolidWorks Assembly Section Drawing Macro - Built from Scratch
' Step-by-step implementation as per user requirements

Sub CreateAssemblySectionDrawing()
    
    ' Declare all variables
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
    Dim swMathTransform As SldWorks.MathTransform
    
    Dim vOriginCoords As Variant
    Dim dOriginArray(2) As Double
    Dim vTransformedCoords As Variant
    Dim dPartOriginX As Double
    Dim dPartOriginY As Double
    Dim dPartOriginZ As Double
    Dim dDrawingY As Double
    Dim bRet As Boolean
    Dim sDrawingTemplate As String
    Dim sDrawingPath As String
    
    ' STEP 1: Initialize SolidWorks application and validate assembly
    Set swApp = Application.SldWorks
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
    
    ' STEP 2: Get selected part component
    If swSelMgr.GetSelectedObjectCount2(-1) = 0 Then
        MsgBox "Please select a component in the assembly."
        Exit Sub
    End If
    
    Set swComp = swSelMgr.GetSelectedObject6(1, -1)
    If swComp Is Nothing Then
        MsgBox "Please select a valid component."
        Exit Sub
    End If
    
    ' STEP 3: Find coordinates of origin of selected part with respect to assembly origin
    Set swXform = swComp.Transform2
    If swXform Is Nothing Then
        MsgBox "Unable to get component transformation."
        Exit Sub
    End If
    
    Set swMathUtil = swApp.GetMathUtility
    
    ' Define origin point (0, 0, 0) of the part
    dOriginArray(0) = 0#
    dOriginArray(1) = 0#
    dOriginArray(2) = 0#
    vOriginCoords = dOriginArray
    
    Set swMathPt = swMathUtil.CreatePoint(vOriginCoords)
    Set swMathPt = swMathPt.MultiplyTransform(swXform)
    vTransformedCoords = swMathPt.ArrayData
    
    dPartOriginX = vTransformedCoords(0)
    dPartOriginY = vTransformedCoords(1)
    dPartOriginZ = vTransformedCoords(2)
    
    ' Use Debug.Print as requested
    Debug.Print "Part Origin in Assembly Coordinates:"
    Debug.Print "X: " & Format(dPartOriginX * 1000, "0.000") & " mm"
    Debug.Print "Y: " & Format(dPartOriginY * 1000, "0.000") & " mm"
    Debug.Print "Z: " & Format(dPartOriginZ * 1000, "0.000") & " mm"
    
    ' STEP 4: Create new drawing file with A3 size
    sDrawingTemplate = swApp.GetUserPreferenceStringValue(swUserPreferenceStringValue_e.swDefaultTemplateDrawing)
    Set swDrawing = swApp.NewDocument(sDrawingTemplate, swDwgPaperSizes_e.swDwgPaperA3size, 0, 0)
    
    If swDrawing Is Nothing Then
        MsgBox "Failed to create drawing document."
        Exit Sub
    End If
    
    ' Set the active model to the drawing
    Set swModel = swDrawing
    Set swSheet = swDrawing.GetCurrentSheet
    
    ' Setup A3 sheet properly
    bRet = swDrawing.SetupSheet5(swSheet.GetName, swDwgPaperSizes_e.swDwgPaperA3size, _
                                swDwgTemplates_e.swDwgTemplateAsize, 1, 1, True, "", 0.42, 0.297, "Default", False)
    
    ' STEP 5: Insert top view of the assembly
    swModel.ClearSelection2 True
    
    ' Try the most reliable method: Use IModelDoc2::CreateDrawViewFromModelDoc
    ' First, open the assembly document to ensure it's loaded
    Dim swAssyModel As SldWorks.ModelDoc2
    Set swAssyModel = swApp.OpenDoc6(swAssy.GetPathName, swDocASSEMBLY, swOpenDocOptions_e.swOpenDocOptions_Silent, "", 0, 0)
    
    If swAssyModel Is Nothing Then
        MsgBox "Could not open assembly file. Please ensure the assembly is saved."
        Exit Sub
    End If
    
    ' Make sure the drawing is active
    swApp.ActivateDoc2 swDrawing.GetTitle, False, 0
    
    ' Use the simplest possible approach: Direct model insertion
    Set swModel = swDrawing
    swModel.ClearSelection2 True
    
    ' Method: Use InsertModel2 to insert the assembly as a view
    ' This is the most basic and universally supported method
    swModel.SetAddToDB True
    swModel.SetDisplayWhenAdded False
    
    ' Insert the assembly model at the specified coordinates
    ' Parameters: FilePath, X, Y, Z, ScaleX, ScaleY, ScaleZ, RotX, RotY, RotZ
    bRet = swModel.InsertModel2(swAssy.GetPathName, 0.21, 0.21, 0, 0.5, 0.5, 0.5, 0, 0, 0)
    
    swModel.SetAddToDB False
    swModel.SetDisplayWhenAdded True
    
    ' Force rebuild to ensure the view is created
    swModel.ForceRebuild3 False
    
    ' Try to get the view that was created
    Dim swFirstView As SldWorks.View
    Set swFirstView = swDrawing.GetFirstView
    If Not swFirstView Is Nothing Then
        Set swView = swFirstView.GetNextView
        
        ' If no next view, look through all views systematically
        If swView Is Nothing Then
            Dim swViews As Variant
            swViews = swDrawing.GetViews
            If IsArray(swViews) And UBound(swViews) >= 0 Then
                Dim swSheetViews As Variant
                swSheetViews = swViews(0)
                If IsArray(swSheetViews) And UBound(swSheetViews) > 0 Then
                    ' Look for the first non-sheet view
                    Dim k As Integer
                    For k = 1 To UBound(swSheetViews)
                        Set swView = swSheetViews(k)
                        If Not swView Is Nothing Then
                            If swView.Type <> swDrawingViewTypes_e.swDrawingSheet Then
                                Exit For
                            End If
                        End If
                    Next k
                End If
            End If
        End If
    End If
    
    ' If still no view, try alternative approach
    If swView Is Nothing Then
        ' Last resort: Create a simple drawing view using basic geometry insertion
        swModel.ClearSelection2 True
        
        ' Try using the feature manager to insert the model
        Dim swFeatMgr As SldWorks.FeatureManager
        Set swFeatMgr = swModel.FeatureManager
        
        ' Insert feature using the most basic method
        swModel.InsertModel swAssy.GetPathName, 0.21, 0.21, 0
        
        ' Try to get the view again
        Set swFirstView = swDrawing.GetFirstView
        If Not swFirstView Is Nothing Then
            Set swView = swFirstView.GetNextView
        End If
    End If
    
    If swView Is Nothing Then
        MsgBox "Failed to create drawing view automatically. Please check that the assembly file is saved and accessible."
        Exit Sub
    End If
    
    ' Set view to top orientation
    swView.SetOrientation2 swStandardViews_e.swTopView, True
    swView.ScaleRatio = Array(1, 2) ' Set scale to 1:2
    
    ' STEP 6: Use ModelToViewTransform on Y coordinate of the origin of part in assembly
    Set swMathTransform = swView.ModelToViewTransform
    
    ' Use the part origin coordinates in assembly space
    dOriginArray(0) = dPartOriginX  ' Part origin X in assembly
    dOriginArray(1) = dPartOriginY  ' Part origin Y in assembly
    dOriginArray(2) = dPartOriginZ  ' Part origin Z in assembly
    vOriginCoords = dOriginArray
    Set swMathPt = swMathUtil.CreatePoint(vOriginCoords)
    
    ' Transform part origin to view coordinates using ModelToViewTransform
    Set swMathPt = swMathPt.MultiplyTransform(swMathTransform)
    vTransformedCoords = swMathPt.ArrayData
    
    ' Use the transformed Y coordinate in drawing space for the section line
    dDrawingY = vTransformedCoords(1)  ' Use the transformed Y coordinate
    
    Debug.Print "Part origin Y coordinate transformed to drawing space: " & Format(dDrawingY * 1000, "0.000") & " mm"
    
    ' STEP 7: Create sketching line with constant Y coordinate
    swModel.ClearSelection2 True
    bRet = swModel.Extension.SelectByID2(swView.Name, "DRAWINGVIEW", 0, 0, 0, False, 0, Nothing, 0)
    
    Set swSketch = swModel.SketchManager
    swSketch.InsertSketch True
    
    ' Create horizontal section line at the transformed Y coordinate
    Dim dLineStartX As Double
    Dim dLineEndX As Double
    dLineStartX = -0.05 ' Adjust based on your model size
    dLineEndX = 0.05    ' Adjust based on your model size
    
    ' Draw the section line (horizontal line with constant Y coordinate)
    swSketch.CreateLine dLineStartX, dDrawingY, 0, dLineEndX, dDrawingY, 0
    swSketch.InsertSketch True ' Exit sketch
    
    ' STEP 8: Create section view using the sketching line
    swModel.ClearSelection2 True
    bRet = swModel.Extension.SelectByID2("Line1", "SKETCHSEGMENT", 0, 0, 0, False, 0, Nothing, 0)
    
    If Not bRet Then
        ' Try alternative selection
        bRet = swModel.Extension.SelectByID2("Line1@Sketch1", "SKETCHSEGMENT", 0, 0, 0, False, 0, Nothing, 0)
    End If
    
    If bRet Then
        ' Create section view at specified position
        Set swSectionView = swDrawing.CreateSectionViewAt4(0.21, 0.1, 0, "A", _
                                                          swCreateSectionViewAtOptions_e.swCreateSectionView_OffsetSection, _
                                                          Nothing)
        
        If Not swSectionView Is Nothing Then
            swSectionView.ScaleRatio = Array(1, 1) ' Set section view scale to 1:1
            MsgBox "Section view created successfully!"
        Else
            MsgBox "Failed to create section view. The section line may not be properly positioned."
        End If
    Else
        MsgBox "Failed to select the section line. Please check if the sketch line was created properly."
    End If
    
    ' STEP 9: Save the drawing sheet
    sDrawingPath = swAssy.GetPathName
    If sDrawingPath <> "" Then
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