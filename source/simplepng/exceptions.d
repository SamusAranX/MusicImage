module simplepng.exceptions;

import std.exception;

static class PNGException : Exception {
    mixin basicExceptionCtors;
}