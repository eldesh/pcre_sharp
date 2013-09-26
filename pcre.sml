(**
 *
 * SML# PCRE(http://www.pcre.org/) wrapper library
 *
 *)

structure Pcre (* :> PCRE *)=
struct
local
  structure E = Either
  structure R = PcreRaw
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
  infix ||

  structure Opt =
  struct
    structure O = R.Opt
    type t = O.t
    fun compose x y = Word.orb (x,y)

    (* Options *)
    val EMPTY              = 0w0
    val CASELESS           = O.PCRE_CASELESS           (*  Compile  *)
    val MULTILINE          = O.PCRE_MULTILINE          (*  Compile  *)
    val DOTALL             = O.PCRE_DOTALL             (*  Compile  *)
    val EXTENDED           = O.PCRE_EXTENDED           (*  Compile  *)
    val ANCHORED           = O.PCRE_ANCHORED           (*  Compile, exec, DFA exec  *)
    val DOLLAR_ENDONLY     = O.PCRE_DOLLAR_ENDONLY     (*  Compile, used in exec, DFA exec  *)
    val EXTRA              = O.PCRE_EXTRA              (*  Compile  *)
    val NOTBOL             = O.PCRE_NOTBOL             (*  Exec, DFA exec  *)
    val NOTEOL             = O.PCRE_NOTEOL             (*  Exec, DFA exec  *)
    val UNGREEDY           = O.PCRE_UNGREEDY           (*  Compile  *)
    val NOTEMPTY           = O.PCRE_NOTEMPTY           (*  Exec, DFA exec  *)
    (*  The next two are also used in exec and DFA exec  *)
    val UTF8               = O.PCRE_UTF8               (*  Compile (same as PCRE_UTF16)  *)
    val UTF16              = O.PCRE_UTF16              (*  Compile (same as PCRE_UTF8)  *)
    val NO_AUTO_CAPTURE    = O.PCRE_NO_AUTO_CAPTURE    (*  Compile  *)
    (*  The next two are also used in exec and DFA exec  *)
    val NO_UTF8_CHECK      = O.PCRE_NO_UTF8_CHECK      (*  Compile (same as PCRE_NO_UTF16_CHECK)  *)
    val NO_UTF16_CHECK     = O.PCRE_NO_UTF16_CHECK     (*  Compile (same as PCRE_NO_UTF8_CHECK)  *)
    val AUTO_CALLOUT       = O.PCRE_AUTO_CALLOUT       (*  Compile  *)
    val PARTIAL_SOFT       = O.PCRE_PARTIAL_SOFT       (*  Exec, DFA exec  *)
    val PARTIAL            = O.PCRE_PARTIAL            (*  Backwards compatible synonym  *)
    val DFA_SHORTEST       = O.PCRE_DFA_SHORTEST       (*  DFA exec  *)
    val DFA_RESTART        = O.PCRE_DFA_RESTART        (*  DFA exec  *)
    val FIRSTLINE          = O.PCRE_FIRSTLINE          (*  Compile, used in exec, DFA exec  *)
    val DUPNAMES           = O.PCRE_DUPNAMES           (*  Compile  *)
    val NEWLINE_CR         = O.PCRE_NEWLINE_CR         (*  Compile, exec, DFA exec  *)
    val NEWLINE_LF         = O.PCRE_NEWLINE_LF         (*  Compile, exec, DFA exec  *)
    val NEWLINE_CRLF       = O.PCRE_NEWLINE_CRLF       (*  Compile, exec, DFA exec  *)
    val NEWLINE_ANY        = O.PCRE_NEWLINE_ANY        (*  Compile, exec, DFA exec  *)
    val NEWLINE_ANYCRLF    = O.PCRE_NEWLINE_ANYCRLF    (*  Compile, exec, DFA exec  *)
    val BSR_ANYCRLF        = O.PCRE_BSR_ANYCRLF        (*  Compile, exec, DFA exec  *)
    val BSR_UNICODE        = O.PCRE_BSR_UNICODE        (*  Compile, exec, DFA exec  *)
    val JAVASCRIPT_COMPAT  = O.PCRE_JAVASCRIPT_COMPAT  (*  Compile, used in exec  *)
    val NO_START_OPTIMIZE  = O.PCRE_NO_START_OPTIMIZE  (*  Compile, exec, DFA exec  *)
    val NO_START_OPTIMISE  = O.PCRE_NO_START_OPTIMISE  (*  Synonym  *)
    val PARTIAL_HARD       = O.PCRE_PARTIAL_HARD       (*  Exec, DFA exec  *)
    val NOTEMPTY_ATSTART   = O.PCRE_NOTEMPTY_ATSTART   (*  Exec, DFA exec  *)
    val UCP                = O.PCRE_UCP                (*  Compile, used in exec, DFA exec  *)
  end

  structure ErrorCode = R.ErrorCode

  exception Error of ErrorCode.t

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
                    fun ext str (from,to) =
                      if (from,to) = (~1,~1) (* skip unused pattern *)
                      then NONE
                      else SOME $ String.extract (str, from, SOME(to-from))
                    fun go i = if (cnt+1) * 2 <= i then NONE
                               else SOME (ext subject (sub(vec,i), sub(vec,i+1)),i+2)
                in unfoldr go 2
                end
              else
                if ret=ErrorCode.PCRE_ERROR_NOMATCH then []
                else
                  case List.find (fn err=> err=ret)
                            [ ErrorCode.PCRE_ERROR_NULL
                            , ErrorCode.PCRE_ERROR_BADOPTION
                            , ErrorCode.PCRE_ERROR_BADMAGIC
                            , ErrorCode.PCRE_ERROR_UNKNOWN_NODE
                            , ErrorCode.PCRE_ERROR_NOMEMORY
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
      then raise Fail (!errmsg^":"^(String.extract (pattern, !erroffset, NONE)))
      else ret
    end

  fun match str pattern =
    let
      val regex = compile (pattern, Opt.EMPTY, NONE)
    in
      exec (regex, NONE, str, 0, Opt.EMPTY) before R.pcre_free regex
    end
   
  structure Open =
  struct
    type t = R.t
    fun str =~ re = match str re
    fun x || y = Opt.compose x y
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
  val test = println o (fn xs=> "match!("^(String.concatWith ","
                                              (map (fn x=> getOpt (x,"")) xs))^")")
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

