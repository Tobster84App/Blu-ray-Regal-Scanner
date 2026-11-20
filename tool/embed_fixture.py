"""Bettet test/fixtures/shelf_01.jpg als Base64 in eine Dart-Datei ein.

Wird im CI vor dem Emulator-Test aufgerufen, damit der Test das Foto
ohne Asset-Eintrag (der die App vergrößern würde) lesen kann.
"""
import base64
import pathlib
import sys

root = pathlib.Path(__file__).resolve().parent.parent
src = root / "test" / "fixtures" / (sys.argv[1] if len(sys.argv) > 1 else "shelf_01.jpg")
out = root / "integration_test" / "fixture_data.g.dart"
data = base64.b64encode(src.read_bytes()).decode("ascii")
out.write_text(
    "// GENERIERT von tool/embed_fixture.py – nicht von Hand bearbeiten.\n"
    "const bool hasFixture = true;\n"
    f"const String shelfJpegBase64 = '{data}';\n"
)
print(f"{src.name}: {len(data)} Base64-Zeichen -> {out}")
