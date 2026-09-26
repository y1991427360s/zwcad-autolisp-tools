using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

using System.Text;
using System.Windows.Input;
using Draw = System.Drawing;
using WinForms = System.Windows.Forms;
using ZwSoft.Windows;
using ZwSoft.ZwCAD.ApplicationServices;
using ZwSoft.ZwCAD.DatabaseServices;
using ZwSoft.ZwCAD.EditorInput;
using ZwSoft.ZwCAD.Runtime;
using ZcadApp = ZwSoft.ZwCAD.ApplicationServices.Application;

[assembly: ExtensionApplication(typeof(AICADRibbon.AiRibbonPlugin))]
[assembly: CommandClass(typeof(AICADRibbon.AiRibbonCommands))]

namespace AICADRibbon
{
    public sealed class AiRibbonPlugin : IExtensionApplication
    {
        private const string LegacyTabId = "AA_TOOLS_TAB";
        private const string PromptPanelSourceId = "AA_AICAD_PANEL_SOURCE";
        private const string PromptPanelTitle = "AICAD";
        private const string RibbonInputVariable = "AICAD_RIBBON_INPUT";
        private const string RibbonInputFileVariable = "AICAD_RIBBON_INPUT_FILE";
        private const string RibbonReplaceSearchVariable = "AICAD_RIBBON_REPLACE_SEARCH";
        private const string RibbonReplaceValueVariable = "AICAD_RIBBON_REPLACE_VALUE";
        private const string RibbonReplaceCountVariable = "AICAD_RIBBON_REPLACE_COUNT";
        private const string RibbonReplaceSearchPrefix = "AICAD_RIBBON_REPLACE_SEARCH_";
        private const string RibbonReplaceValuePrefix = "AICAD_RIBBON_REPLACE_VALUE_";
        private const string RibbonReplaceFileVariable = "AICAD_RIBBON_REPLACE_FILE";
        private const string RibbonFindSearchVariable = "AICAD_RIBBON_FIND_SEARCH";
        private const string RibbonFindFileVariable = "AICAD_RIBBON_FIND_FILE";
        private const string RibbonFindHandleVariable = "AICAD_RIBBON_FIND_HANDLE";
        private const string BaseDirectoryEnvVar = "AICADAA_BASEDIR";
        private static readonly TimeSpan ReplaceCommandDebounceWindow = TimeSpan.FromMilliseconds(750);

        private static readonly string[] PreferredHomeTabTitles =
        {
            "\u5e38\u7528",
            "Home",
            "\u5f00\u59cb",
            "\u4e3b\u9875"
        };

        private static readonly string[] FallbackToolTabTitles =
        {
            "\u5de5\u5177",
            "Tools",
            "TOOLS"
        };

        private static AiRibbonPlugin _instance;

        private bool _idleHooked;
        private bool _documentHooked;
        private bool _eventCallbackActive;
        private bool _ribbonCommandRequested;
        private bool _panelContentsInstalled;
        private bool _replacePanelShownOnce;
        private readonly HashSet<string> _lispLoadQueuedDocuments = new HashSet<string>();
        private DateTime _lastReplaceCommandUtc;
        private string _lastReplaceSearchText = string.Empty;
        private string _lastReplaceValueText = string.Empty;
        private string _promptText = string.Empty;
        private string _replaceSearchText = string.Empty;
        private string _replaceValueText = string.Empty;
        private bool _replacePanelSuppressSync;
        private string _findText = string.Empty;
        private ReplacePanelForm _replacePanel;
        private WindowAgent _windowAgent;

        public void Initialize()
        {
            _instance = this;
            EnsureRibbonVisible();
            TryInstallRibbon();
            EnsureIdleHook();
            EnsureDocumentHook();
            EnsureLispLoadedForActiveDocument();
            _windowAgent = new WindowAgent();
        }

        public void Terminate()
        {
            if (_idleHooked)
            {
                ZcadApp.Idle -= OnApplicationIdle;
                _idleHooked = false;
            }

            if (_documentHooked)
            {
                ZcadApp.DocumentManager.DocumentBecameCurrent -= OnDocumentBecameCurrent;
                _documentHooked = false;
            }

            ClosePromptPanel();
            CloseReplacePanel();
            if (_windowAgent != null) { _windowAgent.Dispose(); _windowAgent = null; }
            _instance = null;
        }

        internal static AiRibbonPlugin EnsureInstance()
        {
            if (_instance == null)
            {
                _instance = new AiRibbonPlugin();
                _instance.Initialize();
            }

            return _instance;
        }

        internal void ShowPromptPanelCommand()
        {
            ClosePromptPanel();
        }

        internal void ShowReplacePanelCommand()
        {
            if (_replacePanel != null && !_replacePanel.IsDisposed && _replacePanel.Visible)
            {
                CloseReplacePanel();
                return;
            }

            EnsureReplacePanelVisible(true);
        }

        internal void ShowWindowManagerCommand()
        {
            try
            {
                string directory = Path.GetDirectoryName(typeof(AiRibbonPlugin).Assembly.Location);
                string executable = Path.Combine(directory, "DwgWindowManager.exe");
                if (!File.Exists(executable)) throw new FileNotFoundException("图纸窗口管理器未安装", executable);
                System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo(executable) { UseShellExecute = false, WorkingDirectory = directory });
            }
            catch (System.Exception ex)
            {
                WinForms.MessageBox.Show("无法启动图纸窗口管理器：" + ex.Message, "图纸窗口管理器", WinForms.MessageBoxButtons.OK, WinForms.MessageBoxIcon.Error);
            }
        }

        private void EnsureIdleHook()
        {
            if (_idleHooked)
            {
                return;
            }

            ZcadApp.Idle += OnApplicationIdle;
            _idleHooked = true;
        }

        private void EnsureDocumentHook()
        {
            if (_documentHooked)
            {
                return;
            }

            ZcadApp.DocumentManager.DocumentBecameCurrent += OnDocumentBecameCurrent;
            _documentHooked = true;
        }

        private void OnApplicationIdle(object sender, EventArgs e)
        {
            if (_eventCallbackActive)
            {
                return;
            }

            try
            {
                _eventCallbackActive = true;
                EnsureRibbonVisible();
                TryInstallRibbon();
                EnsureLispLoadedForActiveDocument();

                if (ComponentManager.Ribbon != null && IsWinformsReady() && _idleHooked)
                {
                    ZcadApp.Idle -= OnApplicationIdle;
                    _idleHooked = false;
                }
            }
            finally
            {
                _eventCallbackActive = false;
            }
        }

        private void OnDocumentBecameCurrent(object sender, DocumentCollectionEventArgs e)
        {
            if (_eventCallbackActive)
            {
                return;
            }

            try
            {
                _eventCallbackActive = true;
                EnsureRibbonVisible();
                TryInstallRibbon();

                if (e != null && e.Document != null)
                {
                    EnsureLispLoaded(e.Document);
                }

            }
            finally
            {
                _eventCallbackActive = false;
            }
        }



        private void EnsurePromptPanelVisible(bool forceShow)
        {
            return;
        }

        private void EnsureReplacePanelVisible(bool forceShow)
        {
            try
            {
                if (_replacePanel != null && !_replacePanel.IsDisposed)
                {
                    _replacePanel.SetReplaceSearchText(_replaceSearchText);
                    _replacePanel.SetReplaceValueText(_replaceValueText);
                    _replacePanel.SetFindText(_findText);
                    if (forceShow)
                    {
                        _replacePanel.Show();
                        _replacePanel.Activate();
                    }

                    return;
                }

                if (!IsWinformsReady())
                {
                    return;
                }

                if (!forceShow && _replacePanelShownOnce)
                {
                    return;
                }

                _replacePanel = new ReplacePanelForm(this);
                _replacePanel.FormClosed += OnReplacePanelClosed;
                _replacePanel.SetReplaceSearchText(_replaceSearchText);
                _replacePanel.SetReplaceValueText(_replaceValueText);
                _replacePanel.SetFindText(_findText);
                ZcadApp.ShowModelessDialog(_replacePanel);
                _replacePanelShownOnce = true;
            }
            catch (System.Exception ex)
            {
                Document document = ZcadApp.DocumentManager.MdiActiveDocument;
                if (document != null)
                {
                    WriteMessage(document.Editor, "AICAD \u6587\u5b57\u66ff\u6362\u9762\u677f\u6253\u5f00\u5931\u8d25\uff1a" + ex.Message);
                }
            }
        }

        private void OnPromptPanelClosed(object sender, WinForms.FormClosedEventArgs e)
        {
            return;
        }

        private void OnReplacePanelClosed(object sender, WinForms.FormClosedEventArgs e)
        {
            if (_replacePanel != null)
            {
                _replacePanel.FormClosed -= OnReplacePanelClosed;
                _replacePanel = null;
            }
        }

        private void ClosePromptPanel()
        {
            return;
        }

        private void CloseReplacePanel()
        {
            if (_replacePanel == null)
            {
                return;
            }

            try
            {
                _replacePanel.FormClosed -= OnReplacePanelClosed;
                _replacePanel.Close();
                _replacePanel.Dispose();
            }
            catch
            {
            }
            finally
            {
                _replacePanel = null;
            }
        }

        private void EnsureRibbonVisible()
        {
            Document document;

            if (ComponentManager.Ribbon != null || _ribbonCommandRequested)
            {
                return;
            }

            document = ZcadApp.DocumentManager.MdiActiveDocument;
            if (document == null)
            {
                return;
            }

            _ribbonCommandRequested = true;
            document.SendStringToExecute("_.RIBBON ", true, false, false);
        }

        private static bool IsWinformsReady()
        {
            try
            {
                var property = typeof(ZcadApp).GetProperty("WinformsLoaded");
                if (property == null)
                {
                    return true;
                }

                object value = property.GetValue(null, null);
                return value is bool ? (bool)value : true;
            }
            catch
            {
                return true;
            }
        }

        private void TryInstallRibbon()
        {
            RibbonControl ribbon = ComponentManager.Ribbon;
            RibbonTab hostTab;
            RibbonPanel panel;

            if (ribbon == null)
            {
                return;
            }

            _ribbonCommandRequested = false;
            RemoveLegacyAaTabs(ribbon);
            hostTab = FindHostTab(ribbon);
            if (hostTab == null)
            {
                return;
            }

            RemovePromptPanelsFromOtherTabs(ribbon, hostTab);
            panel = FindOrCreatePromptPanel(hostTab);
            if (!_panelContentsInstalled)
            {
                EnsurePanelContents(panel.Source);
                _panelContentsInstalled = true;
            }
        }

        private static void RemoveLegacyAaTabs(RibbonControl ribbon)
        {
            RibbonTab[] tabsToRemove = ribbon.Tabs
                .Cast<RibbonTab>()
                .Where(item =>
                    string.Equals(item.Id, LegacyTabId, StringComparison.OrdinalIgnoreCase) ||
                    (!string.IsNullOrEmpty(item.Title) && item.Title.StartsWith("AA", StringComparison.OrdinalIgnoreCase)))
                .ToArray();

            foreach (RibbonTab tab in tabsToRemove)
            {
                ribbon.Tabs.Remove(tab);
            }
        }

        private static RibbonTab FindHostTab(RibbonControl ribbon)
        {
            RibbonTab hostTab = FindTabByTitle(ribbon, PreferredHomeTabTitles, true);
            if (hostTab != null)
            {
                return hostTab;
            }

            hostTab = FindTabByTitle(ribbon, PreferredHomeTabTitles, false);
            if (hostTab != null)
            {
                return hostTab;
            }

            hostTab = FindTabByTitle(ribbon, FallbackToolTabTitles, true);
            if (hostTab != null)
            {
                return hostTab;
            }

            hostTab = FindTabByTitle(ribbon, FallbackToolTabTitles, false);
            if (hostTab != null)
            {
                return hostTab;
            }

            hostTab = ribbon.Tabs.Cast<RibbonTab>()
                .FirstOrDefault(item => !item.IsContextualTab && item.IsVisible && item.IsActive);
            if (hostTab != null)
            {
                return hostTab;
            }

            return ribbon.Tabs.Cast<RibbonTab>()
                .FirstOrDefault(item => !item.IsContextualTab && item.IsVisible);
        }

        private static RibbonTab FindTabByTitle(RibbonControl ribbon, string[] titles, bool exactMatch)
        {
            return ribbon.Tabs.Cast<RibbonTab>()
                .FirstOrDefault(item =>
                {
                    string title = item.Title ?? string.Empty;
                    if (item.IsContextualTab || !item.IsVisible)
                    {
                        return false;
                    }

                    return titles.Any(candidate =>
                        exactMatch
                            ? string.Equals(title, candidate, StringComparison.OrdinalIgnoreCase)
                            : title.IndexOf(candidate, StringComparison.OrdinalIgnoreCase) >= 0);
                });
        }

        private static void RemovePromptPanelsFromOtherTabs(RibbonControl ribbon, RibbonTab hostTab)
        {
            foreach (RibbonTab tab in ribbon.Tabs.Cast<RibbonTab>().Where(item => !ReferenceEquals(item, hostTab)))
            {
                RibbonPanel[] panelsToRemove = tab.Panels.Cast<RibbonPanel>()
                    .Where(item => item.Source != null && string.Equals(item.Source.Id, PromptPanelSourceId, StringComparison.OrdinalIgnoreCase))
                    .ToArray();

                foreach (RibbonPanel panel in panelsToRemove)
                {
                    tab.Panels.Remove(panel);
                }
            }
        }

        private static RibbonPanel FindOrCreatePromptPanel(RibbonTab hostTab)
        {
            RibbonPanel panel = hostTab.Panels.Cast<RibbonPanel>()
                .FirstOrDefault(item => item.Source != null && string.Equals(item.Source.Id, PromptPanelSourceId, StringComparison.OrdinalIgnoreCase));

            if (panel == null)
            {
                RibbonPanelSource source = new RibbonPanelSource();
                source.Id = PromptPanelSourceId;
                source.Title = PromptPanelTitle;

                panel = new RibbonPanel();
                panel.Source = source;
                hostTab.Panels.Add(panel);
                return panel;
            }

            panel.Source.Title = PromptPanelTitle;
            return panel;
        }

        private void EnsurePanelContents(RibbonPanelSource source)
        {
            OpenReplacePanelCommand openReplaceHandler = new OpenReplacePanelCommand(this);
            OpenWindowManagerCommand openWindowHandler = new OpenWindowManagerCommand(this);

            RibbonButton replaceButton = new RibbonButton();
            replaceButton.Id = "AA_AICAD_REPLACE_BUTTON";
            replaceButton.Name = "AA_AICAD_REPLACE_BUTTON";
            replaceButton.Text = "\u6587\u5b57\u66ff\u6362";
            replaceButton.ShowText = true;
            replaceButton.ShowImage = false;
            replaceButton.CommandHandler = openReplaceHandler;
            replaceButton.Description = "\u6253\u5f00 AICAD \u6587\u5b57\u66ff\u6362\u9762\u677f";

            RibbonButton windowButton = new RibbonButton();
            windowButton.Id = "AA_DWG_WINDOW_BUTTON";
            windowButton.Name = "AA_DWG_WINDOW_BUTTON";
            windowButton.Text = "\u56fe\u7eb8\u7a97\u53e3";
            windowButton.ShowText = true;
            windowButton.ShowImage = false;
            windowButton.CommandHandler = openWindowHandler;
            windowButton.Description = "\u6253\u5f00\u56fe\u7eb8\u7a97\u53e3\u7ba1\u7406\u5668";

            source.Items.Clear();
            source.Items.Add(windowButton);
            source.Items.Add(replaceButton);
        }

        private void SyncPromptTextToPanel()
        {
            return;
        }

        private void SyncReplaceTextToPanel()
        {
            if (_replacePanel == null || _replacePanel.IsDisposed)
            {
                return;
            }

            _replacePanel.SetReplaceSearchText(_replaceSearchText);
            _replacePanel.SetReplaceValueText(_replaceValueText);
            _replacePanel.SetFindText(_findText);
        }

        internal void UpdatePromptText(string text)
        {
            _promptText = text ?? string.Empty;
            SyncPromptTextToPanel();
        }

        internal void UpdateReplaceSearchText(string text)
        {
            _replaceSearchText = text ?? string.Empty;
            if (!_replacePanelSuppressSync)
            {
                SyncReplaceTextToPanel();
            }
        }

        internal void UpdateReplaceValueText(string text)
        {
            _replaceValueText = text ?? string.Empty;
            if (!_replacePanelSuppressSync)
            {
                SyncReplaceTextToPanel();
            }
        }

        internal void UpdateFindText(string text)
        {
            _findText = text ?? string.Empty;
            if (!_replacePanelSuppressSync)
            {
                SyncReplaceTextToPanel();
            }
        }

        internal void ExecuteReplaceFromFloatingPanel(string searchText, string replaceText)
        {
            ExecuteReplace(searchText, replaceText);
        }

        internal void ExecuteFindFromFloatingPanel(string searchText)
        {
            ExecuteFind(searchText);
        }

        private void ExecutePrompt(string promptText)
        {
            Document document = ZcadApp.DocumentManager.MdiActiveDocument;
            string prompt;

            if (document == null)
            {
                return;
            }

            prompt = (promptText ?? string.Empty).Trim();
            UpdatePromptText(prompt);
            if (string.IsNullOrWhiteSpace(prompt))
            {
                return;
            }

            try
            {
                EnsureLispLoaded(document);
                PreserveImpliedSelection(document.Editor);

                if (prompt.Length > 100)
                {
                    string tempDir = Path.GetTempPath();
                    int pid = System.Diagnostics.Process.GetCurrentProcess().Id;
                    string filePath = Path.Combine(tempDir, string.Format("aicad_input_{0}.txt", pid));
                    string fallbackPath = Path.Combine(tempDir, "aicad_ribbon_input.txt");

                    File.WriteAllText(filePath, prompt, new System.Text.UTF8Encoding(false));
                    try { File.Copy(filePath, fallbackPath, true); } catch { }

                    try
                    {
                        System.Environment.SetEnvironmentVariable(RibbonInputFileVariable, filePath);
                    }
                    catch
                    {
                    }

                    string lispPath = filePath.Replace("\\", "/");
                    document.SendStringToExecute("(progn (setenv \"" + RibbonInputFileVariable + "\" \"" + lispPath + "\") (princ)) ", true, false, false);
                }
                else
                {
                    document.SendStringToExecute("(progn (setenv \"" + RibbonInputVariable + "\" \"" + EscapeForLisp(prompt) + "\") (princ)) ", true, false, false);
                }

                document.SendStringToExecute("AICADRIBBON ", true, false, false);
            }
            catch (System.Exception ex)
            {
                WriteMessage(document.Editor, "AICAD 输入框执行失败：" + ex.Message);
            }
        }

        private void ExecuteReplace(string searchTextInput, string replaceTextInput)
        {
            Document document = ZcadApp.DocumentManager.MdiActiveDocument;
            string searchText;
            string replaceText;
            List<string[]> pairs;

            if (document == null)
            {
                return;
            }

            searchText = searchTextInput ?? string.Empty;
            replaceText = replaceTextInput ?? string.Empty;
            UpdateReplaceSearchText(searchText);
            UpdateReplaceValueText(replaceText);

            pairs = BuildReplacePairs(searchText, replaceText);
            if (pairs.Count == 0)
            {
                EnsureReplacePanelVisible(true);
                if (_replacePanel != null && !_replacePanel.IsDisposed)
                {
                    _replacePanel.FocusReplaceSearchBox();
                }

                return;
            }

            if (ShouldSkipDuplicateReplace(searchText, replaceText))
            {
                return;
            }

            try
            {
                EnsureLispLoaded(document);
                PreserveImpliedSelection(document.Editor);

                string payloadPath = WriteReplacePayloadFile(pairs);
                string lispPath = payloadPath.Replace("\\", "/");

                try
                {
                    System.Environment.SetEnvironmentVariable(RibbonReplaceFileVariable, payloadPath);
                }
                catch
                {
                }

                // If only 1 short rule, also set legacy env vars for older LISP compatibility
                if (pairs.Count == 1 && pairs[0][0].Length < 35 && pairs[0][1].Length < 35)
                {
                    string legacyCmd = "(progn "
                        + "(setenv \"" + RibbonReplaceCountVariable + "\" \"1\") "
                        + "(setenv \"" + RibbonReplaceSearchPrefix + "1\" \"" + EscapeForLisp(pairs[0][0]) + "\") "
                        + "(setenv \"" + RibbonReplaceValuePrefix + "1\" \"" + EscapeForLisp(pairs[0][1]) + "\") "
                        + "(princ)) ";
                    document.SendStringToExecute(legacyCmd, true, false, false);
                }

                string command = "(progn (setenv \"" + RibbonReplaceFileVariable + "\" \"" + lispPath + "\") (princ)) ";
                document.SendStringToExecute(command, true, false, false);
                document.SendStringToExecute("AICADRIBBONREPLACE ", true, false, false);
            }
            catch (System.Exception ex)
            {
                WriteMessage(document.Editor, "AICAD 替换框执行失败：" + ex.Message);
            }
        }

        private static string WriteReplacePayloadFile(List<string[]> pairs)
        {
            string tempDir = Path.GetTempPath();
            int pid = System.Diagnostics.Process.GetCurrentProcess().Id;
            string filePath = Path.Combine(tempDir, string.Format("aicad_replace_{0}.txt", pid));
            string fallbackPath = Path.Combine(tempDir, "aicad_ribbon_replace.txt");

            var utf8NoBom = new System.Text.UTF8Encoding(false);
            using (var sw = new StreamWriter(filePath, false, utf8NoBom))
            {
                sw.NewLine = "\r\n";
                sw.WriteLine(pairs.Count);
                for (int i = 0; i < pairs.Count; i++)
                {
                    sw.WriteLine(pairs[i][0] ?? string.Empty);
                    sw.WriteLine(pairs[i][1] ?? string.Empty);
                }
            }

            try
            {
                File.Copy(filePath, fallbackPath, true);
            }
            catch
            {
            }

            return filePath;
        }

        // Split the multi-line search/value boxes into ordered replacement pairs.
        // Line N of the search box maps to line N of the value box. Truly empty
        // search lines are skipped. Pure whitespace search text (half/full-width
        // space, tab) is kept so users can replace spaces in CAD text.
        // A missing value line means delete (empty replace).
        private static List<string[]> BuildReplacePairs(string searchText, string replaceText)
        {
            string[] searchLines = SplitLines(searchText);
            string[] valueLines = SplitLines(replaceText);
            List<string[]> pairs = new List<string[]>();

            for (int i = 0; i < searchLines.Length; i++)
            {
                string search = NormalizeReplaceOperand(searchLines[i], true);
                if (search.Length == 0)
                {
                    continue;
                }

                string value = i < valueLines.Length
                    ? NormalizeReplaceOperand(valueLines[i], false)
                    : string.Empty;
                pairs.Add(new string[] { search, value });
            }

            return pairs;
        }

        private static string[] SplitLines(string text)
        {
            return (text ?? string.Empty).Replace("\r\n", "\n").Replace("\r", "\n").Split('\n');
        }

        // Search: keep pure-whitespace operands; only drop truly empty lines.
        // Replace: never Trim — empty means delete; spaces must survive.
        private static string NormalizeReplaceOperand(string text, bool isSearch)
        {
            string value = text ?? string.Empty;
            if (!isSearch)
            {
                return value;
            }

            if (value.Length == 0)
            {
                return string.Empty;
            }

            if (IsOnlyWhitespace(value))
            {
                return value;
            }

            return value.Trim();
        }

        private static bool IsOnlyWhitespace(string text)
        {
            if (string.IsNullOrEmpty(text))
            {
                return true;
            }

            for (int i = 0; i < text.Length; i++)
            {
                char ch = text[i];
                if (ch != ' ' && ch != '\t' && ch != '\u3000' && ch != '\u00A0')
                {
                    return false;
                }
            }

            return true;
        }

        private bool ShouldSkipDuplicateReplace(string searchText, string replaceText)
        {
            DateTime nowUtc = DateTime.UtcNow;
            bool isDuplicateRequest =
                string.Equals(_lastReplaceSearchText, searchText, StringComparison.Ordinal) &&
                string.Equals(_lastReplaceValueText, replaceText, StringComparison.Ordinal) &&
                (nowUtc - _lastReplaceCommandUtc) <= ReplaceCommandDebounceWindow;

            _lastReplaceCommandUtc = nowUtc;
            _lastReplaceSearchText = searchText ?? string.Empty;
            _lastReplaceValueText = replaceText ?? string.Empty;
            return isDuplicateRequest;
        }

        private void ExecuteFind(string searchTextInput)
        {
            Document document = ZcadApp.DocumentManager.MdiActiveDocument;
            FindMatchItem[] matches;
            string searchText;

            if (document == null)
            {
                return;
            }

            searchText = searchTextInput ?? string.Empty;
            UpdateFindText(searchText);
            if (string.IsNullOrWhiteSpace(searchText))
            {
                EnsureReplacePanelVisible(true);
                if (_replacePanel != null && !_replacePanel.IsDisposed)
                {
                    _replacePanel.FocusFindBox();
                }

                return;
            }

            try
            {
                matches = GetFindMatches(document, searchText);
                ShowFindResults(searchText, matches);
            }
            catch (System.Exception ex)
            {
                ShowFindResults(searchText, new FindMatchItem[0]);
                WriteMessage(document.Editor, "AICAD 查找结果列表生成失败：" + ex.Message);
            }

            try
            {
                EnsureLispLoaded(document);
                PreserveImpliedSelection(document.Editor);

                if (searchText.Length > 100)
                {
                    string tempDir = Path.GetTempPath();
                    int pid = System.Diagnostics.Process.GetCurrentProcess().Id;
                    string filePath = Path.Combine(tempDir, string.Format("aicad_find_{0}.txt", pid));
                    string fallbackPath = Path.Combine(tempDir, "aicad_ribbon_find.txt");

                    File.WriteAllText(filePath, searchText, new System.Text.UTF8Encoding(false));
                    try { File.Copy(filePath, fallbackPath, true); } catch { }

                    try
                    {
                        System.Environment.SetEnvironmentVariable(RibbonFindFileVariable, filePath);
                    }
                    catch
                    {
                    }

                    string lispPath = filePath.Replace("\\", "/");
                    document.SendStringToExecute("(progn (setenv \"" + RibbonFindFileVariable + "\" \"" + lispPath + "\") (princ)) ", true, false, false);
                }
                else
                {
                    document.SendStringToExecute(
                        "(progn (setenv \"" + RibbonFindSearchVariable + "\" \"" + EscapeForLisp(searchText) + "\") (princ)) ",
                        true,
                        false,
                        false);
                }

                document.SendStringToExecute("AICADRIBBONFIND ", true, false, false);
            }
            catch (System.Exception ex)
            {
                WriteMessage(document.Editor, "AICAD 查找框执行失败：" + ex.Message);
            }
        }

        private void ExecuteFindResultJump(string handleInput)
        {
            Document document = ZcadApp.DocumentManager.MdiActiveDocument;
            string handle;

            if (document == null)
            {
                return;
            }

            handle = handleInput ?? string.Empty;
            if (string.IsNullOrWhiteSpace(handle))
            {
                return;
            }

            try
            {
                EnsureLispLoaded(document);
                PreserveImpliedSelection(document.Editor);

                document.SendStringToExecute(
                    "(progn (setenv \"" + RibbonFindHandleVariable + "\" \"" + EscapeForLisp(handle) + "\") (princ)) ",
                    true,
                    false,
                    false);
                document.SendStringToExecute("AICADRIBBONFOCUSMATCH ", true, false, false);
            }
            catch (System.Exception ex)
            {
                WriteMessage(document.Editor, "AICAD 查找结果跳转失败：" + ex.Message);
            }
        }

        private void ShowFindResults(string searchText, FindMatchItem[] matches)
        {
            try
            {
                EnsureReplacePanelVisible(true);
                if (_replacePanel == null || _replacePanel.IsDisposed)
                {
                    return;
                }

                _replacePanel.SetFindMatches(searchText, matches);
            }
            catch (System.Exception ex)
            {
                Document document = ZcadApp.DocumentManager.MdiActiveDocument;
                if (document != null)
                {
                    WriteMessage(document.Editor, "AICAD 查找结果面板打开失败：" + ex.Message);
                }
            }
        }

        private static FindMatchItem[] GetFindMatches(Document document, string searchText)
        {
            PromptSelectionResult implied;
            List<FindMatchItem> matches = new List<FindMatchItem>();
            string keyword = searchText ?? string.Empty;

            if (document == null || string.IsNullOrWhiteSpace(keyword))
            {
                return matches.ToArray();
            }

            implied = document.Editor.SelectImplied();
            if (implied.Status != PromptStatus.OK || implied.Value == null)
            {
                return matches.ToArray();
            }

            using (DocumentLock documentLock = document.LockDocument())
            using (Transaction transaction = document.TransactionManager.StartTransaction())
            {
                int index = 1;
                foreach (ObjectId objectId in implied.Value.GetObjectIds())
                {
                    Entity entity = transaction.GetObject(objectId, OpenMode.ForRead, false) as Entity;
                    string textContent = GetEntityTextContent(entity);
                    string handle;

                    if (string.IsNullOrEmpty(textContent) ||
                        textContent.IndexOf(keyword, StringComparison.Ordinal) < 0)
                    {
                        continue;
                    }

                    handle = objectId.Handle.ToString();
                    matches.Add(new FindMatchItem(index, handle, textContent));
                    index++;
                }

                transaction.Commit();
            }

            return matches.ToArray();
        }

        private static string GetEntityTextContent(Entity entity)
        {
            DBText dbText = entity as DBText;
            MText mText = entity as MText;

            if (dbText != null)
            {
                return dbText.TextString ?? string.Empty;
            }

            if (mText != null)
            {
                return mText.Contents ?? string.Empty;
            }

            return string.Empty;
        }

        private static string FormatFindResultText(string value)
        {
            string text = value ?? string.Empty;

            text = text.Replace("\\P", " ").Replace("\\p", " ").Replace("\r", " ").Replace("\n", " ");
            while (text.Contains("  "))
            {
                text = text.Replace("  ", " ");
            }

            text = text.Trim();
            if (text.Length == 0)
            {
                return "<空文字>";
            }

            if (text.Length > 120)
            {
                return text.Substring(0, 117) + "...";
            }

            return text;
        }

        private void EnsureLispLoadedForActiveDocument()
        {
            Document document = ZcadApp.DocumentManager.MdiActiveDocument;
            if (document != null)
            {
                EnsureLispLoaded(document);
            }
        }

        private void EnsureLispLoaded(Document document)
        {
            string lispPath = ResolvePluginFile("aicad_extension.lsp");
            string baseDirectory = Path.GetDirectoryName(lispPath) ?? string.Empty;
            string documentKey = GetDocumentKey(document);

            if (_lispLoadQueuedDocuments.Contains(documentKey))
            {
                return;
            }

            if (!File.Exists(lispPath))
            {
                WriteMessage(document.Editor, "DLL \u540c\u76ee\u5f55\u4e0b\u672a\u627e\u5230 aicad_extension.lsp\u3002");
                return;
            }

            try
            {
                _lispLoadQueuedDocuments.Add(documentKey);
                document.SendStringToExecute(
                    "(progn " +
                    "(setq *AICAD_BaseDirectory* \"" + EscapeForLisp(baseDirectory.Replace('\\', '/')) + "\") " +
                    "(setenv \"" + BaseDirectoryEnvVar + "\" \"" + EscapeForLisp(baseDirectory.Replace('\\', '/')) + "\") " +
                    "(if (not c:AICADRIBBON) (load \"" + EscapeForLisp(lispPath.Replace('\\', '/')) + "\")) " +
                    "(princ)) ",
                    true,
                    false,
                    false);
            }
            catch (System.Exception ex)
            {
                _lispLoadQueuedDocuments.Remove(documentKey);
                WriteMessage(document.Editor, "AICAD LISP load queue failed: " + ex.Message);
            }
        }

        private static string GetDocumentKey(Document document)
        {
            if (document == null)
            {
                return string.Empty;
            }

            return document.GetHashCode().ToString();
        }

        internal void UnloadCommand()
        {
            Document document = ZcadApp.DocumentManager.MdiActiveDocument;

            Terminate();
            _lispLoadQueuedDocuments.Clear();

            if (document != null)
            {
                document.SendStringToExecute("UNLOAD_AICAD ", true, false, false);
            }
        }

        private static void PreserveImpliedSelection(Editor editor)
        {
            PromptSelectionResult implied = editor.SelectImplied();
            if (implied.Status != PromptStatus.OK || implied.Value == null)
            {
                return;
            }

            editor.SetImpliedSelection(implied.Value.GetObjectIds());
        }

        private static void WriteMessage(Editor editor, string message)
        {
            if (editor != null)
            {
                editor.WriteMessage(Environment.NewLine + message);
            }
        }

        private static string GetPluginDirectory()
        {
            string directory = Path.GetDirectoryName(typeof(AiRibbonPlugin).Assembly.Location);
            return string.IsNullOrEmpty(directory) ? string.Empty : directory;
        }

        private static string ResolvePluginFile(string fileName)
        {
            string baseDirectory = GetPluginDirectory();
            string candidate = Path.Combine(baseDirectory, fileName);
            DirectoryInfo parentDirectory;

            if (File.Exists(candidate))
            {
                return candidate;
            }

            parentDirectory = string.IsNullOrEmpty(baseDirectory) ? null : Directory.GetParent(baseDirectory);
            if (parentDirectory != null)
            {
                candidate = Path.Combine(parentDirectory.FullName, fileName);
                if (File.Exists(candidate))
                {
                    return candidate;
                }
            }

            return Path.Combine(baseDirectory, fileName);
        }

        private static string EscapeForLisp(string value)
        {
            string text = value ?? string.Empty;
            return text.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\r", " ").Replace("\n", " ");
        }

        private sealed class OpenReplacePanelCommand : ICommand
        {
            private readonly AiRibbonPlugin _owner;

            public OpenReplacePanelCommand(AiRibbonPlugin owner)
            {
                _owner = owner;
            }

            public event EventHandler CanExecuteChanged
            {
                add { }
                remove { }
            }

            public bool CanExecute(object parameter)
            {
                return true;
            }

            public void Execute(object parameter)
            {
                _owner.ShowReplacePanelCommand();
            }
        }

        private sealed class OpenWindowManagerCommand : ICommand
        {
            private readonly AiRibbonPlugin _owner;
            public OpenWindowManagerCommand(AiRibbonPlugin owner) { _owner = owner; }
            public event EventHandler CanExecuteChanged { add { } remove { } }
            public bool CanExecute(object parameter) { return true; }
            public void Execute(object parameter) { _owner.ShowWindowManagerCommand(); }
        }



        [System.Runtime.InteropServices.DllImport("user32.dll", CharSet = System.Runtime.InteropServices.CharSet.Auto)]
        private static extern int SendMessage(IntPtr hWnd, int msg, int wParam, [System.Runtime.InteropServices.MarshalAs(System.Runtime.InteropServices.UnmanagedType.LPWStr)] string lParam);
        private const int EM_SETCUEBANNER = 0x1501;

        private static void SetCueBanner(WinForms.TextBox textBox, string cueText)
        {
            if (textBox == null || string.IsNullOrEmpty(cueText))
            {
                return;
            }
            if (textBox.IsHandleCreated)
            {
                SendMessage(textBox.Handle, EM_SETCUEBANNER, 1, cueText);
            }
            else
            {
                textBox.HandleCreated += delegate
                {
                    SendMessage(textBox.Handle, EM_SETCUEBANNER, 1, cueText);
                };
            }
        }

        private static List<string[]> ParseRulesFromText(string text)
        {
            List<string[]> result = new List<string[]>();
            if (string.IsNullOrEmpty(text))
            {
                return result;
            }

            string[] lines = text.Replace("\r\n", "\n").Replace("\r", "\n").Split('\n');
            foreach (string rawLine in lines)
            {
                string line = rawLine.Trim();
                if (line.Length == 0)
                {
                    continue;
                }

                string search = string.Empty;
                string value = string.Empty;

                if (rawLine.Contains("\t"))
                {
                    string[] parts = rawLine.Split(new char[] { '\t' }, 2);
                    search = parts[0].Trim();
                    value = parts.Length > 1 ? parts[1].Trim() : string.Empty;
                }
                else if (line.Contains("->") || line.Contains("=>"))
                {
                    string sep = line.Contains("->") ? "->" : "=>";
                    string[] parts = line.Split(new string[] { sep }, 2, StringSplitOptions.None);
                    search = parts[0].Trim();
                    value = parts.Length > 1 ? parts[1].Trim() : string.Empty;
                }
                else if (line.Contains("="))
                {
                    string[] parts = line.Split(new char[] { '=' }, 2);
                    search = parts[0].Trim();
                    value = parts.Length > 1 ? parts[1].Trim() : string.Empty;
                }
                else if (line.Contains(",") || line.Contains("，"))
                {
                    char sep = line.Contains(",") ? ',' : '，';
                    string[] parts = line.Split(new char[] { sep }, 2);
                    search = parts[0].Trim();
                    value = parts.Length > 1 ? parts[1].Trim() : string.Empty;
                }
                else
                {
                    search = line;
                    value = string.Empty;
                }

                if (search.Length > 0)
                {
                    result.Add(new string[] { search, value });
                }
            }

            return result;
        }

        private sealed class BatchRulesDialogForm : WinForms.Form
        {
            private readonly WinForms.TextBox _textBox;
            private List<string[]> _parsedRules;
            public List<string[]> ParsedRules { get { return _parsedRules; } }
            public bool IsAppend { get; private set; }

            public BatchRulesDialogForm(string initialText)
            {
                Text = "批量导入 / 编辑规则";
                FormBorderStyle = WinForms.FormBorderStyle.FixedDialog;
                MaximizeBox = false;
                MinimizeBox = false;
                StartPosition = WinForms.FormStartPosition.CenterParent;
                ClientSize = new Draw.Size(520, 420);
                BackColor = Draw.Color.FromArgb(37, 37, 38);
                ForeColor = Draw.Color.FromArgb(224, 224, 224);
                Font = new Draw.Font("Segoe UI", 9f, Draw.FontStyle.Regular);

                WinForms.TableLayoutPanel layout = new WinForms.TableLayoutPanel();
                layout.Dock = WinForms.DockStyle.Fill;
                layout.Padding = new WinForms.Padding(12);
                layout.RowCount = 3;
                layout.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Absolute, 46f));
                layout.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Percent, 100f));
                layout.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Absolute, 38f));

                WinForms.Label hintLabel = new WinForms.Label();
                hintLabel.Dock = WinForms.DockStyle.Fill;
                hintLabel.ForeColor = Draw.Color.FromArgb(180, 180, 180);
                hintLabel.Text = "在下方粘贴或编辑规则，每行一条。支持：\r\n1. Excel 两列复制（制表符 Tab 分隔） 2. 查找 -> 替换  3. 逗号分隔";
                layout.Controls.Add(hintLabel, 0, 0);

                _textBox = new WinForms.TextBox();
                _textBox.Dock = WinForms.DockStyle.Fill;
                _textBox.Multiline = true;
                _textBox.ScrollBars = WinForms.ScrollBars.Both;
                _textBox.BackColor = Draw.Color.FromArgb(45, 45, 48);
                _textBox.ForeColor = Draw.Color.FromArgb(235, 235, 235);
                _textBox.BorderStyle = WinForms.BorderStyle.FixedSingle;
                _textBox.Font = new Draw.Font("Consolas", 9.5f, Draw.FontStyle.Regular);
                _textBox.Text = initialText ?? string.Empty;
                layout.Controls.Add(_textBox, 0, 1);

                WinForms.FlowLayoutPanel btnPanel = new WinForms.FlowLayoutPanel();
                btnPanel.Dock = WinForms.DockStyle.Fill;
                btnPanel.FlowDirection = WinForms.FlowDirection.RightToLeft;
                btnPanel.Margin = new WinForms.Padding(0);

                WinForms.Button cancelBtn = new WinForms.Button();
                cancelBtn.Text = "取消";
                cancelBtn.Size = new Draw.Size(75, 28);
                cancelBtn.FlatStyle = WinForms.FlatStyle.Flat;
                cancelBtn.BackColor = Draw.Color.FromArgb(60, 60, 64);
                cancelBtn.ForeColor = Draw.Color.FromArgb(220, 220, 220);
                cancelBtn.DialogResult = WinForms.DialogResult.Cancel;
                cancelBtn.Click += delegate { Close(); };

                WinForms.Button appendBtn = new WinForms.Button();
                appendBtn.Text = "追加导入";
                appendBtn.Size = new Draw.Size(95, 28);
                appendBtn.FlatStyle = WinForms.FlatStyle.Flat;
                appendBtn.BackColor = Draw.Color.FromArgb(45, 90, 140);
                appendBtn.ForeColor = Draw.Color.White;
                appendBtn.Click += delegate
                {
                    _parsedRules = ParseRulesFromText(_textBox.Text);
                    IsAppend = true;
                    DialogResult = WinForms.DialogResult.OK;
                    Close();
                };

                WinForms.Button replaceBtn = new WinForms.Button();
                replaceBtn.Text = "覆盖导入";
                replaceBtn.Size = new Draw.Size(95, 28);
                replaceBtn.FlatStyle = WinForms.FlatStyle.Flat;
                replaceBtn.BackColor = Draw.Color.FromArgb(0, 122, 204);
                replaceBtn.ForeColor = Draw.Color.White;
                replaceBtn.Click += delegate
                {
                    _parsedRules = ParseRulesFromText(_textBox.Text);
                    IsAppend = false;
                    DialogResult = WinForms.DialogResult.OK;
                    Close();
                };

                btnPanel.Controls.Add(cancelBtn);
                btnPanel.Controls.Add(appendBtn);
                btnPanel.Controls.Add(replaceBtn);
                layout.Controls.Add(btnPanel, 0, 2);

                Controls.Add(layout);
            }
        }

        private sealed class ReplacePanelForm : WinForms.Form
        {
            private readonly AiRibbonPlugin _owner;
            private readonly WinForms.TextBox _findTextBox;
            private readonly WinForms.Label _findSummaryLabel;
            private readonly WinForms.ListBox _findResultsListBox;
            private readonly WinForms.Label _ruleCountLabel;
            private readonly WinForms.Label _statusLabel;
            private readonly WinForms.Panel _rulesScroll;
            private readonly WinForms.TableLayoutPanel _rulesTable;
            private readonly System.Collections.Generic.List<ReplaceRuleRow> _ruleRows;
            private System.Collections.Generic.List<string> _targetSearchLines;
            private System.Collections.Generic.List<string> _targetValueLines;
            private string _syncedSearchText;
            private string _syncedValueText;
            private bool _syncing;
            private bool _dragging;
            private Draw.Point _dragStart;
            private WinForms.Timer _statusTimer;
            private const string DefaultStatusText =
                "提示：在 CAD 中选中文字后，编辑上方替换规则，点击“替换”或按 Ctrl+Enter 执行；ESC 关闭。";

            private sealed class ReplaceRuleRow
            {
                public WinForms.Panel Card;
                public WinForms.Label NumberLabel;
                public WinForms.TextBox SearchBox;
                public WinForms.TextBox ValueBox;
                public WinForms.Button SwapButton;
                public WinForms.Button CopyButton;
                public WinForms.Button RemoveButton;
            }

            public ReplacePanelForm(AiRibbonPlugin owner)
            {
                _owner = owner;
                _ruleRows = new System.Collections.Generic.List<ReplaceRuleRow>();
                _targetSearchLines = new System.Collections.Generic.List<string>();
                _targetValueLines = new System.Collections.Generic.List<string>();
                _syncedSearchText = string.Empty;
                _syncedValueText = string.Empty;
                _syncing = false;
                _dragging = false;

                Text = "文字替换";
                StartPosition = WinForms.FormStartPosition.CenterScreen;
                FormBorderStyle = WinForms.FormBorderStyle.None;
                ShowInTaskbar = false;
                KeyPreview = true;
                DoubleBuffered = true;
                MinimumSize = new Draw.Size(580, 620);
                ClientSize = new Draw.Size(630, 720);
                BackColor = Draw.Color.FromArgb(32, 32, 35);
                ForeColor = Draw.Color.FromArgb(224, 224, 224);
                Padding = new WinForms.Padding(1);

                // Root: title bar / content / status bar
                WinForms.TableLayoutPanel rootLayout = new WinForms.TableLayoutPanel();
                rootLayout.ColumnCount = 1;
                rootLayout.Dock = WinForms.DockStyle.Fill;
                rootLayout.Margin = new WinForms.Padding(0);
                rootLayout.BackColor = Draw.Color.FromArgb(37, 37, 40);
                rootLayout.ColumnStyles.Add(new WinForms.ColumnStyle(WinForms.SizeType.Percent, 100f));
                rootLayout.RowCount = 3;
                rootLayout.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Absolute, 34f));
                rootLayout.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Percent, 100f));
                rootLayout.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Absolute, 26f));

                // ---- Title bar ----
                WinForms.Panel titleBar = new WinForms.Panel();
                titleBar.Dock = WinForms.DockStyle.Fill;
                titleBar.BackColor = Draw.Color.FromArgb(42, 42, 46);
                titleBar.MouseDown += OnBackgroundMouseDown;
                titleBar.MouseMove += OnBackgroundMouseMove;
                titleBar.MouseUp += OnBackgroundMouseUp;

                WinForms.Label titleLabel = new WinForms.Label();
                titleLabel.AutoSize = true;
                titleLabel.Text = "文字替换";
                titleLabel.Font = new Draw.Font(Font.FontFamily, 10f, Draw.FontStyle.Bold);
                titleLabel.ForeColor = Draw.Color.FromArgb(240, 240, 240);
                titleLabel.Location = new Draw.Point(12, 8);
                titleLabel.MouseDown += OnBackgroundMouseDown;
                titleLabel.MouseMove += OnBackgroundMouseMove;
                titleLabel.MouseUp += OnBackgroundMouseUp;

                WinForms.FlowLayoutPanel titleButtons = new WinForms.FlowLayoutPanel();
                titleButtons.Dock = WinForms.DockStyle.Right;
                titleButtons.FlowDirection = WinForms.FlowDirection.RightToLeft;
                titleButtons.Width = 80;
                titleButtons.Margin = new WinForms.Padding(0);
                titleButtons.BackColor = Draw.Color.Transparent;

                WinForms.Button closeButton = new WinForms.Button();
                closeButton.Text = "\u00d7";
                closeButton.Size = new Draw.Size(34, 26);
                closeButton.FlatStyle = WinForms.FlatStyle.Flat;
                closeButton.FlatAppearance.BorderSize = 0;
                closeButton.FlatAppearance.MouseOverBackColor = Draw.Color.FromArgb(196, 43, 28);
                closeButton.BackColor = Draw.Color.FromArgb(42, 42, 46);
                closeButton.ForeColor = Draw.Color.FromArgb(220, 220, 220);
                closeButton.Cursor = WinForms.Cursors.Hand;
                closeButton.Font = new Draw.Font(Font.FontFamily, 11f, Draw.FontStyle.Bold);
                closeButton.Click += delegate { Close(); };

                WinForms.Button minButton = new WinForms.Button();
                minButton.Text = "－";
                minButton.Size = new Draw.Size(34, 26);
                minButton.FlatStyle = WinForms.FlatStyle.Flat;
                minButton.FlatAppearance.BorderSize = 0;
                minButton.FlatAppearance.MouseOverBackColor = Draw.Color.FromArgb(60, 60, 65);
                minButton.BackColor = Draw.Color.FromArgb(42, 42, 46);
                minButton.ForeColor = Draw.Color.FromArgb(200, 200, 200);
                minButton.Cursor = WinForms.Cursors.Hand;
                minButton.Font = new Draw.Font(Font.FontFamily, 9f, Draw.FontStyle.Regular);
                minButton.Click += delegate { Hide(); };

                titleButtons.Controls.Add(closeButton);
                titleButtons.Controls.Add(minButton);

                titleBar.Controls.Add(titleLabel);
                titleBar.Controls.Add(titleButtons);

                // ---- Content area ----
                WinForms.TableLayoutPanel content = new WinForms.TableLayoutPanel();
                content.ColumnCount = 1;
                content.Dock = WinForms.DockStyle.Fill;
                content.Padding = new WinForms.Padding(10, 6, 10, 6);
                content.Margin = new WinForms.Padding(0);
                content.BackColor = Draw.Color.FromArgb(32, 32, 35);
                content.ColumnStyles.Add(new WinForms.ColumnStyle(WinForms.SizeType.Percent, 100f));
                content.RowCount = 3;
                content.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Percent, 100f));
                content.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Absolute, 195f));
                content.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Absolute, 68f));

                // ================= GroupBox 1: batch replace rules =================
                WinForms.GroupBox rulesGroup = new WinForms.GroupBox();
                rulesGroup.Dock = WinForms.DockStyle.Fill;
                rulesGroup.Text = "  批量替换规则  ";
                rulesGroup.ForeColor = Draw.Color.FromArgb(215, 215, 215);
                rulesGroup.BackColor = Draw.Color.FromArgb(37, 37, 40);
                rulesGroup.Font = new Draw.Font(Font.FontFamily, 9f, Draw.FontStyle.Bold);
                rulesGroup.Padding = new WinForms.Padding(8, 4, 8, 6);

                WinForms.TableLayoutPanel rulesGroupLayout = new WinForms.TableLayoutPanel();
                rulesGroupLayout.ColumnCount = 1;
                rulesGroupLayout.Dock = WinForms.DockStyle.Fill;
                rulesGroupLayout.Margin = new WinForms.Padding(0);
                rulesGroupLayout.BackColor = Draw.Color.FromArgb(37, 37, 40);
                rulesGroupLayout.ColumnStyles.Add(new WinForms.ColumnStyle(WinForms.SizeType.Percent, 100f));
                rulesGroupLayout.RowCount = 2;
                rulesGroupLayout.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Absolute, 32f));
                rulesGroupLayout.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Percent, 100f));

                // toolbar: add-rule, paste clipboard, batch edit, export, clear + count
                WinForms.TableLayoutPanel rulesToolbar = new WinForms.TableLayoutPanel();
                rulesToolbar.ColumnCount = 6;
                rulesToolbar.Dock = WinForms.DockStyle.Fill;
                rulesToolbar.Margin = new WinForms.Padding(0, 0, 0, 4);
                rulesToolbar.BackColor = Draw.Color.FromArgb(37, 37, 40);
                rulesToolbar.ColumnStyles.Add(new WinForms.ColumnStyle(WinForms.SizeType.AutoSize));
                rulesToolbar.ColumnStyles.Add(new WinForms.ColumnStyle(WinForms.SizeType.AutoSize));
                rulesToolbar.ColumnStyles.Add(new WinForms.ColumnStyle(WinForms.SizeType.AutoSize));
                rulesToolbar.ColumnStyles.Add(new WinForms.ColumnStyle(WinForms.SizeType.AutoSize));
                rulesToolbar.ColumnStyles.Add(new WinForms.ColumnStyle(WinForms.SizeType.AutoSize));
                rulesToolbar.ColumnStyles.Add(new WinForms.ColumnStyle(WinForms.SizeType.Percent, 100f));
                rulesToolbar.RowCount = 1;
                rulesToolbar.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Percent, 100f));

                WinForms.Button addRuleButton = new WinForms.Button();
                addRuleButton.Text = "＋ 添加";
                addRuleButton.Size = new Draw.Size(68, 25);
                addRuleButton.FlatStyle = WinForms.FlatStyle.Flat;
                addRuleButton.FlatAppearance.BorderColor = Draw.Color.FromArgb(0, 150, 255);
                addRuleButton.BackColor = Draw.Color.FromArgb(45, 45, 50);
                addRuleButton.ForeColor = Draw.Color.FromArgb(0, 160, 255);
                addRuleButton.Cursor = WinForms.Cursors.Hand;
                addRuleButton.Font = new Draw.Font(Font.FontFamily, 8.5f, Draw.FontStyle.Regular);
                addRuleButton.Click += delegate { AddRuleRow(); };
                rulesToolbar.Controls.Add(addRuleButton, 0, 0);

                WinForms.Button pasteClipButton = new WinForms.Button();
                pasteClipButton.Text = "📋 粘贴剪贴板";
                pasteClipButton.Size = new Draw.Size(95, 25);
                pasteClipButton.FlatStyle = WinForms.FlatStyle.Flat;
                pasteClipButton.FlatAppearance.BorderColor = Draw.Color.FromArgb(70, 70, 75);
                pasteClipButton.BackColor = Draw.Color.FromArgb(45, 45, 50);
                pasteClipButton.ForeColor = Draw.Color.FromArgb(220, 220, 220);
                pasteClipButton.Cursor = WinForms.Cursors.Hand;
                pasteClipButton.Font = new Draw.Font(Font.FontFamily, 8.5f, Draw.FontStyle.Regular);
                pasteClipButton.Click += delegate { PasteRulesFromClipboard(true); };
                rulesToolbar.Controls.Add(pasteClipButton, 1, 0);

                WinForms.Button batchEditButton = new WinForms.Button();
                batchEditButton.Text = "📝 批量导入";
                batchEditButton.Size = new Draw.Size(85, 25);
                batchEditButton.FlatStyle = WinForms.FlatStyle.Flat;
                batchEditButton.FlatAppearance.BorderColor = Draw.Color.FromArgb(70, 70, 75);
                batchEditButton.BackColor = Draw.Color.FromArgb(45, 45, 50);
                batchEditButton.ForeColor = Draw.Color.FromArgb(220, 220, 220);
                batchEditButton.Cursor = WinForms.Cursors.Hand;
                batchEditButton.Font = new Draw.Font(Font.FontFamily, 8.5f, Draw.FontStyle.Regular);
                batchEditButton.Click += delegate { OpenBatchEditDialog(); };
                rulesToolbar.Controls.Add(batchEditButton, 2, 0);

                WinForms.Button exportAllButton = new WinForms.Button();
                exportAllButton.Text = "📤 复制全部";
                exportAllButton.Size = new Draw.Size(85, 25);
                exportAllButton.FlatStyle = WinForms.FlatStyle.Flat;
                exportAllButton.FlatAppearance.BorderColor = Draw.Color.FromArgb(70, 70, 75);
                exportAllButton.BackColor = Draw.Color.FromArgb(45, 45, 50);
                exportAllButton.ForeColor = Draw.Color.FromArgb(220, 220, 220);
                exportAllButton.Cursor = WinForms.Cursors.Hand;
                exportAllButton.Font = new Draw.Font(Font.FontFamily, 8.5f, Draw.FontStyle.Regular);
                exportAllButton.Click += delegate { ExportAllRulesToClipboard(); };
                rulesToolbar.Controls.Add(exportAllButton, 3, 0);

                WinForms.Button clearButton = new WinForms.Button();
                clearButton.Text = "🗑 清空";
                clearButton.Size = new Draw.Size(65, 25);
                clearButton.FlatStyle = WinForms.FlatStyle.Flat;
                clearButton.FlatAppearance.BorderColor = Draw.Color.FromArgb(70, 70, 75);
                clearButton.BackColor = Draw.Color.FromArgb(45, 45, 50);
                clearButton.ForeColor = Draw.Color.FromArgb(190, 190, 190);
                clearButton.Cursor = WinForms.Cursors.Hand;
                clearButton.Font = new Draw.Font(Font.FontFamily, 8.5f, Draw.FontStyle.Regular);
                clearButton.Click += delegate { ResetAllRules(); };
                rulesToolbar.Controls.Add(clearButton, 4, 0);

                _ruleCountLabel = new WinForms.Label();
                _ruleCountLabel.AutoSize = true;
                _ruleCountLabel.Text = "共 1 条规则";
                _ruleCountLabel.Anchor = WinForms.AnchorStyles.Right;
                _ruleCountLabel.ForeColor = Draw.Color.FromArgb(160, 160, 160);
                _ruleCountLabel.Font = new Draw.Font(Font.FontFamily, 8.5f, Draw.FontStyle.Regular);
                rulesToolbar.Controls.Add(_ruleCountLabel, 5, 0);
                rulesGroupLayout.Controls.Add(rulesToolbar, 0, 0);

                // scrollable rule cards
                _rulesScroll = new WinForms.Panel();
                _rulesScroll.Dock = WinForms.DockStyle.Fill;
                _rulesScroll.AutoScroll = true;
                _rulesScroll.BackColor = Draw.Color.FromArgb(32, 32, 35);
                _rulesScroll.Margin = new WinForms.Padding(0);

                _rulesTable = new WinForms.TableLayoutPanel();
                _rulesTable.ColumnCount = 1;
                _rulesTable.Dock = WinForms.DockStyle.Top;
                _rulesTable.AutoSize = true;
                _rulesTable.AutoSizeMode = WinForms.AutoSizeMode.GrowAndShrink;
                _rulesTable.Margin = new WinForms.Padding(0);
                _rulesTable.BackColor = Draw.Color.FromArgb(32, 32, 35);
                _rulesTable.ColumnStyles.Add(new WinForms.ColumnStyle(WinForms.SizeType.Percent, 100f));
                _rulesTable.RowCount = 0;

                _rulesScroll.Controls.Add(_rulesTable);
                rulesGroupLayout.Controls.Add(_rulesScroll, 0, 1);
                rulesGroup.Controls.Add(rulesGroupLayout);
                content.Controls.Add(rulesGroup, 0, 0);

                // ================= GroupBox 2: current selection find =================
                WinForms.GroupBox findGroup = new WinForms.GroupBox();
                findGroup.Dock = WinForms.DockStyle.Fill;
                findGroup.Text = "  查找当前选中文字  ";
                findGroup.ForeColor = Draw.Color.FromArgb(215, 215, 215);
                findGroup.BackColor = Draw.Color.FromArgb(37, 37, 40);
                findGroup.Font = new Draw.Font(Font.FontFamily, 9f, Draw.FontStyle.Bold);
                findGroup.Padding = new WinForms.Padding(8, 2, 8, 6);

                WinForms.TableLayoutPanel findLayout = new WinForms.TableLayoutPanel();
                findLayout.ColumnCount = 3;
                findLayout.Dock = WinForms.DockStyle.Fill;
                findLayout.Margin = new WinForms.Padding(0);
                findLayout.BackColor = Draw.Color.FromArgb(37, 37, 40);
                findLayout.ColumnStyles.Add(new WinForms.ColumnStyle(WinForms.SizeType.AutoSize));
                findLayout.ColumnStyles.Add(new WinForms.ColumnStyle(WinForms.SizeType.Percent, 100f));
                findLayout.ColumnStyles.Add(new WinForms.ColumnStyle(WinForms.SizeType.AutoSize));
                findLayout.RowCount = 3;
                findLayout.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Absolute, 28f));
                findLayout.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Absolute, 24f));
                findLayout.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Percent, 100f));

                WinForms.Label findLabel = new WinForms.Label();
                findLabel.AutoSize = true;
                findLabel.Text = "查找:";
                findLabel.Anchor = WinForms.AnchorStyles.Left;
                findLabel.Margin = new WinForms.Padding(0, 2, 8, 0);
                findLabel.ForeColor = Draw.Color.FromArgb(180, 180, 180);
                findLabel.Font = new Draw.Font(Font.FontFamily, 9f, Draw.FontStyle.Regular);
                findLayout.Controls.Add(findLabel, 0, 0);

                _findTextBox = new WinForms.TextBox();
                _findTextBox.Dock = WinForms.DockStyle.Fill;
                _findTextBox.Margin = new WinForms.Padding(0, 2, 8, 0);
                _findTextBox.BackColor = Draw.Color.FromArgb(48, 48, 52);
                _findTextBox.ForeColor = Draw.Color.FromArgb(230, 230, 230);
                _findTextBox.BorderStyle = WinForms.BorderStyle.FixedSingle;
                _findTextBox.TextChanged += OnFindTextChanged;
                _findTextBox.KeyDown += OnFindTextBoxKeyDown;
                SetCueBanner(_findTextBox, "输入要在当前选中文字中查找的内容...");
                findLayout.Controls.Add(_findTextBox, 1, 0);

                WinForms.Button findButton = new WinForms.Button();
                findButton.Text = "查找";
                findButton.Size = new Draw.Size(72, 26);
                findButton.Anchor = WinForms.AnchorStyles.Right;
                findButton.FlatStyle = WinForms.FlatStyle.Flat;
                findButton.BackColor = Draw.Color.FromArgb(0, 122, 204);
                findButton.ForeColor = Draw.Color.White;
                findButton.Cursor = WinForms.Cursors.Hand;
                findButton.Font = new Draw.Font(Font.FontFamily, 9f, Draw.FontStyle.Regular);
                findButton.Click += OnFindButtonClick;
                findLayout.Controls.Add(findButton, 2, 0);

                _findSummaryLabel = new WinForms.Label();
                _findSummaryLabel.AutoSize = true;
                _findSummaryLabel.Text = "在当前选中的文字中查找，结果将显示在下方";
                _findSummaryLabel.Anchor = WinForms.AnchorStyles.Left;
                _findSummaryLabel.ForeColor = Draw.Color.FromArgb(140, 140, 140);
                _findSummaryLabel.Font = new Draw.Font(Font.FontFamily, 8.5f, Draw.FontStyle.Regular);
                findLayout.SetColumnSpan(_findSummaryLabel, 3);
                findLayout.Controls.Add(_findSummaryLabel, 0, 1);

                _findResultsListBox = new WinForms.ListBox();
                _findResultsListBox.Dock = WinForms.DockStyle.Fill;
                _findResultsListBox.Margin = new WinForms.Padding(0, 2, 0, 0);
                _findResultsListBox.BackColor = Draw.Color.FromArgb(42, 42, 46);
                _findResultsListBox.ForeColor = Draw.Color.FromArgb(224, 224, 224);
                _findResultsListBox.BorderStyle = WinForms.BorderStyle.FixedSingle;
                _findResultsListBox.HorizontalScrollbar = true;
                _findResultsListBox.IntegralHeight = false;
                _findResultsListBox.Font = new Draw.Font(Font.FontFamily, 9f, Draw.FontStyle.Regular);
                _findResultsListBox.DoubleClick += OnFindResultsListBoxDoubleClick;
                _findResultsListBox.KeyDown += OnFindResultsListBoxKeyDown;
                findLayout.SetColumnSpan(_findResultsListBox, 3);
                findLayout.Controls.Add(_findResultsListBox, 0, 2);
                findGroup.Controls.Add(findLayout);
                content.Controls.Add(findGroup, 0, 1);

                // ================= GroupBox 3: actions =================
                WinForms.GroupBox actionGroup = new WinForms.GroupBox();
                actionGroup.Dock = WinForms.DockStyle.Fill;
                actionGroup.Text = "  操作  ";
                actionGroup.ForeColor = Draw.Color.FromArgb(215, 215, 215);
                actionGroup.BackColor = Draw.Color.FromArgb(37, 37, 40);
                actionGroup.Font = new Draw.Font(Font.FontFamily, 9f, Draw.FontStyle.Bold);
                actionGroup.Padding = new WinForms.Padding(8, 2, 8, 6);

                WinForms.TableLayoutPanel actionLayout = new WinForms.TableLayoutPanel();
                actionLayout.ColumnCount = 2;
                actionLayout.Dock = WinForms.DockStyle.Fill;
                actionLayout.Margin = new WinForms.Padding(0);
                actionLayout.BackColor = Draw.Color.FromArgb(37, 37, 40);
                actionLayout.ColumnStyles.Add(new WinForms.ColumnStyle(WinForms.SizeType.Percent, 100f));
                actionLayout.ColumnStyles.Add(new WinForms.ColumnStyle(WinForms.SizeType.AutoSize));
                actionLayout.RowCount = 1;
                actionLayout.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Percent, 100f));

                WinForms.Label actionHint = new WinForms.Label();
                actionHint.AutoSize = true;
                actionHint.Text = "替换将作用于 CAD 中当前选中的 TEXT/MTEXT 文字";
                actionHint.Anchor = WinForms.AnchorStyles.Left;
                actionHint.ForeColor = Draw.Color.FromArgb(160, 160, 160);
                actionHint.Font = new Draw.Font(Font.FontFamily, 8.5f, Draw.FontStyle.Regular);
                actionLayout.Controls.Add(actionHint, 0, 0);

                WinForms.Button replaceButton = new WinForms.Button();
                replaceButton.Text = "替换  (Ctrl+Enter)";
                replaceButton.Size = new Draw.Size(170, 30);
                replaceButton.Anchor = WinForms.AnchorStyles.Right;
                replaceButton.FlatStyle = WinForms.FlatStyle.Flat;
                replaceButton.BackColor = Draw.Color.FromArgb(0, 122, 204);
                replaceButton.ForeColor = Draw.Color.White;
                replaceButton.Cursor = WinForms.Cursors.Hand;
                replaceButton.Font = new Draw.Font(Font.FontFamily, 9.5f, Draw.FontStyle.Bold);
                replaceButton.Click += OnReplaceButtonClick;
                actionLayout.Controls.Add(replaceButton, 1, 0);
                actionGroup.Controls.Add(actionLayout);
                content.Controls.Add(actionGroup, 0, 2);

                // ---- Status bar ----
                _statusLabel = new WinForms.Label();
                _statusLabel.Dock = WinForms.DockStyle.Fill;
                _statusLabel.Text = DefaultStatusText;
                _statusLabel.TextAlign = Draw.ContentAlignment.MiddleLeft;
                _statusLabel.Padding = new WinForms.Padding(12, 0, 0, 0);
                _statusLabel.BackColor = Draw.Color.FromArgb(30, 30, 32);
                _statusLabel.ForeColor = Draw.Color.FromArgb(160, 160, 160);
                _statusLabel.Font = new Draw.Font(Font.FontFamily, 8.5f, Draw.FontStyle.Regular);

                _statusTimer = new WinForms.Timer();
                _statusTimer.Interval = 4000;
                _statusTimer.Tick += delegate
                {
                    _statusTimer.Stop();
                    _statusLabel.Text = DefaultStatusText;
                };

                rootLayout.Controls.Add(titleBar, 0, 0);
                rootLayout.Controls.Add(content, 0, 1);
                rootLayout.Controls.Add(_statusLabel, 0, 2);
                Controls.Add(rootLayout);
            }

            protected override WinForms.CreateParams CreateParams
            {
                get
                {
                    WinForms.CreateParams cp = base.CreateParams;
                    cp.ExStyle &= ~0x200;
                    return cp;
                }
            }

            protected override void OnPaint(WinForms.PaintEventArgs e)
            {
                base.OnPaint(e);
                using (Draw.Pen borderPen = new Draw.Pen(Draw.Color.FromArgb(0, 122, 204), 1))
                {
                    e.Graphics.DrawRectangle(borderPen, 0, 0, ClientSize.Width - 1, ClientSize.Height - 1);
                }
            }

            protected override void OnKeyDown(WinForms.KeyEventArgs e)
            {
                if (e.KeyCode == WinForms.Keys.Escape)
                {
                    // ESC 只隐藏面板，保留规则控件和当前输入，重新打开时继续使用原规则。
                    Hide();
                    e.Handled = true;
                    return;
                }
                base.OnKeyDown(e);
            }

            // ---- Rule card management ----

            private void AddRuleRow()
            {
                _syncing = true;
                ReplaceRuleRow row;
                try
                {
                    row = AddRuleRowCore(string.Empty, string.Empty);
                }
                finally
                {
                    _syncing = false;
                }
                RenumberRules();
                UpdateRuleCount();
                if (row != null)
                {
                    row.SearchBox.Focus();
                }
            }

            private ReplaceRuleRow AddRuleRowCore(string searchText, string valueText)
            {
                ReplaceRuleRow row = new ReplaceRuleRow();

                WinForms.Panel card = new WinForms.Panel();
                card.Dock = WinForms.DockStyle.Top;
                card.Height = 82;
                card.Margin = new WinForms.Padding(0, 3, 0, 3);
                card.BackColor = Draw.Color.FromArgb(44, 44, 48);
                card.BorderStyle = WinForms.BorderStyle.FixedSingle;
                row.Card = card;

                WinForms.TableLayoutPanel inner = new WinForms.TableLayoutPanel();
                inner.Dock = WinForms.DockStyle.Fill;
                inner.ColumnCount = 2;
                inner.Padding = new WinForms.Padding(6, 4, 6, 4);
                inner.BackColor = Draw.Color.FromArgb(44, 44, 48);
                inner.ColumnStyles.Add(new WinForms.ColumnStyle(WinForms.SizeType.Percent, 100f));
                inner.ColumnStyles.Add(new WinForms.ColumnStyle(WinForms.SizeType.AutoSize));
                inner.RowCount = 3;
                inner.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Absolute, 22f));
                inner.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Absolute, 25f));
                inner.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Absolute, 25f));

                // Row 0: number badge + actions
                WinForms.FlowLayoutPanel numberFlow = new WinForms.FlowLayoutPanel();
                numberFlow.Dock = WinForms.DockStyle.Fill;
                numberFlow.FlowDirection = WinForms.FlowDirection.LeftToRight;
                numberFlow.WrapContents = false;
                numberFlow.BackColor = Draw.Color.FromArgb(44, 44, 48);
                numberFlow.Margin = new WinForms.Padding(0);

                WinForms.Label number = new WinForms.Label();
                number.AutoSize = false;
                number.Size = new Draw.Size(26, 18);
                number.Text = "1";
                number.TextAlign = Draw.ContentAlignment.MiddleCenter;
                number.Margin = new WinForms.Padding(0, 1, 6, 0);
                number.BackColor = Draw.Color.FromArgb(0, 122, 204);
                number.ForeColor = Draw.Color.White;
                number.Font = new Draw.Font(Font.FontFamily, 8.5f, Draw.FontStyle.Bold);
                row.NumberLabel = number;

                WinForms.Label caption = new WinForms.Label();
                caption.AutoSize = true;
                caption.Text = "规则";
                caption.Anchor = WinForms.AnchorStyles.Left;
                caption.Margin = new WinForms.Padding(0, 2, 0, 0);
                caption.ForeColor = Draw.Color.FromArgb(160, 160, 160);
                caption.Font = new Draw.Font(Font.FontFamily, 8.5f, Draw.FontStyle.Regular);

                numberFlow.Controls.Add(number);
                numberFlow.Controls.Add(caption);
                inner.Controls.Add(numberFlow, 0, 0);

                // Actions: Swap, Duplicate, Delete
                WinForms.FlowLayoutPanel actionFlow = new WinForms.FlowLayoutPanel();
                actionFlow.Dock = WinForms.DockStyle.Fill;
                actionFlow.FlowDirection = WinForms.FlowDirection.RightToLeft;
                actionFlow.WrapContents = false;
                actionFlow.BackColor = Draw.Color.FromArgb(44, 44, 48);
                actionFlow.Margin = new WinForms.Padding(0);

                WinForms.Button removeButton = new WinForms.Button();
                removeButton.Text = "\u00d7";
                removeButton.Size = new Draw.Size(22, 20);
                removeButton.FlatStyle = WinForms.FlatStyle.Flat;
                removeButton.FlatAppearance.BorderSize = 0;
                removeButton.FlatAppearance.MouseOverBackColor = Draw.Color.FromArgb(196, 43, 28);
                removeButton.BackColor = Draw.Color.FromArgb(44, 44, 48);
                removeButton.ForeColor = Draw.Color.FromArgb(180, 180, 180);
                removeButton.Cursor = WinForms.Cursors.Hand;
                removeButton.Font = new Draw.Font(Font.FontFamily, 9f, Draw.FontStyle.Bold);
                removeButton.Click += delegate { RemoveRuleRow(row); };
                row.RemoveButton = removeButton;

                WinForms.Button copyButton = new WinForms.Button();
                copyButton.Text = "📄 复制";
                copyButton.Size = new Draw.Size(56, 20);
                copyButton.FlatStyle = WinForms.FlatStyle.Flat;
                copyButton.FlatAppearance.BorderSize = 0;
                copyButton.FlatAppearance.MouseOverBackColor = Draw.Color.FromArgb(60, 60, 66);
                copyButton.BackColor = Draw.Color.FromArgb(44, 44, 48);
                copyButton.ForeColor = Draw.Color.FromArgb(180, 180, 180);
                copyButton.Cursor = WinForms.Cursors.Hand;
                copyButton.Font = new Draw.Font(Font.FontFamily, 8f, Draw.FontStyle.Regular);
                copyButton.Click += delegate { DuplicateRuleRow(row); };
                row.CopyButton = copyButton;

                WinForms.Button swapButton = new WinForms.Button();
                swapButton.Text = "⇄ 互换";
                swapButton.Size = new Draw.Size(56, 20);
                swapButton.FlatStyle = WinForms.FlatStyle.Flat;
                swapButton.FlatAppearance.BorderSize = 0;
                swapButton.FlatAppearance.MouseOverBackColor = Draw.Color.FromArgb(60, 60, 66);
                swapButton.BackColor = Draw.Color.FromArgb(44, 44, 48);
                swapButton.ForeColor = Draw.Color.FromArgb(180, 180, 180);
                swapButton.Cursor = WinForms.Cursors.Hand;
                swapButton.Font = new Draw.Font(Font.FontFamily, 8f, Draw.FontStyle.Regular);
                swapButton.Click += delegate { SwapRuleRow(row); };
                row.SwapButton = swapButton;

                actionFlow.Controls.Add(removeButton);
                actionFlow.Controls.Add(copyButton);
                actionFlow.Controls.Add(swapButton);
                inner.Controls.Add(actionFlow, 1, 0);

                // Row 1: Search Box row
                WinForms.TableLayoutPanel searchLine = new WinForms.TableLayoutPanel();
                searchLine.Dock = WinForms.DockStyle.Fill;
                searchLine.ColumnCount = 2;
                searchLine.Margin = new WinForms.Padding(0, 1, 0, 1);
                searchLine.ColumnStyles.Add(new WinForms.ColumnStyle(WinForms.SizeType.Absolute, 42f));
                searchLine.ColumnStyles.Add(new WinForms.ColumnStyle(WinForms.SizeType.Percent, 100f));
                searchLine.RowCount = 1;

                WinForms.Label searchLbl = new WinForms.Label();
                searchLbl.Text = "查找:";
                searchLbl.Dock = WinForms.DockStyle.Fill;
                searchLbl.TextAlign = Draw.ContentAlignment.MiddleLeft;
                searchLbl.ForeColor = Draw.Color.FromArgb(170, 170, 170);
                searchLbl.Font = new Draw.Font(Font.FontFamily, 8.5f, Draw.FontStyle.Regular);
                searchLine.Controls.Add(searchLbl, 0, 0);

                WinForms.TextBox searchBox = new WinForms.TextBox();
                searchBox.Dock = WinForms.DockStyle.Fill;
                searchBox.Margin = new WinForms.Padding(0);
                searchBox.BackColor = Draw.Color.FromArgb(28, 28, 30);
                searchBox.ForeColor = Draw.Color.FromArgb(235, 235, 235);
                searchBox.BorderStyle = WinForms.BorderStyle.FixedSingle;
                searchBox.Font = new Draw.Font(Font.FontFamily, 9.5f, Draw.FontStyle.Regular);
                searchBox.Text = searchText ?? string.Empty;
                searchBox.TextChanged += OnRuleBoxTextChanged;
                searchBox.KeyDown += OnRuleBoxKeyDown;
                SetCueBanner(searchBox, "输入要查找的内容...");
                row.SearchBox = searchBox;
                searchLine.Controls.Add(searchBox, 1, 0);

                inner.SetColumnSpan(searchLine, 2);
                inner.Controls.Add(searchLine, 0, 1);

                // Row 2: Value Box row
                WinForms.TableLayoutPanel valueLine = new WinForms.TableLayoutPanel();
                valueLine.Dock = WinForms.DockStyle.Fill;
                valueLine.ColumnCount = 2;
                valueLine.Margin = new WinForms.Padding(0, 1, 0, 1);
                valueLine.ColumnStyles.Add(new WinForms.ColumnStyle(WinForms.SizeType.Absolute, 42f));
                valueLine.ColumnStyles.Add(new WinForms.ColumnStyle(WinForms.SizeType.Percent, 100f));
                valueLine.RowCount = 1;

                WinForms.Label valueLbl = new WinForms.Label();
                valueLbl.Text = "替换:";
                valueLbl.Dock = WinForms.DockStyle.Fill;
                valueLbl.TextAlign = Draw.ContentAlignment.MiddleLeft;
                valueLbl.ForeColor = Draw.Color.FromArgb(170, 170, 170);
                valueLbl.Font = new Draw.Font(Font.FontFamily, 8.5f, Draw.FontStyle.Regular);
                valueLine.Controls.Add(valueLbl, 0, 0);

                WinForms.TextBox valueBox = new WinForms.TextBox();
                valueBox.Dock = WinForms.DockStyle.Fill;
                valueBox.Margin = new WinForms.Padding(0);
                valueBox.BackColor = Draw.Color.FromArgb(28, 28, 30);
                valueBox.ForeColor = Draw.Color.FromArgb(235, 235, 235);
                valueBox.BorderStyle = WinForms.BorderStyle.FixedSingle;
                valueBox.Font = new Draw.Font(Font.FontFamily, 9.5f, Draw.FontStyle.Regular);
                valueBox.Text = valueText ?? string.Empty;
                valueBox.TextChanged += OnRuleBoxTextChanged;
                valueBox.KeyDown += OnRuleBoxKeyDown;
                SetCueBanner(valueBox, "替换为 (留空表示删除)...");
                row.ValueBox = valueBox;
                valueLine.Controls.Add(valueBox, 1, 0);

                inner.SetColumnSpan(valueLine, 2);
                inner.Controls.Add(valueLine, 0, 2);

                card.Controls.Add(inner);
                _rulesTable.Controls.Add(card);
                _rulesTable.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Absolute, 88f));
                _ruleRows.Add(row);

                if (!_syncing)
                {
                    SyncRulesToOwner();
                }

                return row;
            }

            private void DuplicateRuleRow(ReplaceRuleRow sourceRow)
            {
                int index = _ruleRows.IndexOf(sourceRow);
                string search = sourceRow.SearchBox.Text;
                string value = sourceRow.ValueBox.Text;

                _syncing = true;
                ReplaceRuleRow newRow;
                try
                {
                    newRow = AddRuleRowCore(search, value);
                    if (index >= 0 && index < _ruleRows.Count - 1)
                    {
                        // 移动到紧邻下方
                        _ruleRows.Remove(newRow);
                        _ruleRows.Insert(index + 1, newRow);
                        RebuildTableCards();
                    }
                }
                finally
                {
                    _syncing = false;
                }

                RenumberRules();
                UpdateRuleCount();
                SyncRulesToOwner();

                newRow.SearchBox.Focus();
                newRow.SearchBox.SelectAll();
                FlashStatus("已复制第 " + (index + 1) + " 条规则到新行");
            }

            private void SwapRuleRow(ReplaceRuleRow row)
            {
                string temp = row.SearchBox.Text;
                row.SearchBox.Text = row.ValueBox.Text;
                row.ValueBox.Text = temp;
                SyncRulesToOwner();
                FlashStatus("已互换查找与替换内容");
            }

            private void RemoveRuleRow(ReplaceRuleRow row)
            {
                if (_ruleRows.Count <= 1)
                {
                    row.SearchBox.Text = string.Empty;
                    row.ValueBox.Text = string.Empty;
                    SyncRulesToOwner();
                    FlashStatus("已清空当前规则");
                    return;
                }
                _rulesTable.Controls.Remove(row.Card);
                row.Card.Dispose();
                _ruleRows.Remove(row);
                RebuildTableCards();
                RenumberRules();
                UpdateRuleCount();
                SyncRulesToOwner();
            }

            private void RebuildTableCards()
            {
                _rulesTable.SuspendLayout();
                _rulesTable.Controls.Clear();
                _rulesTable.RowStyles.Clear();
                foreach (ReplaceRuleRow r in _ruleRows)
                {
                    _rulesTable.Controls.Add(r.Card);
                    _rulesTable.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Absolute, 88f));
                }
                _rulesTable.ResumeLayout(true);
            }

            private void RenumberRules()
            {
                for (int i = 0; i < _ruleRows.Count; i++)
                {
                    _ruleRows[i].NumberLabel.Text = (i + 1).ToString();
                }
            }

            private void UpdateRuleCount()
            {
                _ruleCountLabel.Text = "共 " + _ruleRows.Count.ToString() + " 条规则";
            }

            private void ResetAllRules()
            {
                _syncing = true;
                try
                {
                    _rulesTable.Controls.Clear();
                    _rulesTable.RowStyles.Clear();
                    foreach (ReplaceRuleRow r in _ruleRows)
                    {
                        r.Card.Dispose();
                    }
                    _ruleRows.Clear();
                    AddRuleRowCore(string.Empty, string.Empty);
                }
                finally
                {
                    _syncing = false;
                }
                RenumberRules();
                UpdateRuleCount();
                SyncRulesToOwner();
                FlashStatus("已重置所有替换规则");
            }

            private void PasteRulesFromClipboard(bool append)
            {
                string clip = null;
                try
                {
                    if (WinForms.Clipboard.ContainsText())
                    {
                        clip = WinForms.Clipboard.GetText();
                    }
                }
                catch
                {
                }

                if (string.IsNullOrWhiteSpace(clip))
                {
                    FlashStatus("剪贴板中没有文本内容");
                    return;
                }

                List<string[]> pairs = ParseRulesFromText(clip);
                if (pairs.Count == 0)
                {
                    FlashStatus("未从剪贴板识别出有效规则");
                    return;
                }

                ApplyParsedRules(pairs, append);
                FlashStatus("已从剪贴板" + (append ? "追加" : "导入") + " " + pairs.Count + " 条规则");
            }

            private void OpenBatchEditDialog()
            {
                // 将现有规则导出为文本供编辑
                List<string> lines = new List<string>();
                foreach (ReplaceRuleRow row in _ruleRows)
                {
                    if (!string.IsNullOrEmpty(row.SearchBox.Text) || !string.IsNullOrEmpty(row.ValueBox.Text))
                    {
                        lines.Add(row.SearchBox.Text + "\t" + row.ValueBox.Text);
                    }
                }

                string currentText = string.Join("\r\n", lines);
                if (string.IsNullOrEmpty(currentText))
                {
                    try
                    {
                        if (WinForms.Clipboard.ContainsText())
                        {
                            currentText = WinForms.Clipboard.GetText();
                        }
                    }
                    catch
                    {
                    }
                }

                using (BatchRulesDialogForm dlg = new BatchRulesDialogForm(currentText))
                {
                    if (dlg.ShowDialog(this) == WinForms.DialogResult.OK && dlg.ParsedRules != null && dlg.ParsedRules.Count > 0)
                    {
                        ApplyParsedRules(dlg.ParsedRules, dlg.IsAppend);
                        FlashStatus("已批量导入 " + dlg.ParsedRules.Count + " 条规则");
                    }
                }
            }

            private void ExportAllRulesToClipboard()
            {
                List<string> lines = new List<string>();
                foreach (ReplaceRuleRow row in _ruleRows)
                {
                    if (!string.IsNullOrEmpty(row.SearchBox.Text) || !string.IsNullOrEmpty(row.ValueBox.Text))
                    {
                        lines.Add(row.SearchBox.Text + "\t" + row.ValueBox.Text);
                    }
                }

                if (lines.Count == 0)
                {
                    FlashStatus("当前没有非空的替换规则可复制");
                    return;
                }

                string text = string.Join("\r\n", lines);
                try
                {
                    WinForms.Clipboard.SetText(text);
                    FlashStatus("已复制 " + lines.Count + " 条规则到剪贴板 (Excel 制表符格式)");
                }
                catch (System.Exception ex)
                {
                    FlashStatus("复制到剪贴板失败: " + ex.Message);
                }
            }

            private void ApplyParsedRules(List<string[]> pairs, bool append)
            {
                _syncing = true;
                try
                {
                    if (!append)
                    {
                        _rulesTable.Controls.Clear();
                        _rulesTable.RowStyles.Clear();
                        foreach (ReplaceRuleRow r in _ruleRows)
                        {
                            r.Card.Dispose();
                        }
                        _ruleRows.Clear();
                    }
                    else if (_ruleRows.Count == 1 && string.IsNullOrEmpty(_ruleRows[0].SearchBox.Text) && string.IsNullOrEmpty(_ruleRows[0].ValueBox.Text))
                    {
                        // 如果仅有一条空白规则，直接覆盖
                        _rulesTable.Controls.Clear();
                        _rulesTable.RowStyles.Clear();
                        _ruleRows[0].Card.Dispose();
                        _ruleRows.Clear();
                    }

                    foreach (string[] pair in pairs)
                    {
                        AddRuleRowCore(pair[0], pair[1]);
                    }
                }
                finally
                {
                    _syncing = false;
                }

                RenumberRules();
                UpdateRuleCount();
                SyncRulesToOwner();
            }

            // ---- External sync ----

            private void SyncRulesToOwner()
            {
                if (_syncing)
                {
                    return;
                }
                System.Collections.Generic.List<string> searchLines =
                    new System.Collections.Generic.List<string>();
                System.Collections.Generic.List<string> valueLines =
                    new System.Collections.Generic.List<string>();
                foreach (ReplaceRuleRow row in _ruleRows)
                {
                    searchLines.Add(row.SearchBox.Text);
                    valueLines.Add(row.ValueBox.Text);
                }
                _syncedSearchText = string.Join("\n", searchLines);
                _syncedValueText = string.Join("\n", valueLines);
                _owner._replacePanelSuppressSync = true;
                try
                {
                    _owner.UpdateReplaceSearchText(_syncedSearchText);
                    _owner.UpdateReplaceValueText(_syncedValueText);
                }
                finally
                {
                    _owner._replacePanelSuppressSync = false;
                }
            }

            private void RebuildRulesFromTargets()
            {
                _syncing = true;
                try
                {
                    _rulesTable.Controls.Clear();
                    _rulesTable.RowStyles.Clear();
                    _ruleRows.Clear();
                    int count = System.Math.Max(_targetSearchLines.Count, _targetValueLines.Count);
                    if (count < 1)
                    {
                        count = 1;
                    }
                    for (int i = 0; i < count; i++)
                    {
                        string search = i < _targetSearchLines.Count ? _targetSearchLines[i] : string.Empty;
                        string value = i < _targetValueLines.Count ? _targetValueLines[i] : string.Empty;
                        AddRuleRowCore(search, value);
                    }
                    RenumberRules();
                    UpdateRuleCount();
                }
                finally
                {
                    _syncing = false;
                }
            }

            public void SetReplaceSearchText(string value)
            {
                string text = value ?? string.Empty;
                bool sameAsPanel = string.Equals(_syncedSearchText, text, StringComparison.Ordinal);
                if (sameAsPanel && _ruleRows.Count > 0)
                {
                    return;
                }
                _targetSearchLines = new System.Collections.Generic.List<string>(SplitLines(text));
                RebuildRulesFromTargets();
            }

            public void SetReplaceValueText(string value)
            {
                string text = value ?? string.Empty;
                bool sameAsPanel = string.Equals(_syncedValueText, text, StringComparison.Ordinal);
                if (sameAsPanel && _ruleRows.Count > 0)
                {
                    return;
                }
                _targetValueLines = new System.Collections.Generic.List<string>(SplitLines(text));
                RebuildRulesFromTargets();
            }

            public void FocusReplaceSearchBox()
            {
                if (_ruleRows.Count > 0)
                {
                    _ruleRows[0].SearchBox.Focus();
                    _ruleRows[0].SearchBox.SelectAll();
                }
                else
                {
                    AddRuleRow();
                }
            }

            public void FocusReplaceValueBox()
            {
                if (_ruleRows.Count > 0)
                {
                    _ruleRows[0].ValueBox.Focus();
                    _ruleRows[0].ValueBox.SelectAll();
                }
                else
                {
                    AddRuleRow();
                }
            }

            public void SetFindText(string value)
            {
                string text = value ?? string.Empty;
                if (_findTextBox.Text != text)
                {
                    _findTextBox.Text = text;
                }
            }

            public void SetFindMatches(string searchText, FindMatchItem[] matches)
            {
                string text = searchText ?? string.Empty;
                FindMatchItem[] items = matches ?? new FindMatchItem[0];

                _findSummaryLabel.Text = "查找“" + text + "”，共 " + items.Length +
                    " 条" + (items.Length > 0 ? "；双击或按 Enter 定位" : string.Empty);
                _findSummaryLabel.ForeColor = items.Length > 0
                    ? Draw.Color.FromArgb(180, 180, 180)
                    : Draw.Color.FromArgb(220, 150, 90);

                _findResultsListBox.BeginUpdate();
                try
                {
                    _findResultsListBox.Items.Clear();
                    foreach (FindMatchItem item in items)
                    {
                        _findResultsListBox.Items.Add(item);
                    }
                }
                finally
                {
                    _findResultsListBox.EndUpdate();
                }

                if (_findResultsListBox.Items.Count > 0)
                {
                    _findResultsListBox.SelectedIndex = 0;
                }
            }

            public void FocusFindBox()
            {
                _findTextBox.Focus();
                _findTextBox.SelectAll();
            }

            private void OnBackgroundMouseDown(object sender, WinForms.MouseEventArgs e)
            {
                if (e.Button == WinForms.MouseButtons.Left)
                {
                    _dragging = true;
                    _dragStart = e.Location;
                }
            }

            private void OnBackgroundMouseMove(object sender, WinForms.MouseEventArgs e)
            {
                if (_dragging)
                {
                    Draw.Point screenPos = ((WinForms.Control)sender).PointToScreen(e.Location);
                    Location = new Draw.Point(screenPos.X - _dragStart.X, screenPos.Y - _dragStart.Y);
                }
            }

            private void OnBackgroundMouseUp(object sender, WinForms.MouseEventArgs e)
            {
                _dragging = false;
            }

            private void OnRuleBoxTextChanged(object sender, EventArgs e)
            {
                SyncRulesToOwner();
            }

            private void OnRuleBoxKeyDown(object sender, WinForms.KeyEventArgs e)
            {
                WinForms.TextBox currentBox = sender as WinForms.TextBox;
                ReplaceRuleRow currentRow = null;
                foreach (ReplaceRuleRow r in _ruleRows)
                {
                    if (r.SearchBox == currentBox || r.ValueBox == currentBox)
                    {
                        currentRow = r;
                        break;
                    }
                }

                // Ctrl+Enter: 立即执行替换
                if (e.KeyCode == WinForms.Keys.Enter && e.Control)
                {
                    e.SuppressKeyPress = true;
                    ExecuteReplaceNow();
                    return;
                }

                // Ctrl+D: 复制当前规则
                if (e.KeyCode == WinForms.Keys.D && e.Control && currentRow != null)
                {
                    e.SuppressKeyPress = true;
                    DuplicateRuleRow(currentRow);
                    return;
                }

                // 单独 Enter 键跳格
                if (e.KeyCode == WinForms.Keys.Enter && !e.Shift && !e.Alt && currentRow != null)
                {
                    e.SuppressKeyPress = true;
                    if (currentBox == currentRow.SearchBox)
                    {
                        currentRow.ValueBox.Focus();
                        currentRow.ValueBox.SelectAll();
                    }
                    else if (currentBox == currentRow.ValueBox)
                    {
                        int idx = _ruleRows.IndexOf(currentRow);
                        if (idx >= 0 && idx < _ruleRows.Count - 1)
                        {
                            _ruleRows[idx + 1].SearchBox.Focus();
                            _ruleRows[idx + 1].SearchBox.SelectAll();
                        }
                        else
                        {
                            AddRuleRow();
                        }
                    }
                    return;
                }
            }

            private void OnReplaceButtonClick(object sender, EventArgs e)
            {
                ExecuteReplaceNow();
            }

            private void ExecuteReplaceNow()
            {
                SyncRulesToOwner();
                _owner.ExecuteReplaceFromFloatingPanel(_syncedSearchText, _syncedValueText);
                FlashStatus("替换命令已发送，结果请查看 CAD 命令行");
            }

            private void FlashStatus(string message)
            {
                _statusLabel.Text = message;
                _statusTimer.Stop();
                _statusTimer.Start();
            }

            private void OnFindTextChanged(object sender, EventArgs e)
            {
                _owner.UpdateFindText(_findTextBox.Text);
                _findSummaryLabel.Text = "在当前选中的文字中查找，结果将显示在下方";
                _findSummaryLabel.ForeColor = Draw.Color.FromArgb(140, 140, 140);
                _findResultsListBox.Items.Clear();
            }

            private void OnFindButtonClick(object sender, EventArgs e)
            {
                _owner.ExecuteFindFromFloatingPanel(_findTextBox.Text);
            }

            private void JumpToSelectedFindResult()
            {
                FindMatchItem item = _findResultsListBox.SelectedItem as FindMatchItem;
                if (item != null)
                {
                    _owner.ExecuteFindResultJump(item.Handle);
                    FlashStatus("已定位到第 " + item.Index + " 条查找结果");
                }
            }

            private void OnFindResultsListBoxDoubleClick(object sender, EventArgs e)
            {
                JumpToSelectedFindResult();
            }

            private void OnFindResultsListBoxKeyDown(object sender, WinForms.KeyEventArgs e)
            {
                if (e.KeyCode == WinForms.Keys.Enter)
                {
                    e.SuppressKeyPress = true;
                    JumpToSelectedFindResult();
                }
            }

            private void OnFindTextBoxKeyDown(object sender, WinForms.KeyEventArgs e)
            {
                if (e.KeyCode == WinForms.Keys.Enter)
                {
                    e.SuppressKeyPress = true;
                    _owner.ExecuteFindFromFloatingPanel(_findTextBox.Text);
                }
            }
        }
        private sealed class FindMatchItem
        {
            public FindMatchItem(int index, string handle, string text)
            {
                Index = index;
                Handle = handle ?? string.Empty;
                Text = text ?? string.Empty;
            }

            public int Index { get; private set; }

            public string Handle { get; private set; }

            public string Text { get; private set; }

            public override string ToString()
            {
                return Index.ToString("00") + ". " + FormatFindResultText(Text);
            }
        }

    }

    public sealed class AiRibbonCommands
    {
        [CommandMethod("DWGWIN", CommandFlags.Session)]
        public void ShowWindowManager()
        {
            AiRibbonPlugin.EnsureInstance().ShowWindowManagerCommand();
        }

        [CommandMethod("AICADPANEL", CommandFlags.Session)]
        public void ShowPromptPanel()
        {
            return;
        }

        [CommandMethod("AICADREPLACEPANEL", CommandFlags.Session)]
        public void ShowReplacePanel()
        {
            AiRibbonPlugin.EnsureInstance().ShowReplacePanelCommand();
        }

        [CommandMethod("HUAN", CommandFlags.Session)]
        public void ToggleReplacePanel()
        {
            AiRibbonPlugin.EnsureInstance().ShowReplacePanelCommand();
        }

        [CommandMethod("UNLOADAICAD", CommandFlags.Session)]
        public void UnloadAicad()
        {
            AiRibbonPlugin.EnsureInstance().UnloadCommand();
        }
    }
}
