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

	real radius, gap;
	PointInt centerPoint;

	this(string pngfile, real radius, real gap) {
		this.image = readPng(pngfile).getAsTrueColorImage();
		this.colorData = this.image.imageData.colors;

		this.radius = radius;
		this.gap = gap;

		// assuming image height == image width and both divisible by 2
		this.centerPoint = PointInt(this.image.width() / 2, this.image.width() / 2);
	}

	bool decode(int channels, int sampleRate, int bitsPerSample, string outfile) {
		auto spiral = new Spiral(this.radius, this.centerPoint, this.gap);

		int minX = centerPoint.x * 2, maxX = 0;
		int minY = centerPoint.y * 2, maxY = 0;

		Color c;
		int sideLength = this.image.width();
		uint numberOfEmptyPixels = 0; // empty = fully black or transparent pixels

		writeln("Processing pixels…");

		ubyte[] samples;
		while (numberOfEmptyPixels < 10) {
			auto coords = spiral.nextRounded();

			//writeln(coords);

			ulong colorDataOffset = cast(ulong)(coords.y * sideLength + coords.x);
			c = this.colorData[colorDataOffset];

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

		//int padSamplesTo = 3;
		//ulong samplesRemainder = wave.samples.length % padSamplesTo;
		//ulong samplesPadded = wave.samples.length;
		//if (samplesRemainder > 0)
		//	samplesPadded += (padSamplesTo - samplesRemainder);

		//int progress = -1;
		//PointInt[] drawCoords;

		//// First of two loops: Filling an array of coordinates
		//for (int i = 0; i < samplesPadded; i += padSamplesTo) {
		//	auto coords = spiral.nextRounded();

		//	minX = min(coords.x, minX);
		//	minY = min(coords.y, minY);
		//	maxX = max(coords.x, maxX);
		//	maxY = max(coords.y, maxY);

		//	drawCoords ~= coords;

		//	int newProgress = cast(int)(cast(float)i / samplesPadded * 100);
		//	if (progress < newProgress) {
		//		progress = newProgress;
		//		writefln("Progress: %03d%%", progress);
		//	}

		//	//toggle = !toggle;
		//}

		//int rawWidth  = maxX - minX;
		//int rawHeight = maxY - minY;

		//int longerSide = max(rawWidth, rawHeight);

		//// Padding size to be +20px max
		//float padding = 2;
		//int finalSize  = cast(int)((floor(cast(float)longerSide / 10) + padding) * 10);
		//auto newCenter = PointInt(finalSize/2, finalSize/2);

		//auto image = new TrueColorImage(finalSize, finalSize);
		//auto colorData = image.imageData.colors;

		//for (int i = 0; i < samplesPadded; i += padSamplesTo) {
		//	auto coords = drawCoords[i / 3] - arbCenterPoint + newCenter;

		//	ubyte r, g, b;
		//	r = wave.samples[i + 0];
		//	g = wave.samples[i + 1];
		//	b = wave.samples[i + 2];

		//	//writefln("Sample: 0x%02X 0x%02X 0x%02X (%02.3f%%)", r, g, b, cast(float)i / samplesPadded * 100);
			
		//	ulong colorDataOffset = cast(ulong)(coords.y * finalSize + coords.x);
		//	colorData[colorDataOffset] = Color(r, g, b);
		//}

		//writefln("Progress: %03d%%", 100);

		//writePng(outfile, image);

		//writefln("Saved image as %s.", outfile);
		return true;
	}

}