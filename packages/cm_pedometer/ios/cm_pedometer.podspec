Pod::Spec.new do |s|
  s.name             = 'cm_pedometer'
  s.version          = '1.2.0'
  s.summary          = 'Core Motion pedometer bridge.'
  s.homepage         = 'https://github.com/hieutv-dng/cm_pedometer'
  s.license          = { :type => 'MIT' }
  s.author           = { 'Mingalar Run' => 'dev@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency       'Flutter'
  s.platform         = :ios, '12.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
