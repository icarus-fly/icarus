#!/usr/bin/env python3
"""
Firebase Setup Helper Script for Traqa
This script helps generate the proper Firebase configuration structure.
"""

import os
import shutil
from pathlib import Path

def create_directory_structure():
    """Create the proper Flutter project directory structure."""
    base_dir = Path("traqa")

    # Create standard Flutter directories
    directories = [
        base_dir / "android" / "app",
        base_dir / "ios" / "Runner",
        base_dir / "lib",
    ]

    for directory in directories:
        directory.mkdir(parents=True, exist_ok=True)
        print(f"✓ Created directory: {directory}")

    # Check if malformed directory exists and move contents
    malformed_dir = base_dir / "{android,ios,lib"
    if malformed_dir.exists():
        print(f"Found malformed directory: {malformed_dir}")

        # Move contents to proper locations
        for item in malformed_dir.iterdir():
            if item.is_dir():
                if item.name == "android":
                    dest = base_dir / "android"
                elif item.name == "ios":
                    dest = base_dir / "ios"
                elif item.name == "lib":
                    dest = base_dir / "lib"
                else:
                    dest = base_dir / item.name

                # Move the directory
                if dest.exists():
                    # Merge contents
                    for subitem in item.iterdir():
                        subdest = dest / subitem.name
                        if subdest.exists():
                            if subitem.is_file():
                                subdest.write_text(subitem.read_text())
                            else:
                                # For directories, we'd need to merge recursively
                                print(f"  Warning: {subdest} already exists, skipping")
                        else:
                            if subitem.is_file():
                                shutil.copy2(subitem, subdest)
                            else:
                                shutil.copytree(subitem, subdest)
                else:
                    shutil.copytree(item, dest)

                print(f"  Moved {item.name} to {dest}")

        # Remove the malformed directory
        shutil.rmtree(malformed_dir)
        print(f"✓ Removed malformed directory: {malformed_dir}")

def create_config_templates():
    """Create configuration file templates."""
    base_dir = Path("traqa")

    # Create placeholder Firebase config files
    config_files = {
        base_dir / "android" / "app" / "google-services.json": "{}",
        base_dir / "ios" / "Runner" / "GoogleService-Info.plist": "{}",
    }

    for file_path, content in config_files.items():
        if not file_path.exists():
            file_path.parent.mkdir(parents=True, exist_ok=True)
            file_path.write_text(content)
            print(f"✓ Created placeholder: {file_path}")

def main():
    print("🚀 Traqa Firebase Setup Helper")
    print("=" * 40)

    create_directory_structure()
    create_config_templates()

    print("\n✅ Setup complete!")
    print("\nNext steps:")
    print("1. Create Firebase project at https://console.firebase.google.com")
    print("2. Download google-services.json and GoogleService-Info.plist")
    print("3. Replace the placeholder files with your actual config")
    print("4. Run 'flutter pub get' to install dependencies")
    print("5. Follow the instructions in FIREBASE_SETUP.md")

if __name__ == "__main__":
    main()