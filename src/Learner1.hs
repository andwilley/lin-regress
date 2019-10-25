module Learner1
    ( main
    )
where

import           LearnerUtils
import           System.Environment             ( getArgs )
-----------------------------
-- Gradient Descent
-----------------------------

{-|
    eta -> reps -> initWeights -> examples -> learnedWeights
    given params, random weights and exmaples
    Returns a list of learned weights
-}
gradientDescent :: Float -> Int -> [Weight] -> [Example] -> [Weight]
gradientDescent _ 0 wts _ = wts
gradientDescent eta reps wts examples =
    gradientDescent eta (reps - 1) (learnWeights eta wts examples) examples

{-|
    eta -> oldWeights -> examples -> newWeights
    for each input in each example, update the relevant weight
    Return the new weights after going through each example
-}
learnWeights :: Float -> [Weight] -> [Example] -> [Weight]
learnWeights _   wts []                   = wts
learnWeights eta wts (example : examples) = learnWeights
    eta
    (updateWts wts (fst example) eta delta)
    examples
    where delta = snd example - calcYcap wts (fst example)

{-|
    weights -> xValues -> ycap
    given a list of weights and a list of X values
    Return sum i-n (wi*xi)
-}
calcYcap :: [Weight] -> [Float] -> Float
calcYcap wts xs = sum $ zipWith (*) wts xs

{-|
    oldWeights -> xValues -> eta -> delta -> newWeights
    given weights and X values, eta and delta (where delta is the diff between prediction and actual)
    return list of new weights: from 0-i (wi + eta * delta * xi)
-}
updateWts :: [Weight] -> [Float] -> Float -> Float -> [Weight]
updateWts _  [] _ _ = []
updateWts [] _  _ _ = []
updateWts (wi : wts) (xi : xs) eta delta =
    wi + eta * delta * xi : updateWts wts xs eta delta

-----------------------------
-- Run and Check Prediction
-----------------------------

{-|
    weights -> examples -> ycaps
    Takes a list of weights and a list of examples
    Returns a list of predicted y's (ycaps) for each examples with those weights
-}
predict :: [Weight] -> [Example] -> [Float]
predict _   []                   = []
predict wts ((xs, y) : examples) = calcYcap wts xs : predict wts examples

{-|
    ycaps -> examples -> SoSqError
    Takes a list of predicted values (ycaps) and a list of examples (with actual ys)
    Returns a single value for sum of squares error for these examples
-}
sumOfSquares :: [Float] -> [Example] -> Float
sumOfSquares [] _  = 0
sumOfSquares _  [] = 0
sumOfSquares (prediction : predictions) ((xs, y) : examples) =
    (y - prediction) ^ 2 + sumOfSquares predictions examples

-----------------------------
-- Entry Point
-----------------------------

main :: IO ()
main = do
    a <- getArgs
    let [train, test, output] = a
    -- init parameters
    let eta                   = 0.000004
    let reps                  = 20000
    -- parse data
    trainingData <- readDataFromFile train
    testingData  <- readDataFromFile test
    -- train weights
    wts          <-
        getRandomWeights (0, 100) $ length <$> (fst <$> maybeHead trainingData)
    let learnedWts = gradientDescent eta reps wts trainingData
    -- check against test data
    let ssqerr     = sumOfSquares (predict learnedWts testingData) testingData
    printOutput eta reps learnedWts ssqerr output
