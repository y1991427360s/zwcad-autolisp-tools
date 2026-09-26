"""Static checks for AICAD extension, Ribbon integration, and payload transfer (no CAD)."""
from pathlib import Path
import tempfile
from lsp_common import parse, read_source, defun_forms, walk

ROOT = Path(__file__).resolve().parents[1]
AICAD_LSP = ROOT / 'V6' / 'aicad_extension.lsp'
RIBBON_CS = ROOT / 'V6' / 'AICADRibbon' / 'AiRibbonPlugin.cs'


def check_lsp_encoding_and_structure():
    raw, text = read_source(AICAD_LSP)
    assert not raw.startswith(b'\xef\xbb\xbf'), "UTF-8 BOM found in aicad_extension.lsp"
    assert b'\r\n' in raw and b'\n' not in raw.replace(b'\r\n', b''), "Mixed newlines in aicad_extension.lsp"
    forms = parse(text)
    funcs = {f[1]: f for f in defun_forms(forms)}
    
    # Required core defuns
    required = [
        'c:aicad', 'c:ascad', 'c:aicadribbon', 'c:aicadribbonreplace',
        'c:aicadribbonfind', 'c:aicadribbonfocusmatch', 'c:aicadcleanui',
        'aicad:read-text-file', 'aicad:read-replace-payload-file',
        'aicad:command-ribbon', 'aicad:command-ribbon-replace', 'aicad:command-ribbon-find'
    ]
    for req in required:
        assert req in funcs, f"Missing required function: {req}"
    print(f"PASS: aicad_extension.lsp {len(forms)} forms, {len(funcs)} defuns, all required functions present")
    return text, funcs


def check_ribbon_cs_buffer_safety():
    cs_text = RIBBON_CS.read_text(encoding='utf-8')
    assert 'RibbonReplaceFileVariable = "AICAD_RIBBON_REPLACE_FILE"' in cs_text
    assert 'RibbonInputFileVariable = "AICAD_RIBBON_INPUT_FILE"' in cs_text
    assert 'RibbonFindFileVariable = "AICAD_RIBBON_FIND_FILE"' in cs_text
    assert 'WriteReplacePayloadFile' in cs_text
    # Ensure SendStringToExecute is not building giant replace loops
    assert 'command += "(setenv \\"" + RibbonReplaceSearchPrefix' not in cs_text, \
        "Obsolete giant SendStringToExecute loop found in ExecuteReplace!"
    print("PASS: AiRibbonPlugin.cs uses file payloads; no oversized SendStringToExecute loops")


def check_payload_parser_logic():
    # Test payload file format:
    # Line 1: count
    # Line 2N: search
    # Line 2N+1: replace
    payload_content = "3\r\nABC\r\nXYZ\r\n  spaces  \r\n\r\n旧型号-01\r\n新型号-02\r\n"
    with tempfile.NamedTemporaryFile(mode='w', encoding='utf-8', delete=False, newline='', suffix='.txt') as tf:
        tf.write(payload_content)
        temp_path = tf.name
    try:
        lines = Path(temp_path).read_text(encoding='utf-8').splitlines()
        count = int(lines[0])
        assert count == 3
        pairs = []
        for i in range(count):
            s = lines[1 + i * 2]
            v = lines[2 + i * 2]
            pairs.append((s, v))
        assert pairs[0] == ('ABC', 'XYZ')
        assert pairs[1] == ('  spaces  ', '')  # empty replace means delete
        assert pairs[2] == ('旧型号-01', '新型号-02')
        print(f"PASS: Payload parser simulation matches {len(pairs)} pairs with empty and unicode values")
    finally:
        Path(temp_path).unlink(missing_ok=True)


def main():
    check_lsp_encoding_and_structure()
    check_ribbon_cs_buffer_safety()
    check_payload_parser_logic()
    print("ALL AICAD STATIC CHECKS PASS")
    return 0


if __name__ == '__main__':
    main()
