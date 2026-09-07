[Setup]
AppId={{5D4E12C8-1B90-413A-9EBA-ABCD12345678}
AppName=Clod
AppVersion={#MyAppVersion}
AppPublisher=Clod Team
AppPublisherURL=https://example.com/
AppSupportURL=https://example.com/
AppUpdatesURL=https://example.com/
DefaultDirName={autopf}\Clod
DisableProgramGroupPage=yes
OutputBaseFilename=clod_installer
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\..\build\windows\x64\runner\Release\clod.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{autoprograms}\Clod"; Filename: "{app}\clod.exe"
Name: "{autodesktop}\Clod"; Filename: "{app}\clod.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\clod.exe"; Description: "{cm:LaunchProgram,Clod}"; Flags: nowait postinstall skipifsilent
