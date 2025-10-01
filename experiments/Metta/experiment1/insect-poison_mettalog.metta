!(import! &self imports_mettalog)
!(import! &insect metta-attention:experiments:Metta/experiment1/data/insect-words)
!(import! &poison metta-attention:experiments:Metta/experiment1/data/poison-words)
!(import! &tempspace metta-attention:experiments:Metta/experiment1/data/links)
!(import! &self metta-attention:experiments:logger)


(= (spaceAdder) (get-atoms &tempspace))
!(spaceAdder)

; write the params to a file
!(updateAttentionParam MAX_AF_SIZE 10.0)
!(updateAttentionParam TARGET_STI 1000.0) 
!(updateAttentionParam TARGET_LTI 1000.0) 
!(updateAttentionParam STI_FUNDS_BUFFER 1000.0) 
!(updateAttentionParam LTI_FUNDS_BUFFER 1000.0) 
!(updateAttentionParam FUNDS_STI 2000.0) 
!(updateAttentionParam FUNDS_LTI 2000.0) 

!(updateAttentionParam MAX_SPREAD_PERCENTAGE 0.60)
!(updateAttentionParam AFRentFrequency 5.0)


!(start_log (attentionParam) experiments/Metta/experiment1)

(= (randomWord $space)
    (let* 
        (
            ($atomList (collapse (match $space ($type $atom) $atom)))
            ($randInt (random-int 0 (size-atom $atomList)))
        )
        (index-atom $atomList $randInt)
    )
)

(= (insectPoisonExp $maxim $insect $poison)
    (if (<= $maxim 0)
        finished
        (let* 
            (
                ($randAtom (if (> $maxim 3)
                                (randomWord $poison)
                                (randomWord $insect)
                            )
                )
                ($newMaxim (- $maxim 1))
            )
            (superpose (
                (insectPoisonExp $newMaxim $insect $poison) 
                (collapse (test-superpose))
                (println! $randAtom)
                (stimulate $randAtom 30)
            ))
        )
    )
)     



!(insectPoisonExp 6 &insect &poison)
