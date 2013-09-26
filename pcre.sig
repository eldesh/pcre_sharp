
signature PCRE =
sig
  type pcre
  type extra
  type table
  type t

  structure Opt : sig
    type t
    val compose : t -> t -> t

    val EMPTY              : t
    val CASELESS           : t
    val MULTILINE          : t
    val DOTALL             : t
    val EXTENDED           : t
    val ANCHORED           : t
    val DOLLAR_ENDONLY     : t
    val EXTRA              : t
    val NOTBOL             : t
    val NOTEOL             : t
    val UNGREEDY           : t
    val NOTEMPTY           : t
    val UTF8               : t
    val UTF16              : t
    val NO_AUTO_CAPTURE    : t
    val NO_UTF8_CHECK      : t
    val NO_UTF16_CHECK     : t
    val AUTO_CALLOUT       : t
    val PARTIAL_SOFT       : t
    val PARTIAL            : t
    val DFA_SHORTEST       : t
    val DFA_RESTART        : t
    val FIRSTLINE          : t
    val DUPNAMES           : t
    val NEWLINE_CR         : t
    val NEWLINE_LF         : t
    val NEWLINE_CRLF       : t
    val NEWLINE_ANY        : t
    val NEWLINE_ANYCRLF    : t
    val BSR_ANYCRLF        : t
    val BSR_UNICODE        : t
    val JAVASCRIPT_COMPAT  : t
    val NO_START_OPTIMIZE  : t
    val NO_START_OPTIMISE  : t
    val PARTIAL_HARD       : t
    val NOTEMPTY_ATSTART   : t
    val UCP                : t
  end
  
  structure ErrorCode : sig
    type t = int
    val PCRE_ERROR_NOMATCH        : t
    val PCRE_ERROR_NULL           : t
    val PCRE_ERROR_BADOPTION      : t
    val PCRE_ERROR_BADMAGIC       : t
    val PCRE_ERROR_UNKNOWN_OPCODE : t
    val PCRE_ERROR_UNKNOWN_NODE   : t
    val PCRE_ERROR_NOMEMORY       : t
    val PCRE_ERROR_NOSUBSTRING    : t
    val PCRE_ERROR_MATCHLIMIT     : t
    val PCRE_ERROR_CALLOUT        : t
    val PCRE_ERROR_BADUTF8        : t
    val PCRE_ERROR_BADUTF8_OFFSET : t
    val PCRE_ERROR_PARTIAL        : t
    val PCRE_ERROR_BADPARTIAL     : t
    val PCRE_ERROR_INTERNAL       : t
    val PCRE_ERROR_BADCOUNT       : t
    val PCRE_ERROR_DFA_UITEM      : t
    val PCRE_ERROR_DFA_UCOND      : t
    val PCRE_ERROR_DFA_UMLIMIT    : t
    val PCRE_ERROR_DFA_WSSIZE     : t
    val PCRE_ERROR_DFA_RECURSE    : t
    val PCRE_ERROR_RECURSIONLIMIT : t
    val PCRE_ERROR_NULLWSLIMIT    : t
    val PCRE_ERROR_BADNEWLINE     : t
    val PCRE_ERROR_BADOFFSET      : t
    val PCRE_ERROR_SHORTUTF8      : t

    (*  Specific error codes for UTF-8 validity checks  *)

    val PCRE_UTF8_ERR0            : t
    val PCRE_UTF8_ERR1            : t
    val PCRE_UTF8_ERR2            : t
    val PCRE_UTF8_ERR3            : t
    val PCRE_UTF8_ERR4            : t
    val PCRE_UTF8_ERR5            : t
    val PCRE_UTF8_ERR6            : t
    val PCRE_UTF8_ERR7            : t
    val PCRE_UTF8_ERR8            : t
    val PCRE_UTF8_ERR9            : t
    val PCRE_UTF8_ERR10           : t
    val PCRE_UTF8_ERR11           : t
    val PCRE_UTF8_ERR12           : t
    val PCRE_UTF8_ERR13           : t
    val PCRE_UTF8_ERR14           : t
    val PCRE_UTF8_ERR15           : t
    val PCRE_UTF8_ERR16           : t
    val PCRE_UTF8_ERR17           : t
    val PCRE_UTF8_ERR18           : t
    val PCRE_UTF8_ERR19           : t
    val PCRE_UTF8_ERR20           : t
    val PCRE_UTF8_ERR21           : t

    (*  Specific error codes for UTF-16 validity checks  *)

    val PCRE_UTF16_ERR0           : t
    val PCRE_UTF16_ERR1           : t
    val PCRE_UTF16_ERR2           : t
    val PCRE_UTF16_ERR3           : t
    val PCRE_UTF16_ERR4           : t
  end

  exception Error of ErrorCode.t

  val version : string

  val capture_count : t -> (int, int) Either.t

  val exec : (t * extra option * string * int * Opt.t) -> string option list

  val compile : (string * Opt.t * table option) -> t

  val match : string -> string -> string option list
  
  structure Open :
  sig
    type t
    val =~ : string * string -> string option list
	val || : Opt.t * Opt.t -> Opt.t
  end
end


