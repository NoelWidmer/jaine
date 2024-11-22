Tool :: enum u8 {
  Move;
  Rotate;
}

get_selected_tool :: () -> Tool {
    return selected_tool;
}

switch_tool :: () {
    if selected_tool == last_tool 
      then selected_tool = first_tool;
      else selected_tool += 1;
}

#scope_file

first_tool :: Tool.Move;
last_tool :: Tool.Rotate;

selected_tool : Tool;