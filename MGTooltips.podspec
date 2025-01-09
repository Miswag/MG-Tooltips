Pod::Spec.new do |spec|
  spec.name         = 'MGTooltips'
  spec.version      = '1.1.1'
  spec.summary      = 'A dynamic and customizable tooltip system for iOS using UIKit.'
  spec.description  = <<-DESC
    MGTooltips is a dynamic and customizable tooltip system for iOS. 
    It allows tooltips to be displayed on any item from four sides, supports both RTL and LTR layouts, 
    and is fully customizable for integration into any project.
  DESC
  spec.homepage     = 'https://github.com/Miswag/MG-Tooltips.git'
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }

  spec.author       = {
  'Mosa Khaldun' => 'mosa.khaldun@miswag.com',
  'Mustafa Naser' => 'mustafa.naser@miswag.com',
  'Mustafa Ahmed' => 'mustafa@miswag.com'
}

  spec.source       = { :git => 'https://github.com/Miswag/MG-Tooltips.git', :tag => '1.1.1' }
  spec.ios.deployment_target = '13.0'
  spec.swift_version = '5.0'
  spec.source_files  = 'MGTooltips/**/*.swift'
  spec.resources     = ['MGTooltips/**/*.xcstrings', 'MGTooltips/**/*.h']
  spec.frameworks    = 'UIKit'
end
