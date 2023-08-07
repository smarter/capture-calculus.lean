import Mathlib.Data.Finset.Basic
import Mathlib.Data.Finset.Image

import CC.Basic
import CC.Rename

import CC.CaptureSet
import CC.Context
import CC.Type
import CC.Subcapt
import CC.Subcapt.Basic
import CC.Subcapt.Rename
import CC.Subtype
import CC.Subtype.Basic
import CC.Subtype.Subst
import CC.Subtype.TypeSubst

namespace CC

def SubtypeP.tvar_inv_motive (Γ : Ctx n m) (S1 S2 : PType n m) : Prop :=
  ∀ X, 
    S2 = PType.tvar X ->
    SubtypeP Γ S1 S2 ->
    ∃ Y, S1 = PType.tvar Y

def SubtypeP.tvar_inv' :
  SubtypeP Γ S1 S2 ->
  SubtypeP.tvar_inv_motive Γ S1 S2 := by
  intro h
  apply SubtypeP.rec
    (motive_1 := fun Γ T1 T2 _ => True)
    (motive_2 := fun Γ S1 S2 _ => SubtypeP.tvar_inv_motive Γ S1 S2)
    <;> try (solve | trivial | intros; trivial | intros; unfold tvar_inv_motive; intros _ he; cases he)
  case refl =>
    intros; unfold tvar_inv_motive
    intros X he h
    aesop
  case trans =>
    intros; unfold tvar_inv_motive at *
    intros X he h
    rename_i h1 h2 ih1 ih2
    subst_vars
    have ih2' := ih2 _ rfl h2
    cases ih2'
    subst_vars
    apply ih1 <;> trivial
  case tvar => 
    intros; unfold tvar_inv_motive at *
    aesop

lemma SubtypeP.tvar_inv :
  SubtypeP Γ S1 (PType.tvar X2) ->
  ∃ X1, S1 = PType.tvar X1 := by
  intro h
  apply SubtypeP.tvar_inv' <;> trivial

private def SubtypeP.fun_inv_motive (Γ : Ctx n m) (S1 S2 : PType n m) : Prop :=
  ∀ T U, 
    S2 = PType.arr T U ->
    SubtypeP Γ S1 S2 ->
    (∃ X, S1 = PType.tvar X) ∨ 
    (∃ T' U', S1 = PType.arr T' U' ∧ Subtype Γ T T' ∧ Subtype (Ctx.extend_var Γ T) U' U)

lemma SubtypeP.fun_inv' :
  SubtypeP Γ S1 S2 ->
  SubtypeP.fun_inv_motive Γ S1 S2 := by
  intro h
  apply SubtypeP.rec
    (motive_1 := fun Γ T1 T2 _ => True)
    (motive_2 := fun Γ S1 S2 _ => SubtypeP.fun_inv_motive Γ S1 S2)
    <;> try (solve | trivial | intros; trivial | intros; unfold fun_inv_motive; intros _ _ he; cases he)
  case refl =>
    intros; unfold fun_inv_motive
    intros T U he h
    subst_vars
    apply Or.inr
    repeat apply Exists.intro
    constructor
    rfl
    constructor <;> apply Subtype.refl
  case trans =>
    intros
    unfold fun_inv_motive at *
    intros T U he h
    rename_i h1 h2 ih1 ih2
    have ih2' := ih2 _ _ he h2
    cases ih2'
    case inl ih =>
      let ⟨X0, he0⟩ := ih
      subst_vars
      have h1' := SubtypeP.tvar_inv h1
      aesop
    case inr ih =>
      let ⟨T', U', he, ih1, ih2⟩ := ih
      subst_vars
      have ih' := ih1 _ _ rfl h1
      cases ih'
      case inl => aesop
      case inr =>
        rename_i ih
        let ⟨T'', U'', he', ih1', ih2'⟩ := ih
        subst_vars
        apply Or.inr
        repeat apply Exists.intro
        constructor
        rfl
        constructor
        apply Subtype.trans <;> trivial
        apply Subtype.trans
        apply Subtype.narrow_var
        assumption
        assumption
        assumption
  case tvar =>
    intros
    unfold fun_inv_motive at *
    intros T U he h
    subst_vars
    apply Or.inl
    apply Exists.intro
    rfl
  case arr =>
    intros
    unfold fun_inv_motive at *
    intros T U he h
    subst_vars
    apply Or.inr
    repeat apply Exists.intro
    constructor
    rfl
    cases he
    constructor <;> trivial

theorem SubtypeP.fun_inv :
  SubtypeP Γ P (PType.arr T U) ->
  (∃ X, P = PType.tvar X) ∨ 
  (∃ T' U', P = PType.arr T' U' ∧ Subtype Γ T T' ∧ Subtype (Ctx.extend_var Γ T) U' U) := by
  intros
  apply SubtypeP.fun_inv' <;> aesop

private def SubtypeP.tfun_inv_motive (Γ : Ctx n m) (S1 S2 : PType n m) : Prop :=
  ∀ T U, 
    S2 = PType.tarr T U ->
    SubtypeP Γ S1 S2 ->
    (∃ X, S1 = PType.tvar X) ∨ 
    (∃ T' U', S1 = PType.tarr T' U' ∧ SubtypeP Γ T T' ∧ Subtype (Ctx.extend_tvar Γ T) U' U)

lemma SubtypeP.tfun_inv' 
  (h : SubtypeP Γ S1 S2) :
  SubtypeP.tfun_inv_motive Γ S1 S2 := by
  apply SubtypeP.rec
    (motive_1 := fun Γ T1 T2 _ => True)
    (motive_2 := fun Γ S1 S2 _ => SubtypeP.tfun_inv_motive Γ S1 S2)
    <;> try (solve | trivial | intros; trivial | intros; unfold tfun_inv_motive; intros _ _ he; cases he)
  case refl =>
    intros; unfold tfun_inv_motive
    intros
    apply Or.inr
    repeat apply Exists.intro
    constructor
    trivial
    constructor
    apply SubtypeP.refl
    apply Subtype.refl
  case trans =>
    intros; unfold tfun_inv_motive at *
    intros T U he h
    rename_i h1 h2 ih1 ih2
    subst_vars
    have ih2' := ih2 _ _ rfl h2
    cases ih2'
    case inl ih =>
      let ⟨X0, he0⟩ := ih
      subst_vars
      have h1' := SubtypeP.tvar_inv h1
      aesop
    case inr ih =>
      let ⟨T', U', he, ih1, ih2⟩ := ih
      subst_vars
      have ih' := ih1 _ _ rfl h1
      cases ih'
      case inl => aesop
      case inr ih' =>
        let ⟨T'', U'', he', ih1', ih2'⟩ := ih'
        subst_vars
        apply Or.inr
        repeat apply Exists.intro
        constructor
        trivial
        constructor
        apply SubtypeP.trans <;> trivial
        apply Subtype.trans
        · apply Subtype.narrow_tvar <;> trivial
        · assumption
  case tvar =>
    intros; unfold tfun_inv_motive at *
    intros T U he h
    subst_vars
    apply Or.inl
    apply Exists.intro
    rfl
  case tarr =>
    intros; unfold tfun_inv_motive at *
    intros T U he h
    subst_vars
    apply Or.inr
    repeat apply Exists.intro
    constructor
    rfl
    cases he
    constructor <;> trivial

lemma SubtypeP.tfun_inv :
  SubtypeP Γ P (PType.tarr T U) ->
  (∃ X, P = PType.tvar X) ∨ 
  (∃ T' U', P = PType.tarr T' U' ∧ SubtypeP Γ T T' ∧ Subtype (Ctx.extend_tvar Γ T) U' U) := by
  intro h
  apply SubtypeP.tfun_inv' <;> aesop
