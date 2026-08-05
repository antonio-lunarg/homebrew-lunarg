# Copyright (c) 2026 Lunarg, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-2-Clause

class VulkanSdk < Formula
  desc "Enable development of Vulkan applications"
  homepage "https://vulkan.lunarg.com/sdk/home"
  url "https://sdk.lunarg.com/sdk/download/1.4.357.0/mac/vulkansdk-macos-1.4.357.0.zip"
  sha256 "539433589c83522e6f31b1c7b418a4167e21597a4a361ab119e1dc0760cf3865"
  version "1.4.357.0"

  livecheck do
    url "https://vulkan.lunarg.com/sdk/latest/mac.json"
    strategy :json do |json|
      json["mac"]
    end
  end

  depends_on :macos

  conflicts_with "vulkan-headers"
  conflicts_with "vulkan-loader"
  conflicts_with "molten-vk"
  conflicts_with "vulkan-tools"
  conflicts_with "glslang"
  conflicts_with "shaderc"
  conflicts_with "spirv-tools"
  conflicts_with "vulkan-validationlayers"

  def install
    # The zip contains a single .app, so Homebrew stages the bundle itself as
    # the buildpath and creates .brew_home inside it. That unsealed content
    # invalidates the code signature and Gatekeeper silently kills the
    # installer, so run it from a pristine copy of the bundle instead.
    app = buildpath.parent/"installer.app"
    system "/usr/bin/ditto", buildpath/"Contents", app/"Contents"

    # --cache-path keeps the Qt installer framework metadata cache inside the
    # build directory; its default under ~/Library/Caches is not writable in
    # Homebrew's sandbox, which leaves it unable to resolve any component.
    system app/"Contents/MacOS/vulkansdk-macOS-#{version}",
      "--root", prefix, "--accept-licenses", "--default-answer",
      "--cache-path", buildpath.parent/"ifw-cache",
      "--confirm-command", "install", "com.lunarg.vulkan.kosmic"

    # Make bin, include, lib, share, Frameworks directories available in the prefix.
    prefix.install (prefix/"macOS").children
    (prefix/"macOS").rmdir
  end

  def caveats
    <<~EOS
      License: https://vulkan.lunarg.com/license/

      For other software to find the Vulkan SDK, you may need to set:
        export VULKAN_SDK=$(brew --prefix vulkan-sdk)
    EOS
  end
end
