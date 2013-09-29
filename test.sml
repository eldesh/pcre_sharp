

(* sample code *)
local
  open Pcre Pcre.Open
  structure E = Either
  infix =~
  fun println s = print(s^"\n")
  fun maybe none f (SOME x) = f x
    | maybe none _  NONE    = none
  val test = println o
             (maybe "not match"
                    (fn xs => "match!("^(String.concatWith ","
                                       (map (fn x=> getOpt (x,"")) xs))^")"))
  fun getLineWith prompt () =
    (print (prompt^"> ");
     let val str = valOf (TextIO.inputLine TextIO.stdIn)
     in
       String.extract (str, 0, SOME(size str-1))
     end
    )
  val go = ref true
in
  fun main () =
    while !go do
    (let
       val subject = getLineWith "subject" ()
       val pattern = getLineWith "pattern" ()
     in
       if subject="" andalso pattern=""
       then go := false
       else
         println (concat["<", subject, " =~ ", pattern, ">"]);
         test (subject =~ pattern)
     end)
    (*
    let
      val subject = "fixes #314"
      val pattern = "fixes #(\\d+)"
    in
      println (concat[pattern, " =~ ", subject]);
      test (pattern =~ subject)
    end
    *)
end
val _ = main();

