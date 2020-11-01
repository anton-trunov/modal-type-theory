Note: the evaluator does not typecheck terms, so if you need to call 
a function like (λa: A. a) you can apply it to the unit value ().

K I = K*
  $ mtt eval <<EOF
  > <((λa: (A -> A). λb: B. a) (λa: A. a)) (),
  >  (λa: A. λb: B. b) ()>
  > EOF
  <λa. a, λb. b>

'Let .. in' expression
  $ mtt eval <<EOF
  > (fun x: A. let y = x in y) ()
  > EOF
  ()

  $ mtt eval <<EOF
  > let f = fun x: A. < x, x > in f ()
  > EOF
  <(), ()>

  $ mtt eval <<EOF
  > let f = fun p: A * B. < snd p, fst p > in f < (), () >
  > EOF
  <(), ()>

  $ mtt eval <<EOF
  > (fun p: A * B. 
  > let f = fst p in
  > let s = snd p in
  > < s, f > ) < (), () >
  > EOF
  <(), ()>
