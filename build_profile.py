from sys import argv
from modeller import *


env = environ()

#usage:python build_profile.py [path to the .ali file]

#-- read in the binary database
sdb = sequence_db(env)
sdb.read(seq_database_file='pdball.bin', seq_database_format='BINARY',
         chains_list='ALL')

#-- Read in the target sequence/alignment
aln = alignment(env)
aln.append(file=argv[1], alignment_format='PIR', align_codes='ALL')

#-- Convert the input sequence/alignment into
#   profile format
prf = aln.to_profile()

#-- Scan sequence database to pick up homologous sequences
prf.build(sdb, matrix_offset=-450, rr_file='${LIB}/blosum62.sim.mat',
          gap_penalties_1d=(-500, -50), n_prof_iterations=1,
          check_profile=False, max_aln_evalue=0.01)

#-- Write out the profile in text format
prf.write(file=argv[1].replace('.ali','.prf'), profile_format='TEXT')

#-- Convert the profile back to alignment format
aln = prf.to_alignment()

#-- Write out the alignment file
aln.write(file=argv[1].replace('.ali','')+'_profile.ali', alignment_format='PIR')

