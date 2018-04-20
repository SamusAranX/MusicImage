import std.stdio;
import std.getopt: config, getopt;
import std.algorithm.searching: endsWith;

import musicimage: Encoder, Decoder, Spiral, PointInt;

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

	//writeln(infile);
	//writeln(outfile);

	if (endsWith(infile, "wav") && endsWith(outfile, "png")) {
		// encode file
		writefln("Opening %s…", infile);
		auto enc = new Encoder(infile);

		writeln("--------------------");
		writefln("Channels: %d", enc.wave.channels);
		writefln("Sample rate: %d Hz", enc.wave.sampleRate);
		writefln("Bit rate: %d", enc.wave.bitsPerSample);
		writefln("Samples: %d", enc.wave.samples.length);
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