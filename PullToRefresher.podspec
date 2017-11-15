Pod::Spec.new do |s|

  s.name         = "PullToRefresher"
  s.version      = "2.0.2"
  s.summary      = "This component implements pure pull-to-refresh logic and you can use it for developing your own pull-to-refresh animations"
  s.homepage     = "https://www.summerize.me"

  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = "Summerize"
  s.social_media_url   = "https://twitter.com/Summerize_9"

  s.ios.deployment_target = "10.0"

  s.source       = { :git => "https://github.com/Summerize/PullToRefresh.git", :tag => s.version }
  s.source_files = "PullToRefresh/*.swift"
  s.module_name  = "PullToRefresh"
  s.dependency 'lottie-ios', '2.1.3'

end
