// lib/data/journal_questions.dart

// An enum to define the type of journal entry
enum JournalType {
  general,
  depression,
  anxiety,
  stress,
}

// A map that holds all the questions categorized by JournalType
const Map<JournalType, List<String>> journalQuestions = {
  JournalType.general: [
    'How are you feeling overall today — positive, neutral, or negative?',
    'Did you have any thoughts today that felt very heavy or overwhelming?',
    'Was there a moment you felt hopeful or happy? What caused it?',
    'Did you find yourself avoiding people or conversations today?',
    'How strongly do you feel connected to your surroundings right now?',
  ],
  JournalType.depression: [
    'Have you felt sad or down for most of the day today?',
    'Did you lose interest in activities you normally enjoy?',
    'How often did you feel tired or without energy?',
    'Did you feel worthless or guilty today?',
    'How was your sleep — too much, too little, or disturbed?',
    'Did you have trouble focusing or making decisions?',
    'Do you feel like the future is hopeless or dark?',
  ],
  JournalType.anxiety: [
    'Did you feel nervous or on edge most of the day?',
    'Was it hard to control your worrying thoughts?',
    'Did you feel restless, like you couldn’t sit still?',
    'Did you experience racing heartbeat, sweating, or shaking?',
    'How much did you avoid situations out of fear?',
    'Did you overthink small problems or replay them in your mind?',
    'Were you scared that something bad might happen soon?',
  ],
  JournalType.stress: [
    'Did you feel overwhelmed by responsibilities today?',
    'Did you feel under pressure at work, school, or home?',
    'Did you have physical tension (like tight shoulders, headaches)?',
    'Did you find yourself snapping or getting irritated quickly?',
    'How well were you able to relax or calm down today?',
    'Did you feel you had enough support from others?',
    'Did stress interfere with your sleep or appetite?',
  ],
};

// Define the answer options that will be used for most questions.
const List<String> answerOptions = [
  'Not at all',
  'A little',
  'Moderately',
  'Quite a bit',
  'Extremely',
];