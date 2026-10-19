"""检查屏柜源码与设置面板覆盖关系；只读，不连接 CAD。"""
from cabinet_panel import SOURCE, discover, read_source, render


def main():
    text = read_source(SOURCE)
    entries = discover(text)
    if not entries:
        raise ValueError("未识别到任何屏柜命令，检查源码及面板解析规则。")
    if render(text, entries) != text:
        raise ValueError("面板无修改保存不能保持源码一致。")
    print(f"PASS cabinet panel: {len(entries)} commands covered; unchanged roundtrip preserved")


if __name__ == '__main__':
    main()
