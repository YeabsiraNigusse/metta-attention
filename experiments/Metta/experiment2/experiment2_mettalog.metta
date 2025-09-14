; ; ============================================================================
; ; EXPERIMENT2 METTALOG - OPTIMIZED VERSION
; ; ============================================================================
; ; Economic Attention Networks (ECAN) experiment demonstrating attention
; ; allocation dynamics with insect-to-poison topic shifting
; ;
; ; This experiment processes sentences that transition from insect-related
; ; topics to poison-related topics, using ECAN framework for attention
; ; allocation and diffusion between concepts.
; ; ============================================================================

; ; Import all required dependencies from centralized import file
 !(import! &self imports_mettalog)

; ; ============================================================================
; ; EXPERIMENT CONFIGURATION
; ; ============================================================================
!(import! &tempspace metta-attention:experiments:Metta/experiment2/data/sent-kb)
!(import! &insect metta-attention:experiments:Metta/experiment2/data/insect-sent)
!(import! &poison metta-attention:experiments:Metta/experiment2/data/poison-sent)
!(import! &self metta-attention:experiments:logger)

; ============================================================================
; MEMORY-OPTIMIZED ATTENTION PARAMETERS
; ============================================================================
; These parameters are specifically tuned to prevent memory leaks and CPU overload
; while maintaining proper attention dynamics

; ULTRA-AGGRESSIVE MEMORY OPTIMIZATION FOR METTALOG
; These parameters are specifically tuned to prevent exponential memory growth
; that occurs when processing multiple sentences sequentially

; Minimal fund management - drastically reduced for Mettalog compatibility
!(updateAttentionParam STI_FUNDS_BUFFER 10000)
!(updateAttentionParam LTI_FUNDS_BUFFER 10000)
!(updateAttentionParam TARGET_STI 10000)
!(updateAttentionParam TARGET_LTI 10000)
!(updateAttentionParam FUNDS_STI 15000) 
!(updateAttentionParam FUNDS_LTI 15000) 

; Tight attention focus - prevent memory explosion
!(updateAttentionParam MAX_AF_SIZE 10)
!(updateAttentionParam MAX_SPREAD_PERCENTAGE 0.60)

; Aggressive cleanup - maximum frequency
!(updateAttentionParam AFRentFrequency 5.0)
(updateAttentionParam HEBBIAN_MAX_ALLOCATION_PERCENTAGE 0.51)

(= (spaceAdder) (get-atoms &tempspace))
!(spaceAdder)

; write the params to a file
!(start_log (attentionParam) experiments/Metta/experiment2)

(= (insectPoisonReadExp $space $type $expr)
    (
        (if (and (== $type poisonSent) (== $expr ()))
            finished
            (let* 
                (
                    ($now (car-atom $expr))
                    ($rest (cdr-atom $expr))
                    
                )
                (superpose (
                    (if (== $rest ())
                        (if (== $type poisonSent)
                             (insectPoisonReadExp &insect insectSent (match &insect (insectSent $x) $x))
                             finished
                        )
                        (insectPoisonReadExp $space $type $rest)
                    )
                    (collapse (test-superpose))
                    (println! $now)
                    (stimulate $now 500)
                ))
            )
        )     
    )
)

!(insectPoisonReadExp &poison poisonSent (match &poison (poisonSent $x) $x))
