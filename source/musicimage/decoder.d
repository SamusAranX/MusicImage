module musicimage.decoder;

import std.stdio;
import std.algorithm.comparison;
import std.math;
import std.conv;
import core.thread;

import simplewave: WaveWriter;
import arsd.png: TrueColorImage, Color, readPng;
import musicimage.spiral;

/*
	PNG -> WAV
*/

class Decoder {

	TrueColorImage image;
	Color[] colorData;

	real holeDiameter, gap;
	PointInt centerPoint;

	this(string pngfile, real holeDiameter, real gap) {
		this.image = readPng(pngfile).getAsTrueColorImage();
		this.colorData = this.image.imageData.colors;

		this.holeDiameter = holeDiameter;
		this.gap = gap;

		// assuming image height == image width and both divisible by 2
		this.centerPoint = PointInt(this.image.width() / 2, this.image.width() / 2);
	}

	bool decode(int channels, int sampleRate, int bitsPerSample, string outfile) {
		auto spiral = new Spiral(this.holeDiameter, this.centerPoint, this.gap);

		int minX = centerPoint.x * 2, maxX = 0;
		int minY = centerPoint.y * 2, maxY = 0;

		int sideLength = this.image.width();
		uint numberOfEmptyPixels = 0; // empty = fully black or transparent pixels

		writeln("Processing pixels…");

		ubyte[] samples;
		while (numberOfEmptyPixels < 10) {
			auto coords = spiral.nextRounded();

			ulong colorDataOffset = cast(ulong)(coords.y * sideLength + coords.x);

			if (colorDataOffset < 0 || colorDataOffset >= this.colorData.length) {
				writeln("Image boundaries reached.");
				break;
			}

			auto c = this.colorData[colorDataOffset];

			//writefln("Color: 0x%03X 0x%03X 0x%03X 0x%03X", c.r, c.g, c.b, c.a);
			//writefln("Empty: %02d", numberOfEmptyPixels);

			if ((c.r == 0 && c.g == 0 && c.b == 0) || c.a == 0)
				numberOfEmptyPixels++;
			else
				numberOfEmptyPixels = 0;

			samples ~= [c.r, c.g, c.b];
		}

		// remove "empty" samples from the end of the array
		samples = samples[0..$-numberOfEmptyPixels*3];

		writefln("Total samples read: %d", samples.length);
		writefln("Writing %d samples to %s…", samples.length, outfile);

		auto wave = new WaveWriter(outfile);
		wave.writeSamples(
			cast(ushort)channels,
			cast(uint)sampleRate,
			cast(ushort)bitsPerSample,
			samples
		);

		writefln("%s successfully saved.", outfile);

		return true;
	}

}