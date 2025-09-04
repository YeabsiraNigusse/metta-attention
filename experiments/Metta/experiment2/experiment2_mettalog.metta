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
!(updateAttentionParam STI_FUNDS_BUFFER 100)
!(updateAttentionParam LTI_FUNDS_BUFFER 100)
!(updateAttentionParam TARGET_STI 50)
!(updateAttentionParam TARGET_LTI 50)

; Tight attention focus - prevent memory explosion
!(updateAttentionParam MIN_AF_SIZE 1)
!(updateAttentionParam MAX_AF_SIZE 3)
!(updateAttentionParam AFB_DECAY 0.5)
!(updateAttentionParam AFB_BOTTOM 1.0)

; Strict link control - critical for preventing exponential growth
!(updateAttentionParam MAX_LINK_NUM 20.0)
!(updateAttentionParam MAX_SPREAD_PERCENTAGE 0.01)
!(updateAttentionParam DIFFUSION_TOURNAMENT_SIZE 2.0)

; Aggressive cleanup - maximum frequency
!(updateAttentionParam AFRentFrequency 0.5)
!(updateAttentionParam DEFAULT_K 20)

; Additional memory control parameters
!(updateAttentionParam FORGET_THRESHOLD 0.1)
!(updateAttentionParam HEBBIAN_MAX_ALLOCATION_PERCENTAGE 0.01)
(= (spaceAdder) (get-atoms &tempspace))
!(spaceAdder)

; write the params to a file
!(start_log (attentionParam) eexperimentss)

(= (insectPoisonReadExp $space $type $expr)
    (
        (if (and (== $type poisonSent) (== $expr ()))
            finished
            (let* 
                (
                    ($now (car-atom $expr))
                    ($rest (cdr-atom $expr))
                    
                )
                (
                    ; Ultra-low stimulation for Mettalog memory management
                    (stimulate $now 25)
                    (println! $now)
                    (collapse (test-superpose))
                    (if (== $rest ())
                            (if (== $type insectSent)
                                (insectPoisonReadExp &poison poisonSent (match &poison (poisonSent $x) $x))
                                finished
                    )
                 
                 (insectPoisonReadExp $space $type $rest)
             )
                    
                )
            )
        )     
    )
)

!(insectPoisonReadExp &insect insectSent (match &insect (insectSent $x) $x))
!(getAtomList)
!(get-atoms (TypeSpace))
