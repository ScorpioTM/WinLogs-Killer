#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.8.1
 Script Version: 1.0.1
 Author:         Scorpio

 Script Function:
	Clear diverses Logs and History Files saved by Windows.

#ce ----------------------------------------------------------------------------
#RequireAdmin

_ClearEventLog()
_ClearRDPLog()
_ClearRecentLog()

Func _ClearEventLog()
	Local $Timer, $List, $Line

	If FileExists(@ScriptDir & '\EventLog.txt') Then FileDelete(@ScriptDir & '\EventLog.txt')
	If Not FileExists(@SystemDir & '\wevtutil.exe') Then Return SetError(1, 'WEvtUtil dont exist', False)

	RunWait(@ComSpec & ' /c wevtutil.exe enum-logs > "' & @ScriptDir & '\EventLog.txt"', @SystemDir, @SW_HIDE)
	If @Error Then Return SetError(2, 'An Error as ocurred Enumerating the logs', False)

	$Timer = TimerInit()

	While TimerDiff($Timer) < 5000
		If FileExists(@ScriptDir & '\EventLog.txt') Then ExitLoop
		Sleep(100)
	WEnd

	If Not FileExists(@ScriptDir & '\EventLog.txt') Then Return SetError(3, 'Cannot Find the EventLog.txt file', False)

	$List = FileOpen(@ScriptDir & '\EventLog.txt', 0)
	If @Error Then Return SetError(4, 'Cannot Open the EventLog.txt file', False)

	While True
		$Line = FileReadLine($List)
		If @Error = -1 Then ExitLoop

		RunWait(@ComSpec & ' /c wevtutil.exe clear-log "' & $Line & '"', @SystemDir, @SW_HIDE)
		If @Error Then ConsoleWrite('An Error as ocurred Deleting the Log: ' & $Line & @CRLF)

		Sleep(100)
	WEnd

	FileClose($List)

	If FileExists(@ScriptDir & '\EventLog.txt') Then FileDelete(@ScriptDir & '\EventLog.txt')

	Return SetError(0, 'Event Log clear sucessfully', True)
EndFunc

Func _ClearRDPLog()
	Local $Count, $Value

	If RegRead('HKEY_CURRENT_USER\Software\Microsoft\Terminal Server Client\Default', '') Then
		$Count = 1

		While True
			$Value = RegEnumVal('HKEY_CURRENT_USER\Software\Microsoft\Terminal Server Client\Default', $Count)
			If @Error = -1 Then ExitLoop

			ConsoleWrite('Deleting Registry Value: ' & $Value & @CRLF)
			RegDelete('HKEY_CURRENT_USER\Software\Microsoft\Terminal Server Client\Default', $Value)

			$Count += 1
		WEnd
	EndIf

	If RegRead('HKEY_CURRENT_USER\Software\Microsoft\Terminal Server Client\Servers', '') Then
		$Count = 1

		While True
			$Value = RegEnumKey('HKEY_CURRENT_USER\Software\Microsoft\Terminal Server Client\Servers', $Count)
			If @Error = -1 Then ExitLoop

			ConsoleWrite('Deleting Registry Key: ' & $Value & @CRLF)
			RegDelete('HKEY_CURRENT_USER\Software\Microsoft\Terminal Server Client\Servers\' & $Value)

			$Count += 1
		WEnd
	EndIf

	If FileExists(@UserProfileDir & '\Documents\Default.rdp') Then
		ConsoleWrite('Deleting Default RDP' & @CRLF)
		FileDelete(@UserProfileDir & '\Documents\Default.rdp')
	EndIf

	Return SetError(0, 'RDP Connection Log clear sucessfully', True)
EndFunc

Func _ClearRecentLog()
	If FileExists(@AppDataDir & '\Microsoft\Windows\Recent') Then
		ConsoleWrite('Cleaning Recent Files' & @CRLF)
		FileDelete(@AppDataDir & '\Microsoft\Windows\Recent\*')

		If @Error Then Return SetError(1, 'Cannot Clear the Recent Files', False)
	EndIf

	Return SetError(0, 'RDP Connection Log clear sucessfully', True)
EndFunc
