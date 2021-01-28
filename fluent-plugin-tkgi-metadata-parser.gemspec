$:.push File.expand_path('../lib', __FILE__)
Gem::Specification.new do |spec|
    spec.name                  = 'fluent-plugin-tkgi-metadata-parser'
    spec.version               = '1.2.1'
    spec.authors               = ['Saurabh Kulkarni']
    spec.email                 = ['saurabh.kl@outlook.com']
    spec.summary               = 'Fluentd parser plugin to parse TKGI metadata'
    spec.homepage              = 'https://github.com/srbhklkrn/fluent-plugin-tkgi-metadata-parser'
    spec.license               = 'MIT'
    spec.platform              = Gem::Platform::RUBY
    spec.files                 = `git ls-files`.split("\n").reject{|f| f.start_with?(".")}
    spec.test_files            = `git ls-files -- {test,spec,features}/*`.split("\n")
    spec.executables           = `git ls-files -- bin/*`.split("\n").map{|f| File.basename(f)}
    spec.require_paths         = ["lib"]
    spec.required_ruby_version = '>= 2.5.0'
  end