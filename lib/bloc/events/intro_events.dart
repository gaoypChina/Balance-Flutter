
abstract class IntroEvents {
  const IntroEvents();
}

class NeedToValidateEvent extends IntroEvents {
  final int index;

  const NeedToValidateEvent(this.index);
}
class ValidationResultEvent extends IntroEvents {
  final bool isValid;

  const ValidationResultEvent(this.isValid);
}