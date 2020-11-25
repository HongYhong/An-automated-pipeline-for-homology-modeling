from modeller import *
import argparse
import os


parser = argparse.ArgumentParser()
parser.add_argument( "--templatepath",required=True, help="the path of the template pdb file")
parser.add_argument( "--targetname",required=True, help="the name of the target file.")
args = parser.parse_args()
template_path = args.templatepath
target_name = args.targetname  #pdbcid means pdb chain id.

(template_dir, template_fn) = os.path.split(template_path)

template_name = template_fn.replace(".pdb","")
target_dir = template_dir + "/../"

env = environ()

aln = alignment(env)

mdl = model(env, file=template_path.replace(".pdb",""))
aln.append_model(mdl, align_codes=template_name, atom_files=template_fn)
aln.append(file=target_dir + target_name + ".ali", align_codes=target_name)
aln.align2d()
aln.write(file=target_dir+target_name+"_"+template_name + '.ali', alignment_format='PIR')
aln.write(file=target_dir+target_name+"_"+template_name + '.pap', alignment_format='PAP')

