using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
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
        private string _findText = string.Empty;
        private ReplacePanelForm _replacePanel;
        private FindResultsForm _findResultsForm;

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
            CloseFindResultsPanel();
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

        private void OnFindResultsPanelClosed(object sender, WinForms.FormClosedEventArgs e)
        {
            if (_findResultsForm != null)
            {
                _findResultsForm.FormClosed -= OnFindResultsPanelClosed;
                _findResultsForm = null;
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

        private void CloseFindResultsPanel()
        {
            if (_findResultsForm == null)
            {
                return;
            }

            try
            {
                _findResultsForm.FormClosed -= OnFindResultsPanelClosed;
                _findResultsForm.Close();
                _findResultsForm.Dispose();
            }
            catch
            {
            }
            finally
            {
                _findResultsForm = null;
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

            RibbonButton replaceButton = new RibbonButton();
            replaceButton.Id = "AA_AICAD_REPLACE_BUTTON";
            replaceButton.Name = "AA_AICAD_REPLACE_BUTTON";
            replaceButton.Text = "\u6587\u5b57\u66ff\u6362";
            replaceButton.ShowText = true;
            replaceButton.ShowImage = false;
            replaceButton.CommandHandler = openReplaceHandler;
            replaceButton.Description = "\u6253\u5f00 AICAD \u6587\u5b57\u66ff\u6362\u9762\u677f";

            source.Items.Clear();
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
            SyncReplaceTextToPanel();
        }

        internal void UpdateReplaceValueText(string text)
        {
            _replaceValueText = text ?? string.Empty;
            SyncReplaceTextToPanel();
        }

        internal void UpdateFindText(string text)
        {
            _findText = text ?? string.Empty;
            SyncReplaceTextToPanel();
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
                if (matches.Length > 0)
                {
                    ShowFindResults(searchText, matches);
                }
                else
                {
                    CloseFindResultsPanel();
                }
            }
            catch (System.Exception ex)
            {
                CloseFindResultsPanel();
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
                if (_findResultsForm != null && !_findResultsForm.IsDisposed)
                {
                    _findResultsForm.SetMatches(searchText, matches);
                    _findResultsForm.Show();
                    _findResultsForm.Activate();
                    return;
                }

                if (!IsWinformsReady())
                {
                    return;
                }

                _findResultsForm = new FindResultsForm(this);
                _findResultsForm.FormClosed += OnFindResultsPanelClosed;
                _findResultsForm.SetMatches(searchText, matches);
                ZcadApp.ShowModelessDialog(_findResultsForm);
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

        private sealed class ReplacePanelForm : WinForms.Form
        {
            private readonly AiRibbonPlugin _owner;
            private readonly WinForms.TextBox _replaceSearchTextBox;
            private readonly WinForms.TextBox _replaceValueTextBox;
            private readonly WinForms.TextBox _findTextBox;
            private bool _dragging;
            private Draw.Point _dragStart;

            public ReplacePanelForm(AiRibbonPlugin owner)
            {
                WinForms.TableLayoutPanel layout;
                WinForms.Button closeButton;
                WinForms.Label replaceLabel;
                WinForms.Button replaceButton;
                WinForms.Label findLabel;
                WinForms.Button findButton;

                _owner = owner;
                Text = "\u6587\u5b57\u66ff\u6362";
                StartPosition = WinForms.FormStartPosition.CenterScreen;
                FormBorderStyle = WinForms.FormBorderStyle.None;
                ShowInTaskbar = false;
                MinimumSize = new Draw.Size(460, 132);
                ClientSize = new Draw.Size(560, 150);
                BackColor = Draw.Color.FromArgb(45, 45, 48);
                ForeColor = Draw.Color.FromArgb(224, 224, 224);
                Padding = new WinForms.Padding(0);

                layout = new WinForms.TableLayoutPanel();
                layout.ColumnCount = 5;
                layout.Dock = WinForms.DockStyle.Fill;
                layout.Padding = new WinForms.Padding(4, 6, 8, 6);
                layout.Margin = new WinForms.Padding(0);
                layout.BackColor = Draw.Color.FromArgb(45, 45, 48);
                layout.ColumnStyles.Add(new WinForms.ColumnStyle(WinForms.SizeType.AutoSize));
                layout.ColumnStyles.Add(new WinForms.ColumnStyle(WinForms.SizeType.AutoSize));
                layout.ColumnStyles.Add(new WinForms.ColumnStyle(WinForms.SizeType.Percent, 50f));
                layout.ColumnStyles.Add(new WinForms.ColumnStyle(WinForms.SizeType.Percent, 50f));
                layout.ColumnStyles.Add(new WinForms.ColumnStyle(WinForms.SizeType.AutoSize));
                layout.RowCount = 2;
                layout.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Absolute, 90f));
                layout.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.AutoSize));
                layout.MouseDown += OnBackgroundMouseDown;
                layout.MouseMove += OnBackgroundMouseMove;
                layout.MouseUp += OnBackgroundMouseUp;

                closeButton = new WinForms.Button();
                closeButton.Text = "\u00d7";
                closeButton.Size = new Draw.Size(20, 20);
                closeButton.Anchor = WinForms.AnchorStyles.Left;
                closeButton.Margin = new WinForms.Padding(0, 0, 2, 0);
                closeButton.FlatStyle = WinForms.FlatStyle.Flat;
                closeButton.FlatAppearance.BorderSize = 0;
                closeButton.BackColor = Draw.Color.FromArgb(45, 45, 48);
                closeButton.ForeColor = Draw.Color.FromArgb(180, 180, 180);
                closeButton.Cursor = WinForms.Cursors.Hand;
                closeButton.Font = new Draw.Font(Font.FontFamily, 9f, Draw.FontStyle.Bold);
                closeButton.Click += delegate { Close(); };
                layout.SetRowSpan(closeButton, 2);

                replaceLabel = new WinForms.Label();
                replaceLabel.AutoSize = true;
                replaceLabel.Text = "\u6587\u5b57\u66ff\u6362";
                replaceLabel.Anchor = WinForms.AnchorStyles.Top;
                replaceLabel.Margin = new WinForms.Padding(0, 4, 8, 0);
                replaceLabel.ForeColor = Draw.Color.FromArgb(224, 224, 224);
                replaceLabel.MouseDown += OnBackgroundMouseDown;
                replaceLabel.MouseMove += OnBackgroundMouseMove;
                replaceLabel.MouseUp += OnBackgroundMouseUp;

                _replaceSearchTextBox = new WinForms.TextBox();
                _replaceSearchTextBox.Dock = WinForms.DockStyle.Fill;
                _replaceSearchTextBox.Margin = new WinForms.Padding(0, 0, 8, 0);
                _replaceSearchTextBox.BackColor = Draw.Color.FromArgb(62, 62, 66);
                _replaceSearchTextBox.ForeColor = Draw.Color.FromArgb(224, 224, 224);
                _replaceSearchTextBox.BorderStyle = WinForms.BorderStyle.FixedSingle;
                _replaceSearchTextBox.Multiline = true;
                _replaceSearchTextBox.AcceptsReturn = true;
                _replaceSearchTextBox.WordWrap = false;
                _replaceSearchTextBox.ScrollBars = WinForms.ScrollBars.Vertical;
                _replaceSearchTextBox.TextChanged += OnReplaceSearchTextChanged;
                _replaceSearchTextBox.KeyDown += OnReplaceSearchTextBoxKeyDown;

                _replaceValueTextBox = new WinForms.TextBox();
                _replaceValueTextBox.Dock = WinForms.DockStyle.Fill;
                _replaceValueTextBox.Margin = new WinForms.Padding(0, 0, 8, 0);
                _replaceValueTextBox.BackColor = Draw.Color.FromArgb(62, 62, 66);
                _replaceValueTextBox.ForeColor = Draw.Color.FromArgb(224, 224, 224);
                _replaceValueTextBox.BorderStyle = WinForms.BorderStyle.FixedSingle;
                _replaceValueTextBox.Multiline = true;
                _replaceValueTextBox.AcceptsReturn = true;
                _replaceValueTextBox.WordWrap = false;
                _replaceValueTextBox.ScrollBars = WinForms.ScrollBars.Vertical;
                _replaceValueTextBox.TextChanged += OnReplaceValueTextChanged;
                _replaceValueTextBox.KeyDown += OnReplaceValueTextBoxKeyDown;

                replaceButton = new WinForms.Button();
                replaceButton.Text = "\u66ff\u6362";
                replaceButton.MinimumSize = new Draw.Size(60, 24);
                replaceButton.AutoSize = true;
                replaceButton.AutoSizeMode = WinForms.AutoSizeMode.GrowOnly;
                replaceButton.Anchor = WinForms.AnchorStyles.Top;
                replaceButton.Padding = new WinForms.Padding(6, 0, 6, 0);
                replaceButton.BackColor = Draw.Color.FromArgb(0, 122, 204);
                replaceButton.ForeColor = Draw.Color.White;
                replaceButton.FlatStyle = WinForms.FlatStyle.Flat;
                replaceButton.FlatAppearance.BorderColor = Draw.Color.FromArgb(0, 122, 204);
                replaceButton.Cursor = WinForms.Cursors.Hand;
                replaceButton.Click += OnReplaceButtonClick;

                findLabel = new WinForms.Label();
                findLabel.AutoSize = true;
                findLabel.Text = "\u67e5\u627e";
                findLabel.Anchor = WinForms.AnchorStyles.Left;
                findLabel.Margin = new WinForms.Padding(0, 0, 8, 0);
                findLabel.ForeColor = Draw.Color.FromArgb(224, 224, 224);
                findLabel.MouseDown += OnBackgroundMouseDown;
                findLabel.MouseMove += OnBackgroundMouseMove;
                findLabel.MouseUp += OnBackgroundMouseUp;

                _findTextBox = new WinForms.TextBox();
                _findTextBox.Dock = WinForms.DockStyle.Fill;
                _findTextBox.Margin = new WinForms.Padding(0, 0, 8, 0);
                _findTextBox.BackColor = Draw.Color.FromArgb(62, 62, 66);
                _findTextBox.ForeColor = Draw.Color.FromArgb(224, 224, 224);
                _findTextBox.BorderStyle = WinForms.BorderStyle.FixedSingle;
                _findTextBox.TextChanged += OnFindTextChanged;
                _findTextBox.KeyDown += OnFindTextBoxKeyDown;

                findButton = new WinForms.Button();
                findButton.Text = "\u67e5\u627e";
                findButton.MinimumSize = new Draw.Size(60, 24);
                findButton.AutoSize = true;
                findButton.AutoSizeMode = WinForms.AutoSizeMode.GrowOnly;
                findButton.Padding = new WinForms.Padding(6, 0, 6, 0);
                findButton.BackColor = Draw.Color.FromArgb(0, 122, 204);
                findButton.ForeColor = Draw.Color.White;
                findButton.FlatStyle = WinForms.FlatStyle.Flat;
                findButton.FlatAppearance.BorderColor = Draw.Color.FromArgb(0, 122, 204);
                findButton.Cursor = WinForms.Cursors.Hand;
                findButton.Click += OnFindButtonClick;

                layout.Controls.Add(closeButton, 0, 0);
                layout.Controls.Add(replaceLabel, 1, 0);
                layout.Controls.Add(_replaceSearchTextBox, 2, 0);
                layout.Controls.Add(_replaceValueTextBox, 3, 0);
                layout.Controls.Add(replaceButton, 4, 0);
                layout.Controls.Add(findLabel, 1, 1);
                layout.Controls.Add(_findTextBox, 2, 1);
                layout.SetColumnSpan(_findTextBox, 2);
                layout.Controls.Add(findButton, 4, 1);

                Controls.Add(layout);
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

            public void SetReplaceSearchText(string value)
            {
                string text = value ?? string.Empty;
                if (_replaceSearchTextBox.Text != text)
                {
                    _replaceSearchTextBox.Text = text;
                }
            }

            public void SetReplaceValueText(string value)
            {
                string text = value ?? string.Empty;
                if (_replaceValueTextBox.Text != text)
                {
                    _replaceValueTextBox.Text = text;
                }
            }

            public void FocusReplaceSearchBox()
            {
                _replaceSearchTextBox.Focus();
                _replaceSearchTextBox.SelectAll();
            }

            public void FocusReplaceValueBox()
            {
                _replaceValueTextBox.Focus();
                _replaceValueTextBox.SelectAll();
            }

            public void SetFindText(string value)
            {
                string text = value ?? string.Empty;
                if (_findTextBox.Text != text)
                {
                    _findTextBox.Text = text;
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

            private void OnReplaceSearchTextChanged(object sender, EventArgs e)
            {
                _owner.UpdateReplaceSearchText(_replaceSearchTextBox.Text);
            }

            private void OnReplaceValueTextChanged(object sender, EventArgs e)
            {
                _owner.UpdateReplaceValueText(_replaceValueTextBox.Text);
            }

            private void OnReplaceButtonClick(object sender, EventArgs e)
            {
                _owner.ExecuteReplaceFromFloatingPanel(_replaceSearchTextBox.Text, _replaceValueTextBox.Text);
            }

            private void OnFindTextChanged(object sender, EventArgs e)
            {
                _owner.UpdateFindText(_findTextBox.Text);
            }

            private void OnFindButtonClick(object sender, EventArgs e)
            {
                _owner.ExecuteFindFromFloatingPanel(_findTextBox.Text);
            }

            private void OnReplaceSearchTextBoxKeyDown(object sender, WinForms.KeyEventArgs e)
            {
                if (e.KeyCode == WinForms.Keys.Enter && e.Control)
                {
                    e.SuppressKeyPress = true;
                    _owner.ExecuteReplaceFromFloatingPanel(_replaceSearchTextBox.Text, _replaceValueTextBox.Text);
                }
            }

            private void OnReplaceValueTextBoxKeyDown(object sender, WinForms.KeyEventArgs e)
            {
                if (e.KeyCode == WinForms.Keys.Enter && e.Control)
                {
                    e.SuppressKeyPress = true;
                    _owner.ExecuteReplaceFromFloatingPanel(_replaceSearchTextBox.Text, _replaceValueTextBox.Text);
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

        private sealed class FindResultsForm : WinForms.Form
        {
            private readonly AiRibbonPlugin _owner;
            private readonly WinForms.Label _summaryLabel;
            private readonly WinForms.ListBox _resultsListBox;

            public FindResultsForm(AiRibbonPlugin owner)
            {
                WinForms.TableLayoutPanel layout;

                _owner = owner;
                Text = "查找结果";
                StartPosition = WinForms.FormStartPosition.CenterScreen;
                FormBorderStyle = WinForms.FormBorderStyle.SizableToolWindow;
                ShowInTaskbar = false;
                MinimumSize = new Draw.Size(320, 220);
                ClientSize = new Draw.Size(420, 280);
                BackColor = Draw.Color.FromArgb(45, 45, 48);
                ForeColor = Draw.Color.FromArgb(224, 224, 224);

                layout = new WinForms.TableLayoutPanel();
                layout.ColumnCount = 1;
                layout.RowCount = 2;
                layout.Dock = WinForms.DockStyle.Fill;
                layout.Padding = new WinForms.Padding(8);
                layout.BackColor = BackColor;
                layout.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.AutoSize));
                layout.RowStyles.Add(new WinForms.RowStyle(WinForms.SizeType.Percent, 100f));

                _summaryLabel = new WinForms.Label();
                _summaryLabel.AutoSize = true;
                _summaryLabel.Margin = new WinForms.Padding(0, 0, 0, 8);
                _summaryLabel.ForeColor = ForeColor;

                _resultsListBox = new WinForms.ListBox();
                _resultsListBox.Dock = WinForms.DockStyle.Fill;
                _resultsListBox.BackColor = Draw.Color.FromArgb(62, 62, 66);
                _resultsListBox.ForeColor = ForeColor;
                _resultsListBox.BorderStyle = WinForms.BorderStyle.FixedSingle;
                _resultsListBox.HorizontalScrollbar = true;
                _resultsListBox.IntegralHeight = false;
                _resultsListBox.DoubleClick += OnResultsListBoxDoubleClick;

                layout.Controls.Add(_summaryLabel, 0, 0);
                layout.Controls.Add(_resultsListBox, 0, 1);
                Controls.Add(layout);
            }

            public void SetMatches(string searchText, FindMatchItem[] matches)
            {
                string text = searchText ?? string.Empty;
                FindMatchItem[] items = matches ?? new FindMatchItem[0];

                _summaryLabel.Text = "查找\"" + text + "\"，共 " + items.Length + " 条，双击可跳转";
                _resultsListBox.BeginUpdate();
                _resultsListBox.Items.Clear();
                foreach (FindMatchItem item in items)
                {
                    _resultsListBox.Items.Add(item);
                }
                _resultsListBox.EndUpdate();

                if (_resultsListBox.Items.Count > 0)
                {
                    _resultsListBox.SelectedIndex = 0;
                }
            }

            private void OnResultsListBoxDoubleClick(object sender, EventArgs e)
            {
                FindMatchItem item = _resultsListBox.SelectedItem as FindMatchItem;
                if (item != null)
                {
                    _owner.ExecuteFindResultJump(item.Handle);
                }
            }
        }
    }

    public sealed class AiRibbonCommands
    {
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
