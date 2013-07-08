# evaluate system  triples to gold standard triples

#opinions
java -Xmx812m -cp ../lib/TripleEvaluation-1.0-jar-with-dependencies.jar vu.tripleevaluation.evaluation.EvaluateTripleFolders --gold-standard-triples "../data/opener/gold-standard" --system-triples "../data/opener/system-output" --key opener-overview --ignore-file-suffix 7


