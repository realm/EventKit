Pod::Spec.new do |s|
  s.name                    = 'EventBlankKit'
  s.version                 = '0.1'
  s.summary                 = 'Shared framework for the EventBlank conference app'
  s.homepage                = 'https://github.com/realm/EventBlank'
  s.source                  = { :git => 'https://github.com/realm/EventBlank.git', :tag => "v#{s.version}" }
  s.author                  = { 'Realm' => 'help@realm.io' }
  s.library                 = 'c++'
  s.requires_arc            = true
  s.social_media_url        = 'https://twitter.com/realm'
  s.license                 = { :type => 'MIT', :file => 'LICENSE' }

  s.source_files            = 'EventBlankKit/**/*.swift'

  s.ios.deployment_target   = '9.2'
  s.osx.deployment_target   = '10.10'

  s.dependency 'RxSwift'
  s.dependency 'RxCocoa'
  s.dependency 'RxRealm'
  s.dependency 'RxDataSources'
  s.dependency 'RealmSwift'
  s.dependency 'DynamicColor'
  s.dependency 'AFDateHelper'
  s.dependency 'RealmContent'
end
