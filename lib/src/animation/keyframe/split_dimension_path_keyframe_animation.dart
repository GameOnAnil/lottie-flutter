import 'dart:ui';

import '../../value/keyframe.dart';
import 'base_keyframe_animation.dart';

class SplitDimensionPathKeyframeAnimation
    extends BaseKeyframeAnimation<Offset, Offset> {
  late Offset _point;
  final BaseKeyframeAnimation<double, double> _xAnimation;
  final BaseKeyframeAnimation<double, double> _yAnimation;

  SplitDimensionPathKeyframeAnimation(this._xAnimation, this._yAnimation)
      : super(<Keyframe<Offset>>[]) {
    // Register listeners so we can propagate changes
    _xAnimation.addUpdateListener(_onUpdate);
    _yAnimation.addUpdateListener(_onUpdate);

    // Initial progress setup
    setProgress(progress);
  }

  void _onUpdate() {
    _point = Offset(_xAnimation.value, _yAnimation.value);
    notifyListeners();
  }

  @override
  void setProgress(double progress) {
    _xAnimation.setProgress(progress);
    _yAnimation.setProgress(progress);
    _onUpdate(); // Ensure listeners are notified with updated point
  }

  @override
  Offset get value => _point;

  @override
  Offset getValue(Keyframe<Offset> keyframe, double keyframeProgress) => _point;

  @override
  void dispose() {
    _xAnimation.removeUpdateListener(_onUpdate);
    _yAnimation.removeUpdateListener(_onUpdate);
    super.dispose();
  }
}
