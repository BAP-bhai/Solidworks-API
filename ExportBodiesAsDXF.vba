Option Explicit

' SolidWorks API objects
Dim swApp As SldWorks.SldWorks
Dim swModel As SldWorks.ModelDoc2
Dim swPart As SldWorks.PartDoc
Dim swFeat As SldWorks.Feature
Dim swBody As SldWorks.Body2
Dim swNewPart As SldWorks.PartDoc
Dim swNewModel As SldWorks.ModelDoc2

Sub ExportBodiesAsDXF()
    ' Connect to SolidWorks
    Set swApp = Application.SldWorks
    
    ' Get active document
    Set swModel = swApp.ActiveDoc
    
    ' Check if a part document is active
    If swModel Is Nothing Then
        MsgBox "No active document found. Please open a part file."
        Exit Sub
    End If
    
    If swModel.GetType() <> swDocumentTypes_e.swDocPART Then
        MsgBox "Active document is not a part file. Please open a part document."
        Exit Sub
    End If
    
    Set swPart = swModel
    
    ' Get the part's file path and name for naming convention
    Dim originalPath As String
    Dim originalName As String
    Dim outputDirectory As String
    
    originalPath = swModel.GetPathName()
    If originalPath = "" Then
        MsgBox "Please save the part file before running this macro."
        Exit Sub
    End If
    
    ' Extract directory and filename without extension
    outputDirectory = Left(originalPath, InStrRev(originalPath, "\"))
    originalName = Mid(originalPath, InStrRev(originalPath, "\") + 1)
    originalName = Left(originalName, InStrRev(originalName, ".") - 1)
    
    ' Get all solid bodies
    Dim vBodies As Variant
    vBodies = swPart.GetBodies2(swBodyType_e.swSolidBody, True)
    
    If IsEmpty(vBodies) Then
        MsgBox "No solid bodies found in the part."
        Exit Sub
    End If
    
    Dim bodyCount As Integer
    bodyCount = UBound(vBodies) + 1
    
    MsgBox "Found " & bodyCount & " solid bodies. Starting export process..."
    
    ' Process each body
    Dim i As Integer
    For i = 0 To UBound(vBodies)
        Set swBody = vBodies(i)
        
        ' Get body name or create a default name
        Dim bodyName As String
        bodyName = swBody.Name
        If bodyName = "" Or bodyName = "Solid Body" Then
            bodyName = "Body" & (i + 1)
        End If
        
        ' Clean the body name for file naming (remove invalid characters)
        bodyName = CleanFileName(bodyName)
        
        ' Create new part document
        Set swNewModel = swApp.NewDocument(swApp.GetDocumentTemplate(swDocumentTypes_e.swDocPART, "", 0, 0, 0), 0, 0, 0)
        Set swNewPart = swNewModel
        
        ' Copy body to new part
        Dim copyBodyResult As Boolean
        copyBodyResult = CopyBodyToNewPart(swBody, swNewPart)
        
        If copyBodyResult Then
            ' Save as DXF
            Dim dxfFileName As String
            dxfFileName = outputDirectory & originalName & "_" & bodyName & ".dxf"
            
            Dim saveResult As Boolean
            saveResult = SaveAsDXF(swNewModel, dxfFileName)
            
            If saveResult Then
                Debug.Print "Successfully exported: " & dxfFileName
            Else
                Debug.Print "Failed to export: " & dxfFileName
            End If
        Else
            Debug.Print "Failed to copy body: " & bodyName
        End If
        
        ' Close the temporary part
        swApp.CloseDoc swNewModel.GetTitle()
        
    Next i
    
    MsgBox "Export process completed. Check the same directory as your part file for DXF files."
    
End Sub

Function CopyBodyToNewPart(sourceBody As SldWorks.Body2, targetPart As SldWorks.PartDoc) As Boolean
    On Error GoTo ErrorHandler
    
    ' Method 1: Try using InsertBody3 (most reliable for solid bodies)
    Dim copyBody As SldWorks.Body2
    Set copyBody = sourceBody.Copy()
    
    If Not copyBody Is Nothing Then
        Dim feat As SldWorks.Feature
        Set feat = targetPart.CreateFeatureFromBody3(copyBody, False, swCreateFeatureBodyOpts_e.swCreateFeatureBodyCheck)
        
        If Not feat Is Nothing Then
            CopyBodyToNewPart = True
            Exit Function
        End If
    End If
    
    ' Method 2: Alternative approach using surface operations
    ' This might work better for certain body types
    Dim surfBodies As Variant
    ReDim surfBodies(0) As Object
    Set surfBodies(0) = sourceBody
    
    Dim surfFeat As SldWorks.Feature
    Set surfFeat = targetPart.FeatureManager.InsertMoveCopyBody2(0, 0, 0, 0, 0, 0, 0, 0, 0, surfBodies, 1, False, 0)
    
    If Not surfFeat Is Nothing Then
        CopyBodyToNewPart = True
        Exit Function
    End If
    
    CopyBodyToNewPart = False
    Exit Function
    
ErrorHandler:
    CopyBodyToNewPart = False
End Function

Function SaveAsDXF(model As SldWorks.ModelDoc2, filePath As String) As Boolean
    On Error GoTo ErrorHandler
    
    ' Set DXF export options
    Dim errors As Long
    Dim warnings As Long
    
    ' Save as DXF
    Dim result As Boolean
    result = model.Extension.SaveAs(filePath, swSaveAsVersion_e.swSaveAsCurrentVersion, swSaveAsOptions_e.swSaveAsOptions_Silent, Nothing, errors, warnings)
    
    SaveAsDXF = result And (errors = 0)
    Exit Function
    
ErrorHandler:
    SaveAsDXF = False
End Function

Function CleanFileName(fileName As String) As String
    ' Remove or replace invalid file name characters
    Dim cleanName As String
    cleanName = fileName
    
    ' Replace invalid characters with underscore
    cleanName = Replace(cleanName, "/", "_")
    cleanName = Replace(cleanName, "\", "_")
    cleanName = Replace(cleanName, ":", "_")
    cleanName = Replace(cleanName, "*", "_")
    cleanName = Replace(cleanName, "?", "_")
    cleanName = Replace(cleanName, """", "_")
    cleanName = Replace(cleanName, "<", "_")
    cleanName = Replace(cleanName, ">", "_")
    cleanName = Replace(cleanName, "|", "_")
    
    ' Remove any trailing/leading spaces
    cleanName = Trim(cleanName)
    
    ' Ensure it's not empty
    If cleanName = "" Then
        cleanName = "Body"
    End If
    
    CleanFileName = cleanName
End Function

' Alternative main subroutine with more options
Sub ExportBodiesAsDXFWithOptions()
    ' This version allows user to select output directory
    Dim outputDir As String
    outputDir = InputBox("Enter output directory path (leave blank for same as part file):", "Output Directory")
    
    If outputDir <> "" Then
        ' Ensure directory ends with backslash
        If Right(outputDir, 1) <> "\" Then
            outputDir = outputDir & "\"
        End If
        
        ' Check if directory exists
        If Dir(outputDir, vbDirectory) = "" Then
            MsgBox "Directory does not exist: " & outputDir
            Exit Sub
        End If
    End If
    
    ' Call main export function with custom directory
    ExportBodiesAsDXFCustomDir outputDir
End Sub

Sub ExportBodiesAsDXFCustomDir(customOutputDir As String)
    ' Similar to main function but with custom output directory option
    ' [Implementation would be similar to main function but use customOutputDir]
    ' This is left as an exercise or can be implemented based on specific needs
End Sub