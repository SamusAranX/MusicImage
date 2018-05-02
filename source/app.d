import std.stdio;
import std.getopt: config, getopt;
import std.algorithm.searching: endsWith;

import std.conv: to;

import musicimage: Encoder, Decoder, Spiral, PointInt;
import simplepng: PNGReader;
import simplepng.png: Color;

string infile;
string outfile;
int diameter = 80;
double gap = 0.3;
int sampleRate = 8000;
void main(string[] args) {
	
	auto opts = getopt(args,
		config.required,
		"infile|i",  &infile,
		config.required,
		"outfile|o", &outfile,
		"diameter|d", &diameter,
		"gap|g", &gap,
		"rate|r", &sampleRate
	);

	//auto p = PNGReader.readPNG(infile);
	//for (uint y = 0; y < p.height; y++) {
	//	for (uint x = 0; x < p.width; x++) {
	//		writefln("%d×%d: %s", x, y, p.pixels[x][y]);
	//	}
	//}
	//foreach(Color c; p.pixels1D)
	//	writeln(c);

	if (endsWith(infile, "wav") && endsWith(outfile, "png")) {
		// encode file
		writefln("Opening %s…", infile);
		auto enc = new Encoder(infile);

		writeln("--------------------");
		writefln("Channels: %d", enc.wave.channels);
		writefln("Bits per sample: %d", enc.wave.bitsPerSample);
		writefln("Sample rate: %d Hz", enc.wave.sampleRate);
		writefln("Samples: %d", enc.wave.samples.length);

		ulong seconds = (enc.wave.samples.length / enc.wave.sampleRate) % 60;
		ulong minutes = (enc.wave.samples.length / enc.wave.sampleRate) / 60;

		writefln("Duration: %02d:%02d", minutes, seconds);
		writeln("--------------------");

		enc.encode(diameter, gap, outfile);
	} else if (endsWith(infile, "png") && endsWith(outfile, "wav")) {
		// decode file
		writefln("Opening %s…", infile);
		auto dec = new Decoder(infile, diameter, gap);

		int channels = 1;
		int sampleRate = sampleRate;
		int bitsPerSample = 8;

		dec.decode(channels, sampleRate, bitsPerSample, outfile);
	} else {
		throw new Exception("Formats other than PNG and WAV are not supported.");
	}
}