module LearnerUtils where

import           System.Random                  ( newStdGen
                                                , randomRs
                                                )
import           Data.Maybe                     ( fromJust )

-----------------------------
-- Types
-----------------------------

--             (  xs,      y)
type Example = ([Float], Float)
type Weight = Float

-----------------------------
-- IO Helper Functions
-----------------------------

readDataFromFile :: String -> IO [Example]
readDataFromFile filePath = do
    content <- readFile filePath
    return $ map (splitXsFromYappend1 . words) $ lines content

{-|
    xValues -> inputLine -> example
    takes a list of x's (should start with just [1]) and an input line
    Returns a single Example (splits inputs from output in a tuple)
-}
splitXsFromY :: [Float] -> [String] -> Example
splitXsFromY _ [] =
    error "need at least one example with at least 1 input and 1 y value"
splitXsFromY [_] [_] =
    error "need at least one example with at least 1 input and 1 y value"
splitXsFromY xs [y             ] = (xs, read y)
splitXsFromY xs (input : inputs) = splitXsFromY (xs ++ [read input]) inputs

{-|
    inputLine -> Example
    Partially apply [1] as the bias X value
-}
splitXsFromYappend1 :: [String] -> Example
splitXsFromYappend1 = splitXsFromY [1]

{-|
    eta -> reps -> wts -> error -> outfile -> Action
    write the outputs of the program to a file in the required format
-}
printOutput :: Float -> Int -> [Weight] -> Float -> String -> IO ()
printOutput eta reps wts err outfile =
    writeFile outfile
        $ "CS-5001: HW#1\n\
        \Programmer: Drew Willey\n\n\
        \TRAINING:\n\
        \Using Learning rate eta = "
        ++ show eta
        ++ "\n\
        \Using "
        ++ show reps
        ++ " iterations.\n\n\
        \OUTPUT:\n"
        ++ makeWeightStrings wts
        ++ "\n\
        \VALIDATION:\n\
        \Sum-of-Squares Error = "
        ++ show err

{-|
    weights -> weightString
    takes the list of weights
    Returns a string with a line for each weight label and its value
-}
makeWeightStrings :: [Weight] -> String
makeWeightStrings =
    unlines . map (\(x, y) -> "w" ++ show x ++ " = " ++ show y) . zip [0, 1 ..]

{-|
    safe version of head
    returns a Maybe first item in the list
-}
maybeHead :: [a] -> Maybe a
maybeHead []      = Nothing
maybeHead (l : _) = Just l

-----------------------------
-- Random Weight Generator
-----------------------------

{-|
    (startOfRange, endOfRange) -> numberOfWeights -> Action containing list of randoms in range
    Return a (IO) list of numWeights random numbers
-}
getRandomWeights :: (Float, Float) -> Maybe Int -> IO [Weight]
getRandomWeights _ Nothing = error "Error: Need at least one example"
getRandomWeights (start, end) numWeights = do
    g <- newStdGen
    return $ take (fromJust numWeights) (randomRs (start, end) g :: [Weight])
