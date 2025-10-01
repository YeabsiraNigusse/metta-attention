(= (test-superpose)
    (superpose
        (
            (AFRentCollectionAgent-run)
            (AFImportanceDiffusionAgent-Run (TypeSpace))
            (HebbianCreationAgent-Run (TypeSpace))
            (HebbianUpdatingAgent-Run (TypeSpace))
            ;(WARentCollectionAgent-Run)
            ;(WAImportanceDiffusionAgent-Run (TypeSpace))
            ;(forgettingAgent-Run (atomBin))
        )
    )
)
