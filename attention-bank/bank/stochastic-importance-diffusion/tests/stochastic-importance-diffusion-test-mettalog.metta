!(register-module! ../../../../../metta-attention)
!(import! &self metta-attention:attention-bank:utilities/helper-functions)
!(import! &self metta-attention:attention:AttentionParam)

!(import! &self metta-attention:attention-bank:bank/importance-index/importance-index)

!(import! &self metta-attention:attention-bank:attention-value/getter-and-setter)
!(import! &self metta-attention:attention-bank:attention-value/get-min-max)

!(import! &self metta-attention:attention-bank:bank/stochastic-importance-diffusion/stochastic-importance-diffusion)


;This sets the STI of a to 1 which will give bin index of 1
!(setAv a (1.0 1.0 1.0))


! (getSti a)
! (calcElapsedTime (getSti a))


! (updateBin a)
! (match &atomBinInfo (1 $a) $a)

! (updateBin a)
! (match &atomBinInfo (1 $b) $b)

! (updateBin a)
! (match &atomBinInfo (1 $c) $c)


! (updateBin a)
! (match &atomBinInfo (1 $d) $d)


! (updateBin a)
! (match &atomBinInfo (1 $e) $e)

! (updateBin a)
! (match &atomBinInfo (1 $f) $f)

! (importanceBin (getSti a))
!(let $a 
    (importanceBin (getSti a))
    (calcElapsedTime $a)
)

!(match (AtomBinInfo) (1 ((count $cnt_val) (index $idx_val) (_size $size_val) (update_rate $update_rate_val) (last_update $last_update_val))) 
    ($last_update_val)) 
!(assertEqual (> (diffusedValue a 0.5) 0.5) True) 
!(assertEqual (diffusedValue a 1) 0) ;after on round the sti value 1 will have decreased by the decay rate=1 therefore, output becomes 0
!(elapsedTime a)



