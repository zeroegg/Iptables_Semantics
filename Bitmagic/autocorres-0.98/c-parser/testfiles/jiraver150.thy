theory jiraver150
imports "../CTranslation"
begin

declare [[use_anonymous_local_variables=true]]
  install_C_file "jiraver150.c"

  context jiraver150
  begin

  ML {* @{const_name "unsigned_char'local0_'"} *}

  thm f_body_def
  thm f2_body_def
  thm g_body_def
  thm h_body_def

  lemma "\<Gamma> \<turnstile> \<lbrace> True \<rbrace> \<acute>unsigned'local0 :== CALL f(1) \<lbrace> \<acute>unsigned'local0 = 2 \<rbrace>"
  apply vcg
  apply (simp add: scast_id)
  done

  end

end
