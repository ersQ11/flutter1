sealed class Countdown {
  const Countdown();

  factory Countdown.forDate(DateTime date, DateTime now) {
    final difference = date.difference(now);
    if (!difference.isNegative) return Upcoming(difference);
    if (now.difference(date).inHours < 1) {
      return Started(now.difference(date));
    }
    return const Ended();
  }
}

class Upcoming extends Countdown {
  const Upcoming(this.duration);
  final Duration duration;
}

class Started extends Countdown {
  const Started(this.duration);
  final Duration duration;
}

class Ended extends Countdown {
  const Ended();
}
