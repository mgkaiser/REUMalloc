.if !.xmatch(current_file, "file.s")
    .import file_save : near
    .import file_load : near
.endif