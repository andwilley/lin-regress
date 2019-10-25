# learner1 - CS5001 Assn1

A basic linear learner using linear regression in Haskell.

## Usage

```bash
Usage: learner1 [FILE training data] [FILE testing data] [FILE output]
```

## Compile and Run

### With Stack

```bash
$ stack build
$ stack exec learner1-exe data/chocodata.txt data/chocovalid.txt output/out.txt
```

### Just the source

```bash
$ ghc -main-is Learner1 Learner1.hs -o learner1
$ ./leaner1 PATH/TO/chocodata.txt PATH/TO/chocovalid.txt PATH/TO/out.txt
```
