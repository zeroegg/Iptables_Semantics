theory Fixed_Action
imports Semantics_Ternary
begin

section{*Fixed Action*}

text{*If firewall rules have the same action, we can focus on the matching only. *}

text{*Applying a rule once or several times makes no difference.*}
lemma approximating_bigstep_fun_prepend_replicate: 
  "n > 0 \<Longrightarrow> approximating_bigstep_fun \<gamma> p (r#rs) Undecided = approximating_bigstep_fun \<gamma> p ((replicate n r)@rs) Undecided"
apply(induction n)
 apply(simp)
apply(simp)
apply(case_tac r)
apply(rename_tac m a)
apply(simp split: action.split)
by fastforce




text{*utility lemmas*}
  lemma fixedaction_Log: "approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m Log) ms) Undecided = Undecided"
  apply(induction ms, simp_all)
  done
  lemma fixedaction_Empty:"approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m Empty) ms) Undecided = Undecided"
  apply(induction ms, simp_all)
  done
  lemma helperX1_Log: "matches \<gamma> m' Log p \<Longrightarrow> 
         approximating_bigstep_fun \<gamma> p (map ((\<lambda>m. Rule m Log) \<circ> MatchAnd m') m2' @ rs2) Undecided =
         approximating_bigstep_fun \<gamma> p rs2 Undecided"
  apply(induction m2')
  apply(simp_all split: action.split)
  done
  lemma helperX1_Empty: "matches \<gamma> m' Empty p \<Longrightarrow> 
         approximating_bigstep_fun \<gamma> p (map ((\<lambda>m. Rule m Empty) \<circ> MatchAnd m') m2' @ rs2) Undecided =
         approximating_bigstep_fun \<gamma> p rs2 Undecided"
  apply(induction m2')
  apply(simp_all split: action.split)
  done
  lemma helperX3: "matches \<gamma> m' a p \<Longrightarrow>
       approximating_bigstep_fun \<gamma> p (map ((\<lambda>m. Rule m a) \<circ> MatchAnd m') m2' @ rs2 ) Undecided =
       approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) m2' @ rs2) Undecided"
  apply(induction m2')
   apply(simp)
  apply(case_tac a)
  apply(simp_all add: matches_simps)
  done
  
  lemmas fixed_action_simps = helperX1_Log helperX1_Empty helperX3
  hide_fact helperX1_Log helperX1_Empty helperX3


lemma fixedaction_swap:
   "approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) (m1@m2)) s = approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) (m2@m1)) s"
proof(cases s)
case Decision thus "approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) (m1 @ m2)) s = approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) (m2 @ m1)) s" 
  by(simp add: Decision_approximating_bigstep_fun)
next
case Undecided
  have "approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) m1 @ map (\<lambda>m. Rule m a) m2) Undecided = approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) m2 @ map (\<lambda>m. Rule m a) m1) Undecided"
  proof(induction m1)
    case Nil thus ?case by simp
    next
    case (Cons m m1)
      { fix m rs
        have "approximating_bigstep_fun \<gamma> p ((map (\<lambda>m. Rule m Log) m)@rs) Undecided =
            approximating_bigstep_fun \<gamma> p rs Undecided"
        by(induction m) (simp_all)
      } note Log_helper=this
      { fix m rs
        have "approximating_bigstep_fun \<gamma> p ((map (\<lambda>m. Rule m Empty) m)@rs) Undecided =
            approximating_bigstep_fun \<gamma> p rs Undecided"
        by(induction m) (simp_all)
      } note Empty_helper=this
      
      show ?case (is ?goal)
        proof(cases "matches \<gamma> m a p")
          case True
            thus ?goal
              proof(induction m2)
                case Nil thus ?case by simp
              next
                case Cons thus ?case
                  apply(simp split:action.split action.split_asm)
                  using Log_helper Empty_helper by fastforce+ 
              qed
          next
          case False
            thus ?goal
             apply(simp)
             apply(simp add: Cons.IH)
             apply(induction m2)
              apply(simp_all)
             apply(simp split:action.split action.split_asm)
             apply fastforce
            done
        qed
    qed
  thus "approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) (m1 @ m2)) s = approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) (m2 @ m1)) s" using Undecided by simp
qed

corollary fixedaction_reorder: "approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) (m1 @ m2 @ m3)) s = approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) (m2 @ m1 @ m3)) s"
proof(cases s)
case Decision thus " approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) (m1 @ m2 @ m3)) s = approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) (m2 @ m1 @ m3)) s" 
  by(simp add: Decision_approximating_bigstep_fun)
next
case Undecided
have "approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) (m1 @ m2 @ m3)) Undecided = approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) (m2 @ m1 @ m3)) Undecided"
  proof(induction m3)
    case Nil thus ?case using fixedaction_swap by fastforce
    next
    case (Cons m3'1 m3)
      have "approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) ((m3'1 # m3) @ m1 @ m2)) Undecided = approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) ((m3'1 # m3) @ m2 @ m1)) Undecided"
        apply(simp)
        apply(cases "matches \<gamma> m3'1 a p")
         apply(simp split: action.split action.split_asm)
         apply (metis append_assoc fixedaction_swap map_append Cons.IH)
        apply(simp)
        by (metis append_assoc fixedaction_swap map_append Cons.IH)
      hence "approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) ((m1 @ m2) @ m3'1 # m3)) Undecided = approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) ((m2 @ m1) @ m3'1 # m3)) Undecided"
        apply(subst fixedaction_swap)
        apply(subst(2) fixedaction_swap)
        by simp
      thus ?case
        apply(subst append_assoc[symmetric])
        apply(subst append_assoc[symmetric])
        by simp
  qed
  thus "approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) (m1 @ m2 @ m3)) s = approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) (m2 @ m1 @ m3)) s" using Undecided by simp
qed


text{*If the actions are equal, the @{term set} (position and replication independent) of the match expressions can be considered. *}
lemma approximating_bigstep_fun_fixaction_matchseteq: "set m1 = set m2 \<Longrightarrow>
        approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) m1) s = 
       approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) m2) s"
proof(cases s)
case Decision thus "approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) m1) s = approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) m2) s" 
  by(simp add: Decision_approximating_bigstep_fun)
next
case Undecided
  assume m1m2_seteq: "set m1 = set m2"
  hence "approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) m1) Undecided = approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) m2) Undecided"
  proof(induction m1 arbitrary: m2)
   case Nil thus ?case by simp
   next
   case (Cons m m1)
    show ?case (is ?goal)
      proof (cases "m \<in> set m1")
      case True
        from True have "set m1 = set (m # m1)" by auto
        from Cons.IH[OF `set m1 = set (m # m1)`] have "approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) (m # m1)) Undecided = approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) (m1)) Undecided" ..
        thus ?goal by (metis Cons.IH Cons.prems `set m1 = set (m # m1)`)
      next
      case False
        from False have "m \<notin> set m1" .
        show ?goal
        proof (cases "m \<notin> set m2")
          case True
          from True `m \<notin> set m1` Cons.prems have "set m1 = set m2" by auto
          from Cons.IH[OF this] show ?goal by (metis Cons.IH Cons.prems `set m1 = set m2`)
        next
        case False
          hence "m \<in> set m2" by simp
  
          have repl_filter_simp: "(replicate (length [x\<leftarrow>m2 . x = m]) m) = [x\<leftarrow>m2 . x = m]"
            by (metis (lifting, full_types) filter_set member_filter replicate_length_same)
  
          from Cons.prems  `m \<notin> set m1` have "set m1 = set (filter (\<lambda>x. x\<noteq>m) m2)" by auto
          from Cons.IH[OF this] have "approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) m1) Undecided = approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) [x\<leftarrow>m2 . x \<noteq> m]) Undecided" .
          from this have "approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) (m#m1)) Undecided = approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) (m#[x\<leftarrow>m2 . x \<noteq> m])) Undecided"
            apply(simp split: action.split)
            by fast
          also have "\<dots> = approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) ([x\<leftarrow>m2 . x = m]@[x\<leftarrow>m2 . x \<noteq> m])) Undecided"
            apply(simp only: list.map)
            thm approximating_bigstep_fun_prepend_replicate[where n="length [x\<leftarrow>m2 . x = m]"]
            apply(subst approximating_bigstep_fun_prepend_replicate[where n="length [x\<leftarrow>m2 . x = m]"])
            apply (metis (full_types) False filter_empty_conv neq0_conv repl_filter_simp replicate_0)
            by (metis (lifting, no_types) map_append map_replicate repl_filter_simp)
          also have "\<dots> =  approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) m2) Undecided"
            proof(induction m2)
            case Nil thus ?case by simp
            next
            case(Cons m2'1 m2')
              have "approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) [x\<leftarrow>m2' . x = m] @ Rule m2'1 a # map (\<lambda>m. Rule m a) [x\<leftarrow>m2' . x \<noteq> m]) Undecided =
                    approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) ([x\<leftarrow>m2' . x = m] @ [m2'1] @ [x\<leftarrow>m2' . x \<noteq> m])) Undecided" by fastforce
              also have "\<dots> = approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) ([m2'1] @ [x\<leftarrow>m2' . x = m] @ [x\<leftarrow>m2' . x \<noteq> m])) Undecided"
              using fixedaction_reorder by fast 
              finally have XX: "approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) [x\<leftarrow>m2' . x = m] @ Rule m2'1 a # map (\<lambda>m. Rule m a) [x\<leftarrow>m2' . x \<noteq> m]) Undecided =
                    approximating_bigstep_fun \<gamma> p (Rule m2'1 a # (map (\<lambda>m. Rule m a) [x\<leftarrow>m2' . x = m] @ map (\<lambda>m. Rule m a) [x\<leftarrow>m2' . x \<noteq> m])) Undecided"
              by fastforce
              from Cons show ?case
                apply(case_tac "m2'1 = m")
                 apply(simp split: action.split)
                 apply fast
                apply(simp del: approximating_bigstep_fun.simps)
                apply(simp only: XX)
                apply(case_tac "matches \<gamma> m2'1 a p")
                 apply(simp)
                 apply(simp split: action.split)
                 apply(fast)
                apply(simp)
                done
            qed
          finally show ?goal .
        qed
      qed
  qed
  thus "approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) m1) s = approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) m2) s" using Undecided m1m2_seteq by simp
qed



subsection{*@{term match_list}*}
  text{*Reducing the firewall semantics to shortcircuit matching evaluation*}

  fun match_list :: "('a, 'packet) match_tac \<Rightarrow> 'a match_expr list \<Rightarrow> action \<Rightarrow> 'packet \<Rightarrow> bool" where
   "match_list \<gamma> [] a p = False" |
   "match_list \<gamma> (m#ms) a p = (if matches \<gamma> m a p then True else match_list \<gamma> ms a p)"


  lemma match_list_True: "match_list \<gamma> ms a p \<Longrightarrow> approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) ms) Undecided = (case a of Accept \<Rightarrow> Decision FinalAllow
              | Drop \<Rightarrow> Decision FinalDeny
              | Reject \<Rightarrow> Decision FinalDeny
              | Log \<Rightarrow> Undecided
              | Empty \<Rightarrow> Undecided
              (*unhandled cases*)
              )"
    apply(induction ms)
     apply(simp)
    apply(simp split: split_if_asm action.split)
    apply(simp add: fixedaction_Log fixedaction_Empty)
    done
  lemma match_list_False: "\<not> match_list \<gamma> ms a p \<Longrightarrow> approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) ms) Undecided = Undecided"
    apply(induction ms)
     apply(simp)
    apply(simp split: split_if_asm action.split)
    done

  lemma match_list_semantics: "match_list \<gamma> ms1 a p \<longleftrightarrow> match_list \<gamma> ms2 a p \<Longrightarrow>
    approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) ms1) s = approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) ms2) s"
    apply(case_tac s)
     prefer 2
     apply(simp add: Decision_approximating_bigstep_fun)
    apply(simp)
    apply(thin_tac "s = ?un")
    apply(induction ms2)
     apply(simp)
     apply(induction ms1)
      apply(simp)
     apply(simp split: split_if_asm)
    apply(rename_tac m ms2)
    apply(simp del: approximating_bigstep_fun.simps)
    apply(simp split: split_if_asm del: approximating_bigstep_fun.simps)
     apply(simp split: action.split add: match_list_True fixedaction_Log fixedaction_Empty)
    apply(simp)
    done

  lemma match_list_singleton: "match_list \<gamma> [m] a p \<longleftrightarrow> matches \<gamma> m a p" by(simp)

  lemma empty_concat: "(concat (map (\<lambda>x. []) ms)) = []"
  apply(induction ms)
    by(simp_all)

  lemma match_list_append: "match_list \<gamma> (m1@m2) a p \<longleftrightarrow> (\<not> match_list \<gamma> m1 a p \<longrightarrow> match_list \<gamma> m2 a p)"
      apply(induction m1)
       apply(simp)
      apply(simp)
      done

  lemma match_list_helper1: "\<not> matches \<gamma> m2 a p \<Longrightarrow> match_list \<gamma> (map (\<lambda>x. MatchAnd x m2) m1') a p \<Longrightarrow> False"
    apply(induction m1')
     apply(simp)
    apply(simp split:split_if_asm)
    by(auto dest: matches_dest)
  lemma match_list_helper2: " \<not> matches \<gamma> m a p \<Longrightarrow> \<not> match_list \<gamma> (map (MatchAnd m) m2') a p"
    apply(induction m2')
     apply(simp)
    apply(simp split:split_if_asm)
    by(auto dest: matches_dest)
  lemma match_list_helper3: "matches \<gamma> m a p \<Longrightarrow> match_list \<gamma> m2' a p \<Longrightarrow> match_list \<gamma> (map (MatchAnd m) m2') a p"
    apply(induction m2')
     apply(simp)
    apply(simp split:split_if_asm)
    by (simp add: matches_simps)
  lemma match_list_helper4: "\<not> match_list \<gamma> m2' a p \<Longrightarrow> \<not> match_list \<gamma> (map (MatchAnd aa) m2') a p "
    apply(induction m2')
     apply(simp)
    apply(simp split:split_if_asm)
    by(auto dest: matches_dest)
  lemma match_list_helper5: " \<not> match_list \<gamma> m2' a p \<Longrightarrow> \<not> match_list \<gamma> (concat (map (\<lambda>x. map (MatchAnd x) m2') m1')) a p "
    apply(induction m2')
     apply(simp add:empty_concat)
    apply(simp split:split_if_asm)
    apply(induction m1')
     apply(simp)
    apply(simp add: match_list_append)
    by(auto dest: matches_dest)
  lemma match_list_helper6: "\<not> match_list \<gamma> m1' a p \<Longrightarrow> \<not> match_list \<gamma> (concat (map (\<lambda>x. map (MatchAnd x) m2') m1')) a p "
    apply(induction m2')
     apply(simp add:empty_concat)
    apply(simp split:split_if_asm)
    apply(induction m1')
     apply(simp)
    apply(simp add: match_list_append split: split_if_asm)
    by(auto dest: matches_dest)
  
  lemmas match_list_helper = match_list_helper1 match_list_helper2 match_list_helper3 match_list_helper4 match_list_helper5 match_list_helper6
  hide_fact match_list_helper1 match_list_helper2 match_list_helper3 match_list_helper4 match_list_helper5 match_list_helper6

  lemma match_list_map_And1: "matches \<gamma> m1 a p = match_list \<gamma> m1' a p \<Longrightarrow>
           matches \<gamma> (MatchAnd m1 m2) a p \<longleftrightarrow> match_list \<gamma>  (map (\<lambda>x. MatchAnd x m2) m1') a p"
    apply(induction m1')
     apply(auto dest: matches_dest)[1]
    apply(simp split: split_if_asm)
    apply safe
    apply(simp_all add: matches_simps)
    apply(auto dest: match_list_helper(1))[1]
    by(auto dest: matches_dest)

  lemma matches_list_And_concat: "matches \<gamma> m1 a p = match_list \<gamma> m1' a p \<Longrightarrow> matches \<gamma> m2 a p = match_list \<gamma> m2' a p \<Longrightarrow>
           matches \<gamma> (MatchAnd m1 m2) a p \<longleftrightarrow> match_list \<gamma> [MatchAnd x y. x <- m1', y <- m2'] a p"
    apply(induction m1')
     apply(auto dest: matches_dest)[1]
    apply(simp split: split_if_asm)
    prefer 2
    apply(simp add: match_list_append)
    apply(subgoal_tac "\<not> match_list \<gamma> (map (MatchAnd aa) m2') a p")
     apply(simp)
    apply safe
    apply(simp_all add: matches_simps match_list_append match_list_helper)
    done
    

lemma fixedaction_wf_ruleset: "wf_ruleset \<gamma> p (map (\<lambda>m. Rule m a) ms) \<longleftrightarrow> \<not> match_list \<gamma> ms a p \<or> \<not> (\<exists>chain. a = Call chain) \<and> a \<noteq> Return \<and> a \<noteq> Unknown"
  proof -
  have helper: "\<And>a b c. a \<longleftrightarrow> c \<Longrightarrow> (a \<longrightarrow> b) = (c \<longrightarrow> b)" by fast
  show ?thesis
    apply(simp add: wf_ruleset_def)
    apply(rule helper)
    apply(induction ms)
     apply(simp)
    apply(simp)
    done
  qed

lemma wf_ruleset_singleton: "wf_ruleset \<gamma> p [Rule m a] \<longleftrightarrow> \<not> matches \<gamma> m a p \<or> \<not> (\<exists>chain. a = Call chain) \<and> a \<noteq> Return \<and> a \<noteq> Unknown"
  by(simp add: wf_ruleset_def)



section{*Normalized (DNF) matches*}

text{*simplify a match expression. The output is a list of match exprissions, the semantics is @{text "\<or>"} of the list elements.*}
fun normalize_match :: "'a match_expr \<Rightarrow> 'a match_expr list" where
  "normalize_match (MatchAny) = [MatchAny]" |
  "normalize_match (Match m) = [Match m]" |
  "normalize_match (MatchAnd m1 m2) = [MatchAnd x y. x <- normalize_match m1, y <- normalize_match m2](*[MatchAnd m1 m2]*)(*and_orlist (normalize_match m1) (normalize_match m2)*)" | (*TODO TODO recursive calls?*)
  "normalize_match (MatchNot (MatchAnd m1 m2)) = normalize_match (MatchNot m1) @ normalize_match (MatchNot m2)" | (*DeMorgan*)
  "normalize_match (MatchNot (MatchNot m)) = normalize_match m" | (*idem*)
  "normalize_match (MatchNot (MatchAny)) = []" | (*false*)
  "normalize_match (MatchNot (Match m)) = [MatchNot (Match m)]"

lemma match_list_normalize_match: "match_list \<gamma> [m] a p \<longleftrightarrow> match_list \<gamma> (normalize_match m) a p"
  proof(induction m rule:normalize_match.induct)
  case 1 thus ?case by(simp add: match_list_singleton)
  next
  case 2 thus ?case by(simp add: match_list_singleton)
  next
  case (3 m1 m2) thus ?case 
    apply(simp_all add: match_list_singleton del: match_list.simps(2))
    apply(case_tac "matches \<gamma> m1 a p")
     apply(rule matches_list_And_concat)
      apply(simp)
     apply(case_tac "(normalize_match m1)")
      apply simp
     apply (auto)[1]
    apply(simp add: bunch_of_lemmata_about_matches match_list_helper)
    done
  next
  case 4 thus ?case 
    apply(simp_all add: match_list_singleton del: match_list.simps(2))
    apply(simp add: match_list_append)
    apply(safe)
        apply(simp_all add: matches_DeMorgan)
    done
  next 
  case 5 thus ?case 
    apply(simp_all add: match_list_singleton del: match_list.simps(2))
    apply (metis matches_not_idem)
    done
  next
  case 6 thus ?case 
    apply(simp_all add: match_list_singleton del: match_list.simps(2))
    by (metis bunch_of_lemmata_about_matches(3))
  next
  case 7 thus ?case by(simp add: match_list_singleton)
qed
  
thm match_list_normalize_match[simplified match_list_singleton]


theorem normalize_match_correct: "approximating_bigstep_fun \<gamma> p (map (\<lambda>m. Rule m a) (normalize_match m)) s = approximating_bigstep_fun \<gamma> p [Rule m a] s"
apply(rule match_list_semantics[of _ _ _ _ "[m]", simplified])
using match_list_normalize_match by fastforce


lemma normalize_match_empty: "normalize_match m = [] \<Longrightarrow> \<not> matches \<gamma> m a p"
  proof(induction m rule: normalize_match.induct)
  case 3 thus ?case by (simp) (metis ex_in_conv matches_simp2 matches_simp22 set_empty)
  next
  case 4 thus ?case using match_list_normalize_match by (metis match_list.simps)
  next
  case 5 thus ?case using matches_not_idem by fastforce
  next
  case 6 thus ?case by (metis bunch_of_lemmata_about_matches(3) matches_def matches_tuple)
  qed(simp_all)


lemma matches_to_match_list_normalize: "matches \<gamma> m a p = match_list \<gamma> (normalize_match m) a p"
  using match_list_normalize_match[simplified match_list_singleton] .

lemma wf_ruleset_normalize_match: "wf_ruleset \<gamma> p [(Rule m a)] \<Longrightarrow> wf_ruleset \<gamma> p (map (\<lambda>m. Rule m a) (normalize_match m))"
proof(induction m rule: normalize_match.induct)
  case 1 thus ?case by simp
  next
  case 2 thus ?case by simp
  next
  case 3 thus ?case
    apply(simp add: fixedaction_wf_ruleset )
    apply(unfold wf_ruleset_singleton)
    apply(simp add: matches_to_match_list_normalize)
    done
  next
  case 4 thus ?case 
    apply(simp add: wf_ruleset_append)
    apply(simp add: fixedaction_wf_ruleset)
    apply(unfold wf_ruleset_singleton)
    apply(safe) (*there is a simpler way but the simplifier takes for ever if we just apply it here, ...*)
           apply(simp_all add: matches_to_match_list_normalize)
         apply(simp_all add: match_list_append)
    done
  next
  case 5 thus ?case 
    apply(unfold wf_ruleset_singleton)
    apply(simp add: matches_to_match_list_normalize)
    done
  next
  case 6 thus ?case by(simp add: wf_ruleset_def)
  next
  case 7 thus ?case by(simp_all add: wf_ruleset_append)
  qed


lemma normalize_match_wf_ruleset: "wf_ruleset \<gamma> p (map (\<lambda>m. Rule m a) (normalize_match m)) \<Longrightarrow> wf_ruleset \<gamma> p [Rule m a]"
proof(induction m rule: normalize_match.induct)
  case 1 thus ?case by simp
  next
  case 2 thus ?case by simp
  next
  case 3 thus ?case
    apply(simp add: fixedaction_wf_ruleset )
    apply(unfold wf_ruleset_singleton)
    apply(simp add: matches_to_match_list_normalize)
    done
  next
  case 4 thus ?case 
    apply(simp add: wf_ruleset_append)
    apply(simp add: fixedaction_wf_ruleset)
    apply(unfold wf_ruleset_singleton)
    apply(safe)
         apply(simp_all add: matches_to_match_list_normalize)
         apply(simp_all add: match_list_append)
    done
  next
  case 5 thus ?case 
    apply(unfold wf_ruleset_singleton)
    apply(simp add: matches_to_match_list_normalize)
    done
  next
  case 6 thus ?case unfolding wf_ruleset_singleton using bunch_of_lemmata_about_matches(3) by metis
  next
  case 7 thus ?case by(simp_all add: wf_ruleset_append)
  qed




fun normalize_rules :: "'a rule list \<Rightarrow> 'a rule list" where
  "normalize_rules [] = []" |
  "normalize_rules ((Rule m a)#rs) = (map (\<lambda>m. Rule m a) (normalize_match m))@(normalize_rules rs)"

lemma normalize_rules_singleton: "normalize_rules [Rule m a] = map (\<lambda>m. Rule m a) (normalize_match m)" by simp

lemma normalize_rules_fst: "(normalize_rules (r # rs)) = (normalize_rules [r]) @ (normalize_rules rs)"
  by(cases r) (simp)


lemma good_ruleset_normalize_match: "good_ruleset [(Rule m a)] \<Longrightarrow> good_ruleset (map (\<lambda>m. Rule m a) (normalize_match m))"
by(simp add: good_ruleset_def)



lemma wf_ruleset_normalize_rules: "wf_ruleset \<gamma> p rs \<Longrightarrow> wf_ruleset \<gamma> p (normalize_rules rs)"
  proof(induction rs)
  case Nil thus ?case by simp
  next
  case(Cons r rs)
    from Cons have IH: "wf_ruleset \<gamma> p (normalize_rules rs)" by(auto dest: wf_rulesetD) 
    from Cons.prems have "wf_ruleset \<gamma> p [r]" by(auto dest: wf_rulesetD) 
    hence "wf_ruleset \<gamma> p (normalize_rules [r])" using wf_ruleset_normalize_match by(cases r) simp
    with IH wf_ruleset_append have "wf_ruleset \<gamma> p (normalize_rules [r] @ normalize_rules rs)" by fast
    thus ?case by(subst normalize_rules_fst)
  qed

lemma good_ruleset_normalize_rules: "good_ruleset rs \<Longrightarrow> good_ruleset (normalize_rules rs)"
  proof(induction rs)
  case Nil thus ?case by (simp add: good_ruleset_tail)
  next
  case(Cons r rs)
    from Cons have IH: "good_ruleset (normalize_rules rs)" using good_ruleset_tail by blast
    from Cons.prems have "good_ruleset [r]" using good_ruleset_fst by fast
    hence "good_ruleset (normalize_rules [r])" by(cases r) (simp add: good_ruleset_normalize_match)
    with IH good_ruleset_append have  "good_ruleset (normalize_rules [r] @ normalize_rules rs)" by blast
    thus ?case by(subst normalize_rules_fst)
  qed


lemma normalize_rules_correct: "wf_ruleset \<gamma> p rs \<Longrightarrow> approximating_bigstep_fun \<gamma> p (normalize_rules rs) s = approximating_bigstep_fun \<gamma> p rs s"
  proof(induction rs)
  case Nil thus ?case by simp
  next
  case (Cons r rs)
    thus ?case (is ?goal)
    proof(cases s)
    case Decision thus ?goal
      by(simp add: Decision_approximating_bigstep_fun)
    next
    case Undecided
    from Cons wf_rulesetD(2) have IH: "approximating_bigstep_fun \<gamma> p (normalize_rules rs) s = approximating_bigstep_fun \<gamma> p rs s" by fast
    from Cons.prems have "wf_ruleset \<gamma> p [r]" and "wf_ruleset \<gamma> p (normalize_rules [r])"
      by(auto dest: wf_rulesetD simp: wf_ruleset_normalize_rules)
    with IH Undecided have
      "approximating_bigstep_fun \<gamma> p (normalize_rules rs) (approximating_bigstep_fun \<gamma> p (normalize_rules [r]) Undecided) = approximating_bigstep_fun \<gamma> p (r # rs) Undecided"
      apply(case_tac r, rename_tac m a)
      apply(simp)
      apply(case_tac a)
             apply(simp_all add: normalize_match_correct Decision_approximating_bigstep_fun wf_ruleset_singleton)
      done
    hence "approximating_bigstep_fun \<gamma> p (normalize_rules [r] @ normalize_rules rs) s = approximating_bigstep_fun \<gamma> p (r # rs) s"
      using Undecided `wf_ruleset \<gamma> p [r]` `wf_ruleset \<gamma> p (normalize_rules [r])` 
      by(simp add: approximating_bigstep_fun_seq_wf)
    thus ?goal using normalize_rules_fst by metis
    qed
  qed


(*
value "normalize_rules
  [(Rule (MatchNot (MatchAnd (MatchNot (Match (Src (Ip4AddrNetmask (192, 168, 0, 0) 16)))) (MatchAnd (Match (Src (Ip4AddrNetmask (127, 0, 0, 0) 8))) (MatchAnd (Match (Prot ipt_protocol.ProtTCP)) (Match (Extra ''reject-with tcp-reset'')))))) Drop)]
 "
*)

fun normalized_match :: "'a match_expr \<Rightarrow> bool" where
  "normalized_match MatchAny = True" |
  "normalized_match (Match _ ) = True" |
  "normalized_match (MatchNot (Match _)) = True" |
  "normalized_match (MatchAnd m1 m2) = ((normalized_match m1) \<and> (normalized_match m2))" |
  "normalized_match _ = False"


text{*Essentially, @{term normalized_match} checks for a negation normal form: Only AND is at toplevel, negation only occurs in front of literals.
 Since @{typ "'a match_expr"} does not support OR, the result is in conjunction normal form.
 Applying @{const normalize_match}, the reuslt is a list. Essentially, this is the disjunctive normal form.*}


lemma normalized_match_normalize_match: "\<forall> m' \<in> set (normalize_match m). normalized_match m'"
  proof(induction m arbitrary: rule: normalize_match.induct)
  case 4 thus ?case by fastforce
  qed (simp_all)


(*Test*)
value "normalize_match (MatchNot (MatchAnd (Match ip_src) (Match tcp))) = [MatchNot (Match ip_src), MatchNot (Match tcp)]"


end