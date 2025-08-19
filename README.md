# ehutchens
A Stata module that extends Hutchens' segregation index to compute its full decomposition across subsamples (e.g., countries, regions), allows the bootstrap of main results, and stores results as a new dataset. 

`ehutchens`  computes hutchens segregation index and their decomposition: the subgroup contribution and local 
indexes, their weighted sum (within component) and the remaining segregation not related to subgroups (between component) across supergroups (subsamples), with bootstrap option for main results, and storing results as new datasets.


---

Installation from GitHub:

    . net install ehutchens, from("https://raw.githubusercontent.com/fceron/ehutchens/main/")

---

Main changes:

    15August (version 1.0.1)
    - Fixed bugs related to the absence of weights and improved bootstrap output display
    - Note on Bootstrap Warning: Older versions of Stata may display the following warning when bootstrapping with custom programs: Warning:  Because hu_int is not an estimation command or does not set e(sample)...
      This warning is purely technical and does not affect the validity of the bootstrap estimates or confidence intervals, which are still valid. The warning means that the auxiliary program (modified hutchens command) 
      is not a standard estimation command, so bootstrap cannot automatically detect the estimation sample. In practice, the program already restricts the sample correctly, so the results are unaffected. 
      I have modified the bootstrap call so that this warning no longer appears (tested on Stata 15 and higher).

    10June2025 (version 1.0.0)
    - Additional checks and update of the help file
    11November2024 (version 1.0.0)
    - released on GitHub
    09November2024 (version 1.0.0)
    - Last revisions and updates


