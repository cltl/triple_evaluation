TripleEvaluation module
======================

Version 0.1
Date: 30 May 2013
Copy right: Piek Vossen, piek.vossen@vu.nl

This program evaluates text mining output from text on the basis of a triple representation.
 
A triple consists of:
 - a relation
 - a list of token ids that represents the first element, e.g. an event
 - a list of token ids that represents the second element , e.g. a participant

Here is an example of a triple in XML format:

<triple id="16" relation="ROLE-DONE-BY">
	<elementFirstIds>
		<elementFirst id="w12250"/>
	</elementFirstIds>
	<elementSecondIds>
		<elementSecond id="w12239"/>
		<elementSecond id="w12240"/>
	</elementSecondIds>
</triple>

The identifiers refer to the token layer of the text, which is the most basic unit of 
analysis providing as little bias as possible.


Any complex structure of information can be converted into a series of triples.
If an element has multiple other elements, a separate triple is created for each pair 
(e.g. an event with each participant is a separate triple). The triple identifier is used to mark 
which triples relate to the same sharing element.

The evaluation module assume that any mined data is converted to triples. 
The program reads a file with triples that represents the gold standard and
another file with triples that is generated by the system, the system triples. 
It calculates the precision and recall for the system file, where the following definitions are used:

 - Precision = nCorrect system triples/n gold standard triples
 - Recall = nCorrect system triples/nr of system triples

Four evaluations are carried out by comparing the triple in four ways:

- all identifiers and the relation exactly match
- all identifiers match and the relation is ignored
- at least one identifier matches and the relation matches
- at least one identifier matches and the relation is ignored

 So that systems cannot cheat by making very long ranges of event Ids and participant Ids, we publish the average size of the ranges.

Furthermore, a range of tokens can be read to limit the range of text that is evaluated. If a file with the range of tokens is omitted, the scope if text is based on the sentences that have been used for the gold standard.

Since different programs generate different formats for representing the annotations of text or the information that is mined,
a separate conversion is needed from each respective output to the triple format.

The Kybot Evaluation has a number of main functions:

1. conversion functions from various formats to triples: KYOTO-KYBOT-OUTPUT, KAF-TO-TRIPLES. TUPLES-TO-TRIPLES
2. translation of relations in a triple file or folder of triple files to other relations
3. evaluation module that compares triple files: FILE-BY-FILE, FOLDER-BY-FOLDER

1. Conversion functions to create triple files

1.1  Conversion of Kybot output to the triple format

Main class:
- vu.tripleevaluation.conversion.KybotOutputToTriples

This function takes 3 obligatory arguments:
- arg1: the output of the Kybots that extract events in the KYOTO system
- arg2: the KAF file from which the Kybot output is generated
- arg3: the threshold for the WSD score of events and roles, if set to 0 all output is taken, if set to 100 only the highest scoring interpretation in case of competition. All other values are proportional to the highest score.

Output:
- a file with the triples

This program is shown by the script:

scripts/convertkybotoutputtotriplets.sh

It takes the KYOTO Kybot output in: the file data/11767.kaf.kybot.xml, which looks like:

<?xml version="1.0" encoding="UTF-8"?>
<kybotOut>
  <doc shortname="11767.mw.wsd.ne.kaf.reduced-to-migration.kaf.onto">
    <event eid="e92" target="t9018" lemma="fish" pos="V" synset="eng-30-01140794-v" rank="0.534691" profile_id="generic_kybot_Vaccomplishment-Nphysical-object-OR-matter,generic_kybot_Vaccomplishment-Naccomplishment,generic_kybot_Vaccomplishment-N-Naccomplishment,generic_kybot_Vaccomplishment-N-Nphysical-object-OR-matter"/>
    <role rid="r170" event="e92" target="t9020" lemma="restoration" pos="N" rtype="patient" synset="eng-30-00268557-n" rank="0.175324" profile_id="generic_kybot_Vaccomplishment-Naccomplishment,generic_kybot_Vaccomplishment-N-Naccomplishment"/>
    <role rid="r171" event="e92" target="t9020" lemma="restoration" pos="N" rtype="patient" synset="eng-30-14424517-n" rank="0.139554" profile_id="generic_kybot_Vaccomplishment-Nphysical-object-OR-matter,generic_kybot_Vaccomplishment-N-Nphysical-object-OR-matter"/>
    <role rid="r174" event="e92" target="t9019" lemma="passage" pos="N" rtype="patient" synset="eng-30-00201058-n" rank="0.101492" profile_id="generic_kybot_Vaccomplishment-Naccomplishment"/>
    <role rid="r179" event="e92" target="t9019" lemma="passage" pos="N" rtype="patient" synset="eng-30-03895293-n" rank="0.118576" profile_id="generic_kybot_Vaccomplishment-Nphysical-object-OR-matter"/>

etc....

and converts it to: data/11767.kaf.kybot.xml.0.trp and data/11767.kaf.kybot.xml.60.trp. The result looks as follows:

<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<triples>
<triple id="e92" profile_id="generic_kybot_Vaccomplishment-Naccomplishment,generic_kybot_Vaccomplishment-N-Naccomplishment" relation="patient">
	<elementFirstIds comment="fish">
		<elementFirst id="w10948"/>
	</elementFirstIds>
	<elementSecondIds comment="restoration">
		<elementSecond id="w10950"/>
	</elementSecondIds>
</triple>
<triple id="e92" profile_id="generic_kybot_Vaccomplishment-Nphysical-object-OR-matter,generic_kybot_Vaccomplishment-N-Nphysical-object-OR-matter" relation="patient">
	<elementFirstIds comment="fish">
		<elementFirst id="w10948"/>
	</elementFirstIds>
	<elementSecondIds comment="restoration">
		<elementSecond id="w10950"/>
	</elementSecondIds>
</triple>
<triple id="e92" profile_id="generic_kybot_Vaccomplishment-Naccomplishment" relation="patient">
	<elementFirstIds comment="fish">
		<elementFirst id="w10948"/>
	</elementFirstIds>
	<elementSecondIds comment="passage">
		<elementSecond id="w10949"/>
	</elementSecondIds>
</triple>
<triple id="e92" profile_id="generic_kybot_Vaccomplishment-Nphysical-object-OR-matter" relation="patient">
	<elementFirstIds comment="fish">
		<elementFirst id="w10948"/>
	</elementFirstIds>
	<elementSecondIds comment="passage">
		<elementSecond id="w10949"/>
	</elementSecondIds>
</triple>

1.2 Conversion of KAF Kybot tuples to triples

Tuples consist of any number of elements with any name. To convert them to tuples, one of the element needs to be the parent and all the other elements will become children. When converted to a triples, a separate triple is generated for each pair of parent and child element. The tuple identifier is used as the triple identifier to trace back triples to the tuple from which they are derived. Below is a fragment of a tuple file:

<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<kafkybot-results>
  <tuples source="bus-accident.ont.dep.kaf">
    <tuple id="1" profile="agent-1-sem" profileConfidence="30" sentenceId="s2">
      <!--Firefighters from multiple agencies responded to Highway 38 near Bryant Street in Mentone about 6:30 p.m. .-->
      <event concept="eng-30-00717358-v" confidence="0.703748" lemma="respond" mention="t33" pos="VBD" tokens="w34"/>
      <participant concept="eng-30-10091651-n" confidence="1.0" lemma="firefighter" mention="t29" pos="NNS" reference="ExtendedDnS.owl#social-object" role="agent" tokens="w30"/>
    </tuple>
    <tuple id="2" profile="agent-1-sem" profileConfidence="30" sentenceId="s2">
      <!--Firefighters from multiple agencies responded to Highway 38 near Bryant Street in Mentone about 6:30 p.m. .-->
      <event concept="eng-30-00717358-v" confidence="0.703748" lemma="respond" mention="t33" pos="VBD" tokens="w34"/>
      <participant concept="eng-30-08057206-n" confidence="0.00369784" lemma="agency" mention="t32" pos="NNS" reference="ExtendedDnS.owl#social-object" role="agent" tokens="w33"/>
    </tuple>
    <tuple id="3" profile="agent-1-sem" profileConfidence="30" sentenceId="s1">
      <!--Several people died and 27 people were injured on Sunday when a private charter tour bus coming down a mountain road collided with an SUV and another car .-->
      <event concept="eng-30-00358431-v" confidence="0.662059" lemma="die" mention="t3" pos="VBD" tokens="w3"/>
      <participant concept="eng-30-08160276-n" confidence="0.0567295" lemma="people" mention="t2" pos="NNS" reference="ExtendedDnS.owl#social-object" role="agent" tokens="w2"/>
    </tuple>
 
    
Main class:
- vu.tripleevaluation.conversion.ConvertTuplesToTriples

This function takes 2 obligatory arguments:

--tuple-file		<path to the file or folder with the tuples>
--first-element		<the name fo the element in the tuple that will become the first element in the triples>
--extension			<in case a folder with tuple files is given , then file extension of the tuple files>

Example:

java -Xmx812m -cp ../lib/TripleEvaluation-1.0-jar-with-dependencies.jar vu.tripleevaluation.conversion.ConvertTuplesToTriples --tuple-file "../data/kyoto/bus-accident.ont.dep.kaf.sem.tpl" --first-element "event"

Output:
- a file with the triples

The above text is converted to the following triples:

?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<triples>
<triple id="bus-accident.ont.dep.kaf#1" profile_id="agent-1-sem" profile_confidence="30" relation="agent">
	<elementFirstIds label="event" comment="respond">
		<elementFirst id="w34"/>
	</elementFirstIds>
	<elementSecondIds label="participant" comment="firefighter">
		<elementSecond id="w30"/>
	</elementSecondIds>
</triple>
<triple id="bus-accident.ont.dep.kaf#2" profile_id="agent-1-sem" profile_confidence="30" relation="agent">
	<elementFirstIds label="event" comment="respond">
		<elementFirst id="w34"/>
	</elementFirstIds>
	<elementSecondIds label="participant" comment="agency">
		<elementSecond id="w33"/>
	</elementSecondIds>
</triple>
<triple id="bus-accident.ont.dep.kaf#3" profile_id="agent-1-sem" profile_confidence="30" relation="agent">
	<elementFirstIds label="event" comment="die">
		<elementFirst id="w3"/>
	</elementFirstIds>
	<elementSecondIds label="participant" comment="people">
		<elementSecond id="w2"/>
	</elementSecondIds>
</triple>
<triple id="bus-accident.ont.dep.kaf#4" profile_id="agent-1-sem" profile_confidence="30" relation="agent">
	<elementFirstIds label="event" comment="collide">
		<elementFirst id="w22"/>
	</elementFirstIds>
	<elementSecondIds label="participant" comment="bus">
		<elementSecond id="w16"/>
	</elementSecondIds>
</triple>
<triple id="bus-accident.ont.dep.kaf#5" profile_id="agent-1-sem" profile_confidence="30" relation="agent">
	<elementFirstIds label="event" comment="collide">
		<elementFirst id="w22"/>
	</elementFirstIds>
	<elementSecondIds label="participant" comment="road">
		<elementSecond id="w21"/>
	</elementSecondIds>
</triple>


This program is shown by the script:

scripts/tuples-to-triples.sh


1.3 Conversion of KAF to triples

Main class:
- vu.tripleevaluation.conversion.ConvertKafToTriples

The usage of the class is as follows:

--kaf-file			<path to a single kaf file>
--kaf-folder		<path to a folder with kaf files>
--extension			[OPTIONAL] <file extension of the KAF files to be considered, to be used with the --kaf-folder option>
--intersect			[OPTIONAL] <only use opinions that have targets or holders that intersect with properties or entities>
--opinion			[OPTIONAL] <opinion layer is converted to triples>
--entity			[OPTIONAL] <entity layer is converted to triples>
--property			[OPTIONAL] <property layer is converted to triples>
--term-sentiment	[OPTIONAL] <sentiments at the term layer are converted to triples>
--srl				[OPTIONAL] <semantic role layer is converted to triples>

Output:
- a file with the triples

This program is shown by the script:

scripts/kaf-to-triples.sh

1.4 Baseline triples for KYOTO

The package includes a function to extract a baseline from a KAF file. The baseline creates triples between all the heads of constituents (chunks),
taking one as the event and all the others as the roles. You can call this function using the main class:

vu.tripleevaluation.kyoto.BaseLineForChunks <kaf-file-path> <optional relation string>

The first argument is the KAF file, the second argument is optional and can be used to name a default relation, e.g. patient.
The program directly generates a triple file from KAF.

The use of this function is shown in scripts/kybotbaselineevaluation.sh

2. Translation of triple relations

In some cases, relations in triples need to be adapted, e.g. because they are too fine-grained. 

Main class:
vu.tripleevaluation.conversion.TripleRelationConversion

Usage:
--triples				<path to the triple file
--relation-mapping		<path to a text file on each line the source relation+tab+targe relation for translation>

Output:
- a triple file with translated relations


3. Evaluation of triple files

3.1 Evaluating two triple files

Main class:
- vu.tripleevaluation.evaluation.EvaluateTriples

This function takes the following arguments:

--gold-standard-triples            file with gold standard triples
--system-triples                   file with system triples
--token-range (optional)            file with tokens for the events to be covered
--ignore-element-second  (optional) lumps differentiated second elements into one single typed
--ignore-relations (optional)       relation labels are ignored for matching
--skip-time-and-location (optional) TIME and LOCATION relations are ignored

Output:
- xls file with statistics and recall & precision for the system file. 

The evaluation is shown through script/kybotevaluation.sh

This script takes 11767.tag.trp as the gold-standard and the above created system files as the system triples. The result is an xls file. This file has details about the statistics of the triples generated  and precision/recall and f-measure. The results are given per relation and overall per file. Also some other statistics are given, such as total number of triples, nr of first elemenets, second elements, average number of first and second element identifiers in the triples (if this deviates too much from the gold standard the evaluation is not valid). 

The tokenrange indicates which tokens are considered. This is used when only a small part of the document is annotated while systems typically extract relations from the complete text. By giving a range of tokens the evaluation can be restricted to triples for that range only. You can specify any range of tokens. If the first element tokens of the system are in that range, it is considered. Typically, token-ranges are provided for gold-standards for the first element or for the sentences that include these.

If the class vu.tripleevaluation.evaluation.EvaluateTriplesDebug is used  instead, it generates details on the type of analysis, such as the precision for each profile, per relation and different types of matches: exact and partial identifiers, exact relation and ignoring the relations. It also generates a log file listing all missed triples (to improve recall), all correct matches and a confusion matrix for the profiles. There is also a log file. This log file contains a list of all the triples that were missed by the system, and errors generated in non-missed relations, e.g.

* Not covered Triples:458
Sorted Triples:458
... followed by the sorted list of triples that were not detected

* Frequency of missed Triple relations:
.... followed by a table with frequency of missed triples per relation
destination-of	36
use-of	5
generic-location	13
source-of	13
instrument	2
elementSecond	1
product-of	3
part-of	1
purpose-of	9
patient	160
path-of	1
result-of	12
has-state	47
state-of	22
done-by	80
simple-cause-of	53

* Missed Triples as table relations:
.... followed by the same missed triples in simple format per line
commercial and recreational fisheries:use-of:The Chesapeake Bay and its tributaries
Drive less:use-of:your car
Use:use-of:phosphorus-free dish detergent
most beneficial use:use-of:Forests
passage:use-of:fish
lowered:state-of:by 11 percent
desired health:state-of:38 percent

* Triples with partial ID match and correct relations:
* Triples with partial ID match but wrong relation:

* Frequency of wrong Triple relations:
patient	5
simple-cause-of	3
purpose-of	2

* Profile confusion matrix:
generic_kybot_Naccomplishment_of_Naccomplishment:patient
	done-by	2
generic_kybot_Naccomplishment_of_Norganism,generic_kybot_Naccomplishment_of_Nphysical-object:patient
	done-by	2
generic_kybot_Nnon-agentive_Vaccomplishment_main_clause:simple-cause-of
	done-by	1
generic_kybot_Norganism-OR-matter_Vaccomplishment_patient_main_clause:patient
	done-by	1
generic_kybot_Norganism-OR-matter_Vaccomplishment_simple-cause-of_main_clause:simple-cause-of
	done-by	1
generic_kybot_Nphysical-object-OR-matter_adverb_Vaccomplishment_Nphysical-object-OR-matter_main_clause,generic_kybot_Vaccomplishment-DET-Naccomplishment,generic_kybot_Vaccomplishment-Nphysical-object-OR-matter,generic_kybot_Vaccomplishment-Naccomplishment,generic_kybot_Vaccomplishment-DET-Nphysical-object-OR-matter:patient
	result-of	1
generic_kybot_Nphysical-object-OR-matter_adverb_Vstative_main_clause,generic_kybot_Nphysical-object-OR-matter_Vstative_main_clause:simple-cause-of
	done-by	1
generic_kybot_Vaccomplishment-DET-Naccomplishment,generic_kybot_Vaccomplishment-Naccomplishment:patient
	result-of	1
generic_kybot_Vaccomplishment-Nphysical-object-OR-matter,generic_kybot_Vaccomplishment-DET-Nphysical-object-OR-matter:patient
	result-of	1
generic_kybot_Vaccomplishment_for_Nphysical-object-OR-matter:purpose-of
	elementSecond	2
	
To run the program in debug mode use:
- vu.tripleevaluation.evaluation.EvaluateTriplesDebug

The KYOTO project offers an annotation tool (KafAnnotator) to create a gold-standard of triples from a text that is represented in the Kyoto annotation format (KAF).

3.2. Evaluating two folders with triple files

This program will compare a folder with system triple files with a folder with gold-standard triple files. 

Main class
vu.tripleevaluation.evaluation.EvaluateTripleFolders

Usage:
--gold-standard-triples		<path to the folder with the gold-standard triples
--system-triples			<path to the folder with the system triples>
--key						[OPTIONAL]<any string to name the evaluation result file
--ignore-file-suffix		[OPTIONAL]<number of characters that are ignored to compare a gold-standard file with a system file. If left out only identical file names are compared, otherwise they need to match expect for specified substring length>\n"+
--ignore-element-second		[OPTIONAL]<only the first element of the triples is considered>
--skip-time-and-location	[OPTIONAL]<Time and location included in the KYOTO based triples are ignored>
--relation-filter			<path to a text file listing the relations that need to be considered. This can be used to limit the evaluation to certain relations only. Each relation is listed on a separate line

Output:
It will create a subfolder in the system triple folder with a date stamp and place and overview XLS file in that folder.

This function is shown in the script /scripts/openerevaluation.sh

The script shows how system generated opinions in hotel reviews are compared with manually annotated reviews. They share the beginning of the file names but differ in the suffixing (name ending). The option --ignore-file-suffix is used to indicate what part of the file name should not be matched for files to be compared.

LICENSE
 TripleEvaluation is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. TripleEvaluation is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with TripleEvaluation.
 If not, see <http://www.gnu.org/licenses/>.