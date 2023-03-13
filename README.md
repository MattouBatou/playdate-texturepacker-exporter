# playdate-texturepacker-exporter
Custom texture packer exporter for use with MattouBatou's Playdate games.

This is just a basic .json format that has sprite rects and animation objects.

## Image Path & Bitmap Table Path
The root level imagePath & bitmapTablePath members have a prepended folder name `"spriteSheets/"`.
This comes from a custom property field added to Texture Packer GUI and can be anything your heart desires (just make sure it is the actual path to your spriteSheet image).

The bitmapTablePath is just the image path with the file extension omitted.
The Playdate SDK C API has a specific format for bitmap table names where you append the width and height of each cell to the end of the file name in the format `-WW-HH`. For some reason the file extension messes with this and won't load the image as a bitmapTable.
I kept the image name with the file extension for no particular reason and should perhaps omit it once I confirm whether there is a use case for it.


## Sprite Data
The sprite rects have the following structure:
```
"spriteData": [
		{
			"name": "idle/player64x64_idle_000",
			"x": 0,
			"y": 0,
			"width": 64,
			"height": 64,
			"index": 0
		},
		{
			"name": "idle/player64x64_idle_002",
			"x": 64,
			"y": 0,
			"width": 64,
			"height": 64,
			"index": 1
		},
		{
			"name": "idle/player64x64_idle_004",
			"x": 128,
			"y": 0,
			"width": 64,
			"height": 64,
			"index": 2
		},
		{
			"name": "run/player64x64_run_000",
			"x": 192,
			"y": 0,
			"width": 64,
			"height": 64,
			"index": 3
		},
		{
			"name": "run/player64x64_run_002",
			"x": 0,
			"y": 64,
			"width": 64,
			"height": 64,
			"index": 4
		},
		{
			"name": "run/player64x64_run_004",
			"x": 64,
			"y": 64,
			"width": 64,
			"height": 64,
			"index": 5
		},
		{
			"name": "walk/player64x64_walk_000",
			"x": 128,
			"y": 64,
			"width": 64,
			"height": 64,
			"index": 6
		},
		{
			"name": "walk/player64x64_walk_001",
			"x": 192,
			"y": 64,
			"width": 64,
			"height": 64,
			"index": 7
		},
		{
			"name": "walk/player64x64_walk_007",
			"x": 0,
			"y": 128,
			"width": 64,
			"height": 64,
			"index": 8
		}
	],
```

The exported sprite sheet image has duplicate images removed which is why the numbering in the names in the spriteData objects are not contiguous.

## Animations Data
The animation objects have the following structure:
```
    animations: [
        {
			"name": "idle",
			"framesLength": 13,
			"frames": [0,0,1,1,2,2,2,2,1,1,0,0,0]
		},
        {
			"name": "run",
			"framesLength": 13,
			"frames": [3,3,4,4,5,5,5,5,4,4,3,3,3]
		},
		{
			"name": "walk",
			"framesLength": 13,
			"frames": [6,7,7,7,7,6,6,8,8,8,8,6,8]
		}
    ],
```

The frames arrays are indexes of the spriteData objects. In rendering code, these are used to select the correct frames to display.

The animation names are taken from smart folder names in Texture Packer and successful exports rely on the use of smart folders.

e.g. In my AnimatedSprite implementation, I have a play function that I simply pass an animation name into which corresponds to the "name" member in my animations objects (AnimatedSprite.play("run"));

## Array lengths
I store the lengths of arrays in the exported data so that I can allocate the exact amount memory for the arrays in C. This prevents the need to do any additional realloc calls.

## Example export
basicAnimationExample.json and basicAnimationExample.png shows a basic use case for the exporter.

### Disclaimer
If anyone has trouble using this due in incomplete documentation (I could add screenshots of my configuration in Texture Packer GUI perhaps), please reach out using github issues and I will happily add better documentation.
What is here is just what came to my mind at the time and is mostly to remind my future self (I don't expect anyone other than me to actually use this).