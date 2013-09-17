(**
 *
 * SML# PCRE(http://www.pcre.org/) wrapper library
 *
 *)

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

structure Pcre =
struct
local
  structure E = Either
  structure R = PcreRaw
  structure Err = R.ErrorCode
  structure Ptr = Pointer

  fun id x = x
  infixr 1 $
  fun f $ a = f a
  infix >>=
  fun rl >>= f = E.bind rl f

  fun maybe none f (SOME x) = f x
    | maybe none _  NONE    = none
in
  type pcre      = R.pcre
  type extra     = R.pcre_extra
  type jit_stack = R.pcre_jit_stack
  type table     = R.table
  type t         = R.t

  infix =~

  val version = R.pcre_version()

  fun fullinfo (re, extra, what, where_) =
    let val extra = maybe (Ptr.NULL()) id extra
    in
      case R.pcre_fullinfo (re, extra, what, where_)
        of 0 => E.Right ()
         | n => E.Left  n
    end

  fun capture_count re =
    let val cnt = ref 0
    in
      fullinfo (re, NONE, R.PCRE_INFO_CAPTURECOUNT, cnt) >>= (fn _ =>
      E.Right (!cnt))
    end

  fun exec (code, extra, subject, startoffset, option, ovector) =
    let val extra = maybe (Ptr.NULL()) id extra
    in
      R.pcre_exec (code, extra, subject, size subject
      , startoffset, option, ovector, Array.length ovector)
    end


    (*
  datatype study = JIT_COMPILE
                 | JIT_PARTIAL_HARD_COMPILE
                 | JIT_PARTIAL_SOFT_COMPILE

  fun studyToInt x =
    case x
      of JIT_COMPILE              => R.PCRE_STUDY_JIT_COMPILE
       | JIT_PARTIAL_HARD_COMPILE => R.PCRE_STUDY_JIT_PARTIAL_HARD_COMPILE
       | JIT_PARTIAL_SOFT_COMPILE => R.PCRE_STUDY_JIT_PARTIAL_SOFT_COMPILE

  fun study (re, study:study) =
    let
      val err = ref ""
    in
      R.pcre_study (re, studyToInt study, err)
    end
    *)

  local structure S = ArraySlice
  in
  fun unfoldArray f arr =
    let
      fun unfoldr' arr =
        if S.length arr=0
        then []
        else if S.length arr=1
        then [f $ S.sub (arr, 0)]
        else (f $ S.sub (arr, 0))
                ::unfoldr' (S.subslice (arr, 1, NONE))
    in unfoldr' (S.full arr)
    end
  end

  fun arrayToString arr =
    concat [ "<"
           , String.concatWith "," $ unfoldArray Int.toString arr
           , ">"
           ]

  (**
   * match pattern that have zero or one capturing subpattern
   * e.g.
   * "foo (bar)"
   * "192.168.0.(\\d+)"
   *)
  fun match_one str re =
    let
      val sub = Array.sub
      val err = ref ""
      val errpos = ref 0
      val regex = R.pcre_compile (re, 0, err, errpos, NONE)
      (*
      val E.Right (cnt, arr) = capture_count regex >>= (fn cnt =>
      *)
      val xxs = Array.array(2*3, 0)
      val E.Right (cnt, arr) = E.Right 0 >>= (fn cnt =>
                (print (concat["capture count:", Int.toString cnt, "\n"]);
                 E.Right (cnt, xxs)
                (*
                 E.Right (cnt, (Array.array((1+cnt)*3, 0)))
                 *)
                ))
                (*
      val _ = print (concat["cnt:", Int.toString cnt, "\n"])
      *)
      val ret = exec (regex, NONE, str, 0, 0, arr)
    in
      print (concat["ret:", Int.toString ret, " ", arrayToString arr, "\n"]);
      if ret=cnt
      then let val idx = 2 * (cnt-1)
           in E.Right $ String.extract(str, sub(arr,idx)
                                     , SOME(sub(arr,idx+1)-sub(arr,idx)))
           end
      else E.Left ret
    end
   
  structure Open =
  struct
    type t = R.t
    fun str =~ re = match_one str re
  end
  open Open
end (* local *)
end

(*
(* sample code *)
local
  open Pcre Pcre.Open
  structure E = Either
  infix =~
  fun maybe none f (SOME x) = f x
    | maybe none f NONE = none
  fun println s = print(s^"\n")
in
  val _ =
    let
      (*
      val subject = "#314"
      val pattern = "#314 #314"
      *)
      val subject = "fixes #(\\d+)"
      val pattern = "fixes #314"
      val test = println o (E.sum (fn _=> "<not match>")
                                  (fn x=> "match!("^x^")"))
    in
      println (concat[subject, " =~ ", pattern]);
      test (pattern =~ subject)
    end
end
*)

