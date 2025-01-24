class Termin {
  String terminName;
  DateTime timeBegin;
  DateTime timeEnd;
  int question0;
  int question1;
  int question2;
  int question3;
  String comment;
  bool answered;

  Termin({
    required this.terminName,
    required this.timeBegin,
    required this.timeEnd,
    required this.question0,
    required this.question1,
    required this.question2,
    required this.question3,
    required this.comment,
    required this.answered,
  });

  Map<String,dynamic> toMap() {
   return{
     "terminName":terminName,
     "timeBegin": timeBegin.toString(),
     "timeEnd": timeEnd.toString(),
     "question0": question0,
     "question1": question1,
     "question2": question2,
     "question3": question3,
     "comment": comment,
     "answered": answered == true ? 1 : 0
   };
}

  @override
  String toString() {
    return 'Termin(terminName: $terminName, timeBegin: $timeBegin, timeEnd: $timeEnd, question0: $question0 ,question1: $question1, question2: $question2, question3: $question3, comment: $comment, answered: $answered)';
  }
}