# brain_machine
Time reversal related code 

Forward-time e-machine is M+ with statistical complexity Cmu+
Reverse-time e-machine is M- with statistical complexity Cmu-

# Causal irreversibility Xi
defined as Xi = Cmu+ - Cmu-
Reverse time M- is taken by flipping the time series data and running CSSR on that instead. 
P.S. if you do anything extra to the data (like do time skipping or downsampling, or end up with more multiline-data) make sure the data is flipped while preserving the ‘formation’ between forward and reverse time data. It is person preference but IMO easier to align the state series this way for crypticity and bidirectional stuff later
e.g.
forward time multiline:     				reverse version should be
line 1: 0 1 1							          1 1 0
line 2: 0 0 1							          1 0 0
line 3: 0 0 0							          0 0 0

# Rate of KL divergence between two machines M1 and M2
This is denoted D(M1||M2).
Need M1 and M2 transition matrices in matlab, then use them to calculate D(M+||M-). The order you do this is:

  1. Obtain the stationary distribution of causal states, as well as the transition probabilities (for each symbol emitted) in separate transition matrices. You don't need to take CSSR's output as the stationary distribution of causal states, since you can calculate this from the transition matrices alone - but I used CSSR's output.
  Running bash script 'transition_grab.sh' in the same folder as your CSSR output files will give you the stationary distribution of causal states, as well as the transition matrix files. You can write your own code (in whatever language) to do this. If you use 'transition_grab.sh' you will need to change:
  a) the loops over filenames the script runs over to match your own files.
  b) the number of possible emitted symbols (it's set to only run over 2 symbols (for binary 0 and 1), just increase num_symbols at the top
  
  2. Read those transition matrices into whatever language/software you use for computing. I assume MATLAB from here on.
I used readmatrix('textfilename'), and stored each separate transition matrix in single matlab cell array (since transition matrices vary in size for different machines).

  3. Calculate the rate of KL divergence between any two machines M1 and M2. This uses the "forward algorithm" to calculate the probability of a machine to emit a particular sequence. Two matlab function files I have included 'fa_hmm.m' and 'fa_hmm_sparse.m' will do this. 'fa_hmm.m' can take as input a transition array that has a transition matrix for any number of possible emitted symbols, but the transition matrices need to be normal full matrices. 'fa_hmm_sparse.m' is set up to use sparse matrices (to save memory/computational time) but I had to hardcode the choice of transition symbols (since you can't have a sparse array). So you would need to alter it if you increase alphabet size past 2.
Normal KL divergence is calculated between two probability distribitions. The probability distributions here is over all possible emitted symbols of length l. e.g. for l=2 and binary {0,1} symbols, the probability distribtion would be over [0 0], [0 1], [1 0], and [1 1]. and the KL divergence would be comparing the two probability distributions from two machines M1 and M2.
The rate of KL divergence is the limit of the above as l goes to infinite, divided by l. The normal KL divergence quickly becomes linear once l > history length of machine. So in a bit of a hack way, we just take the gradient of the line of normal KL divergence as a function of l, at a high enough emitted symbol length.
Matlab script 'gradKL_forward_vs_reverse.m' is an example of this - here I calculate the rate of KL divergence between forward-time and reverse-time epsilon machines.


# Crypticity and Bidirectional machine
Once you have the forward-time machine M+ and reverse-time machine M- you can construct the bi-directional epsilon machine. The bi-directional machine is constructed by stitching together the forward and reverse machine causal states as they appear.

  1. Load the state series output files from CSSR for both M+ and M-. My matlab scripts 'getcell_state_series.m' put each state series (vector) into an array. readmatrix() doesn't like the default ';' delimiter CSSR outputs so 'fixdelimiter.sh' changes it to a comma (run this on your state series files beforehand). 
Fly data (that this was written for) was 18000 values long so I hardcoded this. You need to change that, as well as the loops over file names/structure.
This was also written for a single time series output, not multi-line data. You will need to change the matlab state series format from a vector to a matrix to accomodate multi-line data.
  2. Align the forward time and reverse time state series. This means flipping the reverse time state series (so left to right is "forward in time" again), then lining up the forward and reverse states at each time step. 'align_state_series.m' does this (again for single line 18000 long state series). Make sure each individual line is aligning the states correctly when changing to multi-line.
  3. bidirectional Cmu^{+-} and crypticity: The aligned state series gives you the state series of the bidirectional machine. e.g. for forward causal states A and B, and reverse states X, Y and Z, the possible bidirectional states are (A,X),(A,Y),(A,Z),(B,X),(B,Y),(B,Z).  
From this aligned state series you can calculate the entropy of the bi-directional states: this is the bidirectional statistical complexity Cmu^{+-}. Just count the bidirectional states as they appear and divide by total number of state counts to approximate the stationary distribution of bidirectional states (and use that to calculate Cmu^{+-}). I do this in fly data in '.m'.

Crypticity 'd' is then calculated by d := 2*Cmu^{+-} - Cmu+ - Cmu-

  4. Bidirectional machine itself: If you want the machine itself, not just Cmu+-, you need to infer the transition probabilities from the state series. I do this for fly data in 'do_bistate_counts_and_transitions.m'
  5. Write a .dot file using the bidirectional state transitions (if you want to view it). For fly data 'write_all3machine_dotfile.m' writes that information for forward, reverse and bidirectional machines together in one .dot file.
