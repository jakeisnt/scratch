-- | 
-- module nil where

neighbors :: Int -> [Int]
neighbors i =
  case i of
   1 -> [6, 8]
   2 -> [7, 9]
   3 -> [4, 8]
   4-> [3, 9, 0]
   5-> []
   6-> [1, 7, 0]
   7-> [2, 6]
   8-> [1, 3]
   9-> [2, 4]
   0-> [4, 6]
   _ -> error "bad"


yieldSequences :: Int -> Int -> [Int]
yieldSequences startingPos numHops = yieldSequencesAcc [startingPos] numHops startingPos
  where
    yieldSequencesAcc :: [Int] -> Int -> Int -> [Int]
    yieldSequencesAcc sq 0 _ = sq
    yieldSequencesAcc sq nHops pos =
      concatMap (\neighbor -> yieldSequencesAcc (sq ++ [neighbor]) (nHops - 1) neighbor) (neighbors pos)
    
countSequences :: Int -> Int -> Int
countSequences startingPos numHops = length $ yieldSequences startingPos numHops
