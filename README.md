# MusicImage
Creates fancy vinyl-like PNGs from music files

## Features
* Can "encode" 8-bit mono WAV files to PNG files
* Can "decode" those PNG files to re-create the original WAV

## Download
There are no releases, you'll have to build MusicImage yourself. It's as easy as `dub build` in the project folder though.

## Usage
* `-i`/`--infile`: The input file. Can be either a `.png` or a `.wav` file. *(Required)*
* `-o`/`--outfile`: The output file. Can be either a `.png` or a `.wav` file, but mustn't have the same extension as `-i`. *(Required)*
* `-r`/`--rate`: Sample rate override. Only used when decoding PNGs to WAVs. *(Optional. Default: **8000**)*
* `-d`/`--diameter`: The diameter of the hole in the middle of the spiral. *(Optional. Default: **80**)*
* `-g`/`--gap`: Gap size multiplier. Because of Reasons™, the smaller this value is, the slower MusicImage will run. *(Optional. Default: **0.3**)*

## Example
![MusicImage-encoded excerpt from Ultra Sheriff's Leviathan](https://i.peterwunder.de/leviathan8000.png)

This image decodes to [this WAV file](https://i.peterwunder.de/leviathan.wav). (Standard settings: `-r 8000 -d 80 -g 0.3`)

(The black background and the album cover were added after the fact in Photoshop. MusicImage outputs PNGs with a transparent background.)

(The full song is available [on iTunes](https://itunes.apple.com/us/album/deception-oil-and-laser-beams-ep/1105412287) and [on Spotify](https://open.spotify.com/track/4NRyBYL1pyMX696XcRgeWw), by the way. It's great.)

## Limitations
MusicImage only supports WAV files with:

* one channel
* 8 bits per sample

If you try to open anything else, MusicImage will crash. All the relevant checks are in `simplewave/wavereader.d` if you want to change them.

## Feedback and support
Just tweet at me [@SamusAranX](https://twitter.com/SamusAranX).
Feel free to file an issue if you encounter any crashes, bugs, etc.: https://github.com/SamusAranX/MusicImage/issues
