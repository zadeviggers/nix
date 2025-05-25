import os
import shutil

print("BANANA!")

username = "zade"
home_dir = f"/Users/{username}"

ignore = [".DS_Store"]

ff_profiles_folder_path = f"{home_dir}/Library/Application Support/Firefox/Profiles"
ff_profile = os.path.join(
    ff_profiles_folder_path,
    list(filter(lambda item: item not in ignore, os.listdir(ff_profiles_folder_path)))[0]
)

script_dir = os.path.dirname(os.path.abspath(__file__))
configs_dir = os.path.join(script_dir, "configs")


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
            move_all_files(folder_path, ff_profile)

