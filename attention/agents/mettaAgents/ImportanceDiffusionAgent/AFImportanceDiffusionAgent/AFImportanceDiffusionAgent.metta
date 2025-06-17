!(bind! maxSpreadPercentage 0.4)
!(bind! &AFtradeingSpace (new-space))

;; This function will return the diffusion source vector (atoms that can be diffused) from AF
;; Parameters $space: The space that will be used to find the diffusion source vector
;; Return : The diffusion source vector

(: diffusionSourceVector (-> Grounded Atom))
(= (diffusionSourceVector $space)
    (let*
        (
            ($atoms (collapse (let $temp (match $space $x $x)
                (if (== (get-metatype $temp) Expression)
                    (if (== (car-atom $temp) HEBBIAN_LINK)
                        (empty)
                        $temp
                    )
                    $temp
                    
                ))))
        )
        $atoms
    )
)


;; This function will calculate the diffusion amount
;; Parameters $atom: The atom that will be used to calculate the diffusion amount
;; Return : The diffusion amount

(: calculateDiffusionAmount (-> Atom Number))
(= (calculateDiffusionAmount $atom)
    (* (getSTI $atom) maxSpreadPercentage)
)

;;This function will retrieve the diffusion source vector from AF and then call the diffuseAtom function to diffuse the atoms
;; Parameters $space: The space that will be used to find the diffusion source vector
;;            $space2: The space that will be used to find incomingSets
;; Return : The diffusion get called

(: spreadImportance (-> Grounded Grounded Empty))
(= (spreadImportance $space $space2)
    (let $diffusionSourceVector 
        (diffusionSourceVector $space)
        (diffuseW $diffusionSourceVector $space2)
    )
) 

;; A function to make a call to diffuseAtom which return expression atom with structure
;; (atomGivingSti atomRecivingSTI StiGiven) for all atoms in $diffusionSourceVector
;; and passes this output to addToAFrtrading function to be parse and saved
;; Parameters:
;;      $diffusionSourceVector: An expression atom made of atom that can diffuse
;;      $space2: The space that will be used to find incomingsSets (TypeSpace)
;; Return: unit Atom
(: diffuseW (-> Expression Grounded Atom))
(= (diffuseW $diffusionSourceVector $space2)
    (if (== $diffusionSourceVector ())
        ()
        (let*
            (
                ($head (car-atom $diffusionSourceVector))
                ($tail (cdr-atom $diffusionSourceVector))
                ($diffuse (diffuseAtom $head $space2 AF))
                ($diffuseS (collapse 
                    (let ($atom $atomToReceive $stiGiven)
                        (superpose $diffuse)
                        (addToAFtrading  $atom $atomToReceive $stiGiven)
                    )
                 ))
            )
            (diffuseW $tail $space2)
        )
    )
)

;; This function is responsible for adding information to the AFtradeingSpace
;; it adds two nodes every call one for the atom reciving and one for the atom
;; diffusing. with the atom diffusing have a negative number value associated
;; Parameters
;;      $atom: Symbol defining the atom the is diffusing STI
;;      $atomToReceive: Symbol defining the atom to revice STI
;;      $stiGiven: Number the amount of sti to be exchanged
;; Return: Unit Atom 
(: addToAFtrading (-> Symbol Symbol Number Atom))
(= (addToAFtrading $atom $atomToReceive $stiGiven)
    (let*
        (
            ($negatesti (* -1 $stiGiven))
            (() (add-atom &AFtradeingSpace ($atom $negatesti))) 
        )
        (add-atom &AFtradeingSpace ($atomToReceive $stiGiven))
    )
)

;; Responsible for making final calculations from the AFtradeingSpace before 
;; calling setSTI function. 
;; Parametes: None
;; Returns: Unit Atom
(: collapseValues (-> Atom))
(= (collapseValues)
    (let*
        (
            ($vals (unique (match &AFtradeingSpace ($x $_) $x)))
            ($trades (collapse (match &AFtradeingSpace ($vals $x) $x)))
            ($fold (foldl-atom $trades 0 $acc $x (+ $acc $x)))
            ($oldSti (getSTI $vals))
            ($newSti (+ $oldSti $fold))
        )
        (setSTI $vals $newSti)
    )
)

;; This function is responsibel for clearing the AFtradeingSpace so that next 
;; Iteration can start with an empty space and be isolated
;; Parameters: None
;; Return: Unit Atom
(: removeAtomsFromAFtradding (-> Atom))
(= (removeAtomsFromAFtradding)
    (let $vals 
        (get-atoms &AFtradeingSpace)
        (remove-atom &AFtradeingSpace $vals)
    )
)

;; This function is the entry point to the AFImportance Diffusion Agent
;; Parameters $space: The space that will be used to find the diffusion source vector
;;            $space2: The space that will be used to find incomingSets
;; Return : The spreadImportance function is called

(AFImportanceDiffusionAgent-Run (-> Grounded Grounded Atom))
(= (AFImportanceDiffusionAgent-Run $space $space2)
    (let*
        (($vals (spreadImportance $space $space2)))
        (
            (collapseValues)
            (removeAtomsFromAFtradding)
        )
    )
)
