# This script converts the output of the KYOTO Kybot program to triples, where the first element is the event and the second element is the participant. The relation is the role of the participant in the event.
# takes 3 arguments
# a1 = kybot output format (KYOTO style)
# a2 = path to kaf file
# a3 = threshold integer between 0 en 100 for using WSD-based output above a confidence #threshold 

#Two examples are given, one with the threshold for WSD set to 0 and another set to 60%. #This means that the systems only considers triples using concepts selected with 0% and 60%
#or higher of the highest score, respectively.
 
java -Xmx812m -cp ../lib/TripleEvaluation-1.0-jar-with-dependencies.jar vu.tripleevaluation.conversion.KybotOutputToTriples ../data/11767.kaf.kybot.xml ../data/11767.kaf 0

java -Xmx812m -cp ../lib/TripleEvaluation-1.0-jar-with-dependencies.jar vu.tripleevaluation.conversion.KybotOutputToTriples ../data/11767.kaf.kybot.xml ../data/11767.kaf 60

# after the conversion the triples are compare to the gold-standard triples created with the kybotevaluation.sh

