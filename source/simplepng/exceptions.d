module simplepng.exceptions;

import std.exception;

static class PngException : Exception {
    mixin basicExceptionCtors;
}