#!/bin/bash
swift package experimental-uninstall sparrow 2>/dev/null
swift package experimental-install
ln -sf ~/.swiftpm/bin/sparrow ~/.swiftpm/bin/kln
