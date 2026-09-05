using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Json;
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
        private const string RibbonReplaceSearchVariable = "AICAD_RIBBON_REPLACE_SEARCH";
        private const string RibbonReplaceValueVariable = "AICAD_RIBBON_REPLACE_VALUE";
        private const string RibbonReplaceCountVariable = "AICAD_RIBBON_REPLACE_COUNT";
        private const string RibbonReplaceSearchPrefix = "AICAD_RIBBON_REPLACE_SEARCH_";
        private const string RibbonReplaceValuePrefix = "AICAD_RIBBON_REPLACE_VALUE_";
        private const string RibbonFindSearchVariable = "AICAD_RIBBON_FIND_SEARCH";
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
        private WindowManagerForm _windowManager;

        public void Initialize()
        {
            _instance = this;
            EnsureRibbonVisible();
            TryInstallRibbon();
            EnsureIdleHook();
            EnsureDocumentHook();
            EnsureLispLoadedForActiveDocument();
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
            CloseWindowManager();
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
            if (_windowManager != null && !_windowManager.IsDisposed && _windowManager.Visible)
            {
                _windowManager.Close();
                return;
            }

            _windowManager = new WindowManagerForm(this);
            _windowManager.FormClosed += delegate { _windowManager = null; };
            _windowManager.Show();
            _windowManager.RefreshDocuments();
        }

        private void CloseWindowManager()
        {
            if (_windowManager != null && !_windowManager.IsDisposed)
            {
                _windowManager.Close();
                _windowManager = null;
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
                if (_windowManager != null && !_windowManager.IsDisposed)
                {
                    _windowManager.RefreshDocuments();
                }
            }
            finally
            {
                _eventCallbackActive = false;
            }
        }

        internal Document[] GetOpenDocuments()
        {
            List<Document> documents = new List<Document>();
            foreach (Document document in ZcadApp.DocumentManager)
            {
                documents.Add(document);
            }
            return documents.ToArray();
        }

        internal void ActivateDocument(Document document)
        {
            if (document == null) return;
            try { ZcadApp.DocumentManager.MdiActiveDocument = document; }
            catch (System.Exception ex) { WriteMessage(document.Editor, "切换图纸失败：" + ex.Message); }
        }

        internal void CloseDocument(Document document)
        {
            if (document == null) return;
            try
            {
                bool modified = false;
                try
                {
                    System.Reflection.PropertyInfo property = document.GetType().GetProperty("IsModified");
                    object value = property == null ? null : property.GetValue(document, null);
                    if (value is bool) modified = (bool)value;
                }
                catch { }

                if (modified)
                {
                    string path = document.Name ?? string.Empty;
                    System.Reflection.MethodInfo saveClose = document.GetType().GetMethod("CloseAndSave", new Type[] { typeof(string) });
                    if (saveClose != null && !string.IsNullOrEmpty(path))
                    {
                        saveClose.Invoke(document, new object[] { path });
                    }
                    else document.CloseAndDiscard();
                }
                else
                {
                    System.Reflection.MethodInfo close = document.GetType().GetMethod("Close", Type.EmptyTypes);
                    if (close != null) close.Invoke(document, null);
                    else document.CloseAndDiscard();
                }
            }
            catch (System.Exception ex) { WriteMessage(document.Editor, "关闭图纸失败：" + ex.Message); }
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

                document.SendStringToExecute("(progn (setenv \"" + RibbonInputVariable + "\" \"" + EscapeForLisp(prompt) + "\") (princ)) ", true, false, false);
                document.SendStringToExecute("AICADRIBBON ", true, false, false);
            }
            catch (System.Exception ex)
            {
                WriteMessage(document.Editor, "AICAD \u8f93\u5165\u6846\u6267\u884c\u5931\u8d25\uff1a" + ex.Message);
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

                string command = "(progn ";
                command += "(setenv \"" + RibbonReplaceCountVariable + "\" \"" + pairs.Count + "\") ";
                for (int i = 0; i < pairs.Count; i++)
                {
                    command += "(setenv \"" + RibbonReplaceSearchPrefix + (i + 1) + "\" \"" + EscapeForLisp(pairs[i][0]) + "\") ";
                    command += "(setenv \"" + RibbonReplaceValuePrefix + (i + 1) + "\" \"" + EscapeForLisp(pairs[i][1]) + "\") ";
                }

                command += "(princ)) ";
                document.SendStringToExecute(command, true, false, false);
                document.SendStringToExecute("AICADRIBBONREPLACE ", true, false, false);
            }
            catch (System.Exception ex)
            {
                WriteMessage(document.Editor, "AICAD \u66ff\u6362\u6846\u6267\u884c\u5931\u8d25\uff1a" + ex.Message);
            }
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

                document.SendStringToExecute(
                    "(progn (setenv \"" + RibbonFindSearchVariable + "\" \"" + EscapeForLisp(searchText) + "\") (princ)) ",
                    true,
                    false,
                    false);
                document.SendStringToExecute("AICADRIBBONFIND ", true, false, false);
            }
            catch (System.Exception ex)
            {
                WriteMessage(document.Editor, "AICAD \u67e5\u627e\u6846\u6267\u884c\u5931\u8d25\uff1a" + ex.Message);
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

        [DataContract]
        private sealed class WindowNoteRecord
        {
            [DataMember] public string path;
            [DataMember] public string note;
            [DataMember] public bool favorite;
            [DataMember] public string updatedAt;
        }

        private sealed class WindowNoteStore
        {
            private readonly Dictionary<string, WindowNoteRecord> _records =
                new Dictionary<string, WindowNoteRecord>(StringComparer.OrdinalIgnoreCase);
            private readonly string _filePath;

            public WindowNoteStore()
            {
                string dir = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "ZW-auto_lisp");
                Directory.CreateDirectory(dir);
                _filePath = Path.Combine(dir, "window-notes.json");
                Load();
            }

            public WindowNoteRecord Get(string path)
            {
                WindowNoteRecord record;
                return path != null && _records.TryGetValue(path, out record)
                    ? record
                    : new WindowNoteRecord { path = path ?? string.Empty, note = string.Empty };
            }

            public bool Put(string path, string note, bool favorite)
            {
                if (string.IsNullOrEmpty(path)) return false;
                _records[path] = new WindowNoteRecord {
                    path = path, note = note ?? string.Empty, favorite = favorite,
                    updatedAt = DateTime.Now.ToString("s")
                };
                return Save();
            }

            private void Load()
            {
                if (!File.Exists(_filePath)) return;
                try
                {
                    using (FileStream stream = File.OpenRead(_filePath))
                    {
                        DataContractJsonSerializer serializer = new DataContractJsonSerializer(typeof(WindowNoteRecord[]));
                        WindowNoteRecord[] records = serializer.ReadObject(stream) as WindowNoteRecord[];
                        if (records != null)
                            foreach (WindowNoteRecord record in records)
                                if (record != null && !string.IsNullOrEmpty(record.path)) _records[record.path] = record;
                    }
                }
                catch
                {
                    try { File.Copy(_filePath, _filePath + ".bak", true); } catch { }
                    _records.Clear();
                }
            }

            private bool Save()
            {
                try
                {
                    string temp = _filePath + ".tmp";
                    using (FileStream stream = File.Create(temp))
                    {
                        DataContractJsonSerializer serializer = new DataContractJsonSerializer(typeof(WindowNoteRecord[]));
                        serializer.WriteObject(stream, _records.Values.ToArray());
                    }
                    if (File.Exists(_filePath))
                    {
                        try { File.Replace(temp, _filePath, _filePath + ".bak", true); }
                        catch { File.Copy(temp, _filePath, true); File.Delete(temp); }
                    }
                    else
                    {
                        File.Move(temp, _filePath);
                    }
                    return true;
                }
                catch { try { File.Delete(_filePath + ".tmp"); } catch { } return false; }
            }
        }

        private sealed class WindowDocumentItem
        {
            public Document Document;
            public string Key;
            public string Name;
            public string Path;
            public string Note;
            public bool Favorite;
            public bool Modified;
        }

        private sealed class WindowManagerForm : WinForms.Form
        {
            private static readonly System.Reflection.PropertyInfo FullFileNameProperty = typeof(Document).GetProperty("FullFileName");
            private static readonly System.Reflection.PropertyInfo DocumentModifiedProperty = typeof(Document).GetProperty("IsModified");
            private readonly AiRibbonPlugin _owner;
            private readonly WindowNoteStore _store;
            private readonly WinForms.TextBox _searchBox;
            private readonly WinForms.CheckBox _favoritesOnly;
            private readonly WinForms.ComboBox _sortBox;
            private readonly WinForms.ListView _list;
            private readonly WinForms.TextBox _noteBox;
            private readonly WinForms.Label _status;
            private readonly WinForms.Button _favoriteButton;
            private readonly WinForms.Button _folderButton;
            private readonly WinForms.Button _closeButton;
            private readonly WinForms.Timer _refreshTimer;
            private bool _refreshing;
            private string _lastSignature = string.Empty;
            private string _selectedKey = string.Empty;

            public WindowManagerForm(AiRibbonPlugin owner)
            {
                _owner = owner;
                _store = new WindowNoteStore();
                Text = "图纸窗口管理器";
                StartPosition = WinForms.FormStartPosition.CenterScreen;
                MinimumSize = new Draw.Size(680, 430);
                ClientSize = new Draw.Size(820, 560);
                BackColor = Draw.Color.FromArgb(43, 43, 46);
                ForeColor = Draw.Color.FromArgb(230, 230, 230);
                KeyPreview = true;

                WinForms.TableLayoutPanel root = new WinForms.TableLayoutPanel { Dock = WinForms.DockStyle.Fill, ColumnCount = 1, RowCount = 4, Padding = new WinForms.Padding(10) };
                root.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Absolute, 34));
                root.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Absolute, 32));
                root.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Percent, 100));
                root.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Absolute, 142));

                WinForms.Panel title = new WinForms.Panel { Dock = WinForms.DockStyle.Fill, BackColor = Draw.Color.FromArgb(37, 37, 38) };
                title.Controls.Add(new WinForms.Label { Text = "图纸窗口管理器", AutoSize = true, Location = new Draw.Point(8, 8), Font = new Draw.Font(Font, Draw.FontStyle.Bold) });
                WinForms.Button refresh = MakeButton("刷新", 70); refresh.Location = new Draw.Point(150, 4); refresh.Click += delegate { RefreshDocuments(); }; title.Controls.Add(refresh);
                WinForms.Button close = MakeButton("关闭面板", 82); close.Anchor = WinForms.AnchorStyles.Top | WinForms.AnchorStyles.Right; close.Location = new Draw.Point(Width - 112, 4); close.Click += delegate { Close(); }; title.Controls.Add(close);
                root.Controls.Add(title, 0, 0);

                WinForms.FlowLayoutPanel filters = new WinForms.FlowLayoutPanel { Dock = WinForms.DockStyle.Fill, WrapContents = false, Padding = new WinForms.Padding(0, 3, 0, 0) };
                _searchBox = new WinForms.TextBox { Width = 270, BackColor = Draw.Color.FromArgb(62, 62, 66), ForeColor = ForeColor, BorderStyle = WinForms.BorderStyle.FixedSingle }; _searchBox.TextChanged += delegate { RefreshDocuments(); }; filters.Controls.Add(_searchBox);
                _favoritesOnly = new WinForms.CheckBox { Text = "仅收藏", AutoSize = true, ForeColor = ForeColor, Margin = new WinForms.Padding(12, 4, 8, 0) }; _favoritesOnly.CheckedChanged += delegate { RefreshDocuments(); }; filters.Controls.Add(_favoritesOnly);
                _sortBox = new WinForms.ComboBox { Width = 130, DropDownStyle = WinForms.ComboBoxStyle.DropDownList, BackColor = Draw.Color.FromArgb(62, 62, 66), ForeColor = ForeColor }; _sortBox.Items.AddRange(new object[] { "按当前顺序", "按备注优先", "按文件名" }); _sortBox.SelectedIndex = 0; _sortBox.SelectedIndexChanged += delegate { RefreshDocuments(); }; filters.Controls.Add(_sortBox);
                root.Controls.Add(filters, 0, 1);

                _list = new WinForms.ListView { Dock = WinForms.DockStyle.Fill, View = WinForms.View.Details, FullRowSelect = true, GridLines = true, HideSelection = false, MultiSelect = false, BackColor = Draw.Color.FromArgb(52, 52, 56), ForeColor = ForeColor }; _list.Columns.Add("状态", 72); _list.Columns.Add("备注", 250); _list.Columns.Add("文件名", 600); _list.SelectedIndexChanged += OnSelectionChanged; _list.DoubleClick += delegate { ActivateSelected(); }; root.Controls.Add(_list, 0, 2);

                WinForms.TableLayoutPanel editor = new WinForms.TableLayoutPanel { Dock = WinForms.DockStyle.Fill, ColumnCount = 1, RowCount = 3, Padding = new WinForms.Padding(0, 8, 0, 0) };
                editor.ColumnStyles.Add(new WinForms.ColumnStyle(WinForms.SizeType.Percent, 100));
                editor.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Absolute, 22));
                editor.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Percent, 100));
                editor.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Absolute, 32));
                editor.Controls.Add(new WinForms.Label { Text = "备注（选中图纸后在白色输入框中编辑，Ctrl+Enter 保存）", Dock = WinForms.DockStyle.Fill, ForeColor = Draw.Color.FromArgb(210, 210, 210), TextAlign = Draw.ContentAlignment.MiddleLeft }, 0, 0);
                _noteBox = new WinForms.TextBox { Dock = WinForms.DockStyle.Fill, Multiline = true, AcceptsReturn = true, ScrollBars = WinForms.ScrollBars.Vertical, BackColor = Draw.Color.White, ForeColor = Draw.Color.Black, BorderStyle = WinForms.BorderStyle.Fixed3D, Font = new Draw.Font(Font.FontFamily, 10f) }; _noteBox.KeyDown += OnNoteKeyDown; editor.Controls.Add(_noteBox, 0, 1);
                WinForms.FlowLayoutPanel actions = new WinForms.FlowLayoutPanel { Dock = WinForms.DockStyle.Fill, FlowDirection = WinForms.FlowDirection.LeftToRight, WrapContents = false, Padding = new WinForms.Padding(0, 3, 0, 0) }; WinForms.Button save = MakeButton("保存备注", 110); save.BackColor = Draw.Color.FromArgb(0, 122, 204); save.Click += delegate { SaveNote(); }; actions.Controls.Add(save); _favoriteButton = MakeButton("收藏", 70); _favoriteButton.Click += delegate { ToggleFavorite(); }; actions.Controls.Add(_favoriteButton); _folderButton = MakeButton("打开目录", 82); _folderButton.Click += delegate { OpenFolder(); }; actions.Controls.Add(_folderButton); _closeButton = MakeButton("关闭图纸", 82); _closeButton.Click += delegate { CloseSelected(); }; actions.Controls.Add(_closeButton); _status = new WinForms.Label { AutoSize = true, TextAlign = Draw.ContentAlignment.MiddleLeft, ForeColor = Draw.Color.FromArgb(170, 170, 170), Margin = new WinForms.Padding(14, 5, 0, 0) }; actions.Controls.Add(_status); editor.Controls.Add(actions, 0, 2); root.Controls.Add(editor, 0, 3);
                Controls.Add(root);
                _refreshTimer = new WinForms.Timer { Interval = 1000 };
                _refreshTimer.Tick += delegate { RefreshDocuments(); };
                _refreshTimer.Start();
                KeyDown += OnWindowManagerKeyDown;
                FormClosing += delegate { SaveNote(); };
                FormClosed += delegate { _refreshTimer.Stop(); _refreshTimer.Dispose(); _noteBox.Text = string.Empty; };
            }

            private WinForms.Button MakeButton(string text, int width) { return new WinForms.Button { Text = text, Width = width, Height = 25, FlatStyle = WinForms.FlatStyle.Flat, BackColor = Draw.Color.FromArgb(62, 62, 66), ForeColor = ForeColor, Margin = new WinForms.Padding(4, 0, 0, 0) }; }

            public void RefreshDocuments()
            {
                if (_refreshing || IsDisposed) return;
                if (InvokeRequired)
                {
                    BeginInvoke(new Action(RefreshDocuments));
                    return;
                }
                _refreshing = true;
                try
                {
                    string query = (_searchBox.Text ?? string.Empty).Trim();
                    List<WindowDocumentItem> items = new List<WindowDocumentItem>();
                    foreach (Document document in _owner.GetOpenDocuments())
                    {
                        string path = GetDocumentPath(document);
                        string key = string.IsNullOrEmpty(path) ? "*session*" + document.GetHashCode().ToString() : path;
                        WindowNoteRecord record = _store.Get(path);
                        string name = document.Name ?? "未命名图纸";
                        bool modified = IsDocumentModified(document);
                        if (_favoritesOnly.Checked && !record.favorite) continue;
                        if (query.Length > 0 && name.IndexOf(query, StringComparison.OrdinalIgnoreCase) < 0 && path.IndexOf(query, StringComparison.OrdinalIgnoreCase) < 0 && (record.note ?? string.Empty).IndexOf(query, StringComparison.OrdinalIgnoreCase) < 0) continue;
                        items.Add(new WindowDocumentItem { Document = document, Key = key, Name = name, Path = path, Note = record.note ?? string.Empty, Favorite = record.favorite, Modified = modified });
                    }
                    if (_sortBox.SelectedIndex == 1) items = items.OrderByDescending(x => x.Favorite).ThenByDescending(x => !string.IsNullOrWhiteSpace(x.Note)).ThenBy(x => x.Name).ToList();
                    else if (_sortBox.SelectedIndex == 2) items = items.OrderBy(x => x.Name).ToList();
                    Document active = ZcadApp.DocumentManager.MdiActiveDocument;
                    string signature = string.Join("|", items.Select(item => item.Key + "\u001f" + item.Note + "\u001f" + item.Favorite + "\u001f" + item.Modified + "\u001f" + ReferenceEquals(item.Document, active))) + "|" + query + "|" + _favoritesOnly.Checked + "|" + _sortBox.SelectedIndex;
                    if (string.Equals(signature, _lastSignature, StringComparison.Ordinal)) return;
                    _lastSignature = signature;
                    _list.BeginUpdate();
                    try
                    {
                        _list.Items.Clear();
                        foreach (WindowDocumentItem item in items)
                        {
                            string state = (ReferenceEquals(item.Document, active) ? "当前" : "") + (item.Modified ? " *" : "");
                            if (item.Favorite) state += " ★";
                            WinForms.ListViewItem row = new WinForms.ListViewItem(state); row.SubItems.Add(string.IsNullOrEmpty(item.Note) ? "（未备注）" : item.Note); row.SubItems.Add(item.Name); row.Tag = item; if (ReferenceEquals(item.Document, active)) row.BackColor = Draw.Color.FromArgb(70, 90, 105); _list.Items.Add(row);
                        }
                    }
                    finally
                    {
                        _list.EndUpdate();
                    }
                    _status.Text = "共 " + items.Count.ToString() + " 张图纸";
                    for (int i = 0; i < _list.Items.Count; i++)
                    {
                        WindowDocumentItem item = _list.Items[i].Tag as WindowDocumentItem;
                        if (item != null && string.Equals(item.Key, _selectedKey, StringComparison.OrdinalIgnoreCase))
                        {
                            _list.Items[i].Selected = true;
                            _list.Items[i].EnsureVisible();
                            break;
                        }
                    }
                }
                finally { _refreshing = false; }
            }

        private static string GetDocumentPath(Document document)
            {
                if (document == null) return string.Empty;
                try
                {
                    object value = FullFileNameProperty == null ? null : FullFileNameProperty.GetValue(document, null);
                    if (value is string && !string.IsNullOrEmpty((string)value)) return NormalizePath((string)value);
                }
                catch { }
                try { return NormalizePath(document.Name ?? string.Empty); } catch { return string.Empty; }
            }

            private static string NormalizePath(string path)
            {
                if (string.IsNullOrWhiteSpace(path)) return string.Empty;
                try { return Path.GetFullPath(path).TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar); }
                catch { return path.Trim(); }
            }

            private static bool IsDocumentModified(Document document)
            {
                try
                {
                    object value = DocumentModifiedProperty == null ? null : DocumentModifiedProperty.GetValue(document, null);
                    if (value is bool) return (bool)value;
                }
                catch { }
                try
                {
                    System.Reflection.PropertyInfo property = document.Database.GetType().GetProperty("IsModified");
                    object value = property == null ? null : property.GetValue(document.Database, null);
                    if (value is bool) return (bool)value;
                }
                catch { }
                return false;
            }

            private WindowDocumentItem SelectedItem() { return _list.SelectedItems.Count == 0 ? null : _list.SelectedItems[0].Tag as WindowDocumentItem; }
            private void OnWindowManagerKeyDown(object sender, WinForms.KeyEventArgs e) { if (e.KeyCode == WinForms.Keys.Escape) { e.SuppressKeyPress = true; Close(); } }
            private void OnNoteKeyDown(object sender, WinForms.KeyEventArgs e) { if (e.KeyCode == WinForms.Keys.Enter && e.Control) { e.SuppressKeyPress = true; SaveNote(); } }
            private void OnSelectionChanged(object sender, EventArgs e) { WindowDocumentItem item = SelectedItem(); if (item == null) return; _selectedKey = item.Key; _noteBox.Text = item.Note; _favoriteButton.Text = item.Favorite ? "取消收藏" : "收藏"; _folderButton.Enabled = !string.IsNullOrEmpty(item.Path); _closeButton.Enabled = true; }
            private void ActivateSelected() { WindowDocumentItem item = SelectedItem(); if (item != null) { SaveNote(); _owner.ActivateDocument(item.Document); RefreshDocuments(); } }
            private void SaveNote() { WindowDocumentItem item = SelectedItem(); if (item == null) { _status.Text = "请先在上方列表选中一张图纸"; return; } if (string.IsNullOrEmpty(item.Path)) { _status.Text = "当前图纸没有可关联的文件名"; return; } _selectedKey = item.Key; bool ok = _store.Put(item.Path, _noteBox.Text, item.Favorite); if (ok) { item.Note = _noteBox.Text; _lastSignature = string.Empty; RefreshDocuments(); _status.Text = "备注已保存"; } else { _status.Text = "备注保存失败，请检查配置目录权限"; } }
            private void ToggleFavorite() { WindowDocumentItem item = SelectedItem(); if (item == null || string.IsNullOrEmpty(item.Path)) return; _selectedKey = item.Key; if (_store.Put(item.Path, item.Note, !item.Favorite)) { _lastSignature = string.Empty; RefreshDocuments(); } else { _status.Text = "收藏状态保存失败"; } }
            private void OpenFolder() { WindowDocumentItem item = SelectedItem(); if (item != null && File.Exists(item.Path)) System.Diagnostics.Process.Start("explorer.exe", "/select,\"" + item.Path + "\""); }
            private void CloseSelected() { WindowDocumentItem item = SelectedItem(); if (item == null) return; SaveNote(); _owner.CloseDocument(item.Document); RefreshDocuments(); }
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
                "\u63d0\u793a\uff1a\u5728 CAD \u4e2d\u9009\u4e2d\u6587\u5b57\u540e\uff0c\u7f16\u8f91\u4e0a\u65b9\u66ff\u6362\u89c4\u5219\uff0c\u70b9\u51fb\u201c\u66ff\u6362\u201d\u6216\u6309 Ctrl+Enter \u6267\u884c\uff1bESC \u5173\u95ed\u3002";

            private sealed class ReplaceRuleRow
            {
                public WinForms.Panel Card;
                public WinForms.Label NumberLabel;
                public WinForms.TextBox SearchBox;
                public WinForms.TextBox ValueBox;
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

                Text = "\u6587\u5b57\u66ff\u6362";
                StartPosition = WinForms.FormStartPosition.CenterScreen;
                FormBorderStyle = WinForms.FormBorderStyle.None;
                ShowInTaskbar = false;
                KeyPreview = true;
                MinimumSize = new Draw.Size(560, 620);
                ClientSize = new Draw.Size(620, 720);
                BackColor = Draw.Color.FromArgb(45, 45, 48);
                ForeColor = Draw.Color.FromArgb(224, 224, 224);
                Padding = new WinForms.Padding(0);

                // Root: title bar / content / status bar
                WinForms.TableLayoutPanel rootLayout = new WinForms.TableLayoutPanel();
                rootLayout.ColumnCount = 1;
                rootLayout.Dock = WinForms.DockStyle.Fill;
                rootLayout.Margin = new WinForms.Padding(0);
                rootLayout.BackColor = Draw.Color.FromArgb(45, 45, 48);
                rootLayout.ColumnStyles.Add(new WinForms.ColumnStyle(WinForms.SizeType.Percent, 100f));
                rootLayout.RowCount = 3;
                rootLayout.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Absolute, 34f));
                rootLayout.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Percent, 100f));
                rootLayout.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Absolute, 26f));

                // ---- Title bar ----
                WinForms.Panel titleBar = new WinForms.Panel();
                titleBar.Dock = WinForms.DockStyle.Fill;
                titleBar.BackColor = Draw.Color.FromArgb(37, 37, 38);
                titleBar.MouseDown += OnBackgroundMouseDown;
                titleBar.MouseMove += OnBackgroundMouseMove;
                titleBar.MouseUp += OnBackgroundMouseUp;

                WinForms.Label titleLabel = new WinForms.Label();
                titleLabel.AutoSize = true;
                titleLabel.Text = "\u6587\u5b57\u66ff\u6362";
                titleLabel.Font = new Draw.Font(Font.FontFamily, 10f, Draw.FontStyle.Bold);
                titleLabel.ForeColor = Draw.Color.FromArgb(235, 235, 235);
                titleLabel.Location = new Draw.Point(12, 8);
                titleLabel.MouseDown += OnBackgroundMouseDown;
                titleLabel.MouseMove += OnBackgroundMouseMove;
                titleLabel.MouseUp += OnBackgroundMouseUp;

                WinForms.Button closeButton = new WinForms.Button();
                closeButton.Text = "\u00d7";
                closeButton.Size = new Draw.Size(32, 26);
                closeButton.Anchor = WinForms.AnchorStyles.Top | WinForms.AnchorStyles.Right;
                closeButton.Location = new Draw.Point(ClientSize.Width - 38, 4);
                closeButton.FlatStyle = WinForms.FlatStyle.Flat;
                closeButton.FlatAppearance.BorderSize = 0;
                closeButton.FlatAppearance.MouseOverBackColor = Draw.Color.FromArgb(196, 43, 28);
                closeButton.BackColor = Draw.Color.FromArgb(37, 37, 38);
                closeButton.ForeColor = Draw.Color.FromArgb(220, 220, 220);
                closeButton.Cursor = WinForms.Cursors.Hand;
                closeButton.Font = new Draw.Font(Font.FontFamily, 11f, Draw.FontStyle.Bold);
                closeButton.Click += delegate { Close(); };

                titleBar.Controls.Add(titleLabel);
                titleBar.Controls.Add(closeButton);

                // ---- Content area ----
                WinForms.TableLayoutPanel content = new WinForms.TableLayoutPanel();
                content.ColumnCount = 1;
                content.Dock = WinForms.DockStyle.Fill;
                content.Padding = new WinForms.Padding(12, 8, 12, 8);
                content.Margin = new WinForms.Padding(0);
                content.BackColor = Draw.Color.FromArgb(45, 45, 48);
                content.ColumnStyles.Add(new WinForms.ColumnStyle(WinForms.SizeType.Percent, 100f));
                content.RowCount = 3;
                content.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Percent, 100f));
                content.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Absolute, 220f));
                content.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Absolute, 76f));

                // ================= GroupBox 1: batch replace rules =================
                WinForms.GroupBox rulesGroup = new WinForms.GroupBox();
                rulesGroup.Dock = WinForms.DockStyle.Fill;
                rulesGroup.Text = "  \u6279\u91cf\u66ff\u6362\u89c4\u5219  ";
                rulesGroup.ForeColor = Draw.Color.FromArgb(210, 210, 210);
                rulesGroup.BackColor = Draw.Color.FromArgb(45, 45, 48);
                rulesGroup.Font = new Draw.Font(Font.FontFamily, 9f, Draw.FontStyle.Bold);
                rulesGroup.Padding = new WinForms.Padding(8, 4, 8, 6);

                WinForms.TableLayoutPanel rulesGroupLayout = new WinForms.TableLayoutPanel();
                rulesGroupLayout.ColumnCount = 1;
                rulesGroupLayout.Dock = WinForms.DockStyle.Fill;
                rulesGroupLayout.Margin = new WinForms.Padding(0);
                rulesGroupLayout.BackColor = Draw.Color.FromArgb(45, 45, 48);
                rulesGroupLayout.ColumnStyles.Add(new WinForms.ColumnStyle(WinForms.SizeType.Percent, 100f));
                rulesGroupLayout.RowCount = 2;
                rulesGroupLayout.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Absolute, 32f));
                rulesGroupLayout.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Percent, 100f));

                // toolbar: add-rule button + count
                WinForms.TableLayoutPanel rulesToolbar = new WinForms.TableLayoutPanel();
                rulesToolbar.ColumnCount = 2;
                rulesToolbar.Dock = WinForms.DockStyle.Fill;
                rulesToolbar.Margin = new WinForms.Padding(0, 0, 0, 4);
                rulesToolbar.BackColor = Draw.Color.FromArgb(45, 45, 48);
                rulesToolbar.ColumnStyles.Add(new WinForms.ColumnStyle(WinForms.SizeType.AutoSize));
                rulesToolbar.ColumnStyles.Add(new WinForms.ColumnStyle(WinForms.SizeType.Percent, 100f));
                rulesToolbar.RowCount = 1;
                rulesToolbar.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Percent, 100f));

                WinForms.Button addRuleButton = new WinForms.Button();
                addRuleButton.Text = "\uff0b \u6dfb\u52a0\u89c4\u5219";
                addRuleButton.Size = new Draw.Size(96, 26);
                addRuleButton.Anchor = WinForms.AnchorStyles.Left;
                addRuleButton.FlatStyle = WinForms.FlatStyle.Flat;
                addRuleButton.FlatAppearance.BorderColor = Draw.Color.FromArgb(0, 150, 255);
                addRuleButton.BackColor = Draw.Color.FromArgb(45, 45, 48);
                addRuleButton.ForeColor = Draw.Color.FromArgb(0, 150, 255);
                addRuleButton.Cursor = WinForms.Cursors.Hand;
                addRuleButton.Font = new Draw.Font(Font.FontFamily, 9f, Draw.FontStyle.Regular);
                addRuleButton.Click += delegate { AddRuleRow(); };
                rulesToolbar.Controls.Add(addRuleButton, 0, 0);

                _ruleCountLabel = new WinForms.Label();
                _ruleCountLabel.AutoSize = true;
                _ruleCountLabel.Text = "\u5171 1 \u6761\u89c4\u5219";
                _ruleCountLabel.Anchor = WinForms.AnchorStyles.Right;
                _ruleCountLabel.ForeColor = Draw.Color.FromArgb(160, 160, 160);
                _ruleCountLabel.Font = new Draw.Font(Font.FontFamily, 8.5f, Draw.FontStyle.Regular);
                rulesToolbar.Controls.Add(_ruleCountLabel, 1, 0);
                rulesGroupLayout.Controls.Add(rulesToolbar, 0, 0);

                // scrollable rule cards
                _rulesScroll = new WinForms.Panel();
                _rulesScroll.Dock = WinForms.DockStyle.Fill;
                _rulesScroll.AutoScroll = true;
                _rulesScroll.BackColor = Draw.Color.FromArgb(45, 45, 48);
                _rulesScroll.Margin = new WinForms.Padding(0);

                _rulesTable = new WinForms.TableLayoutPanel();
                _rulesTable.ColumnCount = 1;
                _rulesTable.Dock = WinForms.DockStyle.Top;
                _rulesTable.AutoSize = true;
                _rulesTable.AutoSizeMode = WinForms.AutoSizeMode.GrowAndShrink;
                _rulesTable.Margin = new WinForms.Padding(0);
                _rulesTable.BackColor = Draw.Color.FromArgb(45, 45, 48);
                _rulesTable.ColumnStyles.Add(new WinForms.ColumnStyle(WinForms.SizeType.Percent, 100f));
                _rulesTable.RowCount = 0;

                _rulesScroll.Controls.Add(_rulesTable);
                rulesGroupLayout.Controls.Add(_rulesScroll, 0, 1);
                rulesGroup.Controls.Add(rulesGroupLayout);
                content.Controls.Add(rulesGroup, 0, 0);

                // ================= GroupBox 2: current selection find =================
                WinForms.GroupBox findGroup = new WinForms.GroupBox();
                findGroup.Dock = WinForms.DockStyle.Fill;
                findGroup.Text = "  \u67e5\u627e\u5f53\u524d\u9009\u4e2d\u6587\u5b57  ";
                findGroup.ForeColor = Draw.Color.FromArgb(210, 210, 210);
                findGroup.BackColor = Draw.Color.FromArgb(45, 45, 48);
                findGroup.Font = new Draw.Font(Font.FontFamily, 9f, Draw.FontStyle.Bold);
                findGroup.Padding = new WinForms.Padding(8, 2, 8, 6);

                WinForms.TableLayoutPanel findLayout = new WinForms.TableLayoutPanel();
                findLayout.ColumnCount = 3;
                findLayout.Dock = WinForms.DockStyle.Fill;
                findLayout.Margin = new WinForms.Padding(0);
                findLayout.BackColor = Draw.Color.FromArgb(45, 45, 48);
                findLayout.ColumnStyles.Add(new WinForms.ColumnStyle(WinForms.SizeType.AutoSize));
                findLayout.ColumnStyles.Add(new WinForms.ColumnStyle(WinForms.SizeType.Percent, 100f));
                findLayout.ColumnStyles.Add(new WinForms.ColumnStyle(WinForms.SizeType.AutoSize));
                findLayout.RowCount = 3;
                findLayout.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Absolute, 28f));
                findLayout.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Absolute, 26f));
                findLayout.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Percent, 100f));

                WinForms.Label findLabel = new WinForms.Label();
                findLabel.AutoSize = true;
                findLabel.Text = "\u67e5\u627e";
                findLabel.Anchor = WinForms.AnchorStyles.Left;
                findLabel.Margin = new WinForms.Padding(0, 2, 8, 0);
                findLabel.ForeColor = Draw.Color.FromArgb(180, 180, 180);
                findLabel.Font = new Draw.Font(Font.FontFamily, 9f, Draw.FontStyle.Regular);
                findLayout.Controls.Add(findLabel, 0, 0);

                _findTextBox = new WinForms.TextBox();
                _findTextBox.Dock = WinForms.DockStyle.Fill;
                _findTextBox.Margin = new WinForms.Padding(0, 2, 8, 0);
                _findTextBox.BackColor = Draw.Color.FromArgb(62, 62, 66);
                _findTextBox.ForeColor = Draw.Color.FromArgb(224, 224, 224);
                _findTextBox.BorderStyle = WinForms.BorderStyle.FixedSingle;
                _findTextBox.TextChanged += OnFindTextChanged;
                _findTextBox.KeyDown += OnFindTextBoxKeyDown;
                findLayout.Controls.Add(_findTextBox, 1, 0);

                WinForms.Button findButton = new WinForms.Button();
                findButton.Text = "\u67e5\u627e";
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
                _findSummaryLabel.Text = "\u5728\u5f53\u524d\u9009\u4e2d\u7684\u6587\u5b57\u4e2d\u67e5\u627e\uff0c\u7ed3\u679c\u5c06\u663e\u793a\u5728\u4e0b\u65b9";
                _findSummaryLabel.Anchor = WinForms.AnchorStyles.Left;
                _findSummaryLabel.ForeColor = Draw.Color.FromArgb(140, 140, 140);
                _findSummaryLabel.Font = new Draw.Font(Font.FontFamily, 8.5f, Draw.FontStyle.Regular);
                findLayout.SetColumnSpan(_findSummaryLabel, 3);
                findLayout.Controls.Add(_findSummaryLabel, 0, 1);

                _findResultsListBox = new WinForms.ListBox();
                _findResultsListBox.Dock = WinForms.DockStyle.Fill;
                _findResultsListBox.Margin = new WinForms.Padding(0, 2, 0, 0);
                _findResultsListBox.BackColor = Draw.Color.FromArgb(52, 52, 56);
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
                actionGroup.Text = "  \u64cd\u4f5c  ";
                actionGroup.ForeColor = Draw.Color.FromArgb(210, 210, 210);
                actionGroup.BackColor = Draw.Color.FromArgb(45, 45, 48);
                actionGroup.Font = new Draw.Font(Font.FontFamily, 9f, Draw.FontStyle.Bold);
                actionGroup.Padding = new WinForms.Padding(8, 2, 8, 6);

                WinForms.TableLayoutPanel actionLayout = new WinForms.TableLayoutPanel();
                actionLayout.ColumnCount = 2;
                actionLayout.Dock = WinForms.DockStyle.Fill;
                actionLayout.Margin = new WinForms.Padding(0);
                actionLayout.BackColor = Draw.Color.FromArgb(45, 45, 48);
                actionLayout.ColumnStyles.Add(new WinForms.ColumnStyle(WinForms.SizeType.Percent, 100f));
                actionLayout.ColumnStyles.Add(new WinForms.ColumnStyle(WinForms.SizeType.AutoSize));
                actionLayout.RowCount = 1;
                actionLayout.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Percent, 100f));

                WinForms.Label actionHint = new WinForms.Label();
                actionHint.AutoSize = true;
                actionHint.Text = "\u66ff\u6362\u5c06\u4f5c\u7528\u4e8e CAD \u4e2d\u5f53\u524d\u9009\u4e2d\u7684 TEXT/MTEXT \u6587\u5b57";
                actionHint.Anchor = WinForms.AnchorStyles.Left;
                actionHint.ForeColor = Draw.Color.FromArgb(160, 160, 160);
                actionHint.Font = new Draw.Font(Font.FontFamily, 8.5f, Draw.FontStyle.Regular);
                actionLayout.Controls.Add(actionHint, 0, 0);

                WinForms.Button replaceButton = new WinForms.Button();
                replaceButton.Text = "\u66ff\u6362  (Ctrl+Enter)";
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
                _statusLabel.BackColor = Draw.Color.FromArgb(37, 37, 38);
                _statusLabel.ForeColor = Draw.Color.FromArgb(150, 150, 150);
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
                try
                {
                    AddRuleRowCore(string.Empty, string.Empty);
                }
                finally
                {
                    _syncing = false;
                }
                RenumberRules();
                UpdateRuleCount();
                if (_ruleRows.Count > 0)
                {
                    _ruleRows[_ruleRows.Count - 1].SearchBox.Focus();
                }
            }

            private void AddRuleRowCore(string searchText, string valueText)
            {
                ReplaceRuleRow row = new ReplaceRuleRow();

                WinForms.Panel card = new WinForms.Panel();
                card.Dock = WinForms.DockStyle.Top;
                card.Height = 104;
                card.Margin = new WinForms.Padding(0, 3, 0, 3);
                card.BackColor = Draw.Color.FromArgb(52, 52, 56);
                card.BorderStyle = WinForms.BorderStyle.FixedSingle;
                row.Card = card;

                WinForms.TableLayoutPanel inner = new WinForms.TableLayoutPanel();
                inner.Dock = WinForms.DockStyle.Fill;
                inner.ColumnCount = 2;
                inner.Padding = new WinForms.Padding(8, 3, 8, 5);
                inner.BackColor = Draw.Color.FromArgb(52, 52, 56);
                inner.ColumnStyles.Add(new WinForms.ColumnStyle(WinForms.SizeType.Percent, 100f));
                inner.ColumnStyles.Add(new WinForms.ColumnStyle(WinForms.SizeType.AutoSize));
                inner.RowCount = 4;
                inner.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Absolute, 22f));
                inner.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Absolute, 28f));
                inner.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Absolute, 18f));
                inner.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Absolute, 28f));

                // Row 0: number + caption (left), remove button (right)
                WinForms.FlowLayoutPanel numberFlow = new WinForms.FlowLayoutPanel();
                numberFlow.Dock = WinForms.DockStyle.Fill;
                numberFlow.FlowDirection = WinForms.FlowDirection.LeftToRight;
                numberFlow.WrapContents = false;
                numberFlow.BackColor = Draw.Color.FromArgb(52, 52, 56);
                numberFlow.Margin = new WinForms.Padding(0);

                WinForms.Label number = new WinForms.Label();
                number.AutoSize = true;
                number.Text = "1";
                number.Anchor = WinForms.AnchorStyles.Left;
                number.Margin = new WinForms.Padding(0, 1, 8, 0);
                number.ForeColor = Draw.Color.FromArgb(0, 150, 255);
                number.Font = new Draw.Font(Font.FontFamily, 10f, Draw.FontStyle.Bold);
                row.NumberLabel = number;

                WinForms.Label searchCaption = new WinForms.Label();
                searchCaption.AutoSize = true;
                searchCaption.Text = "\u67e5\u627e\u6587\u5b57";
                searchCaption.Anchor = WinForms.AnchorStyles.Left;
                searchCaption.Margin = new WinForms.Padding(0, 2, 0, 0);
                searchCaption.ForeColor = Draw.Color.FromArgb(170, 170, 170);
                searchCaption.Font = new Draw.Font(Font.FontFamily, 8.5f, Draw.FontStyle.Regular);
                numberFlow.Controls.Add(number);
                numberFlow.Controls.Add(searchCaption);
                inner.Controls.Add(numberFlow, 0, 0);

                WinForms.Button removeButton = new WinForms.Button();
                removeButton.Text = "\u00d7";
                removeButton.Size = new Draw.Size(26, 20);
                removeButton.Anchor = WinForms.AnchorStyles.Right;
                removeButton.FlatStyle = WinForms.FlatStyle.Flat;
                removeButton.FlatAppearance.BorderSize = 0;
                removeButton.FlatAppearance.MouseOverBackColor = Draw.Color.FromArgb(196, 43, 28);
                removeButton.BackColor = Draw.Color.FromArgb(52, 52, 56);
                removeButton.ForeColor = Draw.Color.FromArgb(170, 170, 170);
                removeButton.Cursor = WinForms.Cursors.Hand;
                removeButton.Font = new Draw.Font(Font.FontFamily, 9f, Draw.FontStyle.Bold);
                removeButton.Click += delegate { RemoveRuleRow(row); };
                inner.Controls.Add(removeButton, 1, 0);

                // Row 1: search box
                WinForms.TextBox searchBox = new WinForms.TextBox();
                searchBox.Dock = WinForms.DockStyle.Fill;
                searchBox.Margin = new WinForms.Padding(0, 2, 0, 0);
                searchBox.BackColor = Draw.Color.FromArgb(62, 62, 66);
                searchBox.ForeColor = Draw.Color.FromArgb(230, 230, 230);
                searchBox.BorderStyle = WinForms.BorderStyle.FixedSingle;
                searchBox.Font = new Draw.Font(Font.FontFamily, 9.5f, Draw.FontStyle.Regular);
                searchBox.TextChanged += OnRuleBoxTextChanged;
                searchBox.KeyDown += OnRuleBoxKeyDown;
                row.SearchBox = searchBox;
                inner.SetColumnSpan(searchBox, 2);
                inner.Controls.Add(searchBox, 0, 1);

                // Row 2: value caption
                WinForms.Label valueCaption = new WinForms.Label();
                valueCaption.AutoSize = true;
                valueCaption.Text = "\u66ff\u6362\u6587\u5b57";
                valueCaption.Anchor = WinForms.AnchorStyles.Left;
                valueCaption.Margin = new WinForms.Padding(0, 2, 0, 0);
                valueCaption.ForeColor = Draw.Color.FromArgb(170, 170, 170);
                valueCaption.Font = new Draw.Font(Font.FontFamily, 8.5f, Draw.FontStyle.Regular);
                inner.SetColumnSpan(valueCaption, 2);
                inner.Controls.Add(valueCaption, 0, 2);

                // Row 3: value box
                WinForms.TextBox valueBox = new WinForms.TextBox();
                valueBox.Dock = WinForms.DockStyle.Fill;
                valueBox.Margin = new WinForms.Padding(0, 2, 0, 0);
                valueBox.BackColor = Draw.Color.FromArgb(62, 62, 66);
                valueBox.ForeColor = Draw.Color.FromArgb(230, 230, 230);
                valueBox.BorderStyle = WinForms.BorderStyle.FixedSingle;
                valueBox.Font = new Draw.Font(Font.FontFamily, 9.5f, Draw.FontStyle.Regular);
                valueBox.TextChanged += OnRuleBoxTextChanged;
                valueBox.KeyDown += OnRuleBoxKeyDown;
                row.ValueBox = valueBox;
                inner.SetColumnSpan(valueBox, 2);
                inner.Controls.Add(valueBox, 0, 3);

                card.Controls.Add(inner);
                _rulesTable.Controls.Add(card);
                _rulesTable.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Absolute, 110f));
                _ruleRows.Add(row);

                if (!_syncing)
                {
                    SyncRulesToOwner();
                }
            }

            private void RemoveRuleRow(ReplaceRuleRow row)
            {
                if (_ruleRows.Count <= 1)
                {
                    FlashStatus("\u81f3\u5c11\u4fdd\u7559\u4e00\u6761\u89c4\u5219");
                    return;
                }
                _rulesTable.Controls.Remove(row.Card);
                row.Card.Dispose();
                _ruleRows.Remove(row);
                RenumberRules();
                UpdateRuleCount();
                SyncRulesToOwner();
            }

            private void RenumberRules()
            {
                for (int i = 0; i < _ruleRows.Count; i++)
                {
                    _ruleRows[i].NumberLabel.Text = i < 20
                        ? ((char)(0x2460 + i)).ToString()
                        : (i + 1).ToString();
                }
            }

            private void UpdateRuleCount()
            {
                _ruleCountLabel.Text = "\u5171 " + _ruleRows.Count.ToString() + " \u6761\u89c4\u5219";
            }

            // ---- External sync (the rest of the plugin still works on two
            //      newline-joined multi-line strings; rule cards map 1:1 to lines) ----

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
                // The values below come from this panel itself. Suppress the
                // owner's sync-echo (Update* -> SyncReplaceTextToPanel) so the
                // stale cached counterpart is not pushed back and does not
                // trigger a rebuild while the user is typing.
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
                // Guard against the sync echo: when the value coming back from
                // the owner is identical to what the panel already holds, do not
                // rebuild the rule cards (rebuilding mid-typing would destroy the
                // focused TextBox and swallow the typed character).
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

                _findSummaryLabel.Text = "\u67e5\u627e\u201c" + text + "\u201d\uff0c\u5171 " + items.Length +
                    " \u6761" + (items.Length > 0 ? "\uff1b\u53cc\u51fb\u6216\u6309 Enter \u5b9a\u4f4d" : string.Empty);
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
                if (e.KeyCode == WinForms.Keys.Enter && e.Control)
                {
                    e.SuppressKeyPress = true;
                    ExecuteReplaceNow();
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
                FlashStatus("\u66ff\u6362\u547d\u4ee4\u5df2\u53d1\u9001\uff0c\u7ed3\u679c\u8bf7\u67e5\u770b CAD \u547d\u4ee4\u884c");
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
                _findSummaryLabel.Text = "\u5728\u5f53\u524d\u9009\u4e2d\u7684\u6587\u5b57\u4e2d\u67e5\u627e\uff0c\u7ed3\u679c\u5c06\u663e\u793a\u5728\u4e0b\u65b9";
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
                    FlashStatus("\u5df2\u5b9a\u4f4d\u5230\u7b2c " + item.Index + " \u6761\u67e5\u627e\u7ed3\u679c");
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
