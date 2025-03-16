///Klasse für Termin-Objekt
library;

class Termin {
  String weekKey;
  String terminName;
  DateTime timeBegin;
  DateTime timeEnd;
  int doneQuestion;
  int goodMean;
  int calmMean;
  int helpMean;
  String comment;
  bool answered;

  Termin({
    required this.terminName,
    required this.timeBegin,
    required this.timeEnd,
    required this.doneQuestion,
    required this.goodMean,
    required this.calmMean,
    required this.helpMean,
    required this.comment,
    required this.answered,
    required this.weekKey,
  });

  Map<String,dynamic> toMap() {
   return{
     "weekKey": weekKey,
     "terminName":terminName,
     "timeBegin": timeBegin.toString(),
     "timeEnd": timeEnd.toString(),
     "question0": doneQuestion,
     "question1": goodMean,
     "question2": calmMean,
     "question3": helpMean,
     "comment": comment,
     "answered": answered == true ? 1 : 0
   };
}

  @override
  String toString() {
    return "Termin(terminName: $terminName, timeBegin: $timeBegin, timeEnd: $timeEnd, question0: $doneQuestion ,question1: $goodMean, question2: $calmMean, question3: $helpMean, comment: $comment, answered: $answered)";
  }
}