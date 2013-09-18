(**
 *
 * SML# PCRE(http://www.pcre.org/) wrapper library
 *
 *)

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

  exception Error of R.ErrorCode.t

  fun unfoldr f e =
    case f e
      of SOME(x,e) => x::unfoldr f e
       | NONE => []

  fun exec (code, extra, subject, startoffset, option) =
    let val extra = maybe (Ptr.NULL()) id extra
    in
      case capture_count code
        of E.Left n    => raise Error n
         | E.Right cnt =>
            let
              val ovector = Array.array((1+cnt)*3, 0)
              val ret = R.pcre_exec (code, extra, subject, size subject
                          , startoffset, option, ovector, Array.length ovector)
            in
              (* print $ concat["ret:",Int.toString ret,"\n"]; *)
              if 0 < ret
              then
                let val vec = Array.vector ovector
                    val sub = Vector.sub
                    fun ext str (from,to) = String.extract (str, from, SOME(to-from))
                    fun go i = if (cnt+1) * 2 <= i then NONE
                               else SOME (ext subject (sub(vec,i), sub(vec,i+1)),i+2)
                in unfoldr go 0
                end
              else
                if ret=R.ErrorCode.PCRE_ERROR_NOMATCH then []
                else
                  case List.find (fn err=> err=ret)
                            [ R.ErrorCode.PCRE_ERROR_NULL
                            , R.ErrorCode.PCRE_ERROR_BADOPTION
                            , R.ErrorCode.PCRE_ERROR_BADMAGIC
                            , R.ErrorCode.PCRE_ERROR_UNKNOWN_NODE
                            , R.ErrorCode.PCRE_ERROR_NOMEMORY
                            ]
                    of SOME code => raise Error code
                     | NONE      => raise Fail "Pcre.exec"
            end
    end

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

  fun compile (pattern, option, table) =
    let
      val (errmsg, erroffset) = (ref "", ref 0)
      val ret = R.pcre_compile (pattern, option, errmsg, erroffset, table)
    in
      if Ptr.isNull ret
      then E.Left {msg= !errmsg, pos= !erroffset}
      else E.Right ret
    end

  fun match str pattern =
    case compile (pattern, 0, NONE)
      of E.Right regex => E.Right $ exec (regex, NONE, str, 0, 0) before R.pcre_free regex
       | E.Left  err   => E.Left err
   
  structure Open =
  struct
    type t = R.t
    fun str =~ re = match str re
  end
  open Open
end (* local *)
end

(* sample code *)
local
  open Pcre Pcre.Open
  structure E = Either
  infix =~
  fun println s = print(s^"\n")
  val test = println o (E.sum (fn _=> "<not match>")
                              (fn xs=> "match!("^(String.concatWith "," xs)^")"))
  fun getLineWith prompt () =
    (print (prompt^"> ");
     let val str = valOf (TextIO.inputLine TextIO.stdIn)
     in
       String.extract (str, 0, SOME(size str-1))
     end
    )
in
  val _ =
    while true do
    (let
       val subject = getLineWith "subject" ()
       val pattern = getLineWith "pattern" ()
     in
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

