Option Explicit

' Simple Drawing View Creator
' Creates a new drawing document and allows user to insert a view

Sub CreateDrawingWithUserView()
    
    ' Declare variables
    Dim swApp As SldWorks.SldWorks
    Dim swDrawing As SldWorks.DrawingDoc
    Dim swModel As SldWorks.ModelDoc2
    Dim swSheet As SldWorks.Sheet
    Dim swView As SldWorks.View
    Dim bRet As Boolean
    Dim sDrawingTemplate As String
    
    ' Initialize SolidWorks application
    Set swApp = Application.SldWorks
    
    ' Get the default drawing template
    sDrawingTemplate = swApp.GetUserPreferenceStringValue(swUserPreferenceStringValue_e.swDefaultTemplateDrawing)
    
    ' Create new A3 drawing document
    Set swDrawing = swApp.NewDocument(sDrawingTemplate, swDwgPaperSizes_e.swDwgPaperA3size, 0, 0)
    
    If swDrawing Is Nothing Then
        MsgBox "Failed to create drawing document."
        Exit Sub
    End If
    
    ' Set the active model to the drawing
    Set swModel = swDrawing
    Set swSheet = swDrawing.GetCurrentSheet
    
    ' Setup A3 sheet
    bRet = swDrawing.SetupSheet5(swSheet.GetName, swDwgPaperSizes_e.swDwgPaperA3size, _
                                swDwgTemplates_e.swDwgTemplateAsize, 1, 1, True, "", 0.42, 0.297, "Default", False)
    
    ' Clear any selections
    swModel.ClearSelection2 True
    
    ' Show message to user with instruction to create view
    MsgBox "A new A3 drawing has been created." & vbCrLf & vbCrLf & _
           "Next steps:" & vbCrLf & _
           "1. Go to Insert > Drawing Views > Model" & vbCrLf & _
           "2. Browse and select your model file" & vbCrLf & _
           "3. Choose the view orientation (Top, Front, etc.)" & vbCrLf & _
           "4. Place the view on the drawing sheet" & vbCrLf & vbCrLf & _
           "Click OK to continue...", vbInformation, "Create Your Drawing View"
    
    ' Now wait for user to actually create the view
    Dim userResponse As VbMsgBoxResult
    userResponse = MsgBox("Have you finished creating the drawing view?" & vbCrLf & vbCrLf & _
                         "Click YES if you have created the view" & vbCrLf & _
                         "Click NO to cancel", vbYesNo + vbQuestion, "View Creation Complete?")
    
    If userResponse = vbNo Then
        MsgBox "Macro cancelled by user.", vbInformation
        Exit Sub
    End If
    
    ' Now look for the created view
    Dim swFirstView As SldWorks.View
    Set swFirstView = swDrawing.GetFirstView
    
    If Not swFirstView Is Nothing Then
        Set swView = swFirstView.GetNextView
        
        ' If no next view, look through all views
        If swView Is Nothing Then
            Dim swViews As Variant
            swViews = swDrawing.GetViews
            If IsArray(swViews) And UBound(swViews) >= 0 Then
                Dim swSheetViews As Variant
                swSheetViews = swViews(0)
                If IsArray(swSheetViews) And UBound(swSheetViews) > 0 Then
                    Dim i As Integer
                    For i = 1 To UBound(swSheetViews)
                        Set swView = swSheetViews(i)
                        If Not swView Is Nothing Then
                            Exit For
                        End If
                    Next i
                End If
            End If
        End If
    End If
    
    ' Confirm view creation
    If swView Is Nothing Then
        MsgBox "No drawing view was found. Please make sure you created a view.", vbExclamation
    Else
        MsgBox "Drawing view '" & swView.Name & "' was successfully created!" & vbCrLf & _
               "View type: " & GetViewTypeName(swView) & vbCrLf & _
               "The drawing is ready for use.", vbInformation, "Success"
    End If
    
End Sub

' Helper function to get view type name
Function GetViewTypeName(swView As SldWorks.View) As String
    Select Case swView.Type
        Case swDrawingViewTypes_e.swDrawingNamedView
            GetViewTypeName = "Named View"
        Case swDrawingViewTypes_e.swDrawingProjectedView
            GetViewTypeName = "Projected View"
        Case swDrawingViewTypes_e.swDrawingSectionView
            GetViewTypeName = "Section View"
        Case swDrawingViewTypes_e.swDrawingAuxiliaryView
            GetViewTypeName = "Auxiliary View"
        Case swDrawingViewTypes_e.swDrawingDetailView
            GetViewTypeName = "Detail View"
        Case Else
            GetViewTypeName = "Standard View"
    End Select
End Function