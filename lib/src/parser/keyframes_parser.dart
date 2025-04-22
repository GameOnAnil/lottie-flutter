import '../composition.dart';
import '../value/keyframe.dart';
import 'keyframe_parser.dart';
import 'moshi/json_reader.dart';
import 'value_parser.dart';

class KeyframesParser {
  KeyframesParser._();

  static List<Keyframe<T>> parse<T>(
    JsonReader reader,
    LottieComposition composition,
    ValueParser<T> valueParser, {
    bool multiDimensional = false,
  }) {
    final options = JsonReaderOptions.of(['k']);
    final keyframes = <Keyframe<T>>[];

    if (reader.peek() == Token.string) {
      composition.addWarning("Lottie doesn't support expressions.");
      return keyframes;
    }

    reader.beginObject();
    while (reader.hasNext()) {
      final nameIndex = reader.selectName(options);
      if (nameIndex == 0) {
        if (reader.peek() == Token.beginArray) {
          reader.beginArray();
          if (reader.peek() == Token.number) {
            keyframes.add(
              KeyframeParser.parse(
                reader,
                composition,
                valueParser,
                animated: false,
                multiDimensional: multiDimensional,
              ),
            );
          } else {
            while (reader.hasNext()) {
              keyframes.add(
                KeyframeParser.parse(
                  reader,
                  composition,
                  valueParser,
                  animated: true,
                  multiDimensional: multiDimensional,
                ),
              );
            }
          }
          reader.endArray();
        } else {
          keyframes.add(
            KeyframeParser.parse(
              reader,
              composition,
              valueParser,
              animated: false,
              multiDimensional: multiDimensional,
            ),
          );
        }
      } else {
        reader.skipValue();
      }
    }
    reader.endObject();

    setEndFrames(keyframes);
    return keyframes;
  }

  /// Assigns end frames and end values based on the next keyframe's start values.
  static void setEndFrames<T>(List<Keyframe<T>> keyframes) {
    final size = keyframes.length;
    for (var i = 0; i < size - 1; i++) {
      final current = keyframes[i];
      final next = keyframes[i + 1];
      current.endFrame = next.startFrame;
      if (current.endValue == null && next.startValue != null) {
        current.endValue = next.startValue;
      }
    }

    if (size > 1) {
      final last = keyframes.last;
      if (last.startValue == null || last.endValue == null) {
        keyframes.removeLast(); // Avoid keeping redundant keyframe
      }
    }
  }
}
