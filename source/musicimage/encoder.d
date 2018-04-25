module musicimage.encoder;

import std.stdio;
import std.algorithm.comparison;
import std.math;
import std.conv;

import core.exception;

import simplewave: WaveReader;
import arsd.png: TrueColorImage, Color, writePng;
import musicimage.spiral;

/*
	WAV -> PNG
*/

class Encoder {

	WaveReader wave;

	int arbCenter = 5000; // arbitrary large value
	PointInt arbCenterPoint;
	
	this(string wavfile) {
		this.wave = new WaveReader(wavfile);
		this.arbCenterPoint = PointInt(arbCenter, arbCenter);
	}

	bool encode(real diameter, real gap, string outfile) {
		auto spiral = new Spiral(diameter, this.arbCenterPoint, gap);

		int minX = arbCenter * 2, maxX = 0;
		int minY = arbCenter * 2, maxY = 0;

		int padSamplesTo = 3;
		ulong samplesRemainder = wave.samples.length % padSamplesTo;
		ulong samplesPadded = wave.samples.length;
		if (samplesRemainder > 0)
			samplesPadded += (padSamplesTo - samplesRemainder);

		int progress = -1;
		PointInt[] drawCoords;

		// First of two loops: Filling an array of coordinates
		for (int i = 0; i < samplesPadded; i += padSamplesTo) {
			auto coords = spiral.nextRounded();

			minX = min(coords.x, minX);
			minY = min(coords.y, minY);
			maxX = max(coords.x, maxX);
			maxY = max(coords.y, maxY);

			drawCoords ~= coords;

			int newProgress = cast(int)(cast(float)i / samplesPadded * 100);
			if (progress < newProgress) {
				progress = newProgress;
				writefln("Progress: %03d%%", progress);
			}

			//toggle = !toggle;
		}

		int rawWidth  = maxX - minX;
		int rawHeight = maxY - minY;

		int longerSide = max(rawWidth, rawHeight);

		// Padding size to be +30px max
		float padding = 4;
		int finalSize  = cast(int)((floor(cast(float)longerSide / 10) + padding) * 10);
		auto newCenter = PointInt(finalSize/2, finalSize/2);

		auto image = new TrueColorImage(finalSize, finalSize);
		auto colorData = image.imageData.colors;

		//writefln("%d×%d", longerSide, longerSide);
		//writefln("%d×%d", finalSize, finalSize);

		// Second of two loops: Actually creating the image
		for (int i = 0; i < samplesPadded; i += padSamplesTo) {
			auto coords = drawCoords[i / 3] - arbCenterPoint + newCenter;

			// not gonna bother checking of wave.samples actually has enough elements
			// once we've reached the end of the sample array, there will be at most
			// 3 caught exceptions, which is negligible.

			ubyte r, g, b;
			try
				r = wave.samples[i + 0];
			catch (RangeError e)
				r = 0;

			try
				g = wave.samples[i + 1];
			catch (RangeError e)
				g = 0;

			try
				b = wave.samples[i + 2];
			catch (RangeError e)
				b = 0;
			
			uint colorDataOffset = cast(uint)(coords.y * finalSize + coords.x);
			colorData[colorDataOffset] = Color(r, g, b);
		}

		writefln("Progress: %03d%%", 100);

		writePng(outfile, image);

		writefln("Saved image as %s.", outfile);
		return true;
	}

}