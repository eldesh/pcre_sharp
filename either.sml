
structure Either =
struct
  datatype ('a, 'b) t = Right of 'b | Left of 'a
  fun isRight (Right _) = true
    | isRight _         = false
  fun isLeft (Left _) = true
    | isLeft _        = false

  fun sum left right (Right x) = right x
    | sum left right (Left  x) = left  x

  fun return x = Right x

  fun bind (Right x) f = f x
    | bind (Left  x) _ = Left x
end

