open Base

type idT = string [@@deriving equal, sexp]

(** Types *)
module Type = struct
  type t =
    | Unit  (** Unit type *)
    | Base of { idt : idT }
        (** Base uninterpreted types, meaning there are no canonical terms inhabiting these types *)
    | Prod of { ty1 : t; ty2 : t }  (** Type of pairs *)
    | Arr of { dom : t; cod : t }  (** Type of functions *)
    | Box of { ty : t }  (** Type-level box *)
  [@@deriving equal, sexp]
end

(** Expressions *)
module Expr = struct
  type t = t' Location.located

  and t' =
    | Unit  (** [unit] *)
    | Pair of { e1 : t; e2 : t }  (** pairs [(expr1, expr2)] *)
    | Fst of { e : t }  (** first projection of a pair *)
    | Snd of { e : t }  (** second projection of a pair *)
    | VarR of { idr : Id.R.t }  (** variables of the regular context *)
    | VarM of { idm : Id.M.t }
        (** variables of the modal context (or "valid variables"),
        these are syntactically distinct from the regular (ordinary) variables *)
    | Fun of { idr : Id.R.t; ty_id : Type.t; body : t }
        (** anonymous functions: [fun (x : T) => expr] *)
    | App of { fe : t; arge : t }  (** function application: [f x] *)
    | Box of { e : t }  (** term-level box: [box expr1] *)
    | Let of { idr : Id.R.t; bound : t; body : t }
        (** [let u = expr1 in expr2] *)
    | Letbox of { idm : Id.M.t; boxed : t; body : t }
        (** [letbox u = expr1 in expr2] *)
  [@@deriving equal, sexp]

  (* Wrappers for constructors *)
  let unit = Location.locate Unit

  let pair e1 e2 = Location.locate @@ Pair { e1; e2 }

  let fst e = Location.locate @@ Fst { e }

  let snd e = Location.locate @@ Snd { e }

  let var_r idr = Location.locate @@ VarR { idr }

  let var_m idm = Location.locate @@ VarM { idm }

  let func idr ty_id body = Location.locate @@ Fun { idr; ty_id; body }

  let app fe arge = Location.locate @@ App { fe; arge }

  let box e = Location.locate @@ Box { e }

  let letc idr bound body = Location.locate @@ Let { idr; bound; body }

  let letbox idm boxed body = Location.locate @@ Letbox { idm; boxed; body }
end

(** Values *)
module Val = struct
  type t =
    | Unit  (** [unit] literal *)
    | Pair of t * t  (** [(lit1, lit2)] -- a pair of literals is a literal *)
    | Clos of Id.R.t * Expr.t * t Env.R.t  (** Deeply embedded closures *)
    | Box of Expr.t
        (** [box] literal, basically it's an unevaluated expression *)
  [@@deriving sexp]
end
