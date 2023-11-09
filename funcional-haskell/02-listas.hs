main = do
  -- geração de listas
  print [x*2 | x <- [1..10]]
  print [ x*y | x <- [2,5,10], y <- [8,10,11]] 

  let nouns = ["hobo","frog","pope"]  
  let adjectives = ["lazy","grouchy","scheming"]  
  print [adjective ++ " " ++ noun | adjective <- adjectives, noun <- nouns] 
  print [ (a,b,c) | c <- [1..10], b <- [1..c], a <- [1..b], a^2 + b^2 == c^2]

  -- operações com lista
  print (head [5,4,3,2,1])
  print (tail [5,4,3,2,1])
  print (take 3 [5,4,3,2,1])

  -- pegar pelo índice
  print ("Steve Buscemi" !! 6)