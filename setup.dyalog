:Namespace SetItUp
⍝ This script needs to go into either:
⍝ %USERPROFILE%\Documents\MyUCMDs  (Windows)
⍝ $HOME/MyUCMDs   (UNIX flavours: Mac, Linux,...)
⍝ or (since version 16.0) one of the SALT work folders.

⍝ * 3.1.0 - 2021-02-25
⍝   * Couple of improvements
⍝ * 3.0.0 - 2020-11-29
⍝    * Depending on the version of Dyalog (18.0 or better versus old stuff) we now load new (Tatin-compatible)
⍝      or old scripts. Also, in versions prior to 18.0 APLGit is not available.
⍝ * 2.0.0 - 2020-09-10
⍝   * The strategy for getting script into the WS has changed: we load now
⍝     everything we find in MyUCMDs/APLTeam/scripts/
⍝   * Now fully platform independent
⍝   * Some outdated stuff removed
⍝ * 1.8.2 - 2020-08-23
⍝   * The options exec_setup and stop_in_setup require now a leading "-"
⍝   * Function "Assert" added
⍝ * 1.8.1 - 2020-07-27
⍝   * Traps failed in case, say, acre was not available
⍝ * 1.8.0 - 2020-07-19
⍝   * Autoloads Tatin now

⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝
⍝ DO NOT EDIT THIS IN THE DSE/MyUCMDs folder!                              ⍝
⍝ This is part of the APLTeam_DSE acre project and copied over by ]runmake ⍝
⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝⍝

    ∇ {r}←Setup arg;⎕IO;⎕ML;wspath;rf;a;parms;⎕TRAP;defaultPath;dmx;path
      r←⍬      
      ⎕IO←1 ⋄ ⎕ML←1     
      ⎕TRAP←0 'S'
      :If 0
         ∘∘∘
      :EndIf
      :If IfAtLeastVersion 18.1
          ⎕SE.Constants← (9053⌶⍬)~'Dyalog'(⊂'')(⊂⍬)⎕AN''⍬' ',(¯129+⍳256),⎕A ⎕D ⎕NULL,9053,¯129,256,(0 1 2)+⊂,0
      :EndIf
    ⍝ -exec_setup=0 is passed as command line parameter by Launchy in case the user un-ticked "Execute setup.dyalog"
    ⍝ For details regarding Launchy see https://github.com/aplteam/Launchy
      :If ~GetCommandLineParm'-exec_setup=0'
          :If GetCommandLineParm'-stop_in_setup=1'
              ⎕TRAP←0 'S'
              ∘∘∘  ⍝ Deliberate crash because flag stop_in_setup was found (Launchy)
          :EndIf
          :Trap ⎕SE.SALTUtils.DEBUG↓0
              parms←2 ⎕NQ'#' 'GetCommandLineArgs'
              2 ⎕NQ'⎕se' 'CloseSessionItem' 'Debugger'
              2 ⎕NQ'⎕se' 'CloseSessionItem' 'Editor'
              path←GetMyUCMDsPath
              :If IfAtLeastVersion 18
              :AndIf 80=⎕dr ' '  ⍝ Not in "Classic"
                  AutoloadTatin ⍬
                  :If ~⎕NEXISTS path,'APLTeam'
                  :OrIf ~⎕NEXISTS path,'APLTeam/aplteam18.dws'
                  :OrIf ~⎕NEXISTS path,'APLTeam/packages'
                      'APLTeam/ in the MyUCMDS folder does not exist, or does not have the expected contents (WS, Tatin packages)'⎕SIGNAL 11
                  :EndIf
                  :If 0<⎕SE.⎕NC'Tatin'
                      {}⎕SE.Tatin.LoadDependencies(path,'APLTeam\packages')'⎕SE'
                  :EndIf
                  wspath←path,'APLTeam/aplteam18.dws'
              :Else
                  :If ~⎕NEXISTS path,'APLTeam'
                  :OrIf ~⎕NEXISTS path,'APLTeam/aplteam.dws'
                  :OrIf ~⎕NEXISTS path,'APLTeam/scripts'
                      'APLTeam/ in the MyUCMDS folder does not exist, or does not have the expected contents'⎕SIGNAL 11
                  :EndIf
                  LoadScriptsFrom path,'APLTeam/scripts/'
                  ⎕SE.⎕FIX⊃⎕NGET(path,'APLTeam/scripts/APLTreeUtils2.aplc')1 ⍝ Because DSE itself uses APLTreeUtils2
                  wspath←path,'APLTeam/aplteam.dws'
              :EndIf
              :If 80=⎕dr' '
                 'aplteam'⎕SE.⎕CY wspath
                 a←⎕SE.aplteam
                 {}a.StartUp 1
                 {}⎕SE.⎕FX ⎕SE.aplteam.⎕CR'UCMD'
              :EndIf
              {}2704⌶1   ⍝ Enable automatic saving of CONTINUE workspaces
              ⎕SIGNAL 0  ⍝ Reset ⎕DMX and ⎕EN
              {}⎕SE.UCMD'udebug on'              
              :If ~GetCommandLineParm'-acre=0'
              :AndIf 80=⎕dr' '
                  :Trap 911
                      {}⎕SE.UCMD'acre.log hide'
                      {}⎕SE.acre.AfterSave'⎕SE.OnAfterSave'
                  :Else
                      ⎕←'Issuing acre command "hide" failed'
                  :EndTrap
                  {}⎕SE.UCMD'ViewChangeHistory -install'
              :EndIf
          :Else
              dmx←⎕DMX
              ⎕←'Setup.dyalog has a problem and was not executed successfully:'
              ⎕←↑'  '∘,¨dmx.DM
          :EndTrap
      :EndIf
    ∇

    ∇ {r}←AutoloadTatin dummy;wspath;path2Config
      r←⍬
      :If IfAtLeastVersion 18
      :AndIf 80=⎕DR' '  ⍝ Not in Classic
          ⎕SE.⎕EX¨'_Tatin' 'Tatin'
          wspath←(GetMyUCMDsPath),'/Tatin/Client.dws'
          '_Tatin'⎕SE.⎕CY wspath
          path2Config←⎕SE._Tatin.Client.FindUserSettings ⎕AN
          'Create!'⎕SE._Tatin.Client.F.CheckPath path2Config
          'Tatin'⎕SE.⎕NS''
          path2Config ⎕SE._Tatin.Admin.EstablishClientInQuadSE ⍬
      :EndIf
    ∇

      IfAtLeastVersion←{
      ⍝ ⍵ is supposed to be a number like 15 or 17.1, representing a version of Dyalog APL.
      ⍝ Returns a Boolean that is 1 only if the current version is at least as good.
          ⍵≤{⊃(//)⎕VFI ⍵/⍨2>+\'.'=⍵}2⊃# ⎕WG'APLVersion'
      }

    ∇ {r}←CopyAPLGitWorkspace dummy;sf
      r←⍬
      sf←GetMyUCMDsPath ⍝ Source Folder
      'APLGit'⎕SE.⎕CY sf,'/APLGit.dws'
      {}⎕SE.APLGit.U.Init
    ∇

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

    ∇ r←GetMyUCMDsPath
      :If 'Win'≡3⍴1⊃# ⎕WG'APLVersion '
          r←(⊃⎕SH'ECHO %USERPROFILE%'),'\Documents\MyUCMDs\'
      :Else
          r←(⊃⎕SH'echo $HOME'),'/MyUCMDs/'
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

:EndNamespace