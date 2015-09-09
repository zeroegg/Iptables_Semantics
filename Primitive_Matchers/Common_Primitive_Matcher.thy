theory Common_Primitive_Matcher
imports "../Semantics_Ternary/Semantics_Ternary" Common_Primitive_Syntax "../Bitmagic/IPv4Addr" "../Semantics_Ternary/Unknown_Match_Tacs"
begin


subsection{*Primitive Matchers: IP Port Iface Matcher*}

fun common_matcher :: "(common_primitive, simple_packet) exact_match_tac" where
  "common_matcher (IIface i) p = bool_to_ternary (match_iface i (p_iiface p))" |
  "common_matcher (OIface i) p = bool_to_ternary (match_iface i (p_oiface p))" |

  "common_matcher (Src ip) p = bool_to_ternary (p_src p \<in> ipv4s_to_set ip)" |
  "common_matcher (Dst ip) p = bool_to_ternary (p_dst p \<in> ipv4s_to_set ip)" |

  "common_matcher (Prot proto) p = bool_to_ternary (match_proto proto (p_proto p))" |

  "common_matcher (Src_Ports ps) p = bool_to_ternary (p_sport p \<in> ports_to_set ps)" |
  "common_matcher (Dst_Ports ps) p = bool_to_ternary (p_dport p \<in> ports_to_set ps)" |

  "common_matcher (CT_State S) p = bool_to_ternary (match_ctstate S (p_tag_ctstate p))" |

  "common_matcher (Extra _) p = TernaryUnknown"



  text{*Warning: beware of the sloppy term `empty' portrange*} 
  text{*An `empty' port range means it can never match! Basically, @{term "MatchNot (Match (Src_Ports [(0,65535)]))"} is False*}
  lemma "\<not> matches (common_matcher, \<alpha>) (MatchNot (Match (Src_Ports [(0,65535)]))) a 
          \<lparr>p_iiface = ''eth0'', p_oiface = ''eth1'', p_src = ipv4addr_of_dotdecimal (192,168,2,45), p_dst= ipv4addr_of_dotdecimal (173,194,112,111),
                   p_proto=TCP, p_sport=2065, p_dport=80, p_tag_ctstate = CT_New\<rparr>"
  (*<*)by(simp add: matches_case_ternaryvalue_tuple split: ternaryvalue.split)(*>*)
  text{*An `empty' port range means it always matches! Basically, @{term "(MatchNot (Match (Src_Ports [])))"} is True.
        This corresponds to firewall behavior, but usually you cannot specify an empty portrange in firewalls, but omission of portrange means no-port-restrictions, 
        i.e. every port matches.*}
  lemma "matches (common_matcher, \<alpha>) (MatchNot (Match (Src_Ports []))) a 
          \<lparr>p_iiface = ''eth0'', p_oiface = ''eth1'', p_src = ipv4addr_of_dotdecimal (192,168,2,45), p_dst= ipv4addr_of_dotdecimal (173,194,112,111),
                   p_proto=TCP, p_sport=2065, p_dport=80, p_tag_ctstate = CT_New\<rparr>"
  (*<*)by(simp add: matches_case_ternaryvalue_tuple split: ternaryvalue.split)(*>*)
  text{*If not a corner case, portrange matching is straight forward.*}
  lemma "matches (common_matcher, \<alpha>) (Match (Src_Ports [(1024,4096), (9999, 65535)])) a 
          \<lparr>p_iiface = ''eth0'', p_oiface = ''eth1'', p_src = ipv4addr_of_dotdecimal (192,168,2,45), p_dst= ipv4addr_of_dotdecimal (173,194,112,111),
                   p_proto=TCP, p_sport=2065, p_dport=80, p_tag_ctstate = CT_New\<rparr>"
        "\<not> matches (common_matcher, \<alpha>) (Match (Src_Ports [(1024,4096), (9999, 65535)])) a 
          \<lparr>p_iiface = ''eth0'', p_oiface = ''eth1'', p_src = ipv4addr_of_dotdecimal (192,168,2,45), p_dst= ipv4addr_of_dotdecimal (173,194,112,111),
                   p_proto=TCP, p_sport=5000, p_dport=80, p_tag_ctstate = CT_New\<rparr>"
        "\<not>matches (common_matcher, \<alpha>) (MatchNot (Match (Src_Ports [(1024,4096), (9999, 65535)]))) a 
          \<lparr>p_iiface = ''eth0'', p_oiface = ''eth1'', p_src = ipv4addr_of_dotdecimal (192,168,2,45), p_dst= ipv4addr_of_dotdecimal (173,194,112,111),
                   p_proto=TCP, p_sport=2065, p_dport=80, p_tag_ctstate = CT_New\<rparr>"
  (*<*)by(simp_all add: matches_case_ternaryvalue_tuple split: ternaryvalue.split)(*>*)
  
  



text{*Lemmas when matching on @{term Src} or @{term Dst}*}
lemma common_matcher_SrcDst_defined:
  "common_matcher (Src m) p \<noteq> TernaryUnknown"
  "common_matcher (Dst m) p \<noteq> TernaryUnknown"
  "common_matcher (Src_Ports ps) p \<noteq> TernaryUnknown"
  "common_matcher (Dst_Ports ps) p \<noteq> TernaryUnknown"
  apply(case_tac [!] m)
  apply(simp_all add: bool_to_ternary_Unknown)
  done
lemma common_matcher_SrcDst_defined_simp:
  "common_matcher (Src x) p \<noteq> TernaryFalse \<longleftrightarrow> common_matcher (Src x) p = TernaryTrue"
  "common_matcher (Dst x) p \<noteq> TernaryFalse \<longleftrightarrow> common_matcher (Dst x) p = TernaryTrue"
apply (metis eval_ternary_Not.cases common_matcher_SrcDst_defined(1) ternaryvalue.distinct(1))
apply (metis eval_ternary_Not.cases common_matcher_SrcDst_defined(2) ternaryvalue.distinct(1))
done
lemma match_simplematcher_SrcDst:
  "matches (common_matcher, \<alpha>) (Match (Src X)) a p \<longleftrightarrow> p_src  p \<in> ipv4s_to_set X"
  "matches (common_matcher, \<alpha>) (Match (Dst X)) a p \<longleftrightarrow> p_dst  p \<in> ipv4s_to_set X"
   apply(simp_all add: matches_case_ternaryvalue_tuple split: ternaryvalue.split)
   apply (metis bool_to_ternary.elims bool_to_ternary_Unknown ternaryvalue.distinct(1))+
   done
lemma match_simplematcher_SrcDst_not:
  "matches (common_matcher, \<alpha>) (MatchNot (Match (Src X))) a p \<longleftrightarrow> p_src  p \<notin> ipv4s_to_set X"
  "matches (common_matcher, \<alpha>) (MatchNot (Match (Dst X))) a p \<longleftrightarrow> p_dst  p \<notin> ipv4s_to_set X"
   apply(simp_all add: matches_case_ternaryvalue_tuple split: ternaryvalue.split)
   apply(case_tac [!] X)
   apply(simp_all add: bool_to_ternary_simps)
   done
lemma common_matcher_SrcDst_Inter:
  "(\<forall>m\<in>set X. matches (common_matcher, \<alpha>) (Match (Src m)) a p) \<longleftrightarrow> p_src p \<in> (\<Inter>x\<in>set X. ipv4s_to_set x)"
  "(\<forall>m\<in>set X. matches (common_matcher, \<alpha>) (Match (Dst m)) a p) \<longleftrightarrow> p_dst p \<in> (\<Inter>x\<in>set X. ipv4s_to_set x)"
  by(simp_all add: matches_case_ternaryvalue_tuple bool_to_ternary_Unknown bool_to_ternary_simps split: ternaryvalue.split)
lemma match_simplematcher_Iface:
  "matches (common_matcher, \<alpha>) (Match (IIface X)) a p \<longleftrightarrow> match_iface X (p_iiface p)"
  "matches (common_matcher, \<alpha>) (Match (OIface X)) a p \<longleftrightarrow> match_iface X (p_oiface p)"
   by(simp_all add: matches_case_ternaryvalue_tuple bool_to_ternary_Unknown bool_to_ternary_simps split: ternaryvalue.split)
lemma match_simplematcher_Iface_not:
  "matches (common_matcher, \<alpha>) (MatchNot (Match (IIface X))) a p \<longleftrightarrow> \<not> match_iface X (p_iiface p)"
  "matches (common_matcher, \<alpha>) (MatchNot (Match (OIface X))) a p \<longleftrightarrow> \<not> match_iface X (p_oiface p)"
   by(simp_all add: matches_case_ternaryvalue_tuple bool_to_ternary_simps split: ternaryvalue.split)



text{* multiport list is a way to express  disjunction in one matchexpression in some firewalls*}
lemma multiports_disjuction:
        "(\<exists>rg\<in>set spts. matches (common_matcher, \<alpha>) (Match (Src_Ports [rg])) a p) \<longleftrightarrow>
        matches (common_matcher, \<alpha>) (Match (Src_Ports spts)) a p"
        "(\<exists>rg\<in>set dpts. matches (common_matcher, \<alpha>) (Match (Dst_Ports [rg])) a p) \<longleftrightarrow>
        matches (common_matcher, \<alpha>) (Match (Dst_Ports dpts)) a p"
  apply(simp_all add: bool_to_ternary_Unknown matches_case_ternaryvalue_tuple bunch_of_lemmata_about_matches bool_to_ternary_simps split: ternaryvalue.split ternaryvalue.split_asm)
  apply(simp_all add: ports_to_set)
  apply(safe) (*ugly proof*)
     apply force+
  done




text{*Since matching on the iface cannot be @{const TernaryUnknown}*, we can pull out negations.*}
lemma common_matcher_MatchNot_Iface:
      "matches (common_matcher, \<alpha>) (MatchNot (Match (IIface iface))) a p \<longleftrightarrow> \<not> match_iface iface (p_iiface p)"
      "matches (common_matcher, \<alpha>) (MatchNot (Match (OIface iface))) a p \<longleftrightarrow> \<not> match_iface iface (p_oiface p)"
using match_simplematcher_Iface_not by simp_all
(*TODO: duplication!*)
  (*by(simp_all add: matches_case_ternaryvalue_tuple bool_to_ternary_simps split: ternaryvalue.split)*)





(*TODO: basically a copy! *)
text{*Perform very basic optimization. Remove matches to primitives which are essentially @{const MatchAny}*}
fun optimize_primitive_univ :: "common_primitive match_expr \<Rightarrow> common_primitive match_expr" where
  "optimize_primitive_univ (Match (Src (Ip4AddrNetmask (0,0,0,0) 0))) = MatchAny" |
  "optimize_primitive_univ (Match (Dst (Ip4AddrNetmask (0,0,0,0) 0))) = MatchAny" |
  "optimize_primitive_univ (Match (IIface iface)) = (if iface = ifaceAny then MatchAny else (Match (IIface iface)))" |
  "optimize_primitive_univ (Match (OIface iface)) = (if iface = ifaceAny then MatchAny else (Match (OIface iface)))" |
  "optimize_primitive_univ (Match (Src_Ports [(s, e)])) = (if s = 0 \<and> e = 0xFFFF then MatchAny else (Match (Src_Ports [(s, e)])))" |
  "optimize_primitive_univ (Match (Dst_Ports [(s, e)])) = (if s = 0 \<and> e = 0xFFFF then MatchAny else (Match (Dst_Ports [(s, e)])))" |
  "optimize_primitive_univ (Match (Prot ProtoAny)) = MatchAny" |
  "optimize_primitive_univ (Match (CT_State ctstate)) = (if ctstate_is_UNIV ctstate then MatchAny else Match (CT_State ctstate))" |
  "optimize_primitive_univ (Match m) = Match m" |
  (*"optimize_primitive_univ (MatchNot (MatchNot m)) = (optimize_primitive_univ m)" | --"needed to preserve normalized condition"*)
  "optimize_primitive_univ (MatchNot m) = (MatchNot (optimize_primitive_univ m))" |
  (*"optimize_primitive_univ (MatchAnd (Match (Extra e1)) (Match (Extra e2))) = optimize_primitive_univ (Match (Extra (e1@'' ''@e2)))" |
    -- "can be done but normalization does not work afterwards"*)
  "optimize_primitive_univ (MatchAnd m1 m2) = MatchAnd (optimize_primitive_univ m1) (optimize_primitive_univ m2)" |
  "optimize_primitive_univ MatchAny = MatchAny"


lemma optimize_primitive_univ_correct_matchexpr: "matches (common_matcher, \<alpha>) m = matches (common_matcher, \<alpha>) (optimize_primitive_univ m)"
  proof(simp add: fun_eq_iff, clarify, rename_tac a p)
    fix a p
    have "(max_word::16 word) =  65535" by(simp add: max_word_def)
    hence port_range: "\<And>s e port. s = 0 \<and> e = 0xFFFF \<longrightarrow> (port::16 word) \<le> 0xFFFF" by simp
    have "ternary_ternary_eval (map_match_tac common_matcher p m) = ternary_ternary_eval (map_match_tac common_matcher p (optimize_primitive_univ m))"
      apply(induction m rule: optimize_primitive_univ.induct)
      apply(simp_all add: port_range match_ifaceAny ip_in_ipv4range_set_from_bitmask_UNIV ctstate_is_UNIV)
      done
    thus "matches (common_matcher, \<alpha>) m a p = matches (common_matcher, \<alpha>) (optimize_primitive_univ m) a p"
      by(rule matches_iff_apply_f)
    qed

corollary optimize_primitive_univ_correct: "approximating_bigstep_fun (common_matcher, \<alpha>) p (optimize_matches optimize_primitive_univ rs) s = 
                                            approximating_bigstep_fun (common_matcher, \<alpha>) p rs s"
using optimize_matches optimize_primitive_univ_correct_matchexpr by metis


lemma packet_independent_\<beta>_unknown_common_matcher: "packet_independent_\<beta>_unknown common_matcher"
  apply(simp add: packet_independent_\<beta>_unknown_def)
  apply(clarify)
  apply(rename_tac A p1 p2)
  apply(case_tac A)
  by(simp_all add: bool_to_ternary_Unknown)





text{*remove @{const Extra} (i.e. @{const TernaryUnknown}) match expressions*}
fun upper_closure_matchexpr :: "action \<Rightarrow> common_primitive match_expr \<Rightarrow> common_primitive match_expr" where
  "upper_closure_matchexpr _ MatchAny = MatchAny" |
  "upper_closure_matchexpr Accept (Match (Extra _)) = MatchAny" |
  "upper_closure_matchexpr Reject (Match (Extra _)) = MatchNot MatchAny" |
  "upper_closure_matchexpr Drop (Match (Extra _)) = MatchNot MatchAny" |
  "upper_closure_matchexpr _ (Match m) = Match m" |
  "upper_closure_matchexpr Accept (MatchNot (Match (Extra _))) = MatchAny" |
  "upper_closure_matchexpr Drop (MatchNot (Match (Extra _))) = MatchNot MatchAny" |
  "upper_closure_matchexpr Reject (MatchNot (Match (Extra _))) = MatchNot MatchAny" |
  "upper_closure_matchexpr a (MatchNot (MatchNot m)) = upper_closure_matchexpr a m" |
  "upper_closure_matchexpr a (MatchNot (MatchAnd m1 m2)) = 
    (let m1' = upper_closure_matchexpr a (MatchNot m1); m2' = upper_closure_matchexpr a (MatchNot m2) in
    (if m1' = MatchAny \<or> m2' = MatchAny
     then MatchAny
     else 
        if m1' = MatchNot MatchAny then m2' else
        if m2' = MatchNot MatchAny then m1'
     else
        MatchNot (MatchAnd (MatchNot m1') (MatchNot m2')))
       )" |
  "upper_closure_matchexpr _ (MatchNot m) = MatchNot m" | 
  "upper_closure_matchexpr a (MatchAnd m1 m2) = MatchAnd (upper_closure_matchexpr a m1) (upper_closure_matchexpr a m2)"

lemma upper_closure_matchexpr_generic: 
  "a = Accept \<or> a = Drop \<Longrightarrow> remove_unknowns_generic (common_matcher, in_doubt_allow) a m = upper_closure_matchexpr a m"
  by(induction a m rule: upper_closure_matchexpr.induct)
  (simp_all add: unknown_match_all_def unknown_not_match_any_def bool_to_ternary_Unknown)



fun lower_closure_matchexpr :: "action \<Rightarrow> common_primitive match_expr \<Rightarrow> common_primitive match_expr" where
  "lower_closure_matchexpr _ MatchAny = MatchAny" |
  "lower_closure_matchexpr Accept (Match (Extra _)) = MatchNot MatchAny" |
  "lower_closure_matchexpr Reject (Match (Extra _)) = MatchAny" |
  "lower_closure_matchexpr Drop (Match (Extra _)) = MatchAny" |
  "lower_closure_matchexpr _ (Match m) = Match m" |
  "lower_closure_matchexpr Accept (MatchNot (Match (Extra _))) = MatchNot MatchAny" |
  "lower_closure_matchexpr Drop (MatchNot (Match (Extra _))) = MatchAny" |
  "lower_closure_matchexpr Reject (MatchNot (Match (Extra _))) = MatchAny" |
  "lower_closure_matchexpr a (MatchNot (MatchNot m)) = lower_closure_matchexpr a m" |
  "lower_closure_matchexpr a (MatchNot (MatchAnd m1 m2)) = 
    (let m1' = lower_closure_matchexpr a (MatchNot m1); m2' = lower_closure_matchexpr a (MatchNot m2) in
    (if m1' = MatchAny \<or> m2' = MatchAny
     then MatchAny
     else 
        if m1' = MatchNot MatchAny then m2' else
        if m2' = MatchNot MatchAny then m1'
     else
        MatchNot (MatchAnd (MatchNot m1') (MatchNot m2')))
       )" |
  "lower_closure_matchexpr _ (MatchNot m) = MatchNot m" | 
  "lower_closure_matchexpr a (MatchAnd m1 m2) = MatchAnd (lower_closure_matchexpr a m1) (lower_closure_matchexpr a m2)"

lemma lower_closure_matchexpr_generic: 
  "a = Accept \<or> a = Drop \<Longrightarrow> remove_unknowns_generic (common_matcher, in_doubt_deny) a m = lower_closure_matchexpr a m"
  by(induction a m rule: lower_closure_matchexpr.induct)
  (simp_all add: unknown_match_all_def unknown_not_match_any_def bool_to_ternary_Unknown)

end
