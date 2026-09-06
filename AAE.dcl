aae_main : dialog {
  label = "Attribute Editor";
  : edit_box {
    key = "value";
    label = "Value:";
    edit_width = 48;
    allow_accept = true;
  }
  spacer;
  : row {
    alignment = centered;
    : button {
      key = "accept";
      label = "OK";
      is_default = true;
      is_cancel = false;
      fixed_width = true;
      width = 12;
    }
    : button {
      key = "cancel";
      label = "Cancel";
      is_default = false;
      is_cancel = true;
      fixed_width = true;
      width = 12;
    }
  }
}
