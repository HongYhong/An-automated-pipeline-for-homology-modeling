from modeller import *
from modeller.automodel import *
import os
import argparse
#from modeller import soap_protein_od

parser = argparse.ArgumentParser()
parser.add_argument( "--alignmentname",required=True, help="the name of the alignment .ali file")
args = parser.parse_args()
alignment_name = args.alignmentname

trim_alignment_name = alignment_name.replace(".ali","")
template_name = trim_alignment_name.split("_",1)[0]
known_name = trim_alignment_name.split("_",1)[1]


env = environ()

a = automodel(env, alnfile=alignment_name,
              knowns=known_name, sequence=template_name,
              assess_methods=(assess.DOPE,
                              #soap_protein_od.Scorer(),
                              assess.GA341))
a.starting_model = 1
a.ending_model = 5
a.make()