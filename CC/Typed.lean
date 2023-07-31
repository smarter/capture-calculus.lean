import Mathlib.Data.Finset.Basic
import CC.CaptureSet
import CC.Basic
import CC.CaptureSet
import CC.Type
import CC.Type.TypeSubst
import CC.Term
import CC.Context
import CC.Subtype

namespace CC

inductive DropBinderFree : CaptureSet n.succ -> CaptureSet n -> Prop where
  | drop : DropBinderFree C.weaken_var C

inductive DropBinder : CaptureSet n.succ -> CaptureSet n -> Prop where
  | drop_free : DropBinderFree C C' -> DropBinder C C'
  | drop : DropBinder (C.weaken_var ∪ {0}) C

inductive Typed : Ctx n m -> Term n m -> CaptureSet n -> CType n m -> Prop where
| var :
  BoundVar Γ x (CType.capt C S) ->
  Typed Γ (Term.var x) {x} (CType.capt {x} S)
| sub :
  Typed Γ t C T ->
  Subtype Γ T T' ->
  Typed Γ t C T'
| abs :
  Typed (Ctx.extend_var Γ T) t C U ->
  DropBinder C C' ->
  Typed Γ (Term.abs T t) C' (CType.capt C' (PType.arr T U))
| tabs :
  Typed (Ctx.extend_tvar Γ S) t C T ->
  Typed Γ (Term.tabs S t) C (CType.capt C (PType.tarr S T))
| app :
  Typed Γ (Term.var x) Cx (CType.capt C (PType.arr T U)) ->
  Typed Γ (Term.var y) Cy T ->
  Typed Γ (Term.app x y) (Cx ∪ Cy) (U.open_var y)
| tapp :
  Typed Γ (Term.var x) Cx (CType.capt C (PType.tarr S T)) ->
  Typed Γ (Term.tapp x S) Cx (T.open_tvar S)
| box :
  Typed Γ (Term.var x) Cx (CType.capt C S) ->
  Typed Γ (Term.box x) {} (CType.capt {} (PType.boxed (CType.capt C S)))
| unbox :
  Typed Γ (Term.var x) Cx (CType.capt C0 (PType.boxed (CType.capt C S))) ->
  Typed Γ (Term.unbox C x) (C ∪ {x}) (CType.capt C S)
| letval1 : ∀ {Γ : Ctx n m} {U' : CType n m} {Cu' : CaptureSet n},
  Typed Γ t Ct T ->
  Typed (Ctx.extend_var Γ T) u Cu U ->
  U = U'.weaken_var ->
  DropBinder Cu Cu' ->
  Typed Γ (Term.letval t u) (Ct ∪ Cu') U'
| letval2 : ∀ {Γ : Ctx n m} {U' : CType n m} {Cu' : CaptureSet n},
  Typed Γ v Ct T ->
  Value v ->
  Typed (Ctx.extend_var Γ T) u Cu U ->
  U = U'.weaken_var ->
  DropBinderFree Cu Cu' ->
  Typed Γ (Term.letval v u) Cu' U'