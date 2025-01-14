Tool :: enum u8 {
  Move;
  Rotate;
}

get_selected_tool :: () -> Tool {
    return selected_tool;
}

switch_tool :: () {
    tool_type_info :: type_info(Tool);
    first_tool :: #run tool_type_info.values[0];
    last_tool :: #run tool_type_info.values[tool_type_info.values.count - 1];

    if selected_tool == last_tool
      then selected_tool = first_tool;
      else selected_tool += 1;
}

#scope_file

selected_tool : Tool;