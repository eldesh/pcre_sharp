(**
 * SML# PCRE {url= http://www.pcre.org/ } wrapper library
 *)

(**
 * import functions as possible as straightforward
 *)
structure PcreRaw =
struct
  structure Opt =
  struct
    type t = word
    (* Options *)
    val PCRE_CASELESS           = 0wx00000001  (*  Compile  *)
    val PCRE_MULTILINE          = 0wx00000002  (*  Compile  *)
    val PCRE_DOTALL             = 0wx00000004  (*  Compile  *)
    val PCRE_EXTENDED           = 0wx00000008  (*  Compile  *)
    val PCRE_ANCHORED           = 0wx00000010  (*  Compile, exec, DFA exec  *)
    val PCRE_DOLLAR_ENDONLY     = 0wx00000020  (*  Compile, used in exec, DFA exec  *)
    val PCRE_EXTRA              = 0wx00000040  (*  Compile  *)
    val PCRE_NOTBOL             = 0wx00000080  (*  Exec, DFA exec  *)
    val PCRE_NOTEOL             = 0wx00000100  (*  Exec, DFA exec  *)
    val PCRE_UNGREEDY           = 0wx00000200  (*  Compile  *)
    val PCRE_NOTEMPTY           = 0wx00000400  (*  Exec, DFA exec  *)
    (*  The next two are also used in exec and DFA exec  *)
    val PCRE_UTF8               = 0wx00000800  (*  Compile (same as PCRE_UTF16)  *)
    val PCRE_UTF16              = 0wx00000800  (*  Compile (same as PCRE_UTF8)  *)
    val PCRE_NO_AUTO_CAPTURE    = 0wx00001000  (*  Compile  *)
    (*  The next two are also used in exec and DFA exec  *)
    val PCRE_NO_UTF8_CHECK      = 0wx00002000  (*  Compile (same as PCRE_NO_UTF16_CHECK)  *)
    val PCRE_NO_UTF16_CHECK     = 0wx00002000  (*  Compile (same as PCRE_NO_UTF8_CHECK)  *)
    val PCRE_AUTO_CALLOUT       = 0wx00004000  (*  Compile  *)
    val PCRE_PARTIAL_SOFT       = 0wx00008000  (*  Exec, DFA exec  *)
    val PCRE_PARTIAL            = 0wx00008000  (*  Backwards compatible synonym  *)
    val PCRE_DFA_SHORTEST       = 0wx00010000  (*  DFA exec  *)
    val PCRE_DFA_RESTART        = 0wx00020000  (*  DFA exec  *)
    val PCRE_FIRSTLINE          = 0wx00040000  (*  Compile, used in exec, DFA exec  *)
    val PCRE_DUPNAMES           = 0wx00080000  (*  Compile  *)
    val PCRE_NEWLINE_CR         = 0wx00100000  (*  Compile, exec, DFA exec  *)
    val PCRE_NEWLINE_LF         = 0wx00200000  (*  Compile, exec, DFA exec  *)
    val PCRE_NEWLINE_CRLF       = 0wx00300000  (*  Compile, exec, DFA exec  *)
    val PCRE_NEWLINE_ANY        = 0wx00400000  (*  Compile, exec, DFA exec  *)
    val PCRE_NEWLINE_ANYCRLF    = 0wx00500000  (*  Compile, exec, DFA exec  *)
    val PCRE_BSR_ANYCRLF        = 0wx00800000  (*  Compile, exec, DFA exec  *)
    val PCRE_BSR_UNICODE        = 0wx01000000  (*  Compile, exec, DFA exec  *)
    val PCRE_JAVASCRIPT_COMPAT  = 0wx02000000  (*  Compile, used in exec  *)
    val PCRE_NO_START_OPTIMIZE  = 0wx04000000  (*  Compile, exec, DFA exec  *)
    val PCRE_NO_START_OPTIMISE  = 0wx04000000  (*  Synonym  *)
    val PCRE_PARTIAL_HARD       = 0wx08000000  (*  Exec, DFA exec  *)
    val PCRE_NOTEMPTY_ATSTART   = 0wx10000000  (*  Exec, DFA exec  *)
    val PCRE_UCP                = 0wx20000000  (*  Compile, used in exec, DFA exec  *)
  end

  (* Exec-time and get/set-time error codes *)

  structure ErrorCode =
  struct
    type t = int
    val PCRE_ERROR_NOMATCH        = ~1
    val PCRE_ERROR_NULL           = ~2
    val PCRE_ERROR_BADOPTION      = ~3
    val PCRE_ERROR_BADMAGIC       = ~4
    val PCRE_ERROR_UNKNOWN_OPCODE = ~5
    val PCRE_ERROR_UNKNOWN_NODE   = ~5  (* For backward compatibility *)
    val PCRE_ERROR_NOMEMORY       = ~6
    val PCRE_ERROR_NOSUBSTRING    = ~7
    val PCRE_ERROR_MATCHLIMIT     = ~8
    val PCRE_ERROR_CALLOUT        = ~9  (* Never used by PCRE itself *)
    val PCRE_ERROR_BADUTF8        = ~10
    val PCRE_ERROR_BADUTF8_OFFSET = ~11
    val PCRE_ERROR_PARTIAL        = ~12
    val PCRE_ERROR_BADPARTIAL     = ~13
    val PCRE_ERROR_INTERNAL       = ~14
    val PCRE_ERROR_BADCOUNT       = ~15
    val PCRE_ERROR_DFA_UITEM      = ~16
    val PCRE_ERROR_DFA_UCOND      = ~17
    val PCRE_ERROR_DFA_UMLIMIT    = ~18
    val PCRE_ERROR_DFA_WSSIZE     = ~19
    val PCRE_ERROR_DFA_RECURSE    = ~20
    val PCRE_ERROR_RECURSIONLIMIT = ~21
    val PCRE_ERROR_NULLWSLIMIT    = ~22  (* No longer actually used *)
    val PCRE_ERROR_BADNEWLINE     = ~23
    val PCRE_ERROR_BADOFFSET      = ~24
    val PCRE_ERROR_SHORTUTF8      = ~25

    (*  Specific error codes for UTF-8 validity checks  *)

    val PCRE_UTF8_ERR0            =  0
    val PCRE_UTF8_ERR1            =  1
    val PCRE_UTF8_ERR2            =  2
    val PCRE_UTF8_ERR3            =  3
    val PCRE_UTF8_ERR4            =  4
    val PCRE_UTF8_ERR5            =  5
    val PCRE_UTF8_ERR6            =  6
    val PCRE_UTF8_ERR7            =  7
    val PCRE_UTF8_ERR8            =  8
    val PCRE_UTF8_ERR9            =  9
    val PCRE_UTF8_ERR10           = 10
    val PCRE_UTF8_ERR11           = 11
    val PCRE_UTF8_ERR12           = 12
    val PCRE_UTF8_ERR13           = 13
    val PCRE_UTF8_ERR14           = 14
    val PCRE_UTF8_ERR15           = 15
    val PCRE_UTF8_ERR16           = 16
    val PCRE_UTF8_ERR17           = 17
    val PCRE_UTF8_ERR18           = 18
    val PCRE_UTF8_ERR19           = 19
    val PCRE_UTF8_ERR20           = 20
    val PCRE_UTF8_ERR21           = 21

    (*  Specific error codes for UTF-16 validity checks  *)

    val PCRE_UTF16_ERR0           =  0
    val PCRE_UTF16_ERR1           =  1
    val PCRE_UTF16_ERR2           =  2
    val PCRE_UTF16_ERR3           =  3
    val PCRE_UTF16_ERR4           =  4
  end

(*  Request types for pcre_fullinfo()  *)

  val PCRE_INFO_OPTIONS         =  0
  val PCRE_INFO_SIZE            =  1
  val PCRE_INFO_CAPTURECOUNT    =  2
  val PCRE_INFO_BACKREFMAX      =  3
  val PCRE_INFO_FIRSTBYTE       =  4
  val PCRE_INFO_FIRSTCHAR       =  4  (*  For backwards compatibility  *)
  val PCRE_INFO_FIRSTTABLE      =  5
  val PCRE_INFO_LASTLITERAL     =  6
  val PCRE_INFO_NAMEENTRYSIZE   =  7
  val PCRE_INFO_NAMECOUNT       =  8
  val PCRE_INFO_NAMETABLE       =  9
  val PCRE_INFO_STUDYSIZE       = 10
  val PCRE_INFO_DEFAULT_TABLES  = 11
  val PCRE_INFO_OKPARTIAL       = 12
  val PCRE_INFO_JCHANGED        = 13
  val PCRE_INFO_HASCRORLF       = 14
  val PCRE_INFO_MINLENGTH       = 15
  val PCRE_INFO_JIT             = 16
  val PCRE_INFO_JITSIZE         = 17
  val PCRE_INFO_MAXLOOKBEHIND   = 18

  (* Request types for pcre_config(). Do not re-arrange, in order to remain
  compatible. *)

  val PCRE_CONFIG_UTF8                   =  0
  val PCRE_CONFIG_NEWLINE                =  1
  val PCRE_CONFIG_LINK_SIZE              =  2
  val PCRE_CONFIG_POSIX_MALLOC_THRESHOLD =  3
  val PCRE_CONFIG_MATCH_LIMIT            =  4
  val PCRE_CONFIG_STACKRECURSE           =  5
  val PCRE_CONFIG_UNICODE_PROPERTIES     =  6
  val PCRE_CONFIG_MATCH_LIMIT_RECURSION  =  7
  val PCRE_CONFIG_BSR                    =  8
  val PCRE_CONFIG_JIT                    =  9
  val PCRE_CONFIG_UTF16                  = 10
  val PCRE_CONFIG_JITTARGET              = 11

  (* Request types for pcre_study(). Do not re-arrange, in order to remain
  compatible. *)

  val PCRE_STUDY_JIT_COMPILE              = 0wx0001
  val PCRE_STUDY_JIT_PARTIAL_SOFT_COMPILE = 0wx0002
  val PCRE_STUDY_JIT_PARTIAL_HARD_COMPILE = 0wx0004

  (* Bit flags for the pcre[16]_extra structure. Do not re-arrange or redefine
  these bits, just add new ones on the end, in order to remain compatible. *)

  val PCRE_EXTRA_STUDY_DATA            = 0wx0001
  val PCRE_EXTRA_MATCH_LIMIT           = 0wx0002
  val PCRE_EXTRA_CALLOUT_DATA          = 0wx0004
  val PCRE_EXTRA_TABLES                = 0wx0008
  val PCRE_EXTRA_MATCH_LIMIT_RECURSION = 0wx0010
  val PCRE_EXTRA_MARK                  = 0wx0020
  val PCRE_EXTRA_EXECUTABLE_JIT        = 0wx0040

  type pcre           = unit ptr
  type pcre_jit_stack = unit ptr
  type pcre_extra     = unit ptr
  type table          = Word8.word vector
  type t              = pcre

  (* currently SML# don't allows you to access to 16bit width word :(
  type pcre16           = unit ptr
  type pcre16_jit_stack = unit ptr
  type pcre16_extra = unit ptr
  *)

  val pcre_compile_ptr = (* only for giving the NULL pointer *)
    _import "pcre_compile"
    : __attribute__((alloc)) (string, word, string ref, int ref, 'a ptr)-> pcre
   
  val pcre_compile_array =
    _import "pcre_compile"
    : __attribute__((alloc)) (string, word, string ref, int ref, table)-> pcre

  fun pcre_compile (pattern, option, err, erroffset, table) =
    case table
      of SOME arr => pcre_compile_array (pattern, option, err, erroffset, arr)
       | NONE     => pcre_compile_ptr   (pattern, option, err, erroffset, Pointer.NULL())
    
  val pcre_compile2_ptr =
    _import "pcre_compile2"
    : __attribute__((alloc)) (string, word, int ref, string ref, int ref, 'a ptr)-> pcre

  val pcre_compile2_array =
    _import "pcre_compile2"
    : __attribute__((alloc)) (string, word, int ref, string ref, int ref, table)-> pcre

  fun pcre_compile2 (pattern, option, errorcode, err, erroffset, table) =
    case table
      of SOME arr => pcre_compile2_array (pattern, option, errorcode, err, erroffset, arr)
       | NONE     => pcre_compile2_ptr   (pattern, option, errorcode, err, erroffset, Pointer.NULL())

  (* checking build-time options *)
  val pcre_config =
    _import "pcre_config"
    : (int, unit ptr) -> int

  val pcre_study =
    _import "pcre_study"
    : __attribute__((alloc)) (string, int, string ref) -> pcre_extra

  val pcre_free_study =
    _import "pcre_free_study"
    : pcre_extra -> unit

  val pcre_version =
    fn()=> Pointer.importString
      ((_import "pcre_version" : () -> char ptr) ())

  val pcre_free =
    _import "free"
    : pcre -> unit

  val pcre_exec =
    _import "pcre_exec"
    : (pcre, pcre_extra, string, int, int, word, int array, int) -> int;

  val pcre_dfa_exec =
    _import "pcre_dfa_exec"
    : (pcre, pcre_extra, string, int, int, word, int array, int
        , int array, int) -> int

  (**
   * PCRE NATIVE API STRING EXTRACTION FUNCTIONS
   *)
  val pcre_copy_named_substring =
    _import "pcre_copy_named_substring"
    : (string, string, int array, int, string, char array, int) -> int

  val pcre_copy_substring =
    _import "pcre_copy_substring"
    : (string, int array, int, int, char array, int) -> int

  val pcre_get_named_substring =
    _import "pcre_get_named_substring"
    : (pcre, string, int array, int, string, string ref) -> int

  val pcre_get_stringnumber =
    _import "pcre_get_stringnumber"
    : (pcre, string) -> int

  val pcre_get_stringtable_entries =
    _import "pcre_get_stringtable_entries"
    : (pcre, string, char ptr ref, char ptr ref) -> int

  val pcre_get_substring =
    _import "pcre_get_substring"
    : (string, int array, int, int, string ref) -> int

  val pcre_get_substring_list =
    _import "pcre_get_substring_list"
    : (string, int array, int, string array ref) -> int

  val pcre_maketables =
    _import "pcre_maketables"
    : __attribute__((alloc)) () -> table

  val pcre_refcount =
    _import "pcre_refcount"
    : (pcre, int) -> int

  (*
   * INFORMATION ABOUT A PATTERN
   *)
  val pcre_fullinfo =
    _import "pcre_fullinfo"
    : (pcre, pcre_extra, int, 'a ref) -> int

  (* Utility functions for byte order swaps. *)
  val pcre_pattern_to_host_byte_order =
    _import "pcre_pattern_to_host_byte_order"
    : (pcre, pcre_extra, Word8.word array) -> int

end (* structure PcreRaw *)

