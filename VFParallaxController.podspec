Pod::Spec.new do |s|
  s.name             = 'VFParallaxController'
  s.version          = '2.0.0'
  s.summary          = 'Parallax effect between UITableView and MKMapView.'
  s.description      = <<-DESC
VFParallaxController creates a parallax effect between UITableView and MKMapView. VFParallaxController is a subclass of UIViewController.
                       DESC
  s.homepage         = 'https://github.com/vferdiansyah/VFParallaxController'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Veri Ferdiansyah' => 'veri_ferdi@outlook.com' }
  s.source           = { :git => 'https://github.com/vferdiansyah/VFParallaxController.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/vferdiansyah'
  s.ios.deployment_target = '8.0'
  s.source_files = 'VFParallaxController/Classes/**/*'
end
