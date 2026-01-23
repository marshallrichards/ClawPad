#!/usr/bin/env python3
"""
Whisper Transcription Server

A simple HTTP server that accepts audio files and returns transcribed text
using faster-whisper (GPU accelerated).

Run on your 3060 machine, accessible over Tailscale.

Usage:
    pip install faster-whisper flask
    python server.py

The server listens on 0.0.0.0:5000 by default.
"""

import os
import sys
import tempfile
import logging
import traceback

# Fix for CUDA DLLs on Windows - add nvidia package paths before importing faster_whisper
if sys.platform == "win32":
    import importlib.util
    import site

    # Method 1: Try finding nvidia packages
    nvidia_packages = ["nvidia.cublas.lib", "nvidia.cudnn.lib"]
    for pkg in nvidia_packages:
        try:
            spec = importlib.util.find_spec(pkg)
            if spec and spec.submodule_search_locations:
                dll_path = spec.submodule_search_locations[0]
                os.add_dll_directory(dll_path)
                print(f"Added DLL directory: {dll_path}")
        except Exception as e:
            print(f"Could not find {pkg}: {e}")

    # Method 2: Try common locations in site-packages
    for site_dir in site.getsitepackages():
        for nvidia_dir in ["nvidia/cublas/lib", "nvidia/cudnn/lib", "nvidia/cublas/bin", "nvidia/cudnn/bin"]:
            dll_path = os.path.join(site_dir, nvidia_dir)
            if os.path.exists(dll_path):
                os.add_dll_directory(dll_path)
                print(f"Added DLL directory: {dll_path}")

    # Method 3: Check if CUDA Toolkit is installed system-wide
    cuda_path = os.environ.get("CUDA_PATH")
    if cuda_path:
        cuda_bin = os.path.join(cuda_path, "bin")
        if os.path.exists(cuda_bin):
            os.add_dll_directory(cuda_bin)
            print(f"Added CUDA Toolkit bin: {cuda_bin}")

from flask import Flask, request, jsonify
from faster_whisper import WhisperModel

# Configure logging
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

app = Flask(__name__)

# Load model once at startup
# Options: "tiny", "base", "small", "medium", "large-v2", "large-v3", "turbo"
# "turbo" (large-v3-turbo) is 6x faster than large-v3 with nearly same accuracy
MODEL_SIZE = os.environ.get("WHISPER_MODEL", "turbo")
DEVICE = os.environ.get("WHISPER_DEVICE", "cuda")  # "cuda" or "cpu"
COMPUTE_TYPE = os.environ.get("WHISPER_COMPUTE", "float16")  # float16 for GPU

logger.info(f"Loading Whisper model: {MODEL_SIZE} on {DEVICE} with compute_type={COMPUTE_TYPE}...")
model = WhisperModel(MODEL_SIZE, device=DEVICE, compute_type=COMPUTE_TYPE)
logger.info("Model loaded successfully!")


@app.route("/transcribe", methods=["POST"])
def transcribe():
    """Transcribe uploaded audio file."""
    logger.info("=" * 60)
    logger.info("Received transcription request")
    logger.info(f"Request method: {request.method}")
    logger.info(f"Content-Type: {request.content_type}")
    logger.info(f"Content-Length: {request.content_length}")
    logger.debug(f"Request headers: {dict(request.headers)}")
    logger.debug(f"Request files keys: {list(request.files.keys())}")

    if "audio" not in request.files:
        logger.error("No 'audio' field in request.files")
        logger.error(f"Available fields: {list(request.files.keys())}")
        return jsonify({"error": "No audio file provided"}), 400

    audio_file = request.files["audio"]

    # Log file details
    logger.info(f"Audio file received:")
    logger.info(f"  - filename: {audio_file.filename}")
    logger.info(f"  - content_type (mime): {audio_file.content_type}")
    logger.info(f"  - mimetype: {audio_file.mimetype}")

    # Check file size by reading content
    audio_file.seek(0, 2)  # Seek to end
    file_size = audio_file.tell()
    audio_file.seek(0)  # Seek back to start
    logger.info(f"  - file_size: {file_size} bytes ({file_size / 1024:.2f} KB)")

    if file_size == 0:
        logger.error("Audio file is empty (0 bytes)")
        return jsonify({"error": "Audio file is empty"}), 400

    # Determine file extension from filename or mime type
    original_ext = os.path.splitext(audio_file.filename)[1] if audio_file.filename else ".wav"
    if not original_ext:
        original_ext = ".wav"
    logger.info(f"  - detected extension: {original_ext}")

    # Save to temp file
    tmp_path = None
    try:
        logger.info("Creating temporary file...")
        with tempfile.NamedTemporaryFile(suffix=original_ext, delete=False) as tmp:
            tmp_path = tmp.name
            logger.info(f"Saving audio to temp file: {tmp_path}")
            audio_file.save(tmp_path)

        # Verify temp file was written
        tmp_size = os.path.getsize(tmp_path)
        logger.info(f"Temp file size: {tmp_size} bytes")

        if tmp_size == 0:
            logger.error("Temp file is empty after save!")
            return jsonify({"error": "Failed to save audio file"}), 500

        # Transcribe
        logger.info("Starting transcription...")
        logger.info(f"Calling model.transcribe('{tmp_path}', beam_size=5)")

        segments, info = model.transcribe(tmp_path, beam_size=5)
        logger.info(f"Transcription info - language: {info.language}, duration: {info.duration}s")

        logger.info("Collecting segments...")
        segment_list = list(segments)
        logger.info(f"Number of segments: {len(segment_list)}")

        for i, seg in enumerate(segment_list):
            logger.debug(f"  Segment {i}: [{seg.start:.2f}s - {seg.end:.2f}s] {seg.text[:50]}...")

        text = " ".join(seg.text for seg in segment_list).strip()
        logger.info(f"Final text length: {len(text)} chars")
        logger.info(f"Transcription complete!")
        logger.info("=" * 60)

        return jsonify({
            "text": text,
            "language": info.language,
            "duration": info.duration
        })
    except Exception as e:
        logger.error("=" * 60)
        logger.error(f"TRANSCRIPTION FAILED: {type(e).__name__}: {e}")
        logger.error("Full traceback:")
        logger.error(traceback.format_exc())
        logger.error("=" * 60)
        return jsonify({"error": str(e)}), 500
    finally:
        # Clean up temp file
        if tmp_path and os.path.exists(tmp_path):
            logger.debug(f"Cleaning up temp file: {tmp_path}")
            os.unlink(tmp_path)


@app.route("/health", methods=["GET"])
def health():
    """Health check endpoint."""
    logger.debug("Health check requested")
    return jsonify({"status": "ok", "model": MODEL_SIZE, "device": DEVICE})


if __name__ == "__main__":
    # Listen on all interfaces so it's accessible over Tailscale
    logger.info(f"Starting server on 0.0.0.0:5000")
    app.run(host="0.0.0.0", port=5000, threaded=True)
