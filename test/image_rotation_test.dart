import 'package:discscanner/recognition/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

/// Prüft, dass copyRotate(+90) im Uhrzeigersinn dreht – davon hängt die
/// Rückrechnung der Koordinaten ab.
void main() {
  test('copyRotate(+90) entspricht ScanRotation.cw90', () {
    final im = img.Image(width: 4, height: 2);
    im.setPixelRgb(0, 0, 255, 0, 0); // links oben rot
    final cw = img.copyRotate(im, angle: 90);
    expect(cw.width, 2);
    // Nach Drehung im Uhrzeigersinn liegt links oben -> rechts oben.
    expect(cw.getPixel(1, 0).r, 255);
    final back = mapFromRotated(const Box(1, 0, 2, 1), ScanRotation.cw90, 4, 2);
    expect([back.left, back.top], [0, 0]);

    final ccw = img.copyRotate(im, angle: -90);
    // gegen den Uhrzeigersinn: links oben -> links unten
    expect(ccw.getPixel(0, 3).r, 255);
    final back2 = mapFromRotated(const Box(0, 3, 1, 4), ScanRotation.ccw90, 4, 2);
    expect([back2.left, back2.top], [0, 0]);
  });
}
