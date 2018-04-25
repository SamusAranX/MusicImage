module simplewave.wavereader;

import std.range,
       std.file,
       std.array,
       std.string,
       std.stdio,
       std.exception;

import simplewave.exceptions;

class WaveReader {
	immutable uint HEADER_RIFF = 0x46464952;
	immutable uint HEADER_WAVE = 0x45564157;
	immutable uint HEADER_FMT  = 0x20746D66;
	immutable uint HEADER_DATA = 0x61746164;

	immutable uint HEADER_LIST = 0x5453494C;

	struct RiffHeader {
		uint ChunkID;
		uint ChunkSize;
		uint Format;
	}

	struct WaveFormat {
		uint   SubchunkID; // "fmt "
		uint   SubchunkSize; // 16 for PCM
		ushort AudioFormat; // 1 for PCM
		ushort NumChannels; // 1 = Mono, 2 = Stereo etc.
		uint   SampleRate; // e.g. 44100
		uint   ByteRate; // SampleRate * NumChannels * (BitsPerSample/8)
		ushort BlockAlign; // NumChannels * (BitsPerSample/8) or bytes for one sample across all channels
		ushort BitsPerSample; // exactly what it says on the tin
	}

	struct ListChunk {
		uint SubchunkID; // "LIST"
		uint SubchunkSize;
	}

	struct DataChunk {
		uint SubchunkID; // "data"
		uint SubchunkSize;
	}

	int channels;
	int sampleRate;
	int bitsPerSample;

	ubyte[] samples;

	this(string fname) {
		File file = File(fname, "r");

		RiffHeader rh;
		file.rawRead((&rh)[0..1]);

		assert(rh.ChunkID == HEADER_RIFF);
		assert(rh.Format == HEADER_WAVE);

		WaveFormat wf;
		file.rawRead((&wf)[0..1]);

		assert(wf.SubchunkID == HEADER_FMT);

		if (wf.NumChannels != 1)
			throw new WaveReaderException("Wave files must not have more than one channel");

		if (wf.BitsPerSample != 8)
			throw new WaveReaderException("Wave files must not have more than 8 bits per sample");

		this.channels      = wf.NumChannels;
		this.sampleRate    = wf.SampleRate;
		this.bitsPerSample = wf.BitsPerSample;

		// Skip LIST chunk, if present
		uint maybeList;
		maybeList = file.rawRead((&maybeList)[0..1])[0];
		file.seek(-4, SEEK_CUR);
		if (maybeList == HEADER_LIST) {
			throw new WaveReaderException("Wave files must not contain a LIST chunk");
			//ListChunk lc;
			//file.rawRead((&lc)[0..1]);
			//file.rawRead(new ubyte[](lc.SubchunkSize));
		}

		DataChunk dc;
		file.rawRead((&dc)[0..1]);

		this.samples = new ubyte[dc.SubchunkSize];

		samples = file.rawRead(samples);

		file.close();
	}
}


