# coding: utf-8
# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'InstaPark' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'FSCalendar'
  pod 'PickerViewKit'

  # Pods for InstaPark
  pod 'Firebase/Analytics'
  pod 'Firebase/Auth'
  pod 'Firebase/Core'
  pod 'Firebase/Firestore'
  pod 'FirebaseFirestoreSwift'
  pod 'Firebase/Storage'
  # Sign in
  pod 'GoogleSignIn'
  pod ‘GeoFire’, :git => ‘https://github.com/firebase/geofire-objc.git'
  # Payment
  pod 'Braintree'
  pod 'BraintreeDropIn'
  pod 'Braintree/PayPal'
  pod 'Braintree/Venmo'
  pod 'Braintree/Apple-Pay'
  target 'InstaParkTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'InstaParkUITests' do
    # Pods for testing
  end

end
post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
end
