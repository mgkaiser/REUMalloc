.if !.xmatch(current_file, "reu.s")
    .import reu_copy_from_cpu_to_reu: near
    .import reu_copy_from_reu_to_cpu: near
.endif