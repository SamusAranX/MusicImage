# MusicImage
Creates fancy vinyl-like PNGs from music files

## Features
* Can "encode" 8-bit mono WAV files in PNG files
* Can "decode" those PNG files to re-create the original WAV

## Download
There are no releases, you'll have to build MusicImage yourself. It's as easy as `dub build` in the project folder though.

## Limitations
MusicImage only supports WAV files with:

* one channel
* 8 bits per sample
* a bit rate of 8000 Hz or less

If you try to open anything else, MusicImage will crash. All the relevant checks are in `simplewave/wavereader.d` if you want to change them.

## Feedback and support
Just tweet at me [@SamusAranX](https://twitter.com/SamusAranX).
Feel free to file an issue if you encounter any crashes, bugs, etc.: https://github.com/SamusAranX/MusicImage/issues
