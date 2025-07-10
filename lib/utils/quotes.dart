import 'dart:math';

const List<String> mentalHealthQuotes = [
  "Your present circumstances don't determine where you can go; they merely determine where you start.",
  "You don't have to control your thoughts. You just have to stop letting them control you.",
  "The best way out is always through.",
  "Your mental health is a priority. Your happiness is an essential. Your self-care is a necessity.",
  "It's okay to not be okay, but it's not okay to stay that way.",
  "Healing is not linear.",
  "What mental health needs is more sunlight, more candor, and more unashamed conversation."
];

String getDailyQuote() {
  // This provides a new quote every day of the year, repeating if needed.
  final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
  final quoteIndex = dayOfYear % mentalHealthQuotes.length;
  return mentalHealthQuotes[quoteIndex];
}