SetCompress force
SetCompressor /SOLID /FINAL LZMA
ShowInstDetails show
ShowUninstDetails show

; Include Modern UI
	!include "MUI2.nsh"
	!include "WinVer.nsh"
	!include "x64.nsh"

; General

	Var DirectXSetupError
	Var VCPPSetupError
	Var vcppExe

	!define ENC_VERSION "0.1"
	!define PROG_NAME "FuzzyOctoLana"
	!define PROG_NAME_S "FuzzyOctoLana"
	!define PROG_LAUNCHER_F "${PROG_NAME_S}.exe"
	!define FILE_LOCATION "Files"
	!define PROG_BIT "32"
	!define PROG_LAUNCHER "FuzzyOctoLana\Binaries\Win${PROG_BIT}\FuzzyOctoLana.exe"

	; Name and file
	Name "${PROG_NAME}"
	OutFile "${PROG_NAME_S}-install-${PROG_BIT}.exe"

	; Default installation folder
	InstallDir "$PROGRAMFILES\${PROG_NAME_S}"

	; Get installation folder from registry if available
	InstallDirRegKey HKCU "Software\FuzzyOctoLana" ""
	
	InstallDirRegKey HKLM \
				  "Software\Microsoft\Windows\CurrentVersion\Uninstall\ZT${PROG_NAME_S}" \
				  "UninstallString"

	; The text to prompt the user to enter a directory
	DirText "This will install ${PROG_NAME} on your system"

	; Request application privileges for Windows 7
	RequestExecutionLevel admin
  
	; Installer Icon
	/*
	!define MUI_ICON "${PROG_NAME_S}.ico"
	Icon "${PROG_NAME_S}.ico"
	WindowIcon on
	*/
  
; --------------------------------
; Interface Settings

	!define MUI_ABORTWARNING

; --------------------------------
; Pages

	;!insertmacro MUI_PAGE_LICENSE "${NSISDIR}\Docs\Modern UI\License.txt"
	;!insertmacro MUI_PAGE_COMPONENTS
	!insertmacro MUI_PAGE_DIRECTORY
	!define MUI_INSTFILESPAGE_COLORS "FFFFFF 000000" ;Two colors
	!insertmacro MUI_PAGE_INSTFILES

	!insertmacro MUI_UNPAGE_CONFIRM
	!insertmacro MUI_UNPAGE_INSTFILES

	!define MUI_FINISHPAGE

	!define MUI_FINISHPAGE_SHOWREADME ""
	!define MUI_FINISHPAGE_SHOWREADME_TEXT "Create Desktop Shortcut"
	!define MUI_FINISHPAGE_SHOWREADME_FUNCTION createDesktopShortcut
	!define MUI_FINISHPAGE_NOREBOOTSUPPORT
	!define MUI_FINISHPAGE_TEXT_LARGE
	!define MUI_FINISHPAGE_TEXT "${PROG_NAME} is now being installed on your system.$\r$\n$\r$\nIf you would like a shortcut to be placed on your desktop for quicker access to the game, check the box below.$\r$\n$\r$\nFinally, click Close to exit this installer."

	!insertmacro MUI_PAGE_FINISH

	!insertmacro MUI_UNPAGE_CONFIRM
	!insertmacro MUI_UNPAGE_INSTFILES

; --------------------------------
; Languages
 
;	!insertmacro MUI_LANGUAGE "English"

; --------------------------------
; Installer Sections

Function .onInit
	Var /GLOBAL progbit
	StrCpy $progbit "${PROG_BIT}"

	ReadRegStr $R7 HKLM \
		"Software\Microsoft\Windows\CurrentVersion\Uninstall\ZT${PROG_NAME_S}" \
		"UninstallString"
	IfFileExists "$R7" initDone
	IfFileExists "$INSTDIR" initDone

	ReadRegStr $R8 HKLM \
		"SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" "Public"
	ExpandEnvStrings $R9 "$R8"

	${If} ${AtLeastWinVista}
		goto newWindows
	${Else}
		goto oldWindows
	${EndIf}
	newWindows:
		IfFileExists "$R9" dirExists dirCTest
		dirCTest:
		IfFileExists "C:\Users\Public" dirCExists doesntExist
		goto doesntExist
		dirCExists:
			StrCpy $INSTDIR "C:\Users\Public\Games\${PROG_NAME_S}"
			goto initDone
		dirExists:
			;MessageBox MB_OK|MB_ICONQUESTION "DirExists - regtest: $R8 - $R9" IDOK
			StrCpy $INSTDIR "$R9\Games\${PROG_NAME_S}"
			goto initDone
		doesntExist:
	oldWindows:
	initDone:

	;MessageBox MB_OK|MB_ICONQUESTION "$R0 - $INSTDIR" IDOK
FunctionEnd

Function createDesktopShortcut
	SetShellVarContext all
	createShortCut "$DESKTOP\${PROG_NAME}.lnk" "$INSTDIR\${PROG_LAUNCHER}"
FunctionEnd


; Install section
Section ""
	
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ZT${PROG_NAME_S}" \
                 "DisplayName" "${PROG_NAME}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ZT${PROG_NAME_S}" \
				"UninstallString" "$INSTDIR\uninstall.exe"

	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ZT${PROG_NAME_S}" \
				"InstallLocation" "$INSTDIR"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ZT${PROG_NAME_S}" \
				"URLInfoAbout" "http://miaw.zibings.net/"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ZT${PROG_NAME_S}" \
				"HelpLink" "http://miaw.zibings.net/"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ZT${PROG_NAME_S}" \
				"DisplayIcon" "$INSTDIR\${PROG_LAUNCHER},0"
;	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ZT${PROG_NAME_S}" \
;				"DisplayVersion" "${ENC_VERSION}"
	
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ZT${PROG_NAME_S}" \
				"NoModify" 0x00000001
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ZT${PROG_NAME_S}" \
				"NoRepair" 0x00000001
	
	; Set output path to the installation directory.
	SetOutPath $INSTDIR

	; Put files there
	;File "${FILE_LOCATION}\${PROG_LAUNCHER}"
	;File "${FILE_LOCATION}\UpdateLibrary.dll"
	
	;File "${FILE_LOCATION}\Manifest_NonUFSFiles.txt"
	;File "${FILE_LOCATION}\UE4CommandLine.txt"

; Exclude x-bit files
	;File /r /x Win32 "${FILE_LOCATION}\*"
	File /r /x Win64 "${FILE_LOCATION}\*"

	writeUninstaller "$INSTDIR\uninstall.exe"

	SetShellVarContext all
	CreateDirectory "$SMPROGRAMS\${PROG_NAME_S}"
	createShortCut "$SMPROGRAMS\${PROG_NAME_S}\${PROG_NAME}.lnk" "$INSTDIR\${PROG_LAUNCHER}"
	createShortCut "$SMPROGRAMS\${PROG_NAME_S}\Uninstall ${PROG_NAME}.lnk" "$INSTDIR\uninstall.exe"
SectionEnd ; end the section


# uninstaller section start
section "uninstall"
	
;	MessageBox MB_YESNO "Are you sure you want to uninstall ${PROG_NAME}?" IDYES unContinue
;	DetailPrint "Uninstall canceled."
;	Goto done
	
	unContinue:
	# first, delete the uninstaller
	delete "$INSTDIR\uninstall.exe"

	SetShellVarContext all
	# remove desktop shortcut
	delete "$DESKTOP\${PROG_NAME}.lnk"

	SetShellVarContext all
	# remove the link from the start menu
	RMDir /r "$SMPROGRAMS\${PROG_NAME_S}"

	ReadRegStr $R0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ZT${PROG_NAME_S}" \
	"InstallLocation"
	StrCmp $R0 "" done
	# delete files
	delete "$R0\${PROG_LAUNCHER}"
	
	delete "$R0\Manifest_NonUFSFiles.txt"
	delete "$R0\UE4CommandLine.txt"
	
	RMDir /r /REBOOTOK "$R0\FuzzyOctoLana\"
	RMDir /r /REBOOTOK "$R0\Engine\"

	#delete directory
	RMDir "$R0"

	# delete registry keys
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ZT${PROG_NAME_S}"
	done:
# uninstaller section end
sectionEnd


; VC++
Section "VC++ Install" SEC_VCPP

	SectionIn RO

	SetOutPath "$TEMP"

	DetailPrint "Checking for Visual C++ Installation..."

	${If} ${RunningX64}
		ReadRegStr $1 HKLM "SOFTWARE\Microsoft\VisualStudio\12.0\VC\Runtimes\x64" "Installed"
		StrCmp $1 1 cppAInstalled cppInstallNew
	${Else}
		ReadRegStr $1 HKLM "SOFTWARE\Microsoft\VisualStudio\12.0\VC\Runtimes\x86" "Installed"
		StrCmp $1 1 cppAInstalled cppInstallOld
	${EndIf}

	;not installed, so run the installer
	cppInstallNew:
		StrCpy $vcppExe "vcredist_x64.exe"
		goto cppInstalling

	cppInstallOld:
		StrCpy $vcppExe "vcredist_x86.exe"
		goto cppInstalling
	
	cppInstalling:
		File "vcredist_x64.exe"
		File "vcredist_x86.exe"
		DetailPrint "Running Visual C++ Setup..."
		ExecWait '"$TEMP\$vcppExe" /passive /norestart' $VCPPSetupError

		goto cppInstalled

	cppAInstalled:
		DetailPrint "Visual C++ Already installed"

	cppInstalled:
	DetailPrint "Finished Visual C++ Setup"

	Delete "$TEMP\vcredist_x64.exe"
	Delete "$TEMP\vcredist_x64.exe"

	SetOutPath "$INSTDIR"
 
SectionEnd

; DX section
Section "DirectX Install" SEC_DIRECTX
 
	SectionIn RO

	SetOutPath "$TEMP"
	File "dxwebsetup.exe"
	DetailPrint "Running DirectX Setup..."
	ExecWait '"$TEMP\dxwebsetup.exe" /Q' $DirectXSetupError
	DetailPrint "Finished DirectX Setup"

	Delete "$TEMP\dxwebsetup.exe"

	SetOutPath "$INSTDIR"
 
SectionEnd
