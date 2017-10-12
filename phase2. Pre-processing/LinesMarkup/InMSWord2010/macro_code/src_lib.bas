Attribute VB_Name = "NewMacros1"
' *****Notes*****
' Encountered issues:
' 1) (obj is Nothing) // it's incorrect to use Null, since it is the term of database whereas Nothing relates to programming
' 2) Dim MyVar, AnotherVar As Integer  // MyVar is not Integer in this case, it is Variant
' 3) Set var= value // is used only for objects not for var types
' 4) r.SetRange  // redefine range boundaries
' 5) Chr(13)    // new line in VBA
' 6) ChrW() // Use this instead of chr() when dealing with unicode characters
' 7) Optional keyword : Optional arguments are preceded by the Optional keyword in the procedure definition.
' 8) Selection.Collapse direction:=wdCollapseEnd // not Selection.range.collapse
' 9) Selection object is not a range, therefor it has different methods, e.g: Selection.MoveRight unit:=wdWord, Count:=1, Extend:=wdExtend   'm_cur_pos.MoveEnd unit:=wdWord, Count:=1
' 10) Issue: '!' cannot be added with wildcards
' 11) Turkish 'i' without upper point cannot be uppercased, and Turkish 'I' with the point cannot be lowercased by means of UCase(String)
' 12) Cyrilic letters may be lost in this editor after copying from Notepad++ or other. As a result we have '?' signs.
        'Solution: don't copypaste from thirtparty editor, but import .bas files directly in VBA editor
' 13) How to make search for '!' character using wildcards? It's wildcards reserverd character meaning 'not'
'*********
'
' ****Global variables definitions****
        'Frequently used characters
         Dim g_eol As String
         Dim g_tab As String
        
        'Kyrgyz unique characters
        Dim g_ky_origin As String
        Dim g_ky_charset As String
        ' Turkish unique characters
        Dim g_tr_origin As String
        Dim g_tr_charset As String
        'punctuation chars
        Dim g_punct As String

Function init_global_vars()
'Frequently used characters
g_eol = Chr(13)
g_tab = Chr(9)
'Kyrgyz unique characters
g_ky_origin = (ChrW(1199)) & ChrW(1257) & ChrW(1187) & ChrW(1186) & ChrW(1198) & ChrW(1256)
' Turkish unique characters
' i.e. 246-o  252-u  351-s  305-i  231-c  287-g; C-199 O-214 S-350 I-304 U-220 G-286
g_tr_origin = (ChrW(246)) & ChrW(252) & ChrW(351) & ChrW(305) & ChrW(231) & ChrW(287) & ChrW(199) & ChrW(214) & ChrW(350) & ChrW(304) & ChrW(220) & ChrW(286)
'punctuation chars
g_punct = ")?"

g_ky_charset = "AAAAAA??CEEEEIIII?NOOOOO?UUUUY??" & LCase("AAAAAA??CEEEEIIII?NOOOOO?UUUUY??") & g_ky_origin
g_tr_charset = "ABCDEFGHIGKLMNOPQRSTUVWXYZ" & LCase("ABCDEFGHIGKLMNOPQRSTUVWXYZ") & g_tr_origin

End Function
Sub main()
    '' first of all lets initialize global variables
    Call init_global_vars
   '' lets normalize paragraphs.
    m = replace_all_repeatedly(Chr(13) & Chr(13), Chr(13))
    ' lets normalize spaces
    m = replace_all_repeatedly(" " & " ", " ")
    '' Subdevide the plain text to article elements
    Call MarkupArticles
    Call MarkupKeys
    Call MarkupDefinitions
    Call MarkupContent_all
    
    
End Sub
Function is_eod1(r As Range) As Boolean
    Dim temp_r As Range
    Set temp_r = Selection.Range
    
    Selection.HomeKey Unit:=wdStory
    Selection.EndKey Unit:=wdStory, Extend:=wdExtend
    Dim last_char As Long
    last_char = Selection.Range.End
    If r.Start = last_char - 1 Then
        is_eod1 = True
    Else
        is_eod1 = False
    End If
    Selection.SetRange Start:=temp_r.Start, End:=temp_r.End
    
    Selection.Select
    
End Function
Function is_eod2(r As Range) As Boolean
    Dim temp_r As Range
    Set temp_r = Selection.Range
    Dim i1 As Long
    Dim i2 As Long
    temp_r.MoveEnd Unit:=wdCharacter, Count:=1
    i1 = temp_r.End
    temp_r.MoveEnd Unit:=wdCharacter, Count:=1
    i2 = temp_r.End
    If i1 = i2 Then
        is_eod2 = True
    Else
        is_eod2 = False
    End If
    
End Function

Sub MarkupLines()
' Definition: This macro should mark up with red color the last character of each line.
' Bug: function fails if there is a line consisting of one character
' there is probably no such lines in our dictionary except empty paragraphs, but any way it is not good
'

Dim counter As Integer
'Selection.HomeKey Unit:=wdStory
    
Do While Not is_eod2(Selection.Range)
    
    Selection.EndKey Unit:=wdLine
    Selection.MoveLeft Unit:=wdCharacter, Count:=1, Extend:=wdExtend
    Selection.Font.Color = wdColorRed
    Selection.EndKey Unit:=wdLine
    Selection.MoveRight Unit:=wdCharacter, Count:=2
        
    counter = deadlock_saveguard(counter, 25000, "MarkupLines") ' ask when 5000 lines have been processed
    
Loop
End Sub
Sub AlignParagraph()
 ActiveDocument.Paragraphs(1).Alignment = _
 wdAlignParagraphRight
End Sub
Sub TraverseParagraphs()
' snippet taken from: https://www.experts-exchange.com/questions/26231079/How-to-Loop-through-each-line-in-WORD-using-VBA.html
'
'
Dim para As Paragraph
Dim i As Integer
Dim rng As Range

For Each para In ActiveDocument.Paragraphs

    For i = 1 To 4
        If Len(para.Range) >= 4 Then
        
            Set rng = para.Range.Characters(i)
            
            Select Case rng.Text
            
            
                Case "1":
                    rng.HighlightColorIndex = wdRed
                Case "2":
                    rng.HighlightColorIndex = wdBlue
            End Select
        End If
    Next i
Next para


                
End Sub
Sub LinesToParagraphs()
''
'' Starts processing at the current cursor position
'' otherwise add/uncomment
'Selection.HomeKey Unit:=wdStory
''to start from the beginning
''
    Dim counter As Integer
    Do While Not is_eod2(Selection.Range)
        
        Selection.EndKey Unit:=wdLine
        Selection.MoveRight Unit:=wdCharacter, Count:=1, Extend:=wdExtend
        If Not (Selection.Text = Chr(10) Or Selection.Text = Chr(13)) Then
            Selection.Collapse Direction:=wdCollapseStart
            
            Selection.InsertAfter (Chr(10))
            'Selection.Font.Color = wdColorRed
            Selection.EndKey Unit:=wdLine
            Selection.MoveRight Unit:=wdCharacter, Count:=2
        Else
            Selection.MoveRight Unit:=wdCharacter, Count:=2
        End If
        counter = deadlock_saveguard(counter, 500, "MarkupLines")
        
    Loop
End Sub

Sub ManualValidation()
'
    Dim FindWhat As String
    Dim PropsAndVals As String
    FindWhat = "[<]article[>]" & Chr(13) & "[!<]"
    
    Set c = find_str(FindWhat, True)
    
End Sub
Sub MarkupContent_all()
 '
    Dim FindWhat As String
    Dim PropsAndVals As String
    FindWhat = "type = " & Chr(39) & "h" & Chr(39) & "[>]*[<][//]definition[>]"
    
    c = find_and_markup_all(FindWhat, "CDATA", , True, 11, 13)
    k = replace_all("<CDATA>", "<![CDATA[")
    k = replace_all("</CDATA>", "]]>")
    MsgBox "Content Markup is finished!"
End Sub
Sub MarkupDefinitions()
 ' *****************************
    Dim FindWhat As String
    Dim PropsAndVals As String
    FindWhat = "[<][//]key[>]*[<][//]article[>]"
    PropsAndVals = "type = " & Chr(39) & "h" & Chr(39)
    c = find_and_markup_all(FindWhat, "definition", PropsAndVals, True, 6, 11)
End Sub
Sub MarkupKeys()
    Call init_global_vars
 ' *****************************
    Dim TagName As String
    Dim FindWhat As String
    FindWhat = "[<]article[>]" & Chr(13) & "[A-Za-z" & g_tr_origin & "]@>"
    TagName = "key"
    
    n = find_and_markup_all(FindWhat, TagName, , True, 10, 0)
End Sub
Sub MarkupArticles()
    Selection.HomeKey Unit:=wdStory
    ' *************Demarkation****************
    Dim InsertWhat As String
    Dim FindWhat As String
    FindWhat = "[A-?a-y" & g_ky_origin & g_punct & "]" & "[.?]" & Chr(13) & "[A-Za-z" & g_tr_origin & "]"
    InsertWhat = Chr(13) & "</article>" & Chr(13) & "<article>"
    n = find_and_insert_at_all(m_FindWhat:=FindWhat, m_InsertWhere:=-2, m_InsertWhat:=InsertWhat, m_MatchWildCards:=True)
    ' ******************************************
    ' Completing first and last articles
    Selection.HomeKey Unit:=wdStory
    Selection.Range.InsertAfter "<article>"
    Selection.EndKey Unit:=wdStory
    Selection.Range.InsertAfter "</article>"
End Sub
Sub Show_ascw()
    Dim kod As Long
    kod = AscW(Selection.Text)
    str1 = ChrW(kod)
    MsgBox "Selected text: " & Selection.Text & Chr(13) & "ASCW: " & kod
    'Selection.Range.InsertAfter (kod)
End Sub
Function mark_lines_pointed(ByVal m_pointer As String, ByVal m_new_tag As String) As Boolean
Dim exit_code As Boolean
Selection.HomeKey wdStory
exit_code = mark_line_containing(m_pointer, m_new_tag)
Selection.Select
Selection.Collapse wdCollapseEnd
Selection.MoveRight wdCharacter, Len("</header>")
loop_limit = 0
    Do While exit_code
        exit_code = mark_line_containing(m_pointer, m_new_tag)
        Selection.Select
        Selection.Collapse wdCollapseEnd
        Selection.MoveRight wdCharacter, Len("</header>")
        loop_limit = deadlock_saveguard(loop_limit, 1000, "main")
    Loop
mark_pointed_lines = exit_code
End Function

Function mark_line_containing(ByVal m_what, ByVal m_Tag) As Boolean
    Dim r As Range
    Set r = find_str(m_what)
    If (r Is Nothing) = False Then
    
        Selection.HomeKey wdLine
        Selection.Range.InsertBefore "<" & m_Tag & ">"
        Selection.EndKey wdLine
        Selection.Range.InsertAfter "</" & m_Tag & ">"
        Selection.Collapse wdCollapseEnd
        mark_line_containing = True
    Else
        mark_line_containing = False
    End If

End Function
Sub application_of_remove_tag_all()
    Dim r As Range
    'Set r = remove_tag_all("Sect")
    'Set r = remove_tag_all("Part")
    'Set r = remove_tag_all("LI")
    Set r = remove_tag_all("LI_Label")
End Sub
Function remove_tag_all(m_Tag As String) As Range
' Removes all occurrencies of <m_tag>, </m_tag> and <m_tag/>
    Dim n As Long
    Dim r As Long
    Dim open_t As String
    Dim close_t As String
    Dim empty_t As String
    
    open_t = "<" & m_Tag & ">"
    close_t = "</" & m_Tag & ">"
    empty_t = "<" & m_Tag & "/>"
    n = replace_all(open_t, "")
    MsgBox (n & " open tags were removed!")
    r = replace_all(close_t, "")
    If n <> r Then
        MsgBox "Number of close and open tags : ", , vbInformation
    End If
    MsgBox (n & " close tags were removed!")
    n = replace_all(empty_t, "")
    MsgBox (n & " empty tags were removed!")
    
    Set remove_tag_all = Selection.Range
End Function
Sub application_of_mark_lines_pointed()
    Dim response As Boolean
    response = mark_lines_pointed("header", "header")
End Sub
Sub application_of_replace_tag_all()
    Dim r As Range
    'Set r = replace_tag_all("Sect")
    'Set r = replace_tag_all("H5", "P")
    'Set r = replace_tag_all("L", "P")
    Set r = replace_tag_all("LI_Title", "")
End Sub
Sub application_of_markup_all()
    Call init_global_vars
    ' *******************
    Dim TagName As String
    Dim FindWhat As String
    FindWhat = Chr(13) & Chr(13) & Chr(13) & Chr(13) & Chr(13) & "*" & g_tab  '
    TagName = "PageName"
    
    n = find_and_markup_all(FindWhat, TagName, , True, 10, 0)
End Sub
Function replace_tag_all(m_Tag As String, m_new_tag As String) As Range
' If m_new_tag is "" then removes all occurrencies of <m_tag>, </m_tag> and <m_tag/>
' Otherwise substitudes m_tag occurencies by m_new_tag value
    Dim n As Long
    Dim r As Long
    Dim open_t As String
    Dim close_t As String
    Dim empty_t As String
    Dim new_open_t As String
    Dim new_close_t As String
    Dim new_empty_t As String
    
    If m_new_tag = "" Then
        Set replace_tag_all = remove_tag_all(m_Tag)
        Exit Function
    End If
    
    open_t = "<" & m_Tag & ">"
    close_t = "</" & m_Tag & ">"
    empty_t = "<" & m_Tag & "/>"
    
    new_open_t = "<" & m_new_tag & ">"
    new_close_t = "</" & m_new_tag & ">"
    new_empty_t = "<" & m_new_tag & "/>"
    
    n = replace_all(open_t, new_open_t)
        MsgBox (n & " open tags were replaced!")
    r = replace_all(close_t, new_close_t)
        MsgBox (n & " close tags were replaced!")
    If n <> r Then
        MsgBox "Number of close and open tags don't match", , vbInformation
    End If
    n = replace_all(empty_t, new_empty_t)
        MsgBox (n & " empty tags were replaced!")
    
    Set replace_tag_all = Selection.Range
End Function

Sub apply_pattern1_1()
    Dim r As Range
    Do
        Set r = find_str(".^w^p</P>^p<P>^$")
        If r Is Nothing Then
            MsgBox ("no EOE found! Good bay !")
            Exit Sub
        End If
        Set r = insert_at(r, r.Characters.Count - 4, "</article>" & Chr(13) & "<article>" & Chr(13))
        'r.Select
        
        Selection.Range.SetRange Start:=r.Start, End:=r.End
        Selection.Collapse Direction:=wdCollapseEnd
    Loop
    
    
End Sub
Sub application_find_and_insert_at_all()
    Call init_global_vars
    'n = find_and_insert_at_all(".^w</P>^p<P>^$", -4, "<EOA>")
    'n = find_and_insert_at_all(".^w</P>^p<page><P>^#^#^w</P></page>^p<P>^$", -4, "<EOA>") ' when page_tag between two entries
    'n = find_and_insert_at_all("?^w</P>^p<P>^$", -4, "</article>" & Chr(13) & "<article>" & Chr(13))
    ' *************
    Dim InsertWhat As String
    Dim FindWhat As String
    FindWhat = "[A-?a-y" & g_ky_origin & g_punct & "]" & "." & Chr(13) & "[A-Za-z" & g_tr_origin & "]"
    InsertWhat = Chr(13) & "</article>" & Chr(13) & "<article>"
    n = find_and_insert_at_all(m_FindWhat:=FindWhat, m_InsertWhere:=-2, m_InsertWhat:=InsertWhat, m_MatchWildCards:=True)
    ' *************
End Sub
Function find_and_insert_at_all(m_FindWhat As String, m_InsertWhere As Integer, m_InsertWhat As String, Optional m_MatchWildCards As Boolean = False) As Long
' if m_InsertWhere is negative the function will insert the text at the position m_InsertWhere steps to the left from the end of the found range
    Dim r As Range
    Dim counter As Long
    counter = 0
    Do
        Set r = find_str(m_FindWhat, m_MatchWildCards)
        If r Is Nothing Then
            MsgBox (counter & " matching of the pattern were found! Good bay !")
            find_and_insert_at_all = counter
            Exit Function
        End If
        If m_InsertWhere < 0 Then
            Set r = insert_at(r, r.Characters.Count + m_InsertWhere, m_InsertWhat)
        Else
            Set r = insert_at(r, m_InsertWhere, m_InsertWhat)
        End If
        'r.Select
        
        Selection.Range.SetRange Start:=r.Start, End:=r.End
        Selection.Collapse Direction:=wdCollapseEnd
        counter = counter + 1
    Loop
    find_and_insert_at_all = counter
End Function
Function markup_all(m_FindWhat As String, m_Tag As String, Optional ByVal m_PropsAndVals As String = "", Optional m_MatchWildCards As Boolean = False, Optional m_MoveLeft As Integer = 0, Optional m_MoveRight As Integer = 0) As Long
' alias for find_and_markup_all function
'
markup_all = find_and_markup_all(m_FindWhat, m_Tag, m_PropsAndVals, m_MatchWildCards, m_MoveLeft, m_MoveRight)
End Function
Function find_and_markup_all(m_FindWhat As String, m_Tag As String, Optional ByVal m_PropsAndVals As String = "", Optional m_MatchWildCards As Boolean = False, Optional m_MoveLeft As Integer = 0, Optional m_MoveRight As Integer = 0) As Long
' finds all the occurencies of the text and marks it with the specified tag and atributes
'
    ' Performing search and markup on each iteration
    Dim r As Range
    Dim counter As Long
    counter = 0
    Selection.HomeKey Unit:=wdStory
    Do
        Set r = find_str(m_FindWhat, m_MatchWildCards)
        If r Is Nothing Then
            MsgBox (counter & " Exiting find_and_markup_all! ")
            find_and_markup_all = counter
            Exit Function
        End If
    ' Go here if target is found.
        ' adjustments on range boundaries
        If m_MoveLeft <> 0 Or m_MoveRight <> 0 Then
            r.MoveStart Unit:=wdCharacter, Count:=m_MoveLeft
            r.MoveEnd Unit:=wdCharacter, Count:=-m_MoveRight
            r.Select
        End If
        ' tag assembling for markup
        Dim start_tag As String
        Dim end_tag As String
        If m_PropsAndVals <> "" Then
            ' putting delimiting whitespace
            Dim tmp As String
            tmp = Trim(m_PropsAndVals)
            m_PropsAndVals = " " & tmp
        End If
        start_tag = "<" & m_Tag & m_PropsAndVals & ">"
        end_tag = "</" & m_Tag & ">"
        ' marking up
        Selection.Range.InsertBefore start_tag
        Selection.Range.InsertAfter end_tag
        Selection.Collapse Direction:=wdCollapseEnd
        ' incrementing loop counter
        counter = counter + 1
    Loop
    find_and_markup_all = counter
End Function
Function select_word_at(m_Where As Range) As Range
' selects the word the m_Where range is in
    m_Where.Select
    Selection.MoveRight Unit:=wdWord, Count:=1, Extend:=wdExtend
    Selection.Collapse Direction:=wdCollapseEnd
    Selection.MoveLeft Unit:=wdWord, Count:=1, Extend:=wdExtend
    
    Set m_Where = Selection.Range
    Set select_word_at = m_Where
End Function
Sub MarkHeaders()
    Dim response As Boolean
    ' point lines to be marked here
    '.........
    '
    response = mark_lines_pointed("header", "header")
    r = replace_all("<header><header>", "<header>")
End Sub
Sub test_select_word()
    Dim r As Range
    Set r = Selection.Range
    Set r = select_word_at(r)
End Sub
Function change_charset(m_letter As String) As String
' under development
    Dim tr_chars As String
    Dim ky_chars As String
    tr_chars = "ABCEHKMOPTX acekopxy"
    ky_chars = "AANAIEII?OO anaei?oo"
    Selection.InsertAfter ky_chars
    change_charset = ""
End Function
Sub test_change_charset()
 r = change_charset("")
End Sub
Function insert_at(ByRef m_rng As Range, ByVal m_InsertWhere As Integer, ByVal m_what As String) As Range
    If m_InsertWhere > m_rng.Characters.Count Then
        Set insert_at = Nothing
        Exit Function
    End If
    
    Dim r As Range
    Set r = m_rng
    r.SetRange Start:=m_rng.Start + m_InsertWhere, End:=m_rng.End
    r.InsertBefore (m_what)
    m_rng.SetRange Start:=m_rng.Start, End:=m_rng.End + Len(m_what)
    
    Set insert_at = m_rng
End Function
Function replace_all(ByVal m_find As String, ByVal m_replace As String) As Long
    'returns number of replacements
    MsgBox "Starting replacing_all function."
    replace_all = CountNoOfReplaces(m_find, m_replace)
End Function
Sub application_of_replace_all()
    'MsgBox "Number of replacements: " & replace_all(".^w</P>^p<P>^$", "EOE^&"), vbInformation
    'MsgBox "Number of replacements: " & replace_all("</article>", "</article>"), vbInformation
    'MsgBox "Number of replacements: " & replace_all("</article>", "</article>"), vbInformation
    MsgBox "Number of replacements: " & replace_all("</article>", "</article>"), vbInformation
End Sub
Function CountNoOfReplaces(StrFind As String, StrReplace As String) As Long

Dim NumCharsBefore As Long, NumCharsAfter As Long, LengthsAreEqual As Boolean

    Application.ScreenUpdating = False

    'Check whether the length of the Find and Replace strings are the same; _
    if they are, prefix the replace string with a hash (#)
    If Len(StrFind) = Len(StrReplace) Then
        LengthsAreEqual = True
        StrReplace = "#" & StrReplace
    End If

    'Get the number of chars in the doc BEFORE doing Find & Replace
    NumCharsBefore = ActiveDocument.Characters.Count

    'Do the Find and Replace
    With Selection.Find
        .ClearFormatting
        .Replacement.ClearFormatting
        .Text = StrFind
        .Replacement.Text = StrReplace
        .Forward = True
        .Wrap = wdFindContinue
        .Format = False
        .MatchCase = False
        .MatchWholeWord = True
        .MatchWildcards = False
        .MatchSoundsLike = False
        .MatchAllWordForms = False
        .Execute Replace:=wdReplaceAll
    End With

    'Get the number of chars AFTER doing Find & Replace
    NumCharsAfter = ActiveDocument.Characters.Count

    'Calculate of the number of replacements,
    'and put the result into the function name variable
    CountNoOfReplaces = (NumCharsBefore - NumCharsAfter) / _
            (Len(StrFind) - Len(StrReplace))

    'If the lengths of the find & replace strings were equal at the start, _
    do another replace to strip out the #
    If LengthsAreEqual Then

        StrFind = StrReplace
        'Strip off the hash
        StrReplace = Mid$(StrReplace, 2)

        With Selection.Find
            .Text = StrFind
            .Replacement.Text = StrReplace
            .Execute Replace:=wdReplaceAll
        End With

    End If

    Application.ScreenUpdating = True
    'Free up memory
    ActiveDocument.UndoClear

End Function
Function find_str(ByVal m_FindWhat As String, Optional m_MatchWildCards As Boolean = False) As Range
Selection.Find.ClearFormatting
    With Selection.Find
        .Text = m_FindWhat
        .Replacement.Text = ""
        .Forward = True
        .Wrap = wdFindStop
        .Format = True
        .MatchCase = True
        .MatchWholeWord = False
        .MatchWildcards = m_MatchWildCards
        .MatchSoundsLike = False
        .MatchAllWordForms = False
    End With
    Selection.Find.Execute
    If Selection.Find.Found Then
        Set find_str = Selection.Range
    Else
        Set find_str = Nothing
    End If
    
End Function
Function find_with_wildcards(ByVal m_what As String) As Range
Selection.Find.ClearFormatting
    With Selection.Find
        .Text = m_what
        .Replacement.Text = ""
        .Forward = True
        .Wrap = wdFindStop
        .Format = True
        .MatchCase = True
        .MatchWholeWord = False
        .MatchWildcards = True
        .MatchSoundsLike = False
        .MatchAllWordForms = False
    End With
    Selection.Find.Execute
    If Selection.Find.Found Then
        Set find_with_wildcards = Selection.Range
    Else
        Set find_with_wildcards = Nothing
    End If
    
End Function
Sub test_find_with_wildcards()
   
    Call init_global_vars
    ' *******************
    Dim TagName As String
    Dim FindWhat As String
    FindWhat = "[<]header[>][p]"
    TagName = "PageName"
    
    Set r = find_str(FindWhat, True)
End Sub
Sub test_find_white_space_eoe()
    Dim r As Range
    Set r = find_EOE_terminated_by_white_space(Selection.Range)
End Sub
Function find_EOE_fs_cr_l(m_r As Range) As Range
    
End Function
Function find_EOE_terminated_by_white_space(m_r As Range) As Range
' source file to be marked: Some Web Engine
' EOE - End of Entry
    Dim r As Range
    Dim flag As Boolean
    Dim i As Integer
    flag = False
    i = 0
    Do
        Set r = find_str(".^w^$")
        If r Is Nothing Then
            Set find_EOE_terminated_by_white_space = Nothing
            Exit Function
        End If
        If r.Characters.Last.Bold Then
            'MsgBox ("Last char of range is bold.")
            If is_in_one_line(r) = False Then
                MsgBox ("Found range captures two or more lines.EOE is found!")
                Set find_EOE_terminated_by_white_space = r
                Exit Do
            End If
        Else
            Set find_EOE_terminated_by_white_space = Nothing
        End If
        i = deadlock_saveguard(i, 100, "white_space_eof")
    Loop
    
    
End Function
Function deadlock_saveguard(ByVal m_counter As Integer, ByVal m_max_loop As Integer, ByVal m_func_name As String) As Integer
m_counter = m_counter + 1
deadlock_saveguard = m_counter
If m_counter Mod m_max_loop = 0 Then
        If MsgBox("Do you want to continue the loop in " & m_func_name, vbYesNo, "Debugging") = vbNo Then
           Stop
        End If
End If
End Function
Function replace_all_repeatedly(m_what As String, m_by As String)
    ' This procedure replaces "m_what" repeatedly by "m_by" while there are absolutely no new occurrencies
    
    ' lets define limits for deadlock_saveguard
    Dim max, current As Integer
    max = 2000
    current = 0
    ' lets define variable for number of replacements
    Dim l, m As Long
    l = 1 ' lets set it to 1 in order to enter the loop
    m = 0 ' this variable holds sum of all  replacements
    Do While l <> 0
        l = replace_all(m_what, m_by)
        m = m + l
        MsgBox ("Loop number: " & current + 1 & Chr(13) & "Replacements made: " & l)
        current = deadlock_saveguard(current, max, "replace_all_repeatedly")
    Loop
    replace_all_repeatedly = m
End Function
Sub test_find_double_carret_return()

    Dim r As Range
    Do
        Set r = find_by_ascw(13)
        If r Is Nothing Then
            Exit Sub
        End If
        Selection.Collapse wdCollapseEnd
        Selection.MoveRight wdCharacter, 1, True
        Code = AscW(Selection.Text)
        If Code = 13 Then
            MsgBox "double par found!!"
            Exit Sub
        End If
        Selection.Collapse wdCollapseEnd
    Loop
End Sub
Function find_by_ascw(m_ascw As Long) As Range
   
    Dim r As Range
    str1 = ChrW(m_ascw)
    Set r = find_str(str1)
    Set find_by_ascw = r
    
End Function
Sub test_fs_ws_letter()
    Dim r As Range
    Set r = find_str(".^w^$")
    If r.Bold Then
        MsgBox ("Found range is bold.")
    End If
    If r.Characters.Last.Bold Then
        MsgBox ("Last char of range is bold.")
    End If
    If is_in_one_line(r) = False Then
        MsgBox ("Found range is not in one line.")
    End If
    
End Sub
Function is_in_one_line(r As Range) As Boolean
    Dim l1, l2 As Integer
    Dim r1 As Range
    Dim r2 As Range
    Set r1 = r.Characters.First
    Set r2 = r.Characters.Last
    l1 = GetLineNum(r1)
    l2 = GetLineNum(r2)
    
    If l1 = l2 Then
        is_in_one_line = True
    Else
        is_in_one_line = False
    End If
End Function
Sub WhereAmI()
    
    MsgBox "Paragraph number: " & GetParNum(Selection.Range) & vbCrLf & _
    "Absolute line number: " & GetAbsoluteLineNum(Selection.Range) & vbCrLf & _
    "Relative line number: " & GetLineNum(Selection.Range)
End Sub
 
 
Function GetParNum(r As Range) As Integer
    Dim rParagraphs As Range
    Dim CurPos As Long
     
    r.Select
    CurPos = ActiveDocument.Bookmarks("\startOfSel").Start
    Set rParagraphs = ActiveDocument.Range(Start:=0, End:=CurPos)
    GetParNum = rParagraphs.Paragraphs.Count
End Function
 
Function GetLineNum(r As Range) As Integer
     'relative to current page
    GetLineNum = r.Information(wdFirstCharacterLineNumber)
End Function
 
Function GetAbsoluteLineNum(r As Range) As Integer
    Dim i1 As Integer, i2 As Integer, Count As Integer, rTemp As Range
     
    r.Select
    Do
        i1 = Selection.Information(wdFirstCharacterLineNumber)
        Selection.GoTo what:=wdGoToLine, which:=wdGoToPrevious, Count:=1, Name:=""
         
        Count = Count + 1
        i2 = Selection.Information(wdFirstCharacterLineNumber)
    Loop Until i1 = i2
     
    r.Select
    GetAbsoluteLineNum = Count
End Function
