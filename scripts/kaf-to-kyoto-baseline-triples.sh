# generate triples from KAF chunk layer assigning a default relation "patient" between each head of a chunk (first element) in a sentence and the heads of al the other chunks (second elements):
# a1 = path to kaf file
# a2 = default relation string
java -Xmx812m -cp ../lib/TripleEvaluation-1.0-jar-with-dependencies.jar vu.tripleevaluation.kyoto.BaseLineForChunks ../data/11767.kaf patient
