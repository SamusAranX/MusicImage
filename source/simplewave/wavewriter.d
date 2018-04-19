module simplewave.wavewriter;

import std.range,
       std.file,
       std.array,
       std.string,
       std.stdio,
       std.exception;

static class WaveWriterException : Exception {
    mixin basicExceptionCtors;
}

class WaveWriter {
	immutable uint HEADER_RIFF = 0x46464952;
	immutable uint HEADER_WAVE = 0x45564157;
	immutable uint HEADER_FMT  = 0x20746D66;
	immutable uint HEADER_DATA = 0x61746164;

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

	struct DataChunk {
		uint    SubchunkID; // "data"
		uint    SubchunkSize;
		//ubyte[] samples;
	}

	string wavname;

	this(string fname) {
		this.wavname = fname;
	}

	bool writeSamples(ushort channels, uint sampleRate, ushort bitsPerSample, ubyte[] samples) {
		File file = File(this.wavname, "w");

		auto rh = RiffHeader(HEADER_RIFF, cast(uint)(samples.length + 36), HEADER_WAVE);
		auto wf = WaveFormat(HEADER_FMT, 16, 1, 
			                 channels, 
			                 sampleRate,
			                 sampleRate * channels * bitsPerSample / 8,
			                 cast(ushort)(channels * bitsPerSample / 8),
			                 bitsPerSample);
		
		auto dc = DataChunk(HEADER_DATA, cast(uint)samples.length);

		file.rawWrite((&rh)[0..1]); // Write RIFF header
		file.rawWrite((&wf)[0..1]); // Write wave format header
		file.rawWrite((&dc)[0..1]); // Write data chunk

		file.rawWrite(samples);

		file.close();

		return true;
	}
}


