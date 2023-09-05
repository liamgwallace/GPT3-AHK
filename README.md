# OpenAI_AHK_quick_chat

OpenAI_AHK_quick_chat is an AutoHotkey (AHK) script that integrates GPT-3 AI from OpenAI for any input field on your computer. It's a simple tool to send queries to the GPT-3 model and get responses in your clipboard.

I have only tested with Windows!! feedback is welcome

## Installation

1. Install AutoHotkey from [here](https://www.autohotkey.com/).
2. Clone or download this repository and unzip the file.
3. Double-click the 'GPT3-AHK.ahk' file.
4. Generate an OpenAI API key following [this instruction](https://help.openai.com/en/articles/4936850-where-do-i-find-my-secret-api-key)
5. When prompted, input your OpenAI API key. The script will not function without an API key.

## Usage

1. The default shortcut to invoke the script is `Alt + Left Click`.
2. Once invoked, your clipboard contents will be filled into the text box.
3. Select an agent and write your message, then press `OK`. 
    - Choose `Try Again` to continue the conversation - previous messages are 'remembered'.
    - Select `Cancel` to close the dialogue window - AI response is in your clipboard.
    - Select `Continue` to close the dialogue window - AI response is in your clipboard and auto pasted .
   
To change your API key or modify the shortcut key, edit the 'settings.ini' file with a text editor.

To create or modify agents, edit the 'agents.ini' file. When adding a new agent:
- Assign a unique number to 'Name', 'SystemMsg', and 'Temperature' values.
- Update the 'ListLength' value to equal the number of agents
  (this is a bit of a janky workaround, sorry)

To exit or reload the script after making changes, look for the robot icon in your system tray.

## File structure

The main script is `GPT3-AHK.ahk`. Here are the key parts of the script:

- `#SingleInstance`: This line ensures that only one instance of the script is running at a time.
- `MODEL_ID`, `MODEL_MAX_TOKENS`, `MODEL_TEMP`: These variables define the model to be used, the maximum tokens generated in the response, and the sampling temperature respectively.
- `MY_HOTKEY`: This variable sets the shortcut key for the script.
- `http := WinHttpRequest()`: This line initializes an HTTP request.
- `RunGPTAgent` and `AgainGPTAgent`: These are the main commands that handle the interaction with the GPT-3 model.
- `SetSystemCursor` and `RestoreCursors`: These functions manage the system cursor during the script's operation.

## Dependencies

The script uses the following dependencies:

- `WinHttpRequest`: An HTTP request module. Learn more [here](https://www.reddit.com/comments/mcjj4s/input).
- `cJson.ahk`: A JSON library for AutoHotkey. Access it [here](https://github.com/G33kDude/cJson.ahk).

## Notes

This project was modified by [liamgwallace](https://github.com/liamgwallace) from [GPT3-AHK](https://github.com/htadashi/GPT3-AHK) originaly by [htadashi](https://github.com/htadashi). It is available [here](https://github.com/liamgwallace/GPT3-AHK). Please review the code and contribute if you wish.
