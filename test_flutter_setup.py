#!/usr/bin/env python3
"""
Traqa Flutter Setup Test Script
This script helps check if your Flutter environment is ready.
"""

import subprocess
import sys
import os

def run_command(command, check=True):
    """Run a command and return the result."""
    try:
        result = subprocess.run(command, shell=True, capture_output=True, text=True)
        if check and result.returncode != 0:
            print(f"❌ Command failed: {command}")
            print(f"Error: {result.stderr}")
            return False
        return True
    except Exception as e:
        print(f"❌ Error running command: {e}")
        return False

def check_flutter_installation():
    """Check if Flutter is installed."""
    print("🔍 Checking Flutter installation...")

    if run_command("flutter --version", check=False):
        print("✅ Flutter is installed!")
        return True
    else:
        print("❌ Flutter not found. You need to install Flutter:")
        print("   📥 Download from: https://flutter.dev/docs/get-started/install")
        print("   🛠️  Add to PATH: export PATH=\"\$PATH:/path/to/flutter/bin\"")
        return False

def check_android_setup():
    """Check Android development environment."""
    print("\n🔍 Checking Android setup...")

    if run_command("adb --version", check=False):
        print("✅ ADB (Android Debug Bridge) is installed")
    else:
        print("⚠️  ADB not found - needed for Android testing")

    return True

def check_dependencies():
    """Check if project dependencies can be installed."""
    print("\n🔍 Checking project dependencies...")

    if os.path.exists("traqa/pubspec.yaml"):
        print("✅ pubspec.yaml found")

        # Try to get packages
        os.chdir("traqa")
        if run_command("flutter pub get", check=False):
            print("✅ Dependencies installed successfully")
            return True
        else:
            print("⚠️  Could not install dependencies - Flutter may not be ready")
            return False
    else:
        print("❌ pubspec.yaml not found")
        return False

def main():
    print("🚀 Traqa Flutter Environment Check")
    print("=" * 50)

    # Check Flutter installation
    flutter_installed = check_flutter_installation()

    # Check Android setup
    check_android_setup()

    # Check dependencies
    if flutter_installed:
        deps_ready = check_dependencies()
    else:
        deps_ready = False

    print("\n" + "=" * 50)

    if flutter_installed and deps_ready:
        print("🎉 Your environment is ready!")
        print("\nNext steps:")
        print("1. Run: cd traqa")
        print("2. Run: flutter run")
        print("3. Connect an Android device or use emulator")
    elif flutter_installed:
        print("📋 Flutter is installed but dependencies need setup")
        print("\nTry: cd traqa && flutter pub get")
    else:
        print("🛠️  You need to install Flutter first")
        print("\nVisit: https://flutter.dev/docs/get-started/install")

if __name__ == "__main__":
    main()