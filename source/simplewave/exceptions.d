module simplewave.exceptions;

import std.exception;

static class WaveReaderException : Exception {
    mixin basicExceptionCtors;
}

static class WaveWriterException : Exception {
    mixin basicExceptionCtors;
}