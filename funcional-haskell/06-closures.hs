-- soma y :: Int -> Int -> Int
soma y = (\x -> x + y)

main = do
  let abc = soma 10
  print (abc 5)