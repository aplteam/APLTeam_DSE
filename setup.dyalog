:Namespace SetItUp
⍝ This script needs to go into:
⍝ %USERPROFILE%\Documents\MyUCMDs  (Windows)
⍝ $HOME/MyUCMDs   (UNIX flavours: Mac, Linux,...)

    ∇ {r}←Setup arg;⎕IO;⎕ML;wspath;rf;parms;⎕TRAP;defaultPath;dmx;path;debug;version;aplversion
      r←⍬
      ⎕IO←1 ⋄ ⎕ML←1	 
      {}2 ⎕NQ'.' 'setdflags' 130 ⍝ Run always with all debug flags on (except the step-by-step one of course)
      ⎕SE.⎕EX'CiderTatin'
      :If IfAtLeastVersion 18.1
          ⍝ The following was caused by the fact that my WTUTOR would not be loaded into the Classic version
          ⍝ even after deleting everything in the WS. Can be removed one day.
          ⎕SE.Constants←(11005⌶⍬)~'Dyalog'(⊂'')(⊂⍬)⎕AN''⍬' ',(¯129+⍳256),⎕A ⎕D ⎕NULL,9053,¯129,256,(0 1 2)+⊂,0
      :EndIf
          ⍝ -exec_setup=0 is passed as command line parameter by Launchy in case the user un-ticked "Execute setup.dyalog"
          ⍝ For details regarding Launchy see https://github.com/aplteam/Launchy
      :If ~GetCommandLineParm'-exec_setup=0'
          :If debug←GetCommandLineParm'-stop_in_setup=1'
              ⎕TRAP←0 'S'
              ∘∘∘  ⍝ Deliberate crash because flag stop_in_setup was found (Launchy)
          :EndIf
          path←GetProgramFilesFolder'/SessionExtensions/CiderTatin/'
          :If 0=⎕NEXISTS path
          :AndIf 0=⎕NEXISTS path←0 GetProgramFilesFolder'/SessionExtensions/CiderTatin/'
              path←'' ⍝ Neither Tatin nor Cider are available for versions prior to 19.0
          :EndIf
          aplversion←⊃(//)⎕VFI{⍵↑⍨¯1+⍵⍳'.'}2⊃# ⎕WG'APLVersion'
          :Trap (debug∨⎕SE.SALTUtils.DEBUG)↓0
              parms←2 ⎕NQ'#' 'GetCommandLineArgs'
              :If debug
              :AndIf 0
                  2 ⎕NQ'⎕se' 'CloseSessionItem' 'Debugger'
                  2 ⎕NQ'⎕se' 'CloseSessionItem' 'Editor'
              :EndIf
              :If 0<≢path
                  :If path AutoLoadTatin debug
                      ⎕←AddPathToCmdDir path
                  :EndIf
                  ⎕←path AutoLoadCider debug
              :EndIf
              path←GetMyUCMDsFolder'/'
              wspath←path,'APLTeam/aplteam18.dws'
              :If IfAtLeastVersion 18
              :AndIf 80=⎕DR' '  ⍝ Not in "Classic"
                  :If ~⎕NEXISTS path,'APLTeam'
                  :OrIf ~⎕NEXISTS path,'APLTeam/aplteam18.dws'
                  :OrIf ~⎕NEXISTS path,'APLTeam/packages'
                      'APLTeam/ in the MyUCMDS folder does not exist, or does not have the expected contents (WS, Tatin packages)'⎕SIGNAL 11
                  :EndIf
                  :If 0<⎕SE.⎕NC'Tatin'
                      {}⎕SE.Tatin.LoadDependencies(path,'APLTeam/packages')'⎕SE'
                  :EndIf
                  ⎕←path LoadUserCommandPackages debug
              :Else
                  :If ~⎕NEXISTS path,'APLTeam'
                  :OrIf ~⎕NEXISTS path,'APLTeam/aplteam.dws'
                  :OrIf ~⎕NEXISTS path,'APLTeam/scripts'
                      'APLTeam/ in the MyUCMDS folder does not exist, or does not have the expected contents'⎕SIGNAL 11
                  :EndIf
                  LoadScriptsFrom path,'APLTeam/scripts/'
                  2 ⎕SE.⎕FIX⊃⎕NGET(path,'APLTeam/scripts/APLTreeUtils2.aplc')1 ⍝ Because DSE itself uses APLTreeUtils2
                  {}5178⌶⎕SE.APLTreeUtils2
                  wspath←path,'APLTeam/aplteam.dws'
              :EndIf
              :If 80=⎕DR' '
                  :Trap 0
                      'aplteam'⎕SE.⎕CY wspath
                      {}⎕SE.aplteam.StartUp 1
                  :Else
                      ⎕←'APLTeam-specific amendments failed with ',⎕DMX.EM
                  :EndTrap
              :EndIf
              :If ~IfAtLeastVersion 19
                  {}⎕SE.SALTUtils.ResetUCMDcache -1                 
              :EndIf
			  ⎕se.Link.NOTIFY←1
              {}2704⌶1   ⍝ Enable automatic saving of CONTINUE workspaces
              ⎕SIGNAL 0  ⍝ Reset ⎕DMX and ⎕EN
              ⎕SE.UCMD'Tools.Version'
          :Else
              dmx←⎕DMX
              ⎕←'Setup.dyalog has a problem and was not executed successfully:'
              ⎕←↑'  '∘,¨dmx.DM
          :EndTrap
      :EndIf
     
      :If IfAtLeastVersion 18.2
      :AndIf 0=+/'lx='∘≡¨3↑¨⊢2 ⎕NQ #'GetCommandLineArgs'
      :AndIf 0=≢≡⎕LX
      :AndIf 1 YesOrNo'Disable traps that would catch AFFIRM errors? (600⌶)'
          {}(600⌶)4   ⍝ 4=disable AFFIRM errors (see Joplin for details)
      :EndIf
    ∇

    ∇ r←path AutoLoadTatin debug;wspath;path2Config;version
      r←0
      →(0<⎕SE.⎕NC'Tatin')/0
      :Trap debug/0
          version←⊃(//)⎕VFI{⍵↑⍨¯1+⍵⍳'.'}2⊃# ⎕WG'APLVersion'
          :If version<18
              ⎕←'Tatin not loaded, only supported in Dyalog 18.2 and later'
          :ElseIf 9=⎕SE.⎕NC'Tatin'
              ⍝ Aready loaded (19.0)
          :ElseIf 80≠⎕DR' '              ⍝ Not in "Classic"
              ⎕←'Tatin not loaded: not compatible with Classic'
          :Else
              wspath←path,'/Tatin/Client.dws'
              :If ⎕NEXISTS wspath
                  ⎕SE.⎕EX¨'_Tatin' 'Tatin'
                  '_Tatin'⎕SE.⎕CY wspath
                  path2Config←⊃⎕NPARTS ⎕SE._Tatin.Client.FindUserSettings ⎕AN
                  'Create!'⎕SE._Tatin.Client.F.CheckPath path2Config
                  'Tatin'⎕SE.⎕NS''
                  path2Config ⎕SE._Tatin.Admin.EstablishClientInQuadSE ⍬
                  r←1
              :EndIf
          :EndIf
      :Else
          ⎕←'>>> Attempt to load Tatin failed with ',⎕DMX.EM
      :EndTrap
    ∇

    ∇ {r}←path AutoLoadCider debug;version;res;sep;paths;qdmx
      r←0 0⍴''
      →(0<⎕SE.⎕NC'Cider')/0
      :Trap debug/0
          version←⊃(//)⎕VFI{⍵↑⍨¯1+⍵⍳'.'}2⊃# ⎕WG'APLVersion'
          :If version<18
              r←'Cider not loaded, only supported in Dyalog 18.2 and later'
          :ElseIf 9=⎕SE.⎕NC'Cider'
              ⍝ Already loaded (19.0)
          :ElseIf 80≠⎕DR' '              ⍝ Not in "Classic"
              r←'Cider not loaded: not compatible with Classic'
          :Else
              ⎕SE.⎕EX¨'_Cider' 'Cider'    ⍝ Paranoia
              :If 0=⎕SE.⎕NC'Tatin'
                  r←'Cannot load Cider, Tatin is not available' ⋄ →0
              :EndIf
              :If ⎕NEXISTS path,'Cider/'
                  {}⎕SE.Tatin.LoadDependencies(path,'Cider/')'⎕SE'
              :EndIf
          :EndIf
      :Else
          r←'>>> Attempt to load Cider failed with ',⎕DMX.EM
      :EndTrap
    ∇

    ∇ r←AddPathToCmdDir path;res;sep;paths;qdmx
      r←0 0⍴''
      :Trap 0
          :If 'Win'≡3↑1⊃# ⎕WG'APLVersion'
              path←{'\'@(⍸'/'=⍵)⊣⍵}path
              res←{'\'@(⍸'/'=⍵)⊣⍵}⎕SE.SALT.Settings'cmddir'
              sep←';'
              paths←sep(≠⊆⊢)res
          :Else
              path←{'/'@(⍸'\'=⍵)⊣⍵}path
              res←{'/'@(⍸'\'=⍵)⊣⍵}⎕SE.SALT.Settings'cmddir'
              sep←':'
              paths←sep(≠⊆⊢)res
          :EndIf
          path←¯1↓1⊃⎕NPARTS{⍵↓⍨-'\/'∊⍨¯1↑⍵}path
          :If ~(⊂path)∊paths ⍝ Already known?
              {}⎕SE.SALT.Settings'cmddir ,',path,' -permanent'
          :EndIf
      :Else
          qdmx←⎕DMX
          ⎕←'Attempt to add <',path,' to the search paths for user commands failed (',qdmx.EM,', RC=',(⍕qdmx.EN),')' ⋄ →0
      :EndTrap
    ∇

    ∇ r←path LoadUserCommandPackages debug;name;folders;folder;F
    ⍝ This loads Tatin packages installed in <path> into ⎕SE
      r←0 0⍴''
      :If 0<⎕SE.⎕NC'_Tatin'
          F←⎕SE._Tatin.FilesAndDirs
      :AndIf 0<≢folders←F.ListDirs path
          :For folder :In folders
              :If F.IsFile folder,'/apl-buildlist.json'
                  name←2⊃⎕NPARTS folder
                  :Trap (~debug)/0
                      {}⎕SE.Tatin.LoadDependencies folder ⎕SE
                  :Else
                      r,←⊂'>>> Attempt to load ',name,' failed with ',⎕DMX.EM
                  :EndTrap
              :EndIf
          :EndFor
      :EndIf
      :If 0≠≢r
          r←⍪r
      :EndIf
    ∇

    ∇ okay←IfAtLeastLinkVersion min;major;minor;minor2
      ⍝ ⍵ is supposed to be a number like 1 or 20.30, representing a version of Link.
      ⍝ Returns a Boolean that is 1 only if the current version is at least as good.
      okay←0
      :If 9=⎕SE.⎕NC'Link'
      :AndIf 3=⎕SE.Link.⎕NC'Version'
          (major minor)←{⊃⊃(//)⎕VFI ⍵}¨2↑{'.'(≠⊆⊢)⍵}{⍵↑⍨¯1+⍵⍳'-'}⎕SE.Link.Version
          :If ~okay←min≤major
          :AndIf okay←major=⌊min
              :If 0<minor2←min-⌊min
                  okay←minor≥⍎2↓⍕minor2
              :Else
                  okay←minor≤⍎{2↓⍕⍵-⌊⍵}min
              :EndIf
          :EndIf
      :EndIf
    ∇

      IfAtLeastVersion←{
      ⍝ ⍵ is supposed to be a number like 15 or 17.1, representing a version of Dyalog APL.
      ⍝ Returns a Boolean that is 1 only if the current version is at least as good.
          ⍵≤{⊃(//)⎕VFI ⍵/⍨2>+\'.'=⍵}2⊃# ⎕WG'APLVersion'
      }


    ∇ r←{default}GetCommandLineParm string;args;buff
    ⍝ Expects either a flag (like -foo) or a numeric setting (like -foo=1 or foo=1)
    ⍝ Note that this function does not treat -foo the same as -foo=1
    ⍝ In case you specify foo= with whatever value but you search for a "-" then it's
    ⍝ not a match, and a 0 is returned.
      default←{0<⎕NC ⍵:⍎⍵ ⋄ 0}'default'
      args←2 ⎕NQ #'GetCommandLineArgs'
      :If 0=≢buff←∊string{⍵/⍨⍺∘{⍺≡(⍴⍺)↑⍵}¨⍵}args
          r←default
      :Else
          r←0
          :If '='∊buff
              →(~'='∊string)/0
              buff←{⍵↓⍨⍵⍳'='}buff
          :Else
              →(r←~'='∊string)/0
              buff←(≢string)↓buff
          :EndIf
          :If (,'0')≡,buff
          :OrIf '-'=1⍴buff
              r←1
          :Else
              r←⊃(//)⎕VFI buff
          :EndIf
      :EndIf
    ∇

    Assert←{⍺←'' ⋄ (,1)≡,⍵:r←1 ⋄ ⎕ML←3 ⋄ ⍺ ⎕SIGNAL 1↓(↑∊⍵),11}

    ∇ r←{OS}GetMyUCMDsFolder add
    ⍝ Returns standard path for Dyalog's MyUCMDs\ folder.
    ⍝ Works on all platforms but returns different results.\\
    ⍝ Under Windows typically:\\
    ⍝ `C:\Users\{⎕AN}\Documents\MyUCMDs'  ←→ GetMyUCMDsFolder ''
    ⍝ `C:\Users\{⎕AN}\Documents\MyUCMDs\aaa'  ←→ GetMyUCMDsFolder 'aaa'
    ⍝ ⍺ is optional and only specified by test cases: simulating different versions of the operating system.
      :If 0=⎕NC'OS'
          OS←3↑⊃'.'⎕WG'APLVersion'
      :EndIf
      add←{(((~'/\'∊⍨⊃⍵)∧0≠≢⍵)/'/'),⍵}add
      :If 'Win'≡OS
          r←⊃,/1 ⎕NPARTS(2⊃4070⌶0),'\..\MyUCMDs',add
      :Else
          r←(2 ⎕NQ'.' 'GetEnvironment' 'Home'),'/MyUCMDs',add
      :EndIf
    ∇

    ∇ {refs}←LoadScriptsFrom path;script;scripts;body;ref
      refs←⍬
      scripts←⊃⎕NINFO⍠('Wildcard' 1)⊣path,'*'
      scripts←(({⊃¯1↑⎕NPARTS ⍵}¨scripts)∊'.apln' '.aplc' '.dyalog')/scripts
      :For script :In scripts
          body←⊃⎕NGET script 1
          ref←⎕SE.⎕FIX body
          Assert' '=1↑0⍴⍕ref
          refs,←ref
      :EndFor
    ∇

    ∇ yesOrNo←{default}YesOrNo question;isOkay;answer;add;dtb;answer2;bool;flag;buff;alias;LC
 ⍝ Asks a simple question and allows just "Y" (or "y") or "N" (or "n") as answers.\\
 ⍝ The question may be a simple character vector, possibly with `⎕UCS 10` in between,
 ⍝ or a vector of simple character vectors.\\
 ⍝ You may specify a default via the optional left argument which when specified
 ⍝ rules what happens when the user just presses <enter>.
 ⍝ `default` must be either 1 (yes) or 0 (no).\\
 ⍝ By entering "`∘∘∘`" the user may interrupt `YesOrNo`: this activates a stop.\\
 ⍝ Note that this function does **not** work as intended when traced!
      LF←⎕UCS 10
      isOkay←0
      default←{0<⎕NC ⍵:⍎⍵ ⋄ ''}'default'
      isOkay←0
      question←⊃LF{⍺,⍺⍺,⍵}/⊆question
      question←{LF@(⍸⍵=⎕UCS 13)⊣⍵}question
      :If 0≠≢default
          'Left argument must be a scalar'⎕SIGNAL 11/⍨1≠≢default
      :AndIf ~default∊0 1
          'The left argument. if specified, must be a Boolean or empty'⎕SIGNAL 11
      :EndIf
      flag←1
      :If 0<⎕NC'YesOrNo_Answers'
          YesOrNo_Answers←(0<≢¨' '~⍨¨YesOrNo_Answers[;1])⌿YesOrNo_Answers
      :AndIf 0<≢YesOrNo_Answers
          :If '@'∊question
              (alias question)←{l←⍵⍳'@' ⋄ (l↑⍵)(l↓⍵)}question
              flag←0<+/bool←({⍵↑⍨⍵⍳'@'}¨YesOrNo_Answers[;1])≡¨⊂alias
          :ElseIf ~flag←0<+/bool←YesOrNo_Answers[;1]≡¨⊂question
          :AndIf ~flag←0<+/bool←question∘{⍵≡(≢⍵)↑⍺}¨YesOrNo_Answers[;1]
          :AndIf LF∊question
              buff←{⍵↓⍨+/∧\' '=⍵}⊃¯1↑LF(≠⊆⊢)question
              flag←0<+/bool←YesOrNo_Answers[;1]≡¨⊂buff
          :EndIf
          :If flag
              'Multiple pre-prepared answers qualify?!'Assert 1=+/bool
              answer←2⊃YesOrNo_Answers[bool⍳1;]
              :If 0=≢answer
                  yesOrNo←default
              :Else
                  ('Invalid answer: ',answer)Assert answer∊'YyNn'
                  yesOrNo←answer∊'Yy'
              :EndIf
          :EndIf
      :Else
          flag←0
      :EndIf
      :If ~flag
          :If 0=≢default
              add←' (y/n) '
          :Else
              :If default
                  add←' (Y/n) '
              :Else
                  add←' (y/N) '
              :EndIf
          :EndIf
          :If 1<≡question
              question←1↓⊃,/(⎕UCS 10),¨question
          :EndIf
          question←question,add
          :Repeat
              ⎕←''
              ⍞←question
              answer←⍞
              :If answer≡question ⍝ Did ...  (since version 18.0 trailing blanks are not removed anymore)
              :OrIf (≢answer)=¯1+≢question ⍝ ... the ...
              :OrIf 0=≢answer ⍝ ... user ...
              :OrIf question≡(-≢question)↑answer ⍝ ... just ...
                  dtb←{⍵↓⍨-+/∧\' '=⌽⍵}
                  answer2←dtb answer
              :OrIf answer2≡((-≢answer2)↑(⎕UCS 10){~⍺∊⍵:⍵ ⋄ ' ',dtb ⍺{⌽⍵↑⍨1+⍵⍳⍺}⌽⍵}question) ⍝ ... press ...
              :OrIf answer≡{1↓⊃¯1↑(⍵∊⎕UCS 10 13)⊂⍵}(⎕UCS 10),question ⍝ ... <enter>?
                  :If 0≠≢default
                      yesOrNo←default
                      isOkay←1
                  :EndIf
              :Else
                  :If '∘∘∘'≡¯3↑answer
                      (1+⊃⎕LC)⎕STOP⊃⎕SI
                      ∘∘∘ ⍝ Deliberate stop caused by user input
                  :EndIf
                  answer←¯1↑{⍵↓⍨-+/∧\' '=⌽⍵}answer
                  :If answer∊'YyNn'
                      isOkay←1
                      yesOrNo←answer∊'Yy'
                  :EndIf
              :EndIf
          :Until isOkay
      :EndIf
    ⍝Done
    ∇

    ∇ r←{versionSpecific}GetProgramFilesFolder postFix;version;aplVersion;OS
⍝ Returns standard path for Dyalog's version-specific program files folder.\\
⍝ Works on all platforms but returns different results.\\
⍝ Under Windows typically:\\
⍝ `C:\Users\<⎕AN>\Documents\Dyalog APL[-64] 19.0 Unicode Files' ←→ GetMyUCMDsFolder
⍝ ⍺ is optional and defaults to 0, meaning the version-agnostic folder is returned.
⍝ If versionSpecific←1 then the folder associated with the currently running version of Dyalog is returned.
      versionSpecific←{0<⎕NC ⍵:⍎⍵ ⋄ 1}'versionSpecific'
      OS←3↑1⊃# ⎕WG'APLVersion'
      postFix←{(((~'/\'∊⍨⊃⍵)∧0≠≢⍵)/'/'),⍵}postFix
      aplVersion←# ⎕WG'APLVersion'
      :If versionSpecific
          :If OS≡'Win'
              r←(2⊃4070⌶0),postFix
          :Else
              version←({'.'~⍨⍵/⍨2>+\⍵='.'}2⊃aplVersion),((80=⎕DR' ')/'U'),((1+∨/'-64'⍷1⊃aplVersion)⊃'32' '64')
              r←(⊃⎕SH'echo $HOME'),'/.dyalog/dyalog.',version,'.files',postFix
          :EndIf
      :Else
          :If OS≡'Win'
              r←(2 ⎕NQ #'GetEnvironment' 'USERPROFILE'),'\Documents\Dyalog APL Files',postFix
          :Else
              r←(⊃⎕SH'echo $HOME'),'/.dyalog/dyalog.files',postFix
          :EndIf
      :EndIf
    ∇

:EndNamespace