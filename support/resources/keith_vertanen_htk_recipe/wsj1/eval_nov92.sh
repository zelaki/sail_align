# Evaluate on the November 92 ARPA test set.
#
# During the recognition, we'll output lattices
# for each of the test utterances, this will alow
# us to tune the LM scale factor and insertion 
# penalty much quicker than recognizing.
#
# Parameters:
#  1 - Directory name of model to test
#  2 - Distinguishing name for this test run.
#  3 - HVite pruning value
#  4 - Insertion penalty
#  5 - Language model scale factor
#  6 - "cross" if we are doing cross word triphones

cd $WSJ0_DIR

rm -f $TRAIN_WSJ1/hvite_nov92$2.log $TRAIN_WSJ1/hresults_nov92$2.log

# HVite parameters:
#  -H    HMM macro definition files to load
#  -S    List of feature vector files to recognize
#  -i    Where to output the recognition MLF file
#  -w    Word network to you as language model
#  -p    Insertion penalty
#  -s    Language model scale factor
#  -z    Extension for lattice output files
#  -n    Number of tokens in a state (bigger number means bigger lattices)

# We'll run with some reasonable values for insertion penalty and LM scale,
# but these will need to be tuned.

# We need to send in a different config file depending on whether
# we are doing cross word triphones or not.
if [[ $6 != "cross" ]]
then
HVite -A -T 1 -t $3 -C $TRAIN_COMMON/configwi -H $TRAIN_WSJ1/$1/macros -H $TRAIN_WSJ1/$1/hmmdefs -S $WSJ0_DIR/nov92_test.scp -i $TRAIN_WSJ1/recout_nov92$2.mlf -w $TRAIN_WSJ0/wdnet_bigram -p $4 -s $5 -z lat -n 4 $TRAIN_WSJ0/dict_5k $TRAIN_WSJ1/tiedlist >$TRAIN_WSJ1/hvite_nov92$2.log
else
HVite -A -T 1 -t $3 -C $TRAIN_COMMON/configcross -H $TRAIN_WSJ1/$1/macros -H $TRAIN_WSJ1/$1/hmmdefs -S $WSJ0_DIR/nov92_test.scp -i $TRAIN_WSJ1/recout_nov92$2.mlf -w $TRAIN_WSJ0/wdnet_bigram -p $4 -s $5 -z lat -n 4 $TRAIN_WSJ0/dict_5k $TRAIN_WSJ1/tiedlist >$TRAIN_WSJ1/hvite_nov92$2.log
fi

# Now lets see how we did!  
cd $TRAIN_WSJ0
HResults -n -A -T 1 -I $TRAIN_WSJ0/nov92_words.mlf $TRAIN_WSJ1/tiedlist $TRAIN_WSJ1/recout_nov92$2.mlf >$TRAIN_WSJ1/hresults_nov92$2.log

# Add on a NIST style output result for good measure
HResults -n -h -A -T 1 -I $TRAIN_WSJ0/nov92_words.mlf $TRAIN_WSJ1/tiedlist $TRAIN_WSJ1/recout_nov92$2.mlf >>$TRAIN_WSJ1/hresults_nov92$2.log
