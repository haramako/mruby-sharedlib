require 'rake'

txt = `nm --defined-only -g build/host/lib/libmruby.a`

rows = txt.split(/\n/)
    .map{|line| line.split(/\s+/)}
    .select{|row| row.size >= 3 && row[2] =~ /^mrb_/}
    .map{|row| row[2]}

out = []
out << 'LIBRARY mruby.dll'
out << 'EXPORTS'
out << rows.map{|row| "\t"+row}.join("\n")
IO.write(__dir__ + '/mruby.def', out.join("\n"))
