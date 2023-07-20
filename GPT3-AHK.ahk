; AutoHotkey script that enables you to use GPT3 in any input field on your computer

; -- Configuration --
#SingleInstance  ; Allow only one instance of this script to be running.
; This is the hotkey used
MY_HOTKEY := "!LButton"  ; Ctrl+Shift+G
MODEL_ID := "gpt-3.5-turbo" 
MODEL_MAX_TOKENS := 200
MODEL_TEMP:= 0.7
INI_SETTINGS := "settings.ini"
INI_AGENTS := "agents.ini"

; -- Initialization --
; Dependencies
; WinHttpRequest: https://www.reddit.com/comments/mcjj4sinput
; cJson.ahk: https://github.com/G33kDude/cJson.ahk
#Include <Json>
http := WinHttpRequest()

I_Icon = GPT3-AHK.ico
IfExist, %I_Icon%
Menu, Tray, Icon, %I_Icon%

Gosub GetData

Hotkey, %MY_HOTKEY%, DrawMenu
OnExit("ExitFunc")
Return

; -- Main commands --
RunGPTAgent: 
   body := {}   
   body.messages := []
AgainGPTAgent:  
   myDefault := StrReplace(Clipboard, "`n", " ")
   myInputPrompt = Enter Chat GPT instruction 
   InputBox, UserInput , %MY_AGENT%, %myInputPrompt%, ,500 ,150 , , , , , "%myDefault%"
   if ErrorLevel
     {
	 return
	 }
   userMsgContent = %UserInput%
   url := "https://api.openai.com/v1/chat/completions"
   body.model := MODEL_ID ; ID of the model to use.   
   ; Construct the messages manually
   systemMsg := {}
   systemMsg.role := "system"
   systemMsg.content := MY_SYSTEM_MESSAGE   
   userMsg := {}
   userMsg.role := "user"
   userMsg.content := userMsgContent   
   ; Create a blank array and push the messages into it
   body.messages.Push(systemMsg)
   body.messages.Push(userMsg)
   body.max_tokens := MODEL_MAX_TOKENS ; The maximum number of tokens to generate in the completion.
   body.temperature := MY_TEMPERATURE + 0 ; Sampling temperature to use 
   headers := {"Content-Type": "application/json", "Authorization": "Bearer " . API_KEY}
   SetSystemCursor()
   response := http.POST(url, JSON.Dump(body), headers, {Object:true, Encoding:"UTF-8"})
   obj := JSON.Load(response.Text)
   NewContent := obj.choices[1].message.content   
   RestoreCursors()   
   Msgbox, 6, Response from: %MY_AGENT%, %NewContent%`n`n---------------------------------`n`nReponse copied to clipboard!`n`n- Press "Continue" to auto paste the response`n`n- Press "Cancel" to leave and paste the response yourself`n`n- Press "Try Again" to ask GPT again (Your history is remembered)
   Clipboard := NewContent ; Set clipboard content to the new text
   IfMsgBox TryAgain
     {	 
     assistantMsg := {}
     assistantMsg.role := "assistant"
     assistantMsg.content := NewContent   
     body.messages.Push(assistantMsg)
	 GoTo AgainGPTAgent
	 }
   IfMsgBox Continue
     Send, ^v ; Paste the new content to where the cursor is   
   Return

; -- Auxiliar functions --
; Copies the selected text to a variable while preserving the clipboard.

; Change system cursor 
SetSystemCursor()
{
   Cursor = %A_ScriptDir%\GPT3-AHK.ani
   CursorHandle := DllCall( "LoadCursorFromFile", Str,Cursor )

   Cursors = 32512,32513,32514,32515,32516,32640,32641,32642,32643,32644,32645,32646,32648,32649,32650,32651
   Loop, Parse, Cursors, `,
   {
      DllCall( "SetSystemCursor", Uint,CursorHandle, Int,A_Loopfield )
   }
}

RestoreCursors() 
{
   DllCall( "SystemParametersInfo", UInt, 0x57, UInt,0, UInt,0, UInt,0 )
}

ExitFunc(ExitReason, ExitCode)
{
    if ExitReason not in Logoff,Shutdown
    {
        RestoreCursors()
    }
}

GetItemClicked(myTitle)                                    ;function to return an index number of the option clicked - can be used if we have multiple windows later
{
  IfWinNotActive, %myTitle%
  {
      ToolTip
      Return 0                                             ;return 0 if we clicked elsewhere
  }
  MouseGetPos, mX, mY
  ToolTip
  mY -= 4                                                  ;space after which first line starts
  mY /= 15                                                 ;space taken by each line - this is a bit broken, it will need to be tweaked for different peoples computers
  return mY
}

MenuClick:                                                 ;routine that runs a path the user selected
	HotKey, ~LButton, Off
	ItemIndex:=GetItemClicked(Title)
	IfLess, ItemIndex, 1, Return		                       ;quit if we clicked the title
	IfLess, ListLength,%ItemIndex% , Return            ;quit if we clicked off the botom
	MY_TEMPERATURE:=AGENT_TEMPERATURE%ItemIndex%
	MY_SYSTEM_MESSAGE:=AGENT_SYSTEM_MESSAGE%ItemIndex%
	MY_AGENT:=AGENT_NAME%ItemIndex%
	Gosub RunGPTAgent
return

DrawMenu:                                                  ;draw the gui - more shit to go here later
  Title:= "-=-=Select GPT Agent=-=-"
  Menu=%Title%
  Count:=1
  
  Loop %ListLength%
  {
    StringTrimLeft, MenuText, AGENT_NAME%Count%, 0              ;Autohotkey doesnt have arrays, this is a method of reading an array element to another variable
    Menu = %Menu%`n%MenuText%
    Count+=1  
  }
  MouseGetPos, Origin_X, Origin_Y
  Origin_X-=40
  Origin_Y-=25
  ToolTip, %Menu%, %Origin_X%, %Origin_Y%
  WinActivate, %Title%
  
  HotKey, ~LButton, MenuClick                              ;bind the left click to MenuClick routine
  HotKey, ~LButton, On
return

GetData:                                                   ;routine to read the menu ini file for data. N.B.Autohotkey is bad at handling arrays
	IfNotExist, %INI_SETTINGS%     
	{
		InputBox, API_KEY, Please insert your OpenAI API key, API key, , 270, 145
		IniWrite, %API_KEY%, %INI_SETTINGS%, OpenAI, API_Key
		IniWrite, %MY_HOTKEY%, %INI_SETTINGS%, Hotkeys , Hotkey 
		text := ";==HOTKEY=PREFIXES==`n;  ~ -When the hotkey fires, its key's native function will not be blocked(always put first)`n;  # -Windows key`n;  ! -Alt `n;  ^ -Control `n;  + -Shift `n;====OTHER=KEYS=====`n;  RButton,LButton,Mbutton,WheelDown,WheelUp,Tab,Numlock,Capslock,Scrolllock,Numpad0,Numpad1...F1,F2...,`n;====COMBINATIONS====`n;  & -used to combine keys e.g. +Tab&WheelDown = pressing shift,tab,and wheel down opens menu;;`n; See http://www.autohotkey.com/docs/KeyList.htm for full list"
		FileAppend, `n%text%, %INI_SETTINGS%
	} 
	Else
	{
	  IniRead, API_KEY, %INI_SETTINGS%, OpenAI, API_Key  
	  IniRead, MY_HOTKEY, %INI_SETTINGS%, Hotkeys , Hotkey 
	}

	IfNotExist, %INI_AGENTS%  
	{
	  msgbox no agents ini file!`n`n%INI_AGENTS%  will now be created
	  text := "[Agents]`nListLength=4`n`nName1=Excel`nSystemMsg1=Help the user with their excel request. It is important you must return ONLY an excel formula. Do not include any additional text before or after the formula. No explanation, hints or preamble to the formula.`nTemperature1=0`n`nName2=Creative response`nSystemMsg2=you are a helpfull assistant you will answer the task as best possible. Answer only the task, do not elaborate.`nTemperature2=0.9`n`nName3=Balanced response`nSystemMsg3=you are a helpfull assistant you will answer the task as best possible. Answer only the task, do not elaborate.`nTemperature3=0.6`n`nName4=Precise response`nSystemMsg4=you are a helpfull assistant you will answer the task as best possible. Answer only the task, do not elaborate.`nTemperature4=0.1"
	  FileAppend, %text%, %INI_AGENTS%
	}
	IniRead, ListLength, %INI_AGENTS%, Agents , ListLength

	Count:=0
	Loop %ListLength%
	{
		Count+=1 
		IniRead, AGENT_NAME%Count%, %INI_AGENTS%, Agents , Name%Count%         		;read the ini data to AGENT_NAME{i}
		IniRead, AGENT_SYSTEM_MESSAGE%Count%, %INI_AGENTS%, Agents , SystemMsg%Count%
		IniRead, AGENT_TEMPERATURE%Count%, %INI_AGENTS%, Agents , Temperature%Count%
	} 
return