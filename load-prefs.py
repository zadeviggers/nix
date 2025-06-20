#! python3

import os
import shutil

print("BANANA!")


username = "zade"
home_dir = f"/Users/{username}"
application_support = f"{home_dir}/Library/Application Support"

ignore = [".DS_Store"]

configs_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "configs")

def get_profile_moz(product):
    folder_path = os.path.join(application_support, product)
    profiles_path = os.path.join(
        folder_path,
        "Profiles",
    )

    profile_folders = []
    for name in os.listdir(profiles_path):
        if name in ignore:
            continue

        full_path = os.path.join(
            profiles_path,
            name
        )
        
        if not os.path.isdir(full_path):
            continue
        
        profile_folders.append(full_path)

    if len(profile_folders) > 1:
        print()
        print(f"Multiple {product} profiles found")
        counter = 1
        for folder in profile_folders:
            print(f"{counter}. {folder}")
            counter += 1

        print("Which profile folder number should be targeted?")

        folder = int(input("> "))
        return profile_folders[folder-1]
    elif len(profile_folders) == 1:
        return profile_folders[0]
    else:
        print(f"No {product} profiles found!")
        return None

def move_all_files(from_folder: str, to_folder: str):
    for filename in os.listdir(from_folder):
        print(f"Copying {filename} into {to_folder}")

        source_path = os.path.join(from_folder, filename)
        destination_path = os.path.join(to_folder, filename)

        if os.path.isdir(source_path):
            # Move folders
            shutil.copytree(source_path, destination_path, dirs_exist_ok=True)
        else:
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
            ff_profile = get_profile_moz("Firefox")
            if ff_profile is not None:
                print("Copying Firefox profile")
                move_all_files(folder_path, ff_profile)
        case "vscodium":
            print("Copying VSCodium profile")
            codium_config_dir = f"{application_support}/VSCodium/User"
            move_all_files(folder_path, codium_config_dir)
        case "thunderbird":
            # Copy into default TB profile
            tb_profile = get_profile_moz("Thunderbird")
            if tb_profile is not None:
                print("Copying Thunderbird profile")
                move_all_files(folder_path, tb_profile)

