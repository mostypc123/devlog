# devlog

A CLI tool to help managing your devlogs.

## Usage

- `add -n NAME -d DIRECTORY`  Add a project to the list
- `remove -p PROJECT       `  Remove a project from the list
- `update -p PROJECT -m MSG`  Update a project's devlog

## Example usage

- `devlog add -n car -d ~/car`
- `devlog remove -p old-clone-car`
- `devlog update -p car -m "Added why command"`
