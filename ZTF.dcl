ztf_main : dialog {
  label = "ZTF Text Style Font Finder";
  : boxed_column {
    label = "Text Style";
    : edit_box { key = "style_search"; label = "Find:"; edit_width = 28; }
    : row {
      : list_box { key = "style_list"; width = 28; height = 8; fixed_width = true; }
      : column {
        : paragraph { : text { key = "style_info"; width = 48; } }
        : button { key = "pick_style"; label = "Pick Text"; width = 20; }
      }
    }
  }
  : boxed_column {
    label = "Search Font (name or file)";
    : edit_box { key = "font_search"; label = "Keyword:"; edit_width = 38; }
    : list_box { key = "font_list"; width = 58; height = 12; fixed_width = true; }
    : text { key = "font_path"; width = 70; }
  }
  : row {
    alignment = centered;
    : button { key = "apply"; label = "Apply to Style"; is_default = true; width = 22; }
    : button { key = "cancel"; label = "Cancel"; is_cancel = true; width = 12; }
  }
}
