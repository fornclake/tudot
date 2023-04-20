# Tudot

Provides an interactive tutorial system for the Godot Editor. Tutorials can guide users through a series of steps and highlights
specific elements of the Godot Editor, making it an excellent tool for onboarding new developers or teaching specific tasks.


## Current Features

- Interactive tutorial steps with dialogs and highlights
- Easy-to-use tutorial configuration using plain text


## Planned Features

- Anchor popup dialogs and highlight any editor component
- Assert conditions in the editor or currently running game to advance to the next step
- Automatic script and resource diffs for navigating through steps (i.e. version control)


## Installation

1. Download or clone this repository.
2. Copy the addons folder into your Godot project folder.
3. Open your project in the Godot Editor.
4. Go to Project > Project Settings > Plugins.
5. Find Tudot in the list and set its status to Active.


## Usage

1. Navigate to the Tutor dock. It is in the bottom right panel by default.
2. Click on the Load button and choose a tutorial resource file (.tres) from your project.
3. Press the Go button.
4. Follow the on-screen prompts to complete each step of the tutorial.


## Creating Tutorials

To create a new tutorial, follow these steps:


1. In the Godot Editor, click on the FileSystem tab and navigate to the `tutorials` folder in the addon's root directory.
2. Right-click and choose New Resource....
3. In the search bar, type Tutorial and select the Tutorial resource type.
4. Click Create, then save the new resource file (.tres) with a descriptive name.

Edit the tutorial resource file by adding your tutorial text in the text field. Use the following syntax to define steps and dialogs:

```
# Step Title
## Dialog Title
Dialog text.

;highlight inspector
;highlight tutor
```

`#` and `##` represent step and dialog titles, respectively. `;highlight` followed by the element name adds a highlight to the specified element.

Current highlightable elements are `scene_tree`, `file_system`, `inspector`, and `tutor`.


## Limitations

Currently Tudot only works in the Forward+ or Mobile backends. If you are using the Compatibility backend, the overlay transparency will be black.


## Contributing

Contributions to Tudot are welcome! Please submit pull requests or open issues on the GitHub repository for bug reports, feature requests, or enhancements.


## License

This project is licensed under the MIT License.
