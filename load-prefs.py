#! python3

import os
import shutil

print("BANANA!")


username = "zade"
home_dir = f"/Users/{username}"
application_support = f"{home_dir}/Library/Application Support"

ignore = [".DS_Store"]

configs_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "configs")

def get_first_profile_moz(folder_path):
    profiles_path = os.path.join(
        folder_path,
        "Profiles",
    )
    print(profiles_path)
    profile_folders = []
    for name in os.listdir(profiles_path):
        if name in ignore:
            continue

        full_path = os.path.join(
            profiles_path,
            name
        )

        print(full_path)

        
        if not os.path.isdir(full_path):
            continue
        
        profile_folders.append(full_path)

    print(profile_folders)
        
    return profile_folders[0]

def move_all_files(from_folder: str, to_folder: str):
    for filename in os.listdir(from_folder):
        print(f"Copying {filename} into {to_folder}")

        source_path = os.path.join(from_folder, filename)
        destination_path = os.path.join(to_folder, filename)

        # `copy2` wipes metadata, compared to regular `copy``
        shutil.copy2(source_path, destination_path)

for name in os.listdir(configs_dir):
    if name in ignore:
        continue

    folder_path = os.path.abspath(os.path.join(configs_dir, name))
    match name:
        case "dotfiles":
            # These just go in home directory
            print("Copying dotfiles")
            move_all_files(folder_path, home_dir)
        case "firefox":
            # Copy into default Firefox profile
            print("Copying Firefox profile")
            ff_profile = get_first_profile_moz(f"{application_support}/Firefox")
            move_all_files(folder_path, ff_profile)
        case "vscodium":
            print("Copying VSCodium profile")
            codium_config_dir = f"{application_support}/VSCodium/User"
            move_all_files(folder_path, codium_config_dir)
        case "thunderbird":
            # Copy into default TB profile
            print("Copying Thunderbird profile")
            tb_profile = get_first_profile_moz(f"{application_support}/Thunderbird")
            move_all_files(folder_path, tb_profile)

