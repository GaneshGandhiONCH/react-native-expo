# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.

require_relative './utils.rb'

# It sets up the JavaScriptCore and JSI pods.
#
# @parameter react_native_path: relative path to react-native
# @parameter fabric_enabled: whether Fabirc is enabled
def setup_jsc!(react_native_path: "../node_modules/react-native", fabric_enabled: false)
    pod 'React-jsi', :path => "#{react_native_path}/ReactCommon/jsi"
    pod 'React-jsc', :path => "#{react_native_path}/ReactCommon/jsc"
    if fabric_enabled
        pod 'React-jsc/Fabric', :path => "#{react_native_path}/ReactCommon/jsc"
    end
end

# It sets up the Hermes and JSI pods.
#
# @parameter react_native_path: relative path to react-native
# @parameter fabric_enabled: whether Fabirc is enabled
def setup_hermes!(react_native_path: "../node_modules/react-native", fabric_enabled: false)
    # The following captures the output of prepare_hermes for use in tests
    prepare_hermes = 'node scripts/hermes/prepare-hermes-for-build'
    react_native_dir = Pod::Config.instance.installation_root.join(react_native_path)
    prep_output, prep_status = Open3.capture2e(prepare_hermes, :chdir => react_native_dir)
    prep_output.split("\n").each { |line| Pod::UI.info line }
    abort unless prep_status == 0

    pod 'React-jsi', :path => "#{react_native_path}/ReactCommon/jsi"
    # This `:tag => hermestag` below is only to tell CocoaPods to update hermes-engine when React Native version changes.
    # We have custom logic to compute the source for hermes-engine. See sdks/hermes-engine/*
    hermestag_file = File.join(react_native_path, "sdks", ".hermesversion")
    hermestag = File.exist?(hermestag_file) ? File.read(hermestag_file).strip : ''

    pod 'hermes-engine', :podspec => "#{react_native_path}/sdks/hermes-engine/hermes-engine.podspec", :tag => hermestag
    pod 'React-hermes', :path => "#{react_native_path}/ReactCommon/hermes"
    pod 'libevent', '~> 2.1.12'
end
