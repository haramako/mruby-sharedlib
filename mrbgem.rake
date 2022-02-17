MRuby::Gem::Specification.new 'mruby-dll' do |spec|
  spec.license = '?'
  spec.author  = '?'
  spec.summary = '?'
  spec.add_dependency 'mruby-compiler', :core => 'mruby-compiler'

  mruby_sharedlib_ext = (ENV['OS'] == 'Windows_NT')? 'dll' : (`uname` =~ /darwin/i)? 'dylib' : 'so'

  mruby_sharedlib = "#{build.build_dir}/bin/mruby.#{mruby_sharedlib_ext}"

  is_vc = cc.command =~ /^cl(\.exe)?$/
  unless is_vc
    self.cc.flags << '-fPIC'
    self.cxx.flags << '-fPIC'
  end

  p mruby_sharedlib
  file mruby_sharedlib => libfile("#{build.build_dir}/lib/libmruby") do |t|
    is_mingw = ENV['OS'] == 'Windows_NT' && cc.command =~ /^gcc/
    deffile = "#{File.dirname(__FILE__)}/mruby.def"
    unsed_whole_archive = false

    gem_flags = build.gems.map { |g| g.linker.flags }
    #gem_flags = []
    if is_vc
      gem_flags << '/DLL' << "/DEF:#{deffile}"
    else
      gem_flags << '-shared'
      gem_flags <<
        if mruby_sharedlib_ext == 'dylib'
          '-Wl,-force_load'
        elsif is_mingw
          deffile
        else
          unsed_whole_archive = true
          "-Wl,--whole-archive"
        end
    end
    gem_flags << "/MACHINE:#{ENV['Platform']}" if is_vc && ENV['Platform']
    gem_flags += t.prerequisites
    gem_flags << '-Wl,--no-whole-archive' if unsed_whole_archive
    gem_libraries = build.gems.map { |g| g.linker.libraries }
    gem_library_paths = build.gems.map { |g| g.linker.library_paths }
    gem_flags_before_libraries = build.gems.map { |g| g.linker.flags_before_libraries }
    gem_flags_after_libraries = build.gems.map { |g| g.linker.flags_after_libraries }
    linker.run t.name, [], gem_libraries, gem_library_paths, gem_flags, gem_flags_before_libraries, gem_flags_after_libraries
  end

  build.bins << 'mruby.dll'
end
