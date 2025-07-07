Option Explicit

' SolidWorks API VBA Macro
' This macro demonstrates common SolidWorks API operations
' Author: Generated for SolidWorks automation
' Date: Created for macro implementation

Dim swApp As SldWorks.SldWorks
Dim swModel As SldWorks.ModelDoc2
Dim swPart As SldWorks.PartDoc
Dim swAssembly As SldWorks.AssemblyDoc
Dim swDrawing As SldWorks.DrawingDoc
Dim swFeatMgr As SldWorks.FeatureManager
Dim swSelMgr As SldWorks.SelectionMgr
Dim swConfigMgr As SldWorks.ConfigurationManager

' Main entry point for the macro
Sub main()
    
    ' Initialize SolidWorks application
    Set swApp = Application.SldWorks
    
    If swApp Is Nothing Then
        MsgBox "SolidWorks is not running!", vbCritical
        Exit Sub
    End If
    
    ' Get active document
    Set swModel = swApp.ActiveDoc
    
    If swModel Is Nothing Then
        MsgBox "No active document found!", vbExclamation
        Exit Sub
    End If
    
    ' Determine document type and perform appropriate operations
    Select Case swModel.GetType
        Case swDocPART
            ProcessPart
        Case swDocASSEMBLY
            ProcessAssembly
        Case swDocDRAWING
            ProcessDrawing
        Case Else
            MsgBox "Unknown document type!", vbExclamation
    End Select
    
End Sub

' Process Part document operations
Sub ProcessPart()
    
    Set swPart = swModel
    Set swFeatMgr = swModel.FeatureManager
    Set swSelMgr = swModel.SelectionManager
    
    Dim response As VbMsgBoxResult
    response = MsgBox("Part document detected. What would you like to do?" & vbCrLf & _
                     "Yes - Create sample features" & vbCrLf & _
                     "No - Get part information" & vbCrLf & _
                     "Cancel - Exit", vbYesNoCancel + vbQuestion, "Part Operations")
    
    Select Case response
        Case vbYes
            CreateSampleFeatures
        Case vbNo
            GetPartInformation
        Case vbCancel
            Exit Sub
    End Select
    
End Sub

' Create sample features in the part
Sub CreateSampleFeatures()
    
    Dim boolstatus As Boolean
    Dim longstatus As Long, longwarnings As Long
    
    ' Start with a new sketch
    swModel.Insert3DSketch2 True
    swModel.SetPickMode
    
    ' Create a simple rectangle sketch
    swModel.CreateLine2 0, 0, 0, 0.1, 0, 0
    swModel.CreateLine2 0.1, 0, 0, 0.1, 0.1, 0
    swModel.CreateLine2 0.1, 0.1, 0, 0, 0.1, 0
    swModel.CreateLine2 0, 0.1, 0, 0, 0, 0
    
    ' Exit sketch
    swModel.Insert3DSketch2 True
    
    ' Create extrude feature
    swModel.FeatureManager.FeatureExtrusion2 True, False, False, 0, 0, 0.05, 0.01, False, False, _
        False, False, 0.0174532925199433, 0.0174532925199433, False, False, False, False, True, True, True, 0, 0, False
    
    ' Rebuild the model
    swModel.ForceRebuild3 True
    
    MsgBox "Sample features created successfully!", vbInformation
    
End Sub

' Get part information
Sub GetPartInformation()
    
    Dim partInfo As String
    Dim mass As Variant
    Dim volume As Double
    Dim surfaceArea As Double
    Dim featureCount As Long
    
    ' Get mass properties
    mass = swPart.GetMassProperties(0)
    If Not IsEmpty(mass) Then
        volume = mass(3) * 1000000 ' Convert to mm³
        surfaceArea = mass(4) * 1000000 ' Convert to mm²
    End If
    
    ' Get feature count
    featureCount = swModel.GetFeatureCount
    
    ' Build information string
    partInfo = "Part Information:" & vbCrLf & vbCrLf
    partInfo = partInfo & "File Name: " & swModel.GetTitle & vbCrLf
    partInfo = partInfo & "File Path: " & swModel.GetPathName & vbCrLf
    partInfo = partInfo & "Feature Count: " & featureCount & vbCrLf
    
    If Not IsEmpty(mass) Then
        partInfo = partInfo & "Volume: " & Format(volume, "0.00") & " mm³" & vbCrLf
        partInfo = partInfo & "Surface Area: " & Format(surfaceArea, "0.00") & " mm²" & vbCrLf
        partInfo = partInfo & "Mass: " & Format(mass(5), "0.000") & " kg" & vbCrLf
    End If
    
    MsgBox partInfo, vbInformation, "Part Information"
    
End Sub

' Process Assembly document operations
Sub ProcessAssembly()
    
    Set swAssembly = swModel
    
    Dim componentCount As Long
    Dim components As Variant
    Dim i As Long
    Dim assemblyInfo As String
    
    ' Get component count
    componentCount = swAssembly.GetComponentCount(False)
    
    ' Get components
    components = swAssembly.GetComponents(False)
    
    assemblyInfo = "Assembly Information:" & vbCrLf & vbCrLf
    assemblyInfo = assemblyInfo & "File Name: " & swModel.GetTitle & vbCrLf
    assemblyInfo = assemblyInfo & "Component Count: " & componentCount & vbCrLf & vbCrLf
    
    If componentCount > 0 Then
        assemblyInfo = assemblyInfo & "Components:" & vbCrLf
        For i = 0 To UBound(components)
            Dim comp As SldWorks.Component2
            Set comp = components(i)
            assemblyInfo = assemblyInfo & "- " & comp.Name2 & vbCrLf
        Next i
    End If
    
    MsgBox assemblyInfo, vbInformation, "Assembly Information"
    
End Sub

' Process Drawing document operations
Sub ProcessDrawing()
    
    Set swDrawing = swModel
    
    Dim sheetCount As Long
    Dim viewCount As Long
    Dim drawingInfo As String
    
    ' Get sheet count
    sheetCount = swDrawing.GetSheetCount
    
    ' Get view count on current sheet
    viewCount = swDrawing.GetViewCount
    
    drawingInfo = "Drawing Information:" & vbCrLf & vbCrLf
    drawingInfo = drawingInfo & "File Name: " & swModel.GetTitle & vbCrLf
    drawingInfo = drawingInfo & "Sheet Count: " & sheetCount & vbCrLf
    drawingInfo = drawingInfo & "Views on Current Sheet: " & viewCount & vbCrLf
    
    MsgBox drawingInfo, vbInformation, "Drawing Information"
    
End Sub

' Utility function to get selected features
Function GetSelectedFeatures() As Variant
    
    Dim selCount As Long
    Dim features() As SldWorks.Feature
    Dim i As Long
    Dim feat As SldWorks.Feature
    
    selCount = swSelMgr.GetSelectedObjectCount2(-1)
    
    If selCount = 0 Then
        GetSelectedFeatures = Empty
        Exit Function
    End If
    
    ReDim features(selCount - 1)
    
    For i = 1 To selCount
        Set feat = swSelMgr.GetSelectedObject6(i, -1)
        If Not feat Is Nothing Then
            Set features(i - 1) = feat
        End If
    Next i
    
    GetSelectedFeatures = features
    
End Function

' Utility function to save document
Sub SaveDocument()
    
    Dim longstatus As Long
    Dim longwarnings As Long
    
    If swModel.GetPathName = "" Then
        ' Document has never been saved
        MsgBox "Please save the document manually first.", vbExclamation
    Else
        longstatus = swModel.Save3(swSaveAsOptions_Silent, longwarnings)
        If longstatus = 0 Then
            MsgBox "Document saved successfully!", vbInformation
        Else
            MsgBox "Failed to save document. Error code: " & longstatus, vbCritical
        End If
    End If
    
End Sub

' Utility function to export file
Sub ExportFile(filePath As String, exportType As Long)
    
    Dim longstatus As Long
    Dim longwarnings As Long
    
    longstatus = swModel.SaveAs4(filePath, swSaveAsVersion_e.swSaveAsCurrentVersion, _
                                swSaveAsOptions_e.swSaveAsOptions_Silent, longwarnings)
    
    If longstatus = 0 Then
        MsgBox "File exported successfully to: " & filePath, vbInformation
    Else
        MsgBox "Failed to export file. Error code: " & longstatus, vbCritical
    End If
    
End Sub

' Custom property management
Sub SetCustomProperty(propertyName As String, propertyValue As String)
    
    Dim swCustPropMgr As SldWorks.CustomPropertyManager
    Set swCustPropMgr = swModel.Extension.CustomPropertyManager("")
    
    Dim longstatus As Long
    longstatus = swCustPropMgr.Add3(propertyName, swCustomInfoType_e.swCustomInfoText, _
                                   propertyValue, swCustomPropertyAddOption_e.swCustomPropertyReplaceValue)
    
    If longstatus = 0 Then
        MsgBox "Custom property '" & propertyName & "' set successfully!", vbInformation
    Else
        MsgBox "Failed to set custom property.", vbCritical
    End If
    
End Sub

' Get custom property value
Function GetCustomProperty(propertyName As String) As String
    
    Dim swCustPropMgr As SldWorks.CustomPropertyManager
    Set swCustPropMgr = swModel.Extension.CustomPropertyManager("")
    
    Dim propertyValue As String
    Dim resolvedValue As String
    Dim longstatus As Long
    
    longstatus = swCustPropMgr.Get5(propertyName, False, propertyValue, resolvedValue)
    
    If longstatus = 0 Then
        GetCustomProperty = resolvedValue
    Else
        GetCustomProperty = ""
    End If
    
End Function